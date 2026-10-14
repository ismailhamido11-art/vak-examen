-- Pile de l'examen (13/10 ; examen du 11/10 : RLS par niveau MFA de supabase_nextjs_template) : auth.mfa_factors et ses
-- types, forme des migrations de GoTrue, si le vak de l'app ne les a pas posés (vak localdb les pose depuis la 0.28.0).
-- Aucun facteur : A et B se connectent par mot de passe (aal1, relais.mjs). Rejouable : rien ne change s'ils existent.
set client_min_messages = warning;
do $$
begin
  create type auth.factor_type as enum ('totp', 'webauthn', 'phone');
exception when duplicate_object then null;
end;
$$;
do $$
begin
  create type auth.factor_status as enum ('unverified', 'verified');
exception when duplicate_object then null;
end;
$$;
do $$
begin
  create type auth.aal_level as enum ('aal1', 'aal2', 'aal3');
exception when duplicate_object then null;
end;
$$;

create table if not exists auth.mfa_factors (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  friendly_name text,
  factor_type auth.factor_type not null,
  status auth.factor_status not null,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  secret text,
  phone text unique,
  last_challenged_at timestamptz unique,
  web_authn_credential jsonb,
  web_authn_aaguid uuid
);
create unique index if not exists mfa_factors_user_friendly_name_unique on auth.mfa_factors (friendly_name, user_id) where trim(friendly_name) <> '';
alter table auth.mfa_factors enable row level security;
grant select on auth.mfa_factors to postgres;
