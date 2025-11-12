# 🗄️ Banco de Dados - Currículo Online

## 📊 Sistema de Armazenamento

O sistema agora utiliza **H2 Database** com **JPA/Hibernate** para persistência de dados.

### ✅ O que mudou?

**Antes:**
- ❌ Dados armazenados em memória (HashMap)
- ❌ Dados perdidos ao reiniciar o servidor
- ❌ Sem persistência

**Agora:**
- ✅ Banco de dados H2 com persistência em arquivo
- ✅ Dados salvos permanentemente
- ✅ Dados persistem após reiniciar o servidor
- ✅ Console web para visualizar dados

---

## 🗂️ Estrutura do Banco

### Tabela: `users`
Armazena informações dos usuários cadastrados.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id` | BIGINT | ID único (auto-incremento) |
| `username` | VARCHAR(50) | Nome de usuário (único) |
| `password` | VARCHAR | Hash da senha (BCrypt) |
| `email` | VARCHAR(100) | Email (único) |
| `nome` | VARCHAR(100) | Nome completo |
| `created_at` | TIMESTAMP | Data de criação |

### Tabela: `tokens`
Armazena tokens de autenticação.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `token` | VARCHAR(255) | Token único (chave primária) |
| `user_id` | BIGINT | ID do usuário (FK) |
| `created_at` | TIMESTAMP | Data de criação |
| `expires_at` | TIMESTAMP | Data de expiração (24 horas) |

---

## 📁 Localização dos Arquivos

Os arquivos do banco de dados são salvos em:
```
backend/data/curriculo_db.mv.db
backend/data/curriculo_db.trace.db
```

⚠️ **Importante:** O diretório `data/` está no `.gitignore` e não será commitado no Git.

---

## 🔧 Configuração

As configurações do banco estão em `application.properties`:

```properties
# Banco de Dados H2
spring.datasource.url=jdbc:h2:file:./data/curriculo_db
spring.datasource.username=sa
spring.datasource.password=

# JPA/Hibernate
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false
```

### Opções de `ddl-auto`:
- `update`: Cria/atualiza tabelas automaticamente (recomendado para desenvolvimento)
- `create`: Recria tabelas a cada inicialização (apaga dados!)
- `create-drop`: Cria ao iniciar e apaga ao encerrar
- `validate`: Apenas valida o schema (produção)

---

## 🌐 Console H2

Você pode visualizar e gerenciar o banco através do console web:

1. Inicie o backend
2. Acesse: `http://localhost:8080/h2-console`
3. Preencha:
   - **JDBC URL:** `jdbc:h2:file:./data/curriculo_db`
   - **User Name:** `sa`
   - **Password:** (deixe vazio)
4. Clique em "Connect"

### Consultas Úteis

**Ver todos os usuários:**
```sql
SELECT * FROM users;
```

**Ver todos os tokens:**
```sql
SELECT t.token, u.username, t.created_at, t.expires_at 
FROM tokens t 
JOIN users u ON t.user_id = u.id;
```

**Contar usuários:**
```sql
SELECT COUNT(*) FROM users;
```

---

## 🔄 Migração de Dados

Se você tinha dados em memória antes:

1. Os dados antigos foram perdidos (eram apenas em memória)
2. O usuário padrão `admin` será criado automaticamente na primeira inicialização
3. Novos usuários podem ser cadastrados normalmente

---

## 🚀 Próximos Passos (Opcional)

Para produção, você pode migrar para um banco mais robusto:

### PostgreSQL
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/curriculo_db
spring.datasource.username=seu_usuario
spring.datasource.password=sua_senha
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
```

### MySQL
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/curriculo_db
spring.datasource.username=seu_usuario
spring.datasource.password=sua_senha
spring.jpa.database-platform=org.hibernate.dialect.MySQLDialect
```

Basta adicionar a dependência no `pom.xml` e atualizar as configurações.

---

## ✅ Benefícios

- ✅ **Persistência:** Dados não são perdidos ao reiniciar
- ✅ **Segurança:** Validação de unicidade (username, email)
- ✅ **Tokens:** Expiração automática após 24 horas
- ✅ **Escalabilidade:** Fácil migração para PostgreSQL/MySQL
- ✅ **Desenvolvimento:** Console web para visualizar dados

---

**Pronto!** Seu sistema agora tem um banco de dados real! 🎉

