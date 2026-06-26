-- Controle de onboarding por usuário
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS onboarding_completed boolean DEFAULT false;

-- Usuários existentes já usaram o app — marcar como concluído
UPDATE public.profiles SET onboarding_completed = true;
