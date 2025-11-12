# ☕ Como Instalar Java 17 (Recomendado)

O projeto foi ajustado para funcionar com Java 8, mas **recomendamos Java 17** para melhor performance e compatibilidade.

## 🚀 Opção 1: Usando SDKMAN (Recomendado - macOS/Linux)

### Instalar SDKMAN:
```bash
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
```

### Instalar Java 17:
```bash
sdk install java 17.0.9-tem
sdk use java 17.0.9-tem
```

### Verificar instalação:
```bash
java -version
# Deve mostrar: openjdk version "17.0.9"
```

## 🍺 Opção 2: Usando Homebrew (macOS)

```bash
brew install openjdk@17
sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk
```

Configure no seu `~/.zshrc`:
```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@17
export PATH="$JAVA_HOME/bin:$PATH"
```

## 📥 Opção 3: Download Manual

1. Acesse: https://adoptium.net/
2. Baixe Java 17 (LTS)
3. Instale o pacote
4. Configure `JAVA_HOME` no seu sistema

## ✅ Verificar Instalação

```bash
java -version
mvn -version
```

Ambos devem mostrar Java 17.

## 🔄 Alternar Entre Versões (SDKMAN)

```bash
# Listar versões instaladas
sdk list java

# Usar Java 17
sdk use java 17.0.9-tem

# Usar Java 8
sdk use java 8.0.402-amzn
```

---

**Nota:** O projeto foi ajustado para funcionar com Java 8, mas Java 17 é recomendado para melhor performance.

