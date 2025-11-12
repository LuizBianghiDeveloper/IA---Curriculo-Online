package com.curriculo.service;

import com.curriculo.dto.CurriculoAnalysisDTO;
import com.curriculo.dto.VagaDescriptionDTO;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.ArrayList;
import java.util.List;

@Service
public class AiService {

    private final WebClient webClient;
    private final ObjectMapper objectMapper;

    @Value("${ai.provider:gemini}")
    private String aiProvider;

    @Value("${ai.gemini.api.key:}")
    private String geminiApiKey;

    @Value("${ai.openai.api.key:}")
    private String openAiApiKey;

    public AiService(WebClient.Builder webClientBuilder, ObjectMapper objectMapper) {
        this.webClient = webClientBuilder.build();
        this.objectMapper = objectMapper;
    }

    public CurriculoAnalysisDTO analyzeCurriculo(String curriculoText, VagaDescriptionDTO vagaDescription) {
        String provider = aiProvider != null ? aiProvider.toLowerCase() : "gemini";
        if ("gemini".equals(provider)) {
            return analyzeWithGemini(curriculoText, vagaDescription);
        } else if ("openai".equals(provider)) {
            return analyzeWithOpenAI(curriculoText, vagaDescription);
        } else {
            throw new IllegalArgumentException("Provedor de IA não suportado: " + provider);
        }
    }

    private CurriculoAnalysisDTO analyzeWithGemini(String curriculoText, VagaDescriptionDTO vagaDescription) {
        // Verifica se a chave está vazia ou nula
        if (geminiApiKey == null || geminiApiKey.trim().isEmpty()) {
            throw new IllegalStateException("Chave da API Gemini não configurada. Configure 'ai.gemini.api.key' no application.properties");
        }

        try {
            String prompt = buildPrompt(curriculoText, vagaDescription);

            // Construir o JSON corretamente usando ObjectMapper
            java.util.Map<String, Object> requestMap = new java.util.HashMap<>();
            java.util.Map<String, Object> content = new java.util.HashMap<>();
            java.util.Map<String, Object> part = new java.util.HashMap<>();
            part.put("text", prompt);
            java.util.List<java.util.Map<String, Object>> parts = new java.util.ArrayList<>();
            parts.add(part);
            content.put("parts", parts);
            java.util.List<java.util.Map<String, Object>> contents = new java.util.ArrayList<>();
            contents.add(content);
            requestMap.put("contents", contents);

            String requestBody = objectMapper.writeValueAsString(requestMap);

            // Modelos disponíveis na API (verificados via ListModels)
            // Ordem: versão estável primeiro, depois previews, depois alternativas
            String[] models = {
                "gemini-2.5-flash",                    // Versão estável (recomendado)
                "gemini-2.0-flash",                    // Versão 2.0 estável
                "gemini-2.5-flash-preview-05-20",      // Preview mais recente
                "gemini-2.5-pro",                       // Pro estável
                "gemini-2.5-pro-preview-03-25",        // Pro preview
                "gemini-2.0-flash-exp"                 // Experimental
            };
            
            String response = null;
            Exception lastException = null;
            
            for (String model : models) {
                try {
                    // Método 1: Query parameter (mais comum)
                    String url1 = String.format(
                        "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s",
                        model, geminiApiKey.trim()
                    );
                    
                    try {
                        response = webClient.post()
                                .uri(url1)
                                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                                .body(BodyInserters.fromValue(requestBody))
                                .retrieve()
                                .bodyToMono(String.class)
                                .block();
                        
                        // Se chegou aqui, funcionou!
                        break;
                    } catch (Exception e1) {
                        // Se for 404 ou 503, tenta com header Authorization
                        String errorMsg = e1.getMessage() != null ? e1.getMessage() : "";
                        if (errorMsg.contains("404") || errorMsg.contains("503")) {
                            try {
                                String url2 = String.format(
                                    "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent",
                                    model
                                );
                                
                                response = webClient.post()
                                        .uri(url2)
                                        .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                                        .header("x-goog-api-key", geminiApiKey.trim())
                                        .body(BodyInserters.fromValue(requestBody))
                                        .retrieve()
                                        .bodyToMono(String.class)
                                        .block();
                                
                                // Se chegou aqui, funcionou!
                                break;
                            } catch (Exception e2) {
                                // Se também falhar, vai tentar próximo modelo
                                lastException = e2;
                                continue;
                            }
                        }
                        throw e1;
                    }
                } catch (Exception e) {
                    lastException = e;
                    // Se for 404 ou 503 (servidor sobrecarregado), tenta próximo modelo
                    String errorMsg = e.getMessage() != null ? e.getMessage() : "";
                    if (errorMsg.contains("404") || errorMsg.contains("503")) {
                        continue;
                    }
                    // Se for outro erro, propaga
                    throw new RuntimeException("Erro ao analisar com Gemini (modelo " + model + "): " + e.getMessage(), e);
                }
            }
            
            if (response == null) {
                StringBuilder modelsStr = new StringBuilder();
                for (int i = 0; i < models.length; i++) {
                    if (i > 0) modelsStr.append(", ");
                    modelsStr.append(models[i]);
                }
                throw new RuntimeException("Erro ao analisar com Gemini. Tentados modelos: " + 
                    modelsStr.toString() + ". Último erro: " + 
                    (lastException != null ? lastException.getMessage() : "Desconhecido"));
            }

            return parseAiResponse(response, vagaDescription);
        } catch (Exception e) {
            throw new RuntimeException("Erro ao analisar com Gemini: " + e.getMessage(), e);
        }
    }

