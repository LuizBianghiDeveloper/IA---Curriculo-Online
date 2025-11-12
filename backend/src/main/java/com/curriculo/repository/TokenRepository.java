package com.curriculo.repository;

import com.curriculo.model.Token;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface TokenRepository extends JpaRepository<Token, String> {
    
    Optional<Token> findByToken(String token);
    
    @Modifying
    @Query("DELETE FROM Token t WHERE t.expiresAt < ?1")
    void deleteExpiredTokens(LocalDateTime now);
    
    @Modifying
    @Query("DELETE FROM Token t WHERE t.user.id = ?1")
    void deleteByUserId(Long userId);
}

