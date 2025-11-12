package com.curriculo.controller;

import com.curriculo.dto.AuthResponseDTO;
import com.curriculo.dto.LoginRequestDTO;
import com.curriculo.dto.RegisterRequestDTO;
import com.curriculo.model.User;
import com.curriculo.service.UserService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {
    
    private final UserService userService;
    
    public AuthController(UserService userService) {
        this.userService = userService;
    }
    
    @PostMapping("/login")
    public ResponseEntity<AuthResponseDTO> login(@RequestBody LoginRequestDTO loginRequest) {
        try {
            if (loginRequest.getUsername() == null || loginRequest.getUsername().trim().isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(createErrorResponse("Username é obrigatório"));
            }
            
            if (loginRequest.getPassword() == null || loginRequest.getPassword().trim().isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(createErrorResponse("Senha é obrigatória"));
            }
            
            Optional<User> userOpt = userService.findByUsername(loginRequest.getUsername());
            
            if (!userOpt.isPresent()) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(createErrorResponse("Usuário ou senha inválidos"));
            }
            
            User user = userOpt.get();
            
            if (!userService.validatePassword(loginRequest.getPassword(), user.getPassword())) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(createErrorResponse("Usuário ou senha inválidos"));
            }
            
            String token = userService.generateToken(user);
            
            AuthResponseDTO response = new AuthResponseDTO();
            response.setToken(token);
            response.setUsername(user.getUsername());
            response.setNome(user.getNome());
            response.setEmail(user.getEmail());
            response.setMessage("Login realizado com sucesso");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Erro ao realizar login: " + e.getMessage()));
        }
    }
    
    @PostMapping("/register")
    public ResponseEntity<AuthResponseDTO> register(@RequestBody RegisterRequestDTO registerRequest) {
        try {
            if (registerRequest.getUsername() == null || registerRequest.getUsername().trim().isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(createErrorResponse("Username é obrigatório"));
            }
            
            if (registerRequest.getPassword() == null || registerRequest.getPassword().trim().isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(createErrorResponse("Senha é obrigatória"));
            }
            
            if (registerRequest.getEmail() == null || registerRequest.getEmail().trim().isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(createErrorResponse("Email é obrigatório"));
            }
            
            if (registerRequest.getNome() == null || registerRequest.getNome().trim().isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(createErrorResponse("Nome é obrigatório"));
            }
            
            User user = userService.register(
                    registerRequest.getUsername(),
                    registerRequest.getPassword(),
                    registerRequest.getEmail(),
                    registerRequest.getNome()
            );
            
            String token = userService.generateToken(user);
            
            AuthResponseDTO response = new AuthResponseDTO();
            response.setToken(token);
            response.setUsername(user.getUsername());
            response.setNome(user.getNome());
            response.setEmail(user.getEmail());
            response.setMessage("Usuário registrado com sucesso");
            
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
            
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(createErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Erro ao registrar usuário: " + e.getMessage()));
        }
    }
    
    @PostMapping("/logout")
    public ResponseEntity<AuthResponseDTO> logout(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        try {
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                String token = authHeader.substring(7);
                userService.invalidateToken(token);
            }
            
            AuthResponseDTO response = new AuthResponseDTO();
            response.setMessage("Logout realizado com sucesso");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Erro ao realizar logout: " + e.getMessage()));
        }
    }
    
    @GetMapping("/validate")
    public ResponseEntity<AuthResponseDTO> validateToken(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        try {
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(createErrorResponse("Token não fornecido"));
            }
            
            String token = authHeader.substring(7);
            
            Optional<User> userOpt = userService.getUserFromToken(token);
            
            if (!userOpt.isPresent()) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(createErrorResponse("Token inválido ou expirado"));
            }
            
            User user = userOpt.get();
            
            AuthResponseDTO response = new AuthResponseDTO();
            response.setToken(token);
            response.setUsername(user.getUsername());
            response.setNome(user.getNome());
            response.setEmail(user.getEmail());
            response.setMessage("Token válido");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(createErrorResponse("Erro ao validar token: " + e.getMessage()));
        }
    }
    
    private AuthResponseDTO createErrorResponse(String message) {
        AuthResponseDTO response = new AuthResponseDTO();
        response.setMessage(message);
        return response;
    }
}

