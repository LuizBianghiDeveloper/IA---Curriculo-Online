package com.curriculo.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class VagaDescriptionDTO {
    
    @JsonProperty("titulo")
    private String titulo;
    
    @JsonProperty("descricao")
    private String descricao;
    
    @JsonProperty("requisitos")
    private List<String> requisitos;
    
    @JsonProperty("empresa")
    private String empresa;
    
    @JsonProperty("localizacao")
    private String localizacao;
    
    @JsonProperty("tipoContrato")
    private String tipoContrato;
}

