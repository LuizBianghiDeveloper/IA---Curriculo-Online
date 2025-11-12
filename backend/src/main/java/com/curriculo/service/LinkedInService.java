package com.curriculo.service;

import com.curriculo.dto.LinkedInProfileDataDTO;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;

import java.util.stream.Collectors;

@Service
public class LinkedInService {
    
    private final ObjectMapper objectMapper;
    
    public LinkedInService(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }
    
    /**
     * Converte dados do perfil LinkedIn em texto formatado para análise
     */
    public String convertProfileToText(LinkedInProfileDataDTO perfil) {
        if (perfil == null) {
            return "";
        }
        
        StringBuilder texto = new StringBuilder();
        
        // Informações básicas
        if (perfil.getNome() != null) {
            texto.append("Nome: ").append(perfil.getNome()).append("\n\n");
        }
        
        if (perfil.getTitulo() != null) {
            texto.append("Título Profissional: ").append(perfil.getTitulo()).append("\n\n");
        }
        
        if (perfil.getLocalizacao() != null) {
            texto.append("Localização: ").append(perfil.getLocalizacao()).append("\n\n");
        }
        
        if (perfil.getResumo() != null) {
            texto.append("Resumo Profissional:\n").append(perfil.getResumo()).append("\n\n");
        }
        
        // Experiência profissional
        if (perfil.getExperiencia() != null && !perfil.getExperiencia().isEmpty()) {
            texto.append("EXPERIÊNCIA PROFISSIONAL:\n");
            for (int i = 0; i < 50; i++) texto.append("=");
            texto.append("\n");
            for (LinkedInProfileDataDTO.ExperienciaDTO exp : perfil.getExperiencia()) {
                texto.append("\nCargo: ").append(exp.getCargo() != null ? exp.getCargo() : "N/A");
                texto.append("\nEmpresa: ").append(exp.getEmpresa() != null ? exp.getEmpresa() : "N/A");
                if (exp.getPeriodo() != null) {
                    texto.append("\nPeríodo: ").append(exp.getPeriodo());
                }
                if (exp.getDescricao() != null && !exp.getDescricao().trim().isEmpty()) {
                    texto.append("\nDescrição: ").append(exp.getDescricao());
                }
                texto.append("\n");
                for (int i = 0; i < 50; i++) texto.append("-");
                texto.append("\n");
            }
            texto.append("\n");
        }
        
        // Educação
        if (perfil.getEducacao() != null && !perfil.getEducacao().isEmpty()) {
            texto.append("FORMAÇÃO ACADÊMICA:\n");
            for (int i = 0; i < 50; i++) texto.append("=");
            texto.append("\n");
            for (LinkedInProfileDataDTO.EducacaoDTO edu : perfil.getEducacao()) {
                texto.append("\nCurso: ").append(edu.getCurso() != null ? edu.getCurso() : "N/A");
                texto.append("\nInstituição: ").append(edu.getInstituicao() != null ? edu.getInstituicao() : "N/A");
                if (edu.getPeriodo() != null) {
                    texto.append("\nPeríodo: ").append(edu.getPeriodo());
                }
                texto.append("\n");
                for (int i = 0; i < 50; i++) texto.append("-");
                texto.append("\n");
            }
            texto.append("\n");
        }
        
        // Habilidades
        if (perfil.getHabilidades() != null && !perfil.getHabilidades().isEmpty()) {
            texto.append("HABILIDADES:\n");
            for (int i = 0; i < 50; i++) texto.append("=");
            texto.append("\n");
            texto.append(String.join(", ", perfil.getHabilidades()));
            texto.append("\n\n");
        }
        
        // Certificações
        if (perfil.getCertificacoes() != null && !perfil.getCertificacoes().isEmpty()) {
            texto.append("CERTIFICAÇÕES:\n");
            for (int i = 0; i < 50; i++) texto.append("=");
            texto.append("\n");
            texto.append(String.join("\n", perfil.getCertificacoes()));
            texto.append("\n\n");
        }
        
        // Idiomas
        if (perfil.getIdiomas() != null && !perfil.getIdiomas().isEmpty()) {
            texto.append("IDIOMAS:\n");
            for (int i = 0; i < 50; i++) texto.append("=");
            texto.append("\n");
            texto.append(String.join(", ", perfil.getIdiomas()));
            texto.append("\n\n");
        }
        
        return texto.toString();
    }
    
    /**
     * Extrai informações básicas de uma URL do LinkedIn
     * Nota: Esta é uma implementação básica. Para extração completa,
     * seria necessário usar a API oficial do LinkedIn ou biblioteca de scraping.
     */
    public String extractProfileIdFromUrl(String linkedinUrl) {
        if (linkedinUrl == null || linkedinUrl.trim().isEmpty()) {
            return null;
        }
        
        // Remove espaços e formata
        String url = linkedinUrl.trim();
        
        // Padrão: https://www.linkedin.com/in/username/
        if (url.contains("/in/")) {
            int startIndex = url.indexOf("/in/") + 4;
            int endIndex = url.indexOf("/", startIndex);
            if (endIndex == -1) {
                endIndex = url.length();
            }
            return url.substring(startIndex, endIndex);
        }
        
        return null;
    }
    
    /**
     * Valida se a URL é um perfil LinkedIn válido
     */
    public boolean isValidLinkedInUrl(String url) {
        if (url == null || url.trim().isEmpty()) {
            return false;
        }
        
        return url.contains("linkedin.com/in/") || 
               url.contains("linkedin.com/profile/view");
    }
}

