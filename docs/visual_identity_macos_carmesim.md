# 🔴 SukunaOS Visual Identity - Mac Carmesim Edition 🔴

> **Fusão de Design**: Elegância macOS + Poder Malevolente de Sukuna

## 📋 Paleta de Cores (RGB + Hex)

### Primárias - Carmesim Sukuna
| Nome | Hex | RGB | Propósito |
|------|-----|-----|-----------|
| **Crimson Puro** | `#C41020` | `196, 16, 32` | Marca principal, botões primários, focos |
| **Crimson Escuro** | `#A50D1A` | `165, 13, 26` | Profundidade, sombras, estados ativos |
| **Glow Vermelho** | `#FF1A33` | `255, 26, 51` | Destaque, animações, estados hover |

### Ouro Sagrado - Seals & Boundaries
| Nome | Hex | RGB | Propósito |
|------|-----|-----|-----------|
| **Ouro Claro** | `#D4A84A` | `212, 168, 74` | Títulos, dividers, acentos |
| **Ouro Escuro** | `#9D7A2F` | `157, 122, 47` | Sombras de ouro, contexto |

### Fundos - Shrine Void
| Nome | Hex | RGB | Propósito |
|------|-----|-----|-----------|
| **Void Puro** | `#0A0304` | `10, 3, 4` | Fundo base supremo |
| **Void Kamado** | `#140708` | `20, 7, 8` | Superfícies, cards |
| **Void Elevado** | `#1D0A0F` | `29, 10, 15` | Inputs, tabelas, componentes |
| **Void Hover** | `#2A1115` | `42, 17, 21` | Estados hover, focus |
| **Void Active** | `#351620` | `53, 22, 32` | Estados pressionados |

### Texto - Parchment & Translucência
| Nome | Hex | RGB | Propósito |
|------|-----|-----|-----------|
| **Primário** | `#F0E6DB` | `240, 230, 219` | Corpo de texto |
| **Secundário** | `#B89F8F` | `184, 159, 143` | Labels, subtítulos |
| **Terciário** | `#6D5550` | `109, 85, 80` | Placeholders, desabilitado |

### Semânticas
| Estado | Cor | Uso |
|--------|-----|-----|
| **Sucesso** | `#2D8A4E` | Confirmação, valid |
| **Aviso** | `#D4A84A` | Atenção, warning |
| **Erro** | `#C41020` | Crítico, danger |
| **Perigo** | `#FF1A33` | Ação irreversível |

---

## 🎨 Tipografia - Mac SF Pro + Parchment Style

### Fontes Recomendadas
```
Primária:   SF Pro Display (macOS native) / Inter / IBM Plex Sans
Secundária: SF Pro Display (weights: 400, 500, 600, 700)
Monospace:  Cascadia Code / Fira Code / Inconsolata
```

### Hierarquia de Tamanhos
```
H1 (Títulos Principais)      → 28px, 700 weight, tracking -0.5px
H2 (Seções)                  → 22px, 600 weight, tracking -0.3px
H3 (Subtítulos)              → 17px, 600 weight, tracking -0.2px
Body (Padrão)                → 13px, 400 weight
Secondary (Labels)           → 12px, 500 weight
Caption (Placeholder)        → 11px, 400 weight
Mono (Code)                  → 12px, 400 weight
```

### Linha (Line Height)
- **H1-H3**: 1.2x (títulos compactos)
- **Body**: 1.5x (legibilidade)
- **Code**: 1.6x (scanning)

---

## 🎭 Componentes & Estilo

### Botões
#### Primário (Cursed Red)
```css
background: linear-gradient(135deg, #FF1A33, #A50D1A)
color: #F0E6DB
border: none
border-radius: 8px
padding: 10px 28px
font--weight: 600
transition: all 0.2s ease
box-shadow: 0 4px 16px rgba(196, 16, 32, 0.4)

hover: shadow increase, glow effect
```

