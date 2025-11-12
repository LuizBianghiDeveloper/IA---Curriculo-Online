package com.curriculo.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponseDTO {
    
    @JsonProperty("token")
    private String token;
    
    @JsonProperty("username")
    private String username;
    
    @JsonProperty("nome")
    private String nome;
    
    @JsonProperty("email")
    private String email;
    
    @JsonProperty("message")
    private String message;
}

