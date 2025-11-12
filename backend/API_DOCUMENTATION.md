# 📚 Documentação da API - Currículo Online

## Base URL
```
http://localhost:8080/api
```

---

## 🔍 Endpoints Disponíveis

### 1. Autenticação - Login

Realiza login de um usuário no sistema.

**Endpoint:** `POST /api/auth/login`

**Content-Type:** `application/json`

**Request Body:**
```json
{
  "username": "admin",
  "password": "admin123"
}
```

**Response (Sucesso - 200 OK):**
```json
{
  "token": "uuid-token-aqui",
  "username": "admin",
  "nome": "Administrador",
  "email": "admin@curriculo.com",
  "message": "Login realizado com sucesso"
}
```

**Response (Erro - 401 Unauthorized):**
```json
{
  "token": null,
  "username": null,
  "nome": null,
  "email": null,
  "message": "Usuário ou senha inválidos"
}
```

**Status Codes:**
- `200 OK`: Login realizado com sucesso
- `400 Bad Request`: Campos obrigatórios não fornecidos
- `401 Unauthorized`: Credenciais inválidas
- `500 Internal Server Error`: Erro interno do servidor

---

### 2. Autenticação - Registro

Registra um novo usuário no sistema.

**Endpoint:** `POST /api/auth/register`

**Content-Type:** `application/json`

**Request Body:**
```json
{
  "username": "novousuario",
  "password": "senha123",
  "email": "usuario@email.com",
  "nome": "Nome Completo"
}
```

**Response (Sucesso - 201 Created):**
```json
{
  "token": "uuid-token-aqui",
  "username": "novousuario",
  "nome": "Nome Completo",
  "email": "usuario@email.com",
  "message": "Usuário registrado com sucesso"
}
```

**Response (Erro - 409 Conflict):**
```json
{
  "token": null,
  "username": null,
  "nome": null,
  "email": null,
  "message": "Usuário já existe"
}
```

**Status Codes:**
- `201 Created`: Usuário registrado com sucesso
- `400 Bad Request`: Campos obrigatórios não fornecidos
- `409 Conflict`: Usuário já existe
- `500 Internal Server Error`: Erro interno do servidor

---

### 3. Autenticação - Logout

Realiza logout do usuário atual.

**Endpoint:** `POST /api/auth/logout`

**Headers:**
```
Authorization: Bearer {token}
```

**Response (Sucesso - 200 OK):**
```json
{
  "token": null,
  "username": null,
  "nome": null,
  "email": null,
  "message": "Logout realizado com sucesso"
}
```

**Status Codes:**
- `200 OK`: Logout realizado com sucesso
- `500 Internal Server Error`: Erro interno do servidor

---

### 4. Autenticação - Validar Token

Valida se um token de autenticação é válido.

**Endpoint:** `GET /api/auth/validate`

**Headers:**
```
Authorization: Bearer {token}
```

**Response (Sucesso - 200 OK):**
```json
{
  "token": "uuid-token-aqui",
  "username": "admin",
  "nome": "Administrador",
  "email": "admin@curriculo.com",
  "message": "Token válido"
}
```

**Response (Erro - 401 Unauthorized):**
```json
{
  "token": null,
  "username": null,
  "nome": null,
  "email": null,
  "message": "Token inválido ou expirado"
}
```

**Status Codes:**
- `200 OK`: Token válido
- `401 Unauthorized`: Token inválido ou não fornecido
- `500 Internal Server Error`: Erro interno do servidor

---

### 5. Health Check

Verifica se o backend está online e funcionando.

**Endpoint:** `GET /api/health`

**Request:**
```http
GET http://localhost:8080/api/health
```

**Response:**
```
Backend está online!
```

**Status Code:** `200 OK`

---

### 6. Analisar Currículo

Analisa um currículo em relação a uma descrição de vaga usando IA.

**Endpoint:** `POST /api/analyze`

**Content-Type:** `multipart/form-data`

**Request Body:**
- `curriculo` (file): Arquivo do currículo (PDF, DOC ou DOCX)
- `vaga` (string): JSON com a descrição da vaga

**Exemplo de Request (cURL):**
```bash
curl -X POST http://localhost:8080/api/analyze \
  -F "curriculo=@/caminho/para/curriculo.pdf" \
  -F 'vaga={"titulo":"Desenvolvedor Flutter","empresa":"Tech Corp","descricao":"Desenvolver aplicações mobile...","requisitos":["Flutter","Dart","3 anos"],"localizacao":"São Paulo","tipoContrato":"CLT"}'
```

**Exemplo de JSON da Vaga:**
```json
{
  "titulo": "Desenvolvedor Flutter",
  "empresa": "Tech Corp",
  "descricao": "Desenvolver aplicações mobile multiplataforma usando Flutter. Trabalhar em equipe ágil.",
  "requisitos": [
    "3+ anos de experiência com Flutter",
    "Conhecimento em Dart",
    "Experiência com APIs REST",
    "Conhecimento em Git"
  ],
  "localizacao": "São Paulo - SP",
  "tipoContrato": "CLT"
}
```

