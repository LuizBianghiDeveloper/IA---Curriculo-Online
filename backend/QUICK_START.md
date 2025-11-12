# ⚡ Quick Start - Configuração Rápida

## 1️⃣ Obter Chave de API do Gemini (2 minutos)

1. Acesse: **https://makersuite.google.com/app/apikey**
2. Faça login com sua conta Google
3. Clique em **"Create API Key"**
4. Escolha **"Create API key in new project"**
5. **Copie a chave** (ela só aparece uma vez!)

## 2️⃣ Configurar no Backend (1 minuto)

1. Abra: `backend/src/main/resources/application.properties`
2. Cole sua chave:
   ```properties
   ai.gemini.api.key=COLE_SUA_CHAVE_AQUI
   ```

## 3️⃣ Executar (30 segundos)

```bash
cd backend
mvn spring-boot:run
```

## ✅ Pronto!

O backend estará rodando em: `http://localhost:8080`

---

📖 **Guia detalhado:** Veja [COMO_OBTER_CHAVE_GEMINI.md](../COMO_OBTER_CHAVE_GEMINI.md)

