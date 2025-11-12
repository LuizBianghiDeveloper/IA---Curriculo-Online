# Currículo Online - Sistema de Análise de RH com IA

Aplicação Flutter para análise de currículos usando Inteligência Artificial.

## Funcionalidades

- Upload de currículos (PDF, DOC, DOCX)
- Descrição de vagas com requisitos
- Análise automática de compatibilidade entre currículo e vaga
- Feedback detalhado da IA sobre adequação do candidato

## Estrutura do Projeto

```
lib/
  ├── main.dart                 # Ponto de entrada da aplicação
  ├── models/                   # Modelos de dados
  │   ├── curriculo_analysis.dart
  │   └── vaga_description.dart
  ├── screens/                  # Telas da aplicação
  │   ├── home_screen.dart
  │   └── analysis_result_screen.dart
  ├── services/                 # Serviços (API, etc)
  │   └── api_service.dart
  └── widgets/                  # Widgets reutilizáveis
      ├── file_picker_widget.dart
      └── vaga_form_widget.dart
```

## Como executar

### Instalação

1. Instale as dependências:
```bash
flutter pub get
```

### Executar em Dispositivo Móvel

#### Android (Emulador ou Dispositivo Físico)

**Opção 1: Emulador**
```bash
# Listar emuladores disponíveis
flutter emulators

# Iniciar um emulador (exemplo)
flutter emulators --launch Pixel_5_API_34

# Executar a aplicação
flutter run
```

**Opção 2: Dispositivo Físico**
1. Conecte o dispositivo via USB
2. Ative o **Modo Desenvolvedor** e **Depuração USB**
3. Verifique se foi detectado: `flutter devices`
4. Execute: `flutter run`

#### iOS (Simulador ou Dispositivo Físico)

**Opção 1: Simulador**
```bash
# Abrir simulador
open -a Simulator

# Executar a aplicação
flutter run
```

**Opção 2: Dispositivo Físico**
1. Conecte o iPhone/iPad via USB
2. Configure no Xcode: `open ios/Runner.xcworkspace`
3. Selecione seu dispositivo e configure o Team
4. Execute: `flutter run`

📱 **Para um guia completo e detalhado, consulte [GUIA_EXECUCAO_MOBILE.md](GUIA_EXECUCAO_MOBILE.md)**

### Executar em Desktop/Web

```bash
# Desktop (macOS, Windows, Linux)
flutter run -d macos
flutter run -d windows
flutter run -d linux

# Web
flutter run -d chrome
```

## Configuração do Backend

O backend será desenvolvido em Java. Por padrão, a aplicação está configurada para se conectar em:
- URL: `http://localhost:8080/api`

Para alterar a URL do backend, edite o arquivo `lib/services/api_service.dart` e modifique a constante `baseUrl`.

⚠️ **Importante para dispositivos físicos:** Se estiver testando em um dispositivo físico (não emulador), você precisa usar o IP da sua máquina ao invés de `localhost`. Exemplo: `http://192.168.1.100:8080/api`

## Endpoints esperados no Backend

### POST /api/analyze
Recebe um arquivo de currículo e a descrição da vaga, retorna a análise.

**Request:**
- Multipart form data:
  - `curriculo`: arquivo (PDF, DOC, DOCX)
  - `vaga`: JSON com a descrição da vaga

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
Endpoint para verificar se o backend está online.

## Próximos Passos

1. Desenvolver o backend em Java
2. Implementar a integração com IA (OpenAI, Gemini, etc)
3. Adicionar persistência de dados
4. Implementar autenticação de usuários