    private CurriculoAnalysisDTO analyzeWithOpenAI(String curriculoText, VagaDescriptionDTO vagaDescription) {
        if (openAiApiKey == null || openAiApiKey.trim().isEmpty()) {
            throw new IllegalStateException("Chave da API OpenAI não configurada. Configure 'ai.openai.api.key' no application.properties");
        }

        try {
            String prompt = buildPrompt(curriculoText, vagaDescription);

            String requestBody = String.format(
                "{\"model\":\"gpt-4\",\"messages\":[{\"role\":\"system\",\"content\":\"Você é um especialista em RH que analisa currículos e os compara com descrições de vagas.\"},{\"role\":\"user\",\"content\":\"%s\"}],\"temperature\":0.7}",
                prompt.replace("\"", "\\\"").replace("\n", "\\n")
            );

            String response = webClient.post()
                    .uri("https://api.openai.com/v1/chat/completions")
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + openAiApiKey)
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .body(BodyInserters.fromValue(requestBody))
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();

            return parseOpenAiResponse(response, vagaDescription);
        } catch (Exception e) {
            throw new RuntimeException("Erro ao analisar com OpenAI: " + e.getMessage(), e);
        }
    }

    private String buildPrompt(String curriculoText, VagaDescriptionDTO vagaDescription) {
        return String.format(
            "Analise o seguinte currículo e compare com a descrição da vaga fornecida.\n\n" +
            "CURRÍCULO:\n%s\n\n" +
            "DESCRIÇÃO DA VAGA:\n" +
            "Título: %s\n" +
            "Empresa: %s\n" +
            "Descrição: %s\n" +
            "Requisitos: %s\n\n" +
            "Por favor, forneça uma análise detalhada no seguinte formato JSON:\n" +
            "{\n" +
            "  \"compatibilityScore\": <número de 0 a 100>,\n" +
            "  \"summary\": \"<resumo da análise em 2-3 parágrafos>\",\n" +
            "  \"strengths\": [\"<ponto forte 1>\", \"<ponto forte 2>\", ...],\n" +
            "  \"weaknesses\": [\"<ponto fraco 1>\", \"<ponto fraco 2>\", ...],\n" +
            "  \"recommendations\": [\"<recomendação 1>\", \"<recomendação 2>\", ...],\n" +
            "  \"isSuitable\": <true ou false>\n" +
            "}\n\n" +
            "IMPORTANTE: Retorne APENAS o JSON, sem texto adicional antes ou depois.",
            curriculoText,
            vagaDescription.getTitulo(),
            vagaDescription.getEmpresa(),
            vagaDescription.getDescricao(),
            String.join(", ", vagaDescription.getRequisitos())
        );
    }

    private CurriculoAnalysisDTO parseAiResponse(String response, VagaDescriptionDTO vagaDescription) {
        try {
            JsonNode jsonNode = objectMapper.readTree(response);
            String content = "";

            if (jsonNode.has("candidates") && jsonNode.get("candidates").isArray() && jsonNode.get("candidates").size() > 0) {
                // Resposta Gemini
                content = jsonNode.get("candidates").get(0)
                        .get("content").get("parts").get(0)
                        .get("text").asText();
            } else if (jsonNode.has("choices") && jsonNode.get("choices").isArray() && jsonNode.get("choices").size() > 0) {
                // Resposta OpenAI
                content = jsonNode.get("choices").get(0)
                        .get("message").get("content").asText();
            }

            // Extrai JSON da resposta
            String jsonString = extractJsonFromResponse(content);
            JsonNode analysisJson = objectMapper.readTree(jsonString);

            return buildAnalysisDTO(analysisJson);
        } catch (Exception e) {
            // Se falhar no parse, retorna resposta padrão
            return createDefaultResponse(response);
        }
    }

    private CurriculoAnalysisDTO parseOpenAiResponse(String response, VagaDescriptionDTO vagaDescription) {
        try {
            JsonNode jsonNode = objectMapper.readTree(response);
            String content = jsonNode.get("choices").get(0)
                    .get("message").get("content").asText();

            String jsonString = extractJsonFromResponse(content);
            JsonNode analysisJson = objectMapper.readTree(jsonString);

            return buildAnalysisDTO(analysisJson);
        } catch (Exception e) {
            return createDefaultResponse(response);
        }
    }

    private String extractJsonFromResponse(String response) {
        // Remove markdown code blocks se existirem
        String jsonString = response;
        if (jsonString.contains("```json")) {
            jsonString = jsonString.split("```json")[1].split("```")[0].trim();
        } else if (jsonString.contains("```")) {
            jsonString = jsonString.split("```")[1].split("```")[0].trim();
        }

        // Tenta encontrar o JSON no texto
        int jsonStart = jsonString.indexOf("{");
        int jsonEnd = jsonString.lastIndexOf("}") + 1;

        if (jsonStart != -1 && jsonEnd > jsonStart) {
            jsonString = jsonString.substring(jsonStart, jsonEnd);
        }

        return jsonString;
    }

    private CurriculoAnalysisDTO buildAnalysisDTO(JsonNode json) {
        CurriculoAnalysisDTO dto = new CurriculoAnalysisDTO();
        dto.setCompatibilityScore(json.has("compatibilityScore") ? json.get("compatibilityScore").asDouble() : 50.0);
        dto.setSummary(json.has("summary") ? json.get("summary").asText() : "");
        dto.setIsSuitable(json.has("isSuitable") ? json.get("isSuitable").asBoolean() : false);

        List<String> strengths = new ArrayList<>();
        if (json.has("strengths") && json.get("strengths").isArray()) {
            json.get("strengths").forEach(node -> strengths.add(node.asText()));
        }
        dto.setStrengths(strengths);

        List<String> weaknesses = new ArrayList<>();
        if (json.has("weaknesses") && json.get("weaknesses").isArray()) {
            json.get("weaknesses").forEach(node -> weaknesses.add(node.asText()));
        }
        dto.setWeaknesses(weaknesses);

        List<String> recommendations = new ArrayList<>();
        if (json.has("recommendations") && json.get("recommendations").isArray()) {
            json.get("recommendations").forEach(node -> recommendations.add(node.asText()));
        }
        dto.setRecommendations(recommendations);

        return dto;
    }

    private CurriculoAnalysisDTO createDefaultResponse(String response) {
        CurriculoAnalysisDTO dto = new CurriculoAnalysisDTO();
        dto.setCompatibilityScore(50.0);
        dto.setSummary(response);
        dto.setStrengths(new ArrayList<>());
        dto.setWeaknesses(new ArrayList<>());
        dto.setRecommendations(new ArrayList<>());
        dto.setIsSuitable(false);
        return dto;
    }
}

