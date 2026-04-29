-- =============================================================
-- Dashboard Avanço Semanal — Schema Supabase
-- Execute este arquivo no SQL Editor do seu projeto Supabase
-- =============================================================


-- ─────────────────────────────────────────
-- 1. TABELAS
-- ─────────────────────────────────────────

CREATE TABLE cards (
  id               TEXT PRIMARY KEY,       -- slug único, ex: "preliminares"
  theme            TEXT NOT NULL,          -- "teal" | "orange" | "olive"
  emoji            TEXT,
  title            TEXT NOT NULL,
  title_sub        TEXT,
  sub_label        TEXT,
  meta_semana      INTEGER DEFAULT 0,
  meta_val         INTEGER DEFAULT 0,
  avanco           INTEGER DEFAULT 0,
  avanco_acumulado INTEGER DEFAULT 0,
  message          TEXT,
  msg_footer_label TEXT,
  sort_order       INTEGER DEFAULT 0,      -- controla a ordem de exibição dos cards
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE activities (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  card_id    TEXT NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
  icon       TEXT,
  name       TEXT NOT NULL,
  real_val   NUMERIC DEFAULT 0,   -- renomeado de "real" (palavra reservada no PostgreSQL)
  meta       NUMERIC DEFAULT 0,
  pct        NUMERIC,             -- NULL = calcular automaticamente no frontend
  na         BOOLEAN DEFAULT FALSE,
  is_percent BOOLEAN DEFAULT FALSE,
  position   INTEGER DEFAULT 0,   -- controla a ordem das atividades dentro do card
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_activities_card_id ON activities(card_id);


-- ─────────────────────────────────────────
-- 2. ROW LEVEL SECURITY (RLS)
-- ─────────────────────────────────────────

ALTER TABLE cards      ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;

-- Leitura pública: qualquer visitante pode ver os dados
CREATE POLICY "Public read cards"
  ON cards FOR SELECT
  USING (true);

CREATE POLICY "Public read activities"
  ON activities FOR SELECT
  USING (true);

-- Escrita restrita: apenas usuários autenticados podem modificar
CREATE POLICY "Auth write cards"
  ON cards FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Auth write activities"
  ON activities FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');


-- ─────────────────────────────────────────
-- 3. SEED — dados iniciais
-- ─────────────────────────────────────────

INSERT INTO cards
  (id, theme, emoji, title, title_sub, sub_label,
   meta_semana, meta_val, avanco, avanco_acumulado,
   message, msg_footer_label, sort_order)
VALUES
  (
    'preliminares', 'teal', '🍀', 'PRELIMINARES', '(PRELIMINARY)', 'SUB-ATIVIDADES:',
    4, 6, 9, 104,
    'Avanço excelente nos acessos e áreas específicas! Vamos manter o ritmo para o fechamento.',
    NULL, 1
  ),
  (
    'obracivil', 'orange', '🚧', 'OBRA CIVIL', '(CIVIL WORKS)', NULL,
    13, 12, 12, 94,
    'Atenção especial ao cronograma de concretagem! Próxima semana é crucial!.',
    NULL, 2
  ),
  (
    'montagem', 'olive', '🔩', 'MONTAGEM', '(ASSEMBLY)', NULL,
    12, 12, 10, 83,
    'Bom progresso no transporte e pré-montagem. Vamos manter o ritmo para o fechamento das frentes!',
    'MENSAGEM DA SEMANA', 3
  );

INSERT INTO activities (card_id, icon, name, real_val, meta, pct, na, is_percent, position)
VALUES
  -- PRELIMINARES
  ('preliminares', '🛣️', 'ACESSO',         9,   6,   NULL, false, false, 0),
  ('preliminares', '🪓', 'SUPRESSÃO',      7,   9,   NULL, false, false, 1),
  ('preliminares', '🚜', 'ÁREA DE TORRE',  20,  14,  NULL, false, false, 2),
  ('preliminares', '🌳', 'CORTE SELETIVO', 11,  16,  NULL, false, false, 3),
  -- OBRA CIVIL
  ('obracivil', '⛏️', 'ESCAVAÇÃO',   12,  13,  NULL, false, false, 0),
  ('obracivil', '🟫', 'REATERRO',    100, 100, NULL, false, false, 1),
  ('obracivil', '⚡', 'CONTRA PESO', 6,   12,  NULL, false, false, 2),
  ('obracivil', '📋', 'ENSAIOS',     16,  12,  NULL, false, false, 3),
  -- MONTAGEM
  ('montagem', '🚚', 'TRANSPORTE',   11, 14, NULL, false, false, 0),
  ('montagem', '🔧', 'PRÉ-MONTAGEM', 10, 12, NULL, false, false, 1),
  ('montagem', '🏗️', 'MONTAGEM',     0,  10, NULL, false, false, 2),
  ('montagem', '🔍', 'REVISÃO',      0,  10, NULL, false, false, 3);


-- ─────────────────────────────────────────
-- COMO ADICIONAR / REMOVER DADOS NO FUTURO
-- ─────────────────────────────────────────
--
-- Novo card:
--   INSERT INTO cards (id, theme, emoji, title, title_sub, sub_label,
--     meta_semana, meta_val, avanco, avanco_acumulado, message, msg_footer_label, sort_order)
--   VALUES ('meu-id', 'teal', '🔩', 'MINHA CATEGORIA', '(MY CATEGORY)', NULL,
--     0, 0, 0, 0, 'Mensagem inicial.', NULL, 4);
--
-- Nova atividade:
--   INSERT INTO activities (card_id, icon, name, real_val, meta, position)
--   VALUES ('meu-id', '🔧', 'NOME DA ATIVIDADE', 0, 10, 0);
--
-- Remover card (remove atividades em cascade):
--   DELETE FROM cards WHERE id = 'meu-id';
--
-- Remover atividade:
--   DELETE FROM activities WHERE id = '<uuid>';