**Response (Sucesso - 200 OK):**
```json
{
  "compatibilityScore": 85.5,
  "summary": "O candidato possui experiência sólida em Flutter e Dart, com 4 anos de experiência. Demonstra conhecimento em APIs REST e Git. A experiência está alinhada com os requisitos da vaga.",
  "strengths": [
    "Experiência sólida em Flutter (4 anos)",
    "Conhecimento avançado em Dart",
    "Experiência com integração de APIs REST",
    "Portfólio com projetos relevantes"
  ],
  "weaknesses": [
    "Falta experiência com testes automatizados",
    "Não menciona experiência com CI/CD"
  ],
  "recommendations": [
    "Considerar o candidato para entrevista técnica",
    "Avaliar projetos do portfólio",
    "Verificar experiência com testes"
  ],
  "isSuitable": true
}
```

**Response (Erro - 400 Bad Request):**
```json
{
  "compatibilityScore": 0.0,
  "summary": "Erro: Não foi possível extrair texto do currículo",
  "strengths": [],
  "weaknesses": [],
  "recommendations": [],
  "isSuitable": false
}
```

**Response (Erro - 500 Internal Server Error):**
```json
{
  "compatibilityScore": 0.0,
  "summary": "Erro ao processar análise: [detalhes do erro]",
  "strengths": [],
  "weaknesses": [],
  "recommendations": [],
  "isSuitable": false
}
```

**Status Codes:**
- `200 OK`: Análise realizada com sucesso
- `400 Bad Request`: Erro na validação (arquivo inválido, JSON malformado)
- `500 Internal Server Error`: Erro interno do servidor (IA não configurada, erro na extração)

---

## 📋 Estrutura dos DTOs

### LoginRequestDTO

```json
{
  "username": "string (obrigatório)",
  "password": "string (obrigatório)"
}
```

### RegisterRequestDTO

```json
{
  "username": "string (obrigatório)",
  "password": "string (obrigatório)",
  "email": "string (obrigatório)",
  "nome": "string (obrigatório)"
}
```

### AuthResponseDTO

```json
{
  "token": "string (UUID token)",
  "username": "string",
  "nome": "string",
  "email": "string",
  "message": "string"
}
```

### VagaDescriptionDTO

```json
{
  "titulo": "string (obrigatório)",
  "empresa": "string (obrigatório)",
  "descricao": "string (obrigatório)",
  "requisitos": ["string", "string", ...],
  "localizacao": "string (opcional)",
  "tipoContrato": "string (opcional: CLT, PJ, Estágio, Freelance)"
}
```

### CurriculoAnalysisDTO

```json
{
  "compatibilityScore": 0.0-100.0,
  "summary": "string",
  "strengths": ["string", ...],
  "weaknesses": ["string", ...],
  "recommendations": ["string", ...],
  "isSuitable": true/false
}
```

---

## 🔧 Configuração

### Variáveis de Ambiente

A API usa as seguintes configurações (em `application.properties`):

```properties
# Provedor de IA: gemini ou openai
ai.provider=gemini

# Chave da API Gemini
ai.gemini.api.key=SUA_CHAVE_AQUI

# Chave da API OpenAI (opcional)
ai.openai.api.key=
```

---

## 📝 Exemplos de Uso

### Exemplo 1: Vaga de Desenvolvedor Flutter

```json
{
  "titulo": "Desenvolvedor Flutter",
  "empresa": "Startup Tech",
  "descricao": "Desenvolver aplicações mobile multiplataforma",
  "requisitos": [
    "Flutter",
    "Dart",
    "3 anos de experiência"
  ],
  "localizacao": "Remoto",
  "tipoContrato": "PJ"
}
```

### Exemplo 2: Vaga de Desenvolvedor Java

```json
{
  "titulo": "Desenvolvedor Java Senior",
  "empresa": "Empresa Tech",
  "descricao": "Desenvolver e manter aplicações backend",
  "requisitos": [
    "Java 8+",
    "Spring Boot",
    "5+ anos de experiência",
    "Microserviços"
  ],
  "localizacao": "São Paulo",
  "tipoContrato": "CLT"
}
```

---

## 🚨 Limitações

- **Tamanho máximo do arquivo:** 10MB
- **Formatos suportados:** PDF, DOC, DOCX
- **PDFs escaneados (imagens):** Podem não funcionar corretamente
- **Rate limiting:** Depende do plano da API de IA (Gemini: 60 req/min)

---

## 🐛 Tratamento de Erros

A API retorna sempre um `CurriculoAnalysisDTO`, mesmo em caso de erro:

- **Erro de validação:** `compatibilityScore = 0.0`, `summary` contém mensagem de erro
- **Erro de processamento:** `compatibilityScore = 0.0`, `summary` contém detalhes do erro
- **Erro de IA:** `compatibilityScore = 0.0`, `summary` contém mensagem de configuração

---

## 📦 Importar Collection no Postman

1. Abra o Postman
2. Clique em **Import**
3. Selecione o arquivo `Curriculo_Online_API.postman_collection.json`
4. A collection será importada com todos os endpoints prontos para uso

---

## ✅ Testando a API

### 1. Teste o Health Check:
```bash
curl http://localhost:8080/api/health
```

### 2. Teste a Análise (substitua o caminho do arquivo):
```bash
curl -X POST http://localhost:8080/api/analyze \
  -F "curriculo=@/caminho/para/seu/curriculo.pdf" \
  -F 'vaga={"titulo":"Desenvolvedor","empresa":"Tech","descricao":"Desenvolver apps","requisitos":["Flutter"],"localizacao":"SP","tipoContrato":"CLT"}'
```

---

**Pronto para usar! 🚀**

