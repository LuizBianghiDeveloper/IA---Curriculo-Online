# Backend Spring Boot - Currículo Online

Backend em Java Spring Boot para análise de currículos usando Inteligência Artificial.

## 🚀 Funcionalidades

- ✅ Recebe arquivos de currículo (PDF, DOC, DOCX) do Flutter
- ✅ Extrai texto dos arquivos
- ✅ Analisa compatibilidade com descrição da vaga usando IA
- ✅ Suporta Google Gemini e OpenAI
- ✅ API REST com CORS configurado

## 📋 Pré-requisitos

- Java 17 ou superior
- Maven 3.6+
- Chave de API de IA (Gemini ou OpenAI)

## 🔧 Configuração

### 1. Configurar Chave de API

Edite o arquivo `src/main/resources/application.properties`:

```properties
# Escolha o provedor: gemini ou openai
ai.provider=gemini

# Cole sua chave aqui
ai.gemini.api.key=SUA_CHAVE_GEMINI_AQUI

# Ou para OpenAI:
ai.openai.api.key=SUA_CHAVE_OPENAI_AQUI
```

### 2. Obter Chaves de API

**Google Gemini (Recomendado - Gratuito):**
- Acesse: https://makersuite.google.com/app/apikey
- Faça login e crie uma nova chave
- Cole no `application.properties`
- 📖 **Guia detalhado:** Veja [COMO_OBTER_CHAVE_GEMINI.md](../COMO_OBTER_CHAVE_GEMINI.md)

**OpenAI (Pago):**
- Acesse: https://platform.openai.com/api-keys
- Crie uma nova chave
- Cole no `application.properties`

## 🏃 Como Executar

### Opção 1: Maven

```bash
cd backend
mvn spring-boot:run
```

### Opção 2: Executar JAR

```bash
cd backend
mvn clean package
java -jar target/curriculo-online-backend-1.0.0.jar
```

### Opção 3: IDE

1. Abra o projeto no IntelliJ IDEA ou Eclipse
2. Execute a classe `CurriculoOnlineApplication`

O servidor iniciará em: `http://localhost:8080`

## 📡 Endpoints

### POST /api/analyze

Analisa um currículo em relação a uma vaga.

**Request:**
- `multipart/form-data`:
  - `curriculo`: arquivo (PDF, DOC, DOCX)
  - `vaga`: JSON string com descrição da vaga

**Exemplo de vaga (JSON):**
```json
{
  "titulo": "Desenvolvedor Flutter",
  "empresa": "Tech Corp",
  "descricao": "Desenvolver aplicações mobile...",
  "requisitos": ["Flutter", "Dart", "3 anos de experiência"],
  "localizacao": "São Paulo",
  "tipoContrato": "CLT"
}
```

**Response:**
```json
{
  "compatibilityScore": 85.5,
  "summary": "Resumo da análise...",
  "strengths": ["Ponto forte 1", "Ponto forte 2"],
  "weaknesses": ["Ponto fraco 1"],
  "recommendations": ["Recomendação 1"],
  "isSuitable": true
}
```

### GET /api/health

Verifica se o backend está online.

**Response:**
```
Backend está online!
```

## 🏗️ Estrutura do Projeto

```
backend/
├── src/
│   ├── main/
│   │   ├── java/com/curriculo/
│   │   │   ├── CurriculoOnlineApplication.java
│   │   │   ├── config/
│   │   │   │   └── CorsConfig.java
│   │   │   ├── controller/
│   │   │   │   └── AnalysisController.java
│   │   │   ├── dto/
│   │   │   │   ├── CurriculoAnalysisDTO.java
│   │   │   │   └── VagaDescriptionDTO.java
│   │   │   └── service/
│   │   │       ├── AiService.java
│   │   │       └── TextExtractorService.java
│   │   └── resources/
│   │       └── application.properties
│   └── test/
└── pom.xml
```

## 🔒 Segurança

⚠️ **Importante:** Não commite suas chaves de API no Git!

- Adicione `application.properties` ao `.gitignore` se contiver chaves
- Use variáveis de ambiente em produção:
  ```bash
  export AI_GEMINI_API_KEY=sua_chave_aqui
  ```

## 🐛 Solução de Problemas

### Erro: "Chave da API não configurada"
- Verifique se você preencheu a chave em `application.properties`
- Certifique-se de que o `ai.provider` está correto

### Erro ao extrair texto de PDF
- Verifique se o arquivo é um PDF válido
- PDFs escaneados (imagens) podem não funcionar

### Erro de CORS
- O CORS já está configurado para aceitar todas as origens
- Em produção, configure origens específicas em `CorsConfig.java`

## 📝 Próximos Passos

- [ ] Adicionar autenticação
- [ ] Implementar cache de análises
- [ ] Adicionar logging mais detalhado
- [ ] Implementar rate limiting
- [ ] Adicionar testes unitários

## 📚 Tecnologias Utilizadas

- Spring Boot 3.2.0
- Apache PDFBox (extração de PDFs)
- Apache POI (extração de DOC/DOCX)
- WebFlux (chamadas HTTP para APIs de IA)
- Lombok (redução de boilerplate)

