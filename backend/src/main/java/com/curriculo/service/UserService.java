package com.curriculo.service;

import com.curriculo.model.Token;
import com.curriculo.model.User;
import com.curriculo.repository.TokenRepository;
import com.curriculo.repository.UserRepository;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.PostConstruct;
import java.util.Optional;
import java.util.UUID;

@Service
public class UserService {
    
    private final BCryptPasswordEncoder passwordEncoder;
    private final UserRepository userRepository;
    private final TokenRepository tokenRepository;
    
    public UserService(UserRepository userRepository, TokenRepository tokenRepository) {
        this.passwordEncoder = new BCryptPasswordEncoder();
        this.userRepository = userRepository;
        this.tokenRepository = tokenRepository;
    }
    
    @PostConstruct
    public void init() {
        // Cria usuário padrão se não existir
        // Nota: Operações simples de leitura/escrita não precisam de @Transactional no @PostConstruct
        if (!userRepository.existsByUsername("admin")) {
            User defaultUser = new User();
            defaultUser.setUsername("admin");
            defaultUser.setPassword(passwordEncoder.encode("admin123"));
            defaultUser.setEmail("admin@curriculo.com");
            defaultUser.setNome("Administrador");
            userRepository.save(defaultUser);
        }
    }
    
    @Transactional
    public void cleanupExpiredTokens() {
        // Remove tokens expirados (pode ser chamado periodicamente)
        tokenRepository.deleteExpiredTokens(java.time.LocalDateTime.now());
    }
    
    @Transactional
    public User register(String username, String password, String email, String nome) {
        if (userRepository.existsByUsername(username)) {
            throw new IllegalArgumentException("Usuário já existe");
        }
        
        if (userRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("Email já cadastrado");
        }
        
        User user = new User();
        user.setUsername(username);
        user.setPassword(passwordEncoder.encode(password));
        user.setEmail(email);
        user.setNome(nome);
        
        return userRepository.save(user);
    }
    
    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }
    
    public boolean validatePassword(String rawPassword, String encodedPassword) {
        return passwordEncoder.matches(rawPassword, encodedPassword);
    }
    
    @Transactional
    public String generateToken(User user) {
        String token = UUID.randomUUID().toString() + "-" + System.currentTimeMillis();
        
        Token tokenEntity = new Token();
        tokenEntity.setToken(token);
        tokenEntity.setUser(user);
        
        tokenRepository.save(tokenEntity);
        return token;
    }
    
    @Transactional
    public Optional<User> getUserFromToken(String token) {
        Optional<Token> tokenEntity = tokenRepository.findByToken(token);
        
        if (tokenEntity.isPresent()) {
            Token t = tokenEntity.get();
            if (t.isExpired()) {
                tokenRepository.delete(t);
                // Limpa tokens expirados periodicamente
                cleanupExpiredTokens();
                return Optional.empty();
            }
            return Optional.of(t.getUser());
        }
        
        return Optional.empty();
    }
    
    @Transactional
    public boolean isValidToken(String token) {
        Optional<Token> tokenEntity = tokenRepository.findByToken(token);
        if (tokenEntity.isPresent()) {
            Token t = tokenEntity.get();
            if (t.isExpired()) {
                tokenRepository.delete(t);
                return false;
            }
            return true;
        }
        return false;
    }
    
    @Transactional
    public void invalidateToken(String token) {
        tokenRepository.findByToken(token).ifPresent(tokenRepository::delete);
    }
    
    @Transactional
    public void invalidateAllUserTokens(Long userId) {
        tokenRepository.deleteByUserId(userId);
    }
}

