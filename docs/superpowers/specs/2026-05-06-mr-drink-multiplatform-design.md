# Design Spec: Mr. Drink - O Mixologista Social

**Data:** 2026-05-06  
**Status:** Draft  
**Autor:** Gemini CLI & User  

## 1. Visão Geral
Evolução do projeto "Mr. Drink" de um site estático para um ecossistema multiplataforma (Mobile e Web). O foco é transformar a busca de drinks em uma experiência social e inteligente, permitindo que usuários criem, compartilhem listas e usem IA para criar novas receitas.

## 2. Tecnologias (Stack)
- **Frontend:** Flutter (Dart) - Alvo: Android, iOS e Web.
- **Backend/DB:** Supabase
  - **Auth:** E-mail/Senha.
  - **Database:** PostgreSQL (Firestore-like via PostgREST).
  - **Edge Functions:** Para chamadas seguras à API de IA.
- **API de Drinks:** TheCocktailDB (ou similar) para dados core.
- **IA:** Google Gemini API (via Supabase Edge Functions).

## 3. Modelo de Dados (Supabase)

### Tabela: `profiles`
- `id`: uuid (PK, link com auth.users)
- `username`: text (unique)
- `bio`: text
- `avatar_url`: text

### Tabela: `drink_lists`
- `id`: uuid (PK)
- `user_id`: uuid (FK profiles)
- `name`: text
- `description`: text
- `is_public`: boolean (default: false)
- `created_at`: timestamp

### Tabela: `list_items`
- `id`: uuid (PK)
- `list_id`: uuid (FK drink_lists)
- `drink_id`: text (ID da API externa ou ID do drink customizado)
- `is_custom`: boolean (default: false)

### Tabela: `custom_drinks` (Para drinks gerados por IA ou criados pelo usuário)
- `id`: uuid (PK)
- `user_id`: uuid (FK profiles)
- `name`: text
- `ingredients`: jsonb
- `instructions`: text
- `image_url`: text (opcional)

## 4. Funcionalidades Principais

### 4.1. Busca e Descoberta
- Busca por nome e filtro por ingredientes.
- Gerador de Drink Aleatório.
- Feed de Listas Públicas (Social).

### 4.2. Gestão de Listas
- Criação de múltiplas pastas/listas.
- Opção de tornar lista "Pública" para compartilhamento via link único.

### 4.3. Guru IA (Assistente de Mixologia)
- Chat interativo para sugestões baseadas em ingredientes disponíveis.
- Botão "Salvar na Lista" para receitas geradas pela IA.

## 5. Fluxo de UI (Telas)
1. **Login/Signup:** Autenticação via Supabase.
2. **Home:** Busca, Aleatórios e Destaques da Comunidade.
3. **Explorar:** Feed de listas públicas de outros mixologistas.
4. **Guru IA:** Interface de chat para criação assistida.
5. **Minha Biblioteca:** Gestão de listas e perfil.

## 6. Requisitos Não Funcionais
- **Performance:** Carregamento de imagens via cache.
- **Segurança:** Row Level Security (RLS) no Supabase para garantir que apenas donos editem suas listas.
- **Offline:** Cache local de listas favoritas.

---

## 7. Auto-Revisão (Checklist)
- [x] Placeholder scan: Nenhum "TBD" crítico.
- [x] Consistência interna: Arquitetura Flutter casa com as tabelas Supabase.
- [x] Escopo: Focado em MVP social e inteligente.
- [x] Ambiguidade: Definição clara entre drinks de API e Customizados.
