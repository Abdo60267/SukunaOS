# 🔴 Correção de Erros do GitHub Actions

## ❌ Erros Encontrados no Build

### Erro 1: `ubuntu-archive-keyring` não disponível
```
Package 'ubuntu-archive-keyring' is not available, but is referred to by another package.
E: Package 'ubuntu-archive-keyring' has no installation candidate
Error: Process completed with exit code 100.
```

**Causa**: Este pacote não está disponível na imagem do Ubuntu que GitHub Actions usa.

**Solução**: Remover do `apt-get install` e tentar instalar separadamente como opcional.

```bash
# ❌ ANTES (falhava)
sudo apt-get install -y \
  live-build \
  ubuntu-archive-keyring \  ← ERRO AQUI
  live-config

# ✅ DEPOIS (trata como opcional)
sudo apt-get install -y \
  live-build \
  live-config \
  ...
  
# Depois tenta ubuntu-archive-keyring se disponível
sudo apt-get install -y ubuntu-archive-keyring 2>/dev/null || echo "⚠️  não disponível"
```

---

### Erro 2: Diretório não existe
```
/home/runner/work/_temp/4956e3f5-2467-48e9-925a-3b3ae7dd23e9.sh: line 3: 
live-build/BUILD_MANIFEST.txt: No such file or directory
```

**Causa**: Step 13 tentava criar arquivo em `live-build/` mas o diretório não existia.

**Solução**: Criar o diretório no passo de limpeza (Step 7).

```bash
# ❌ ANTES
echo "🔴 Cleaning previous builds..."
rm -rf live-build
# ... build scripts rodavam
# ... step 13 falhava porque live-build não existia

# ✅ DEPOIS
echo "🔴 Cleaning previous builds..."
rm -rf live-build
# ... limpar tudo ...
mkdir -p live-build  ← ADICIONADO
```

---

## 📋 Mudanças Específicas

### Mudança 1: Install Dependencies (Step 5)
**Arquivo**: `.github/workflows/build.yml`

```yaml
# ❌ ANTES
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  live-build \
  ubuntu-archive-keyring \  ← PROBLEMA
  live-config \
  ...

# ✅ DEPOIS
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  live-build \
  live-config \  ← ubuntu-archive-keyring removido
  ...

# Tenta instalar ubuntu-archive-keyring (optional)
sudo apt-get install -y ubuntu-archive-keyring 2>/dev/null || \
  echo "⚠️  ubuntu-archive-keyring not available (non-critical)"
```

**Linha**: ~17-35

---

### Mudança 2: Clean Build (Step 7)
**Arquivo**: `.github/workflows/build.yml`

```yaml
# ❌ ANTES
- name: 🧹 Clean previous builds
  run: |
    rm -rf live-build
    lb clean --purge 2>/dev/null || true
    find . -maxdepth 1 -name "*.iso" -delete 2>/dev/null || true
    # Sem mkdir!

# ✅ DEPOIS
- name: 🧹 Clean previous builds
  run: |
    rm -rf live-build
    lb clean --purge 2>/dev/null || true
    find . -maxdepth 1 -name "*.iso" -delete 2>/dev/null || true
    mkdir -p live-build  ← ADICIONADO
```

**Linha**: ~196-217

---

### Mudança 3: Create Manifest (Step 13)
**Arquivo**: `.github/workflows/build.yml`

```yaml
# ❌ ANTES
- name: 📝 Create build manifest
  if: always()
  run: |
    echo "🔴 Creating build manifest..."
    cat > live-build/BUILD_MANIFEST.txt << EOF  ← Falha porque não existe

# ✅ DEPOIS
- name: 📝 Create build manifest
  if: always()
  run: |
    echo "🔴 Creating build manifest..."
    mkdir -p live-build  ← ADICIONADO (redundante mas seguro)
    cat > live-build/BUILD_MANIFEST.txt << EOF
```

**Linha**: ~347-352

---

## 🧪 Como Testar

1. **Commit as mudanças**:
   ```bash
   git add .github/workflows/build.yml
   git commit -m "🔴 Fix GitHub Actions: remove ubuntu-archive-keyring dependency"
   git push origin main
   ```

2. **Rodá o workflow**:
   - Vai em **Actions** no GitHub
   - Clica em **"Build SukunaOS ISO"**
   - Clica em **"Run workflow"**
   - Seleciona **main**
   - Clica em **"Run workflow"**

3. **Aguarda** 30-40 minutos ⏳

4. **Verifica logs**:
   - Se falhar novamente, vê qual step quebrou
   - Todos os logs estão em "Artifacts"

---

## ✅ Próximos Passos Esperados

Depois da correção, você deve ver:

```
✅ [STEP 5] Install live-build dependencies
   ...
   E: Package 'ubuntu-archive-keyring' has no installation candidate
   ⚠️  ubuntu-archive-keyring not available (non-critical)
   ✅ Dependencies installed successfully

✅ [STEP 7] Clean previous builds
   ✅ Clean complete

...

✅ [STEP 13] Create build manifest
   ✅ Manifest created

✅ Build completed successfully!
```

---

## 🐛 Se Ainda Não Funcionar

### Problema: Outro pacote não está disponível
**Solução**: Remove também do `apt-get install`

### Problema: Espaço insuficiente
**Solução**: GitHub Actions tem 30GB, deve ser suficiente. Se falhar:
- Clean artifacts antigos
- Tenta novamente

### Problema: `scripts/build_iso.sh` falha
**Solução**: Este é o script real de build. Se falhar aqui:
1. Verifica se `live/config/auto/config` existe
2. Verifica se estrutura do projeto está correta
3. Vê logs detalhados

---

## 📊 Resumo das Mudanças

| Item | Antes | Depois |
|------|-------|--------|
| **ubuntu-archive-keyring** | Obrigatório, falha | Opcional, funciona |
| **live-build dir** | Criado em Step 9 | Criado em Step 7 |
| **Manifest fallback** | Não tinha | Redundante no Step 13 |
| **Error handling** | Falha em erro | Graceful com `2>/dev/null` |

---

## 🎯 Status Atual

✅ **CORRIGIDO**:
- ubuntu-archive-keyring é agora opcional
- live-build/ criado mais cedo
- Manifest com mkdir redundante

🚀 **Pronto para próxima tentativa!**

---

**Data**: 2026-06-19  
**Revisão**: 2 correções críticas aplicadas  
**Status**: ✅ Pronto para rerun
