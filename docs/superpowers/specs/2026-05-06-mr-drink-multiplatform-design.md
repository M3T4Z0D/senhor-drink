# Design Spec: Mr. Drink - O Mixologista Social

**Data:** 2026-05-06  
**Revisado:** 2026-06-25  
**Status:** Aprovado para implementação  
**Autor:** Gemini CLI & User  
**Revisor:** Claude Code & User  

## 1. Visão Geral
Evolução do projeto "Mr. Drink" de um site estático para um ecossistema multiplataforma (Mobile e Web). O foco é transformar a busca de drinks em uma experiência social e inteligente, permitindo que usuários criem, compartilhem listas e usem IA para criar novas receitas.

## 2. Tecnologias (Stack)

| Camada | Tecnologia | Notas |
|---|---|---|
| Frontend | Flutter (Dart) | Alvo: Android, iOS e Web |
| State Management | Riverpod | Padrão moderno; integração limpa com Supabase streams |
| Backend/DB | Supabase | Auth + PostgreSQL + Edge Functions |
| Cache de imagens | cached_network_image | Pacote padrão Flutter |
| Cache offline | Hive | Cache local de listas favoritas |
| API de Drinks | TheCocktailDB | Dados core de drinks |
| IA | Google Gemini API | Chamadas via Supabase Edge Functions (chave nunca exposta no client) |

### Autenticação
E-mail/Senha via Supabase Auth.

## 3. Modelo de Dados (Supabase)

### Tabela: `profiles`
| Coluna | Tipo | Notas |
|---|---|---|
| `id` | uuid | PK, link com auth.users |
| `username` | text | unique |
| `bio` | text | |
| `avatar_url` | text | |

### Tabela: `drink_lists`
| Coluna | Tipo | Notas |
|---|---|---|
| `id` | uuid | PK |
| `user_id` | uuid | FK → profiles |
| `name` | text | |
| `description` | text | |
| `is_public` | boolean | default: false |
| `created_at` | timestamp | |

### Tabela: `list_items`
| Coluna | Tipo | Notas |
|---|---|---|
| `id` | uuid | PK |
| `list_id` | uuid | FK → drink_lists |
| `external_drink_id` | text | ID da TheCocktailDB (nullable) |
| `custom_drink_id` | uuid | FK → custom_drinks (nullable) |

> **Regra:** exatamente uma das duas colunas de drink deve ser não-nula.

### Tabela: `custom_drinks`
| Coluna | Tipo | Notas |
|---|---|---|
| `id` | uuid | PK |
| `user_id` | uuid | FK → profiles |
| `name` | text | |
| `ingredients` | jsonb | Array de `{name, measure}` |
| `instructions` | text | |
| `image_url` | text | opcional |

### Tabela: `ai_conversations`
| Coluna | Tipo | Notas |
|---|---|---|
| `id` | uuid | PK |
| `user_id` | uuid | FK → profiles |
| `role` | text | `'user'` ou `'assistant'` |
| `content` | text | Mensagem |
| `created_at` | timestamp | Para ordenação do histórico |

## 4. Funcionalidades Principais (MVP)

### 4.1. Busca e Descoberta
- Busca por nome de drink.
- Gerador de Drink Aleatório.
- Feed de Listas Públicas (Social) — visível mesmo sem login.

### 4.2. Gestão de Listas
- Criação de múltiplas listas por usuário (requer login).
- Opção de tornar lista "Pública" para compartilhamento via deep link.

### 4.3. Guru IA (Assistente de Mixologia)
- Chat interativo com Google Gemini para sugestões baseadas em ingredientes disponíveis.
- Histórico de conversa persistido no Supabase (`ai_conversations`).
- Botão "Salvar na Lista" para receitas geradas pela IA.
- A chave do Gemini nunca é exposta no client — todas as chamadas passam por uma Supabase Edge Function.

## 5. Navegação (UI)

**Padrão:** Bottom Navigation Bar com 4 itens principais. A tela de Perfil/Biblioteca é acessada via ícone no topo da Home.

| Tab | Ícone | Tela |
|---|---|---|
| Home | 🏠 | Busca + Aleatório + Destaques |
| Explorar | 🧭 | Feed de listas públicas |
| Guru IA | 🤖 | Chat de mixologia |
| Biblioteca | 📚 | Minhas listas + Perfil |

### Fluxo de telas
1. **Splash / Auth:** Login ou Signup via Supabase. Usuários não autenticados podem ver Home e Explorar.
2. **Home:** Campo de busca por nome, botão "Aleatório", cards de destaques da comunidade.
3. **Detalhe do Drink:** Foto, ingredientes, modo de preparo, botão "Adicionar a uma lista".
4. **Explorar:** Feed paginado de listas públicas.
5. **Guru IA:** Interface de chat; histórico carregado do Supabase ao abrir.
6. **Biblioteca:** Lista de `drink_lists` do usuário autenticado + opção de criar nova.
7. **Perfil:** Edição de `username`, `bio`, `avatar_url`.

## 6. Requisitos Não Funcionais

| Requisito | Abordagem |
|---|---|
| Performance de imagens | `cached_network_image` com cache em disco |
| Segurança da chave IA | Supabase Edge Function; RLS ativado em todas as tabelas |
| Offline | Hive para cache local de listas favoritas |
| Autoria de dados | Row Level Security (RLS) garante que apenas o dono edite suas listas/drinks |

## 7. Fases de Implementação (Sugeridas)

### Fase 1 — Fundação
- [ ] Criar projeto Flutter com estrutura de pastas e Riverpod
- [ ] Configurar Supabase: criar projeto, tabelas e RLS
- [ ] Implementar Auth (Login/Signup)
- [ ] Navegação entre as 4 tabs

### Fase 2 — Core de Drinks
- [ ] Integração com TheCocktailDB
- [ ] Telas Home e Detalhe do Drink
- [ ] Tela Explorar (feed de listas públicas)

### Fase 3 — Listas
- [ ] CRUD de drink_lists e list_items
- [ ] Deep link de compartilhamento de lista pública

### Fase 4 — Guru IA
- [ ] Supabase Edge Function para Gemini API
- [ ] Tela de chat com histórico persistido
- [ ] Fluxo "Salvar na Lista" a partir do chat

### Fase 5 — Polimento
- [ ] Cache offline com Hive
- [ ] Perfil do usuário
- [ ] Testes e ajustes de UX

---

## 8. Checklist de Revisão
- [x] Stack definida com justificativas
- [x] State management escolhido (Riverpod)
- [x] Ambiguidade de `drink_id` resolvida (colunas separadas)
- [x] Persistência do histórico IA definida (Supabase)
- [x] Segurança da chave Gemini garantida (Edge Function)
- [x] Navegação definida (Bottom Nav Bar)
- [x] Fases de implementação sequenciadas
