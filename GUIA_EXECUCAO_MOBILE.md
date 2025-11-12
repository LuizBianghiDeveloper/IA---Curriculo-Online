# 📱 Guia: Como Rodar a Aplicação em Dispositivo Móvel

Este guia explica como executar a aplicação Flutter em dispositivos Android e iOS.

## 📋 Pré-requisitos

### Para Android:
- ✅ Android Studio instalado
- ✅ Android SDK configurado
- ✅ Dispositivo Android com **Modo Desenvolvedor** ativado
- ✅ **Depuração USB** habilitada no dispositivo

### Para iOS:
- ✅ Xcode instalado (apenas macOS)
- ✅ Dispositivo iOS ou Simulador
- ✅ Conta de desenvolvedor Apple (para dispositivo físico)

---

## 🔧 Configuração Inicial

### 1. Verificar Instalação do Flutter

```bash
flutter doctor
```

Certifique-se de que todas as ferramentas necessárias estão instaladas.

### 2. Aceitar Licenças do Android (se necessário)

```bash
flutter doctor --android-licenses
```

---

## 📱 Executando em Dispositivo Android

### Opção 1: Dispositivo Físico Conectado via USB

1. **Conecte o dispositivo Android ao computador via cabo USB**

2. **Ative o Modo Desenvolvedor no dispositivo:**
   - Vá em **Configurações** → **Sobre o telefone**
   - Toque 7 vezes em **Número da versão** ou **Número da compilação**
   - Volte para **Configurações** → **Sistema** → **Opções do desenvolvedor**
   - Ative **Depuração USB**

3. **Verifique se o dispositivo foi detectado:**
   ```bash
   flutter devices
   ```
   Você deve ver seu dispositivo listado.

4. **Execute a aplicação:**
   ```bash
   flutter run
   ```
   Ou especifique o dispositivo:
   ```bash
   flutter run -d <device-id>
   ```

### Opção 2: Emulador Android

1. **Listar emuladores disponíveis:**
   ```bash
   flutter emulators
   ```

2. **Iniciar um emulador:**
   ```bash
   flutter emulators --launch <emulator-id>
   ```

3. **Aguardar o emulador iniciar e executar:**
   ```bash
   flutter run
   ```

### Opção 3: Criar e Iniciar Novo Emulador

1. **Abrir Android Studio**
2. **Tools** → **Device Manager**
3. **Create Device** → Escolha um dispositivo
4. **Download** uma imagem do sistema (se necessário)
5. **Finish** e execute `flutter run`

---

## 🍎 Executando em Dispositivo iOS

### Opção 1: Simulador iOS

1. **Listar simuladores disponíveis:**
   ```bash
   flutter devices
   ```

2. **Executar no simulador:**
   ```bash
   flutter run
   ```
   O Flutter detectará automaticamente o simulador se estiver aberto.

3. **Ou abrir simulador manualmente:**
   ```bash
   open -a Simulator
   ```
   Depois execute `flutter run`

### Opção 2: Dispositivo iOS Físico

1. **Conecte o iPhone/iPad via cabo USB**

2. **Configure o projeto no Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

3. **No Xcode:**
   - Selecione seu dispositivo no topo
   - Vá em **Signing & Capabilities**
   - Selecione seu **Team** (conta de desenvolvedor)
   - O Xcode configurará automaticamente

4. **Execute a aplicação:**
   ```bash
   flutter run
   ```

5. **No dispositivo iOS:**
   - Vá em **Configurações** → **Geral** → **Gerenciamento de VPN e Dispositivo**
   - Confie no certificado do desenvolvedor

---

## 🚀 Comandos Úteis

### Ver dispositivos conectados:
```bash
flutter devices
```

### Executar em dispositivo específico:
```bash
flutter run -d <device-id>
```

### Executar em modo release (otimizado):
```bash
flutter run --release
```

### Hot Reload (durante execução):
- Pressione `r` no terminal para recarregar
- Pressione `R` para hot restart
- Pressione `q` para sair

### Limpar e reconstruir:
```bash
flutter clean
flutter pub get
flutter run
```

---

## 🔍 Solução de Problemas

### Dispositivo Android não detectado:

1. **Verifique se a depuração USB está ativada**
2. **Tente outro cabo USB**
3. **Instale drivers USB do fabricante** (Windows)
4. **Reinicie o servidor ADB:**
   ```bash
   adb kill-server
   adb start-server
   ```

### Erro de permissões no Android:

As permissões já estão configuradas no `AndroidManifest.xml`. Se ainda houver problemas:
- Verifique se o Android 13+ está usando as novas permissões de mídia
- Teste em um dispositivo Android mais antigo primeiro

### Erro de assinatura no iOS:

1. **Abra o projeto no Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Configure o Team em Signing & Capabilities**

3. **Se não tiver conta de desenvolvedor:**
   - Use apenas o Simulador iOS
   - Ou crie uma conta gratuita na Apple Developer

### Erro de conexão com backend:

Se estiver testando em dispositivo físico, o `localhost:8080` não funcionará. Você precisa:

1. **Descobrir o IP do seu computador:**
   ```bash
   # macOS/Linux:
   ifconfig | grep "inet "
   
   # Windows:
   ipconfig
   ```

2. **Atualizar a URL no código:**
   Edite `lib/services/api_service.dart`:
   ```dart
   static const String baseUrl = 'http://SEU_IP_AQUI:8080/api';
   ```
   Exemplo: `http://192.168.1.100:8080/api`

3. **Certifique-se de que o dispositivo e o computador estão na mesma rede Wi-Fi**

---

## 📝 Notas Importantes

- ⚠️ **Para testar com backend local em dispositivo físico**, use o IP da sua máquina, não `localhost`
- 📱 **Primeira execução pode demorar** (compilação inicial)
- 🔄 **Hot Reload** funciona apenas em modo debug
- 🚀 **Modo Release** é mais rápido, mas não permite hot reload

---

## ✅ Checklist Rápido

- [ ] Flutter instalado e configurado (`flutter doctor`)
- [ ] Dispositivo conectado e detectado (`flutter devices`)
- [ ] Permissões configuradas (já feito)
- [ ] Backend rodando (se necessário)
- [ ] URL do backend atualizada (se dispositivo físico)
- [ ] Executar: `flutter run`

---

**Pronto! Sua aplicação deve estar rodando no dispositivo móvel! 🎉**

