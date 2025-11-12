package com.curriculo.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LinkedInProfileDataDTO {
    
    @JsonProperty("nome")
    private String nome;
    
    @JsonProperty("titulo")
    private String titulo;
    
    @JsonProperty("localizacao")
    private String localizacao;
    
    @JsonProperty("resumo")
    private String resumo;
    
    @JsonProperty("experiencia")
    private List<ExperienciaDTO> experiencia;
    
    @JsonProperty("educacao")
    private List<EducacaoDTO> educacao;
    
    @JsonProperty("habilidades")
    private List<String> habilidades;
    
    @JsonProperty("certificacoes")
    private List<String> certificacoes;
    
    @JsonProperty("idiomas")
    private List<String> idiomas;
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ExperienciaDTO {
        @JsonProperty("empresa")
        private String empresa;
        
        @JsonProperty("cargo")
        private String cargo;
        
        @JsonProperty("periodo")
        private String periodo;
        
        @JsonProperty("descricao")
        private String descricao;
    }
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class EducacaoDTO {
        @JsonProperty("instituicao")
        private String instituicao;
        
        @JsonProperty("curso")
        private String curso;
        
        @JsonProperty("periodo")
        private String periodo;
    }
}

