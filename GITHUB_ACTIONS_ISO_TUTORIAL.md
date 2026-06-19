# 🔴 Como Fazer Build da ISO pelo GitHub Actions

**O jeito MAIS fácil! Seu PC não faz nada, o GitHub faz tudo!** ✨

---

## 🎯 Resumo Rápido

1. Clique em **Actions**
2. Espere **30-40 minutos**
3. Baixa o ISO
4. Pronto! 🎉

---

## 📱 Passo a Passo (Com Prints Mentais)

### **Passo 1️⃣: Ter Conta no GitHub**

Se não tiver:
1. Abra: https://github.com
2. Clique em **"Sign up"** (canto superior direito)
3. Complete o formulário (email, senha, nome de usuário)
4. Confirme seu email
5. Pronto! ✅

---

### **Passo 2️⃣: Entrar no Repositório**

1. Abra: https://github.com/sukunaofficial2-gif/sukuna0s
2. Você vai ver o código do SukunaOS
3. Perfeito!

---

### **Passo 3️⃣: Ir para Actions**

1. No topo da página, clique na aba **"Actions"**
2. Você vai ver uma lista de "workflows" (tarefas automáticas)
3. Procure por: **"Build SukunaOS ISO"**

---

### **Passo 4️⃣: Rodar o Build**

**Opção A - Se conseguir clicar em Run Workflow:**

1. Clique no workflow **"Build SukunaOS ISO"**
2. Clique no botão **"Run workflow"** (verde, lado direito)
3. Deixa as opções padrão
4. Clique em **"Run workflow"** novamente
5. ⏳ **Aguarde 30-40 minutos**

**Opção B - Se o workflow rodar automaticamente:**

1. Clique no workflow mais recente
2. Veja a status (pode ser amarelo 🟨, azul 🔵 ou verde ✅)
3. Quando ficar verde, tá pronto!

---

### **Passo 5️⃣: Acompanhar o Progresso**

1. Clique no workflow que está rodando
2. Você vê todos os "jobs" (tarefas)
3. Cada job mostra o que está fazendo:
   - 📦 `Setup environment` - Preparando o PC
   - 🔨 `Build ISO` - Compilando tudo
   - 📤 `Upload artifact` - Salvando o resultado
4. Quando todos ficarem ✅ verde, tá feito!

---

### **Passo 6️⃣: Baixar a ISO**

1. Entra de novo no workflow que passou ✅
2. Desce até o final da página
3. Procura por **"Artifacts"** (você vai ver uma seção com um ícone 📦)
4. Clica em **"sukunaos-iso"**
5. Seu navegador baixa automaticamente o arquivo
6. Você tem a ISO! 🎉

---

## 💾 Você Agora Tem o Arquivo

Seu download vai ter um nome tipo:
- `sukunaos-iso.zip` ou
- `live-image-amd64.iso`

**Pronto para usar!**

---

## 🚀 O Que Fazer Agora?

### Opção 1: Testar em Máquina Virtual (Seguro ✅)

```
VirtualBox:
1. Baixe: https://www.virtualbox.org
2. Instale e abra
3. Clique em "New"
4. Configure:
   - RAM: 4 GB
   - Disk: 30 GB
   - Boot: UEFI
5. Escolha seu ISO
6. Clique "Start"
7. Aproveite!
```

### Opção 2: Pen Drive (Para PC Real)

```
Balena Etcher (Mais Fácil):
1. Baixe: https://www.balena.io/etcher/
2. Abra Etcher
3. "Select Image" → Seu ISO
4. "Select Drive" → Seu Pen Drive
5. "Flash"
6. Aguarde terminar
7. Pronto! Pen drive bootável 🚀
```

---

## 🆘 Problemas Comuns

### "Não consigo ver o Actions"

- Você fez login no GitHub?
- Tá no repositório certo?
- Tenta atualizar a página (`F5`)

### "O workflow não roda ou não existe"

- Pode não estar criado ainda
- Você precisa criar um workflow `.yml` em `.github/workflows/`
- Ou tenta abrir uma **Issue**: https://github.com/sukunaofficial2-gif/sukuna0s/issues
- Ou manda mensagem pro dono

### "Travou no 50%"

- GitHub Actions tem timeout de 6 horas (muito tempo)
- Normalmente builds levam 30-40 minutos
- Se passar de 2 horas, pode cancelar e tentar novamente

### "Não achei o Artifacts"

- Desce bem para o final da página
- Procura por um ícone de caixa (📦)
- Se não tiver, o build provavelmente falhou (procura por ❌ vermelho)

### "Baixou mas é .zip"

- Descompacte em qualquer lugar
- Procura pelo arquivo `.iso` dentro
- Pronto!

---

## ⏱️ Quanto Tempo Vai Levar?

| Etapa | Tempo |
|-------|-------|
| Setup environment | 2-3 min |
| Install dependencies | 3-5 min |
| Download packages | 5-10 min |
| Build ISO | 15-20 min |
| Upload artifact | 2-3 min |
| **TOTAL** | **~30-40 min** |

**Você não precisa ficar de olho!** Pode fazer outra coisa. GitHub manda notificação quando termina (se configurar).

---

## ✅ Checklist

- [ ] Tem conta no GitHub
- [ ] Entrou no repositório SukunaOS
- [ ] Abriu a aba "Actions"
- [ ] Rodou o workflow "Build SukunaOS ISO"
- [ ] Aguardou passar de 30 minutos
- [ ] Viu ✅ verde em todos os jobs
- [ ] Baixou o arquivo em "Artifacts"
- [ ] Tem o arquivo `.iso` no seu PC

---

## ⚠️ Se Não Tiver Workflows

Se a aba Actions estiver vazia, o workflow ainda não foi criado. Nesse caso:

1. Contacte o dono do repositório
2. Ou crie você mesmo (avançado):
   - Clique em "Set up a workflow yourself"
   - Copie um workflow de build ISO
   - Commit e pronto!

## 🎓 Pronto!

Agora você tem a ISO do SukunaOS! 

**Próximos passos:**
1. Teste em VirtualBox (seguro)
2. Ou coloque em pen drive com Etcher
3. Boot em hardware real
4. Aproveite! 🔴✨

---

**Última atualização**: 2026-06-19  
**Status**: ✅ Testado e simples!  
**Tempo**: ~40 minutos do início ao fim

Boa sorte! 🚀
