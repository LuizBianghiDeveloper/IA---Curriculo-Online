package com.curriculo.controller;

import com.curriculo.dto.CurriculoAnalysisDTO;
import com.curriculo.dto.LinkedInAnalysisRequestDTO;
import com.curriculo.dto.LinkedInProfileDataDTO;
import com.curriculo.dto.VagaDescriptionDTO;
import com.curriculo.service.AiService;
import com.curriculo.service.LinkedInService;
import com.curriculo.service.TextExtractorService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class AnalysisController {
    
    // TODO: Adicionar validação de token quando necessário
    // Por enquanto, endpoints públicos para facilitar testes

    private final TextExtractorService textExtractorService;
    private final AiService aiService;
    private final LinkedInService linkedInService;
    private final ObjectMapper objectMapper;

    public AnalysisController(TextExtractorService textExtractorService, 
                             AiService aiService,
                             LinkedInService linkedInService,
                             ObjectMapper objectMapper) {
        this.textExtractorService = textExtractorService;
        this.aiService = aiService;
        this.linkedInService = linkedInService;
        this.objectMapper = objectMapper;
    }

    @PostMapping("/analyze")
    public ResponseEntity<CurriculoAnalysisDTO> analyzeCurriculo(
            @RequestParam("curriculo") MultipartFile curriculoFile,
            @RequestParam("vaga") String vagaJson) {
        
        try {
            // Validação do arquivo
            if (curriculoFile.isEmpty()) {
                return ResponseEntity.badRequest().build();
            }

            // Parse da descrição da vaga
            VagaDescriptionDTO vagaDescription = objectMapper.readValue(vagaJson, VagaDescriptionDTO.class);

            // Extrai texto do currículo
            String curriculoText = textExtractorService.extractText(curriculoFile);

            if (curriculoText == null || curriculoText.trim().isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(createErrorResponse("Não foi possível extrair texto do currículo"));
            }

            // Analisa com IA
            CurriculoAnalysisDTO analysis = aiService.analyzeCurriculo(curriculoText, vagaDescription);

            return ResponseEntity.ok(analysis);

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(createErrorResponse(e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Erro de configuração: " + e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Erro ao processar análise: " + e.getMessage()));
        }
    }

    @PostMapping("/analyze/linkedin")
    public ResponseEntity<CurriculoAnalysisDTO> analyzeLinkedInProfile(
            @RequestBody LinkedInAnalysisRequestDTO request) {
        
        try {
            // Validação
            if (request.getVaga() == null) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(createErrorResponse("Descrição da vaga é obrigatória"));
            }
            
            String perfilText = null;
            
            // Se dados do perfil foram fornecidos diretamente
            if (request.getPerfilData() != null) {
                perfilText = linkedInService.convertProfileToText(request.getPerfilData());
            } 
            // Se URL foi fornecida
            else if (request.getLinkedinUrl() != null && !request.getLinkedinUrl().trim().isEmpty()) {
                // Valida URL
                if (!linkedInService.isValidLinkedInUrl(request.getLinkedinUrl())) {
                    return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                            .body(createErrorResponse("URL do LinkedIn inválida. Forneça uma URL válida ou os dados do perfil diretamente."));
                }
                
                // Extrai ID do perfil (para referência futura)
                String profileId = linkedInService.extractProfileIdFromUrl(request.getLinkedinUrl());
                
                // Nota: Para extração automática completa, seria necessário:
                // 1. Implementar OAuth 2.0 com LinkedIn
                // 2. Usar LinkedIn API para buscar dados do perfil
                // 3. Ou usar biblioteca de scraping (não recomendado)
                
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(createErrorResponse(
                            "Extração automática de perfil via URL ainda não está implementada. " +
                            "Por favor, forneça os dados do perfil diretamente no campo 'perfilData'. " +
                            "URL recebida: " + request.getLinkedinUrl()
                        ));
            } 
            else {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(createErrorResponse("Forneça uma URL do LinkedIn ou os dados do perfil (perfilData)"));
            }
            
            if (perfilText == null || perfilText.trim().isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(createErrorResponse("Não foi possível processar os dados do perfil"));
            }
            
            // Analisa com IA
            CurriculoAnalysisDTO analysis = aiService.analyzeCurriculo(perfilText, request.getVaga());
            
            return ResponseEntity.ok(analysis);
            
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(createErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Erro ao processar análise do LinkedIn: " + e.getMessage()));
        }
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Backend está online!");
    }

    private CurriculoAnalysisDTO createErrorResponse(String message) {
        CurriculoAnalysisDTO dto = new CurriculoAnalysisDTO();
        dto.setCompatibilityScore(0.0);
        dto.setSummary("Erro: " + message);
        dto.setStrengths(java.util.Collections.emptyList());
        dto.setWeaknesses(java.util.Collections.emptyList());
        dto.setRecommendations(java.util.Collections.emptyList());
        dto.setIsSuitable(false);
        return dto;
    }
}

