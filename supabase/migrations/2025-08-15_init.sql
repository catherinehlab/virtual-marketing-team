-- Supabase initial schema for Vitrual-marketing-team (Catherineh Lab)
create type approval_status as enum ('pending','approved','rejected','modified');

create table if not exists public.clients (
  id               text primary key,
  name             text not null,
  mode             text not null default 'hands_off',
  telegram_chat_id text,
  created_at       timestamptz default now()
);

create table if not exists public.approvals (
  id            bigserial primary key,
  client_id     text not null references public.clients(id) on delete cascade,
  kind          text not null,
  payload       jsonb not null,
  status        approval_status not null default 'pending',
  ttl_ts        timestamptz,
  resolved_at   timestamptz,
  resolved_by   text,
  created_at    timestamptz default now()
);
create index if not exists approvals_client_status_created_idx on public.approvals (client_id, status, created_at);

create table if not exists public.events (
  id         bigserial primary key,
  client_id  text not null references public.clients(id) on delete cascade,
  source     text not null,
  level      text not null default 'info',
  message    text not null,
  meta       jsonb,
  created_at timestamptz default now()
);
create index if not exists events_client_created_idx on public.events (client_id, created_at);

create table if not exists public.campaigns (
  id            bigserial primary key,
  client_id     text not null references public.clients(id) on delete cascade,
  channel       text not null,
  name          text not null,
  status        text not null default 'active',
  budget_daily  numeric,
  created_at    timestamptz default now()
);
create index if not exists campaigns_client_channel_idx on public.campaigns (client_id, channel);

create table if not exists public.metrics_daily (
  client_id       text not null references public.clients(id) on delete cascade,
  d               date not null,
  channel         text not null,
  clicks          numeric default 0,
  spend_krw       numeric default 0,
  conversions     numeric default 0,
  revenue_krw     numeric default 0,
  profile_clicks  numeric default 0,
  phone_clicks    numeric default 0,
  primary key (client_id, d, channel)
);
create index if not exists metrics_daily_client_d_idx on public.metrics_daily (client_id, d);

create table if not exists public.content_posts (
  id            bigserial primary key,
  client_id     text not null references public.clients(id) on delete cascade,
  platform      text not null,
  scheduled_at  timestamptz,
  status        text not null default 'planned',
  url           text,
  caption       text,
  metrics       jsonb,
  created_at    timestamptz default now()
);
create index if not exists content_posts_client_platform_idx on public.content_posts (client_id, platform, scheduled_at);

create table if not exists public.leads (
  id            bigserial primary key,
  client_id     text not null references public.clients(id) on delete cascade,
  source        text not null,
  company       text,
  contact       jsonb,
  details       jsonb,
  status        text not null default 'new',
  created_at    timestamptz default now()
);
create index if not exists leads_client_status_idx on public.leads (client_id, status, created_at);

create or replace view public.kpi_last_30d as
select
  client_id,
  coalesce(sum(conversions) filter (where channel in ('instagram','google','naver')),0) as total_conversions,
  coalesce(sum(profile_clicks),0) as total_profile_clicks,
  coalesce(sum(phone_clicks),0) as total_phone_clicks,
  coalesce(sum(spend_krw),0) as total_spend_krw
from public.metrics_daily
where d >= (current_date - interval '30 days')
group by client_id;

alter table public.clients         enable row level security;
alter table public.approvals       enable row level security;
alter table public.events          enable row level security;
alter table public.campaigns       enable row level security;
alter table public.metrics_daily   enable row level security;
alter table public.content_posts   enable row level security;
alter table public.leads           enable row level security;

insert into public.clients (id, name, mode) values ('catherineh-lab','Catherineh Lab','hands_off')
on conflict (id) do nothing;

