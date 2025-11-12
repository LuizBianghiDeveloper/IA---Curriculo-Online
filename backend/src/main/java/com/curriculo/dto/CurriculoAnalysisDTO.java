package com.curriculo.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CurriculoAnalysisDTO {
    
    @JsonProperty("compatibilityScore")
    private Double compatibilityScore;
    
    @JsonProperty("summary")
    private String summary;
    
    @JsonProperty("strengths")
    private List<String> strengths;
    
    @JsonProperty("weaknesses")
    private List<String> weaknesses;
    
    @JsonProperty("recommendations")
    private List<String> recommendations;
    
    @JsonProperty("isSuitable")
    private Boolean isSuitable;
}

