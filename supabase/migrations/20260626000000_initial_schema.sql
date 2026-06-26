-- Migration: initial_schema
-- Cria todas as tabelas do Mr. Drink com RLS

-- =============================================
-- TABELAS
-- =============================================

-- Profiles (extensão do auth.users)
CREATE TABLE profiles (
  id uuid PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  username text UNIQUE NOT NULL,
  bio text,
  avatar_url text,
  created_at timestamptz DEFAULT now()
);

-- Drink lists do usuário
CREATE TABLE drink_lists (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  is_public boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Itens de cada lista
CREATE TABLE list_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  list_id uuid NOT NULL REFERENCES drink_lists ON DELETE CASCADE,
  external_drink_id text,          -- ID da TheCocktailDB
  custom_drink_id uuid,            -- FK para custom_drinks
  CONSTRAINT one_drink_source CHECK (
    (external_drink_id IS NOT NULL)::int + (custom_drink_id IS NOT NULL)::int = 1
  )
);

-- Drinks criados pelo usuário (via IA ou manualmente)
CREATE TABLE custom_drinks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles ON DELETE CASCADE,
  name text NOT NULL,
  ingredients jsonb NOT NULL DEFAULT '[]',
  instructions text,
  image_url text,
  created_at timestamptz DEFAULT now()
);

-- FK de list_items → custom_drinks (criada depois da tabela)
ALTER TABLE list_items
  ADD CONSTRAINT list_items_custom_drink_id_fkey
  FOREIGN KEY (custom_drink_id) REFERENCES custom_drinks ON DELETE SET NULL;

-- Histórico de chat com a IA
CREATE TABLE ai_conversations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles ON DELETE CASCADE,
  role text NOT NULL CHECK (role IN ('user', 'assistant')),
  content text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- =============================================
-- ROW LEVEL SECURITY
-- =============================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Perfil visível para todos"          ON profiles FOR SELECT USING (true);
CREATE POLICY "Usuário edita só o próprio perfil"  ON profiles FOR ALL    USING (auth.uid() = id);

ALTER TABLE drink_lists ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Listas públicas visíveis para todos" ON drink_lists FOR SELECT
  USING (is_public = true OR auth.uid() = user_id);
CREATE POLICY "Usuário gerencia suas listas"        ON drink_lists FOR ALL
  USING (auth.uid() = user_id);

ALTER TABLE list_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Itens visíveis se lista for pública ou do dono" ON list_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM drink_lists dl
      WHERE dl.id = list_id AND (dl.is_public = true OR dl.user_id = auth.uid())
    )
  );
CREATE POLICY "Dono da lista gerencia os itens" ON list_items FOR ALL
  USING (
    EXISTS (SELECT 1 FROM drink_lists dl WHERE dl.id = list_id AND dl.user_id = auth.uid())
  );

ALTER TABLE custom_drinks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Custom drinks visíveis para o dono"  ON custom_drinks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Usuário gerencia seus custom drinks" ON custom_drinks FOR ALL    USING (auth.uid() = user_id);

ALTER TABLE ai_conversations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Usuário vê só suas conversas" ON ai_conversations FOR ALL USING (auth.uid() = user_id);

-- =============================================
-- TRIGGER: cria perfil automaticamente no signup
-- =============================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  base_username text;
BEGIN
  base_username := SPLIT_PART(NEW.email, '@', 1);

  INSERT INTO public.profiles (id, username)
  VALUES (NEW.id, base_username)
  ON CONFLICT (username) DO UPDATE
    SET username = base_username || '_' || SUBSTRING(NEW.id::text, 1, 8);

  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =============================================
-- GRANTS
-- "Automatically expose new tables" foi desabilitado na criação do projeto,
-- então é necessário conceder permissões manualmente.
-- =============================================

GRANT SELECT, INSERT, UPDATE, DELETE ON public.profiles         TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.drink_lists      TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.list_items       TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.custom_drinks    TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.ai_conversations TO authenticated;

GRANT SELECT ON public.profiles    TO anon;
GRANT SELECT ON public.drink_lists TO anon;
GRANT SELECT ON public.list_items  TO anon;