#### Gold (Sacred Seal)
```css
background: transparent
color: #D4A84A
border: 1.5px solid #D4A84A
border-radius: 8px
padding: 10px 28px

hover: background rgba(212, 168, 74, 0.08), color shift to #FF1A33
```

#### Secundário
```css
background: #140708
color: #F0E6DB
border: 1px solid #2A1115
border-radius: 8px
padding: 8px 20px

hover: border-color #C41020
```

### Inputs & Fields
```css
background: #1D0A0F
color: #F0E6DB
border: 1px solid #2A1015
border-radius: 8px
padding: 10px 14px
font-size: 13px

focus: border 1.5px solid #C41020, background #2A1115
placeholder: color #6D5550
disabled: background #0A0304, color #6D5550
```

### Cards & Surfaces
```css
background: #140708
border: 1px solid #2A1015
border-radius: 12px
padding: 20px 16px
box-shadow: 0 2px 8px rgba(0, 0, 0, 0.4)

hover: border-color light increase, shadow increase
```

### Badges & Tags
```
Sucesso:   bg #2D8A4E, text #F0E6DB, border-radius 6px
Aviso:     bg #D4A84A, text #0A0304, border-radius 6px
Erro:      bg #C41020, text #F0E6DB, border-radius 6px
```

### Separadores & Borders
```css
Subtle:    #2A1015 (1px)
Focus:     #C41020 (1.5px)
Gold:      #D4A84A55 (translucent, 1.5px)
```

---

## 🎬 Animações & Transições

### Durações Padrão
- **Quick feedback**: 150ms (button click, hover)
- **Smooth transition**: 250ms (panel slide, fade)
- **Extended**: 400ms (major layout changes)

### Easing
- **Normal**: `ease-in-out` (interactive elements)
- **Linear**: `linear` (progress bars, loading)
- **Ease-out**: `ease-out` (entrance animations)

### Exemplos
```css
/* Button Hover */
transition: all 150ms ease-in-out;
transform: scale(1.02);
box-shadow: 0 8px 24px rgba(196, 16, 32, 0.3);

/* Panel Slide */
transition: transform 250ms ease-in-out;
transform: translateX(-100%);

/* Loading Glow */
animation: glow 2s ease-in-out infinite;
@keyframes glow {
    0%, 100% { box-shadow: 0 0 8px #C41020; }
    50% { box-shadow: 0 0 24px #FF1A33; }
}
```

---

## 📐 Spacing & Layout

### Escala de Espaçamento (8px base)
```
xs: 4px   (minimal padding)
sm: 8px   (default padding)
md: 12px  (component spacing)
lg: 16px  (section spacing)
xl: 20px  (major sections)
2xl: 24px (page margins)
3xl: 32px (viewport gaps)
```

### Arredondamento de Cantos
```
sm: 4px    (small elements, badges)
md: 8px    (buttons, inputs)
lg: 12px   (cards, panels)
xl: 16px   (major containers)
```

---

## 🖼️ Ícones

### Estilo
- **Peso**: 2px stroke (macOS-style)
- **Tamanho**: 16px (UI), 24px (header), 32px (hero)
- **Cantos**: Levemente arredondados
- **Cores**:
  - Primário: `#F0E6DB`
  - Accent: `#D4A84A` ou `#C41020`
  - Disabled: `#6D5550`

### Exemplos Sukuna
- ⚔️ **Cleave/Dismantle**: Dois traços horizontais cruzados
- 🏯 **Shrine**: Torii gate silhueta
- 🔴 **Domain**: Círculo com marca vermelha
- ⭐ **Seal**: Estrela com ouro

---

## 📱 Responsividade

### Breakpoints
```
Mobile:   < 640px   (single column, large touch targets)
Tablet:   640-1024px (two columns, medium padding)
Desktop:  > 1024px  (multi-column, full spacing)
```

### Adaptações
- Buttons: min-height 44px (mobile touch)
- Padding: lg on mobile, xl on desktop
- Font: +1px on desktop (readability)

