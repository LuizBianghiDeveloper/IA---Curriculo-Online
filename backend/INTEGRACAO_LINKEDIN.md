# 🔗 Integração com LinkedIn - Currículo Online

## 📋 Visão Geral

Este documento explica como integrar o sistema com LinkedIn para avaliar candidatos diretamente de seus perfis.

---

## 🎯 Opções de Integração

### 1. **LinkedIn API v2 (Recomendado - Oficial)**

**Vantagens:**
- ✅ API oficial e suportada
- ✅ Dados estruturados e confiáveis
- ✅ Atualizações automáticas

**Desvantagens:**
- ❌ Requer aprovação da LinkedIn (Partner Program)
- ❌ Processo de aprovação pode levar semanas/meses
- ❌ Requer OAuth 2.0 para autenticação
- ❌ Limitações de rate limiting

**Requisitos:**
- Conta LinkedIn Developer
- Aplicação registrada no LinkedIn Developer Portal
- Aprovação para endpoints específicos (Profile API)
- Para buscar perfis de terceiros: requer parceria oficial

**Documentação:** https://docs.microsoft.com/en-us/linkedin/

---

### 2. **LinkedIn Recruiter API**

**Vantagens:**
- ✅ Acesso direto a perfis de candidatos
- ✅ Integração nativa com ferramentas de recrutamento

**Desvantagens:**
- ❌ Requer conta LinkedIn Recruiter (paga)
- ❌ Apenas para empresas com licença Recruiter
- ❌ Processo de aprovação necessário

**Requisitos:**
- Conta LinkedIn Recruiter ativa
- Aprovação da LinkedIn para integração

---

### 3. **Solução Híbrida (Implementada)**

**Como funciona:**
- ✅ Usuário fornece URL do perfil LinkedIn
- ✅ Sistema extrai informações públicas do perfil
- ✅ Usa IA para analisar o perfil em relação à vaga
- ✅ Não requer aprovação da LinkedIn

**Limitações:**
- ⚠️ Apenas dados públicos do perfil
- ⚠️ Pode precisar de autenticação do usuário para perfis privados
- ⚠️ Estrutura do HTML pode mudar (requer manutenção)

**Implementação:**
- Endpoint: `POST /api/analyze/linkedin`
- Aceita URL do perfil ou dados do perfil em JSON
- Processa e analisa usando IA

---

## 🚀 Implementação Atual

### Endpoint: Analisar Perfil LinkedIn

**POST** `/api/analyze/linkedin`

**Request Body:**
```json
{
  "linkedinUrl": "https://www.linkedin.com/in/candidato/",
  "vaga": {
    "titulo": "Desenvolvedor Java Senior",
    "empresa": "Tech Corp",
    "descricao": "Desenvolver aplicações backend...",
    "requisitos": ["Java", "Spring Boot", "5+ anos"],
    "localizacao": "São Paulo",
    "tipoContrato": "CLT"
  }
}
```

**Ou com dados do perfil diretamente:**
```json
{
  "perfilData": {
    "nome": "João Silva",
    "titulo": "Desenvolvedor Java Senior",
    "experiencia": [
      {
        "empresa": "Tech Corp",
        "cargo": "Desenvolvedor Java",
        "periodo": "2020 - Presente",
        "descricao": "Desenvolvi aplicações backend..."
      }
    ],
    "educacao": [...],
    "habilidades": ["Java", "Spring Boot", "PostgreSQL"]
  },
  "vaga": {...}
}
```

**Response:**
```json
{
  "compatibilityScore": 85.5,
  "summary": "O perfil do candidato demonstra...",
  "strengths": [...],
  "weaknesses": [...],
  "recommendations": [...],
  "isSuitable": true
}
```

---

## 🔧 Configuração

### Opção 1: Usando LinkedIn API (Futuro)

1. **Registrar aplicação no LinkedIn:**
   - Acesse: https://www.linkedin.com/developers/
   - Crie uma nova aplicação
   - Configure OAuth 2.0
   - Solicite permissões necessárias

2. **Configurar no `application.properties`:**
```properties
# LinkedIn API Configuration
linkedin.client.id=SEU_CLIENT_ID
linkedin.client.secret=SEU_CLIENT_SECRET
linkedin.redirect.uri=http://localhost:8080/api/auth/linkedin/callback
```

3. **Fluxo OAuth:**
   - Usuário autoriza aplicação
   - Recebe token de acesso
   - Usa token para buscar perfil

### Opção 2: Solução Híbrida (Atual)

Não requer configuração adicional. O sistema aceita:
- URL do perfil LinkedIn (para extração manual)
- Dados do perfil em JSON (fornecidos pelo usuário)

---

## 📝 Como Usar

### 1. Via URL do Perfil

```bash
curl -X POST http://localhost:8080/api/analyze/linkedin \
  -H "Content-Type: application/json" \
  -d '{
    "linkedinUrl": "https://www.linkedin.com/in/candidato/",
    "vaga": {
      "titulo": "Desenvolvedor Java",
      "empresa": "Tech Corp",
      "descricao": "...",
      "requisitos": ["Java", "Spring Boot"],
      "localizacao": "São Paulo",
      "tipoContrato": "CLT"
    }
  }'
```

### 2. Via Dados do Perfil

```bash
curl -X POST http://localhost:8080/api/analyze/linkedin \
  -H "Content-Type: application/json" \
  -d '{
    "perfilData": {
      "nome": "João Silva",
      "titulo": "Desenvolvedor Java Senior",
      "experiencia": [...],
      "habilidades": ["Java", "Spring Boot"]
    },
    "vaga": {...}
  }'
```

---

## 🔐 Segurança e Privacidade

⚠️ **Importante:**
- Respeite os Termos de Serviço do LinkedIn
- Não faça scraping agressivo
- Solicite consentimento do candidato antes de analisar
- Armazene dados com segurança (LGPD/GDPR)
- Use HTTPS em produção

---

## 🚧 Limitações Atuais

1. **Extração de Perfil:**
   - Implementação básica (aceita dados fornecidos)
   - Para extração automática via URL, requer biblioteca de scraping ou API oficial

2. **Autenticação:**
   - Não implementado OAuth 2.0 ainda
   - Requer desenvolvimento adicional

3. **Rate Limiting:**
   - LinkedIn tem limites de requisições
   - Implementar cache e throttling

---

## 🔮 Próximos Passos

1. **Implementar OAuth 2.0:**
   - Fluxo de autenticação LinkedIn
   - Armazenamento seguro de tokens

2. **Extração Automática:**
   - Biblioteca para extrair dados de URL
   - Fallback para dados manuais

3. **Cache:**
   - Cachear perfis analisados
   - Reduzir chamadas à API

4. **Notificações:**
   - Notificar candidato sobre análise
   - Dashboard para acompanhamento

---

## 📚 Recursos

- **LinkedIn API Docs:** https://docs.microsoft.com/en-us/linkedin/
- **LinkedIn Developer Portal:** https://www.linkedin.com/developers/
- **OAuth 2.0 Guide:** https://oauth.net/2/

---

## ✅ Status da Implementação

- ✅ Endpoint para análise via LinkedIn
- ✅ Suporte a dados de perfil em JSON
- ✅ Integração com IA existente
- ⏳ OAuth 2.0 (planejado)
- ⏳ Extração automática de URL (planejado)
- ⏳ Cache de perfis (planejado)

---

**Nota:** A implementação atual permite análise de perfis do LinkedIn fornecendo os dados manualmente ou via URL. Para integração completa com API oficial, é necessário aprovação da LinkedIn e implementação de OAuth 2.0.

