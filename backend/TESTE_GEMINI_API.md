# 🧪 Teste da API Gemini

Se você está recebendo erro 404, pode ser que:

1. **A chave de API não tem acesso aos modelos**
2. **O modelo não está disponível na sua região**
3. **A chave está incorreta ou expirada**

## ✅ Como Testar a Chave Manualmente

### Teste 1: cURL

```bash
curl -X POST \
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=SUA_CHAVE_AQUI' \
  -H 'Content-Type: application/json' \
  -d '{
    "contents": [{
      "parts": [{
        "text": "Olá, você está funcionando?"
      }]
    }]
  }'
```

### Teste 2: Postman

1. **Método:** POST
2. **URL:** 
   ```
   https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=SUA_CHAVE_AQUI
   ```
3. **Headers:**
   - `Content-Type: application/json`
4. **Body (raw JSON):**
   ```json
   {
     "contents": [{
       "parts": [{
         "text": "Olá, você está funcionando?"
       }]
     }]
   }
   ```

## 🔍 Verificar Chave de API

1. Acesse: https://makersuite.google.com/app/apikey
2. Verifique se a chave está ativa
3. Verifique se há limites ou restrições
4. Tente criar uma nova chave se necessário

## 📝 Modelos Disponíveis

O código tenta automaticamente estes modelos (nessa ordem):
1. `gemini-2.0-flash-exp` (mais recente)
2. `gemini-1.5-flash-latest`
3. `gemini-1.5-flash`
4. `gemini-1.5-pro-latest`
5. `gemini-1.5-pro`
6. `gemini-pro` (fallback)

## ⚠️ Se Nenhum Modelo Funcionar

1. **Verifique a chave:** Pode estar incorreta ou sem permissões
2. **Verifique a região:** Alguns modelos podem não estar disponíveis
3. **Crie uma nova chave:** Às vezes chaves antigas perdem acesso
4. **Verifique quotas:** Pode ter excedido o limite

## 🔗 Links Úteis

- **Documentação:** https://ai.google.dev/api
- **Status:** https://status.cloud.google.com/
- **Suporte:** https://support.google.com/cloud