---

## 🌙 Modo Dark (Padrão) vs Light (Futuro)

### Dark (Current)
- Fundos: Void (#0A0304 → #351620)
- Texto: Parchment (#F0E6DB)
- Acentos: Crimson & Ouro (inalterados)

### Light (Roadmap)
- Fundos: Parchment (#F0E6DB → #F9F5F0)
- Texto: Void (#0A0304)
- Acentos: Crimson mais claro (#E8142A), Ouro mais claro

---

## 🎯 Referências Sukuna Específicas

### Visual Motifs
1. **Marks (Marcas)** - Linhas vermelhas e ouro como separadores
2. **Shrine** - Torii gates como ícones, backgrounds com shrines
3. **Domain** - Círculos concêntricos para expandir interações
4. **Seals** - Gold badges com padrões geométricos
5. **Cursed Energy** - Glow efeitos em vermelho/ouro

### Copy/Text Themes
```
"Expandir Domínio"      → [Action button]
"Maldição Selada"       → [Protected/locked state]
"Energia Amaldiçoada"   → [Loading/processing]
"Ritual Concluído"      → [Success]
"Domínio Quebrado"      → [Error/critical]
```

---

## 📝 Exemplos de Implementação

### React Component (styled-components)
```jsx
import styled from 'styled-components';

const ButtonPrimary = styled.button`
  background: linear-gradient(135deg, #FF1A33, #A50D1A);
  color: #F0E6DB;
  border: none;
  border-radius: 8px;
  padding: 10px 28px;
  font-weight: 600;
  transition: all 150ms ease-in-out;
  box-shadow: 0 4px 16px rgba(196, 16, 32, 0.4);
  
  &:hover {
    box-shadow: 0 8px 24px rgba(196, 16, 32, 0.6);
    transform: scale(1.02);
  }
  
  &:active {
    transform: scale(0.98);
  }
`;
```

### QSS (Qt StyleSheets)
```qss
QPushButton[accessibleName="primary"] {
    background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
        stop:0 #FF1A33, stop:1 #A50D1A);
    color: #F0E6DB;
    border: none;
    border-radius: 8px;
    padding: 10px 28px;
    font-weight: 600;
}

QPushButton[accessibleName="primary"]:hover {
    background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
        stop:0 #FF3355, stop:1 #C41020);
}
```

---

## ✅ Design Checklist

- [ ] Todos os fundos usam paleta Void (#0A0304-#351620)
- [ ] Todos os textos primários #F0E6DB
- [ ] Botões primários usam gradiente Crimson
- [ ] Acentos importante use #D4A84A (Ouro)
- [ ] Separadores usam #2A1015 (Void Sutil)
- [ ] Transições 150-400ms com easing apropriado
- [ ] Espaçamento múltiplo de 8px
- [ ] Cantos arredondados 8-16px (não sharp)
- [ ] Sombras subtis (rgba preto com 0.4 opacity)
- [ ] Touch targets mínimo 44px (mobile)
- [ ] Hover/focus estados sempre vísíveis
- [ ] Referências visuais Sukuna (marcas, shrine, domain)

---

## 🔴 Brand Voice

**Slogan**: "A Maldição Eterna governa... e o domínio reina supremo"

**Tone**: Elegante, poderoso, um pouco malevolente, mas acessível
- Usar "Domínio" em vez de "Desktop"
- "Maldição" para erros críticos (dramaticamente)
- "Ritual" para processos de build/setup
- "Marca" para ações importantes
- "Santuário" para home/main screen

**Exemplo de Copy**:
- ✅ "Expandir Domínio e instalar?"
- ✅ "Energia Amaldiçoada processando..."
- ❌ "Installing..." (muito genérico)
- ❌ "Desktop" (use "Domínio" instead)

---

**Versão**: 1.0  
**Última atualização**: June 2026  
**Manutenido por**: Sukuna OS Team 🔴
