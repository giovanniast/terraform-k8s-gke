1- Algumas Queries para visualizções dos custos. Analisem os retornos de cada uma.



-- 1. TOP 10 PROJETOS COM MAIOR CUSTO (MÊS ATUAL)
SELECT 
  project.id AS projeto,
  project.name AS nome_projeto,
  ROUND(SUM(cost), 2) AS custo_total_usd,
  ROUND(SUM(cost) * 100 / SUM(SUM(cost)) OVER(), 2) AS percentual_total
FROM 
  `prodam-d6584-finops-labs.gcp_billing_export_prodam.gcp_billing_export_resource_v1_01AFBD_678DDE_E90FCA`
WHERE 
  DATE(usage_start_time) >= DATE_TRUNC(CURRENT_DATE(), MONTH)
  AND cost > 0
GROUP BY 
  projeto, nome_projeto
ORDER BY 
  custo_total_usd DESC
LIMIT 10;

-- ============================================

-- 2. CUSTOS POR SERVIÇO (MÊS ATUAL)
SELECT 
  service.description AS servico,
  ROUND(SUM(cost), 2) AS custo_total_usd,
  ROUND(SUM(cost) * 100 / SUM(SUM(cost)) OVER(), 2) AS percentual_total,
  COUNT(DISTINCT project.id) AS qtd_projetos
FROM 
  `seu-projeto.seu_dataset.gcp_billing_export_v1_XXXXXX`
WHERE 
  DATE(usage_start_time) >= DATE_TRUNC(CURRENT_DATE(), MONTH)
  AND cost > 0
GROUP BY 
  servico
ORDER BY 
  custo_total_usd DESC
LIMIT 15;

-- ============================================

-- 3. PERCENTUAL DE RECURSOS ROTULADOS (LABELS)
SELECT 
  CASE 
    WHEN ARRAY_LENGTH(labels) > 0 THEN 'Com Labels'
    ELSE 'Sem Labels'
  END AS status_rotulacao,
  ROUND(SUM(cost), 2) AS custo_total_usd,
  ROUND(SUM(cost) * 100 / SUM(SUM(cost)) OVER(), 2) AS percentual_custo,
  COUNT(*) AS qtd_registros
FROM 
  `seu-projeto.seu_dataset.gcp_billing_export_v1_XXXXXX`
WHERE 
  DATE(usage_start_time) >= DATE_TRUNC(CURRENT_DATE(), MONTH)
  AND cost > 0
GROUP BY 
  status_rotulacao
ORDER BY 
  custo_total_usd DESC;

-- ============================================

-- 4. TENDÊNCIA DE CUSTOS - ÚLTIMOS 6 MESES
SELECT 
  FORMAT_DATE('%Y-%m', DATE(usage_start_time)) AS mes,
  ROUND(SUM(cost), 2) AS custo_total_usd,
  ROUND(SUM(cost) - LAG(SUM(cost)) OVER(ORDER BY FORMAT_DATE('%Y-%m', DATE(usage_start_time))), 2) AS variacao_mes_anterior,
  ROUND((SUM(cost) - LAG(SUM(cost)) OVER(ORDER BY FORMAT_DATE('%Y-%m', DATE(usage_start_time)))) * 100 / 
    NULLIF(LAG(SUM(cost)) OVER(ORDER BY FORMAT_DATE('%Y-%m', DATE(usage_start_time))), 0), 2) AS variacao_percentual
FROM 
  `seu-projeto.seu_dataset.gcp_billing_export_v1_XXXXXX`
WHERE 
  DATE(usage_start_time) >= DATE_SUB(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 6 MONTH)
  AND cost > 0
GROUP BY 
  mes
ORDER BY 
  mes DESC;

-- ============================================

-- 5. CUSTOS POR SKU (UNIDADE DE PRODUTO) - TOP 20
SELECT 
  service.description AS servico,
  sku.description AS sku,
  ROUND(SUM(cost), 2) AS custo_total_usd,
  ROUND(SUM(cost) * 100 / SUM(SUM(cost)) OVER(), 2) AS percentual_total,
  SUM(usage.amount) AS quantidade_uso
FROM 
  `seu-projeto.seu_dataset.gcp_billing_export_v1_XXXXXX`
WHERE 
  DATE(usage_start_time) >= DATE_TRUNC(CURRENT_DATE(), MONTH)
  AND cost > 0
GROUP BY 
  servico, sku
ORDER BY 
  custo_total_usd DESC
LIMIT 20;

-- ============================================

-- 6. CUSTOS POR REGIÃO/LOCALIZAÇÃO
SELECT 
  location.location AS regiao,
  location.country AS pais,
  ROUND(SUM(cost), 2) AS custo_total_usd,
  ROUND(SUM(cost) * 100 / SUM(SUM(cost)) OVER(), 2) AS percentual_total,
  COUNT(DISTINCT project.id) AS qtd_projetos
FROM 
  `seu-projeto.seu_dataset.gcp_billing_export_v1_XXXXXX`
WHERE 
  DATE(usage_start_time) >= DATE_TRUNC(CURRENT_DATE(), MONTH)
  AND cost > 0
  AND location.location IS NOT NULL
GROUP BY 
  regiao, pais
ORDER BY 
  custo_total_usd DESC;

-- ============================================

-- 7. ANÁLISE DE CRÉDITOS E DESCONTOS
SELECT 
  project.id AS projeto,
  ROUND(SUM(cost), 2) AS custo_bruto_usd,
  ROUND(SUM(IFNULL((SELECT SUM(amount) FROM UNNEST(credits)), 0)), 2) AS total_creditos_usd,
  ROUND(SUM(cost) + SUM(IFNULL((SELECT SUM(amount) FROM UNNEST(credits)), 0)), 2) AS custo_liquido_usd,
  ROUND(ABS(SUM(IFNULL((SELECT SUM(amount) FROM UNNEST(credits)), 0))) * 100 / 
    NULLIF(ABS(SUM(cost)), 0), 2) AS percentual_economia
FROM 
  `seu-projeto.seu_dataset.gcp_billing_export_v1_XXXXXX`
WHERE 
  DATE(usage_start_time) >= DATE_TRUNC(CURRENT_DATE(), MONTH)
GROUP BY 
  projeto
HAVING 
  custo_bruto_usd > 0
ORDER BY 
  custo_bruto_usd DESC
LIMIT 10;

-- ============================================

-- 8. RECURSOS OCIOSOS (CUSTOS BAIXOS COM USO CONTÍNUO)
-- Identifica recursos com custo diário muito baixo mas constante
SELECT 
  project.id AS projeto,
  service.description AS servico,
  sku.description AS sku,
  COUNT(DISTINCT DATE(usage_start_time)) AS dias_ativos,
  ROUND(SUM(cost), 2) AS custo_total_usd,
  ROUND(AVG(cost), 4) AS custo_medio_diario_usd
FROM 
  `seu-projeto.seu_dataset.gcp_billing_export_v1_XXXXXX`
WHERE 
  DATE(usage_start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
  AND cost > 0
GROUP BY 
  projeto, servico, sku
HAVING 
  dias_ativos >= 25
  AND custo_medio_diario_usd < 1
  AND custo_total_usd > 5
ORDER BY 
  custo_total_usd DESC
LIMIT 50;

-- ============================================

-- 9. CUSTO POR LABEL (TAGS ESPECÍFICAS)
-- Analisa custos por centro de custo, ambiente, etc.
SELECT 
  label.key AS chave_label,
  label.value AS valor_label,
  ROUND(SUM(cost), 2) AS custo_total_usd,
  ROUND(SUM(cost) * 100 / SUM(SUM(cost)) OVER(), 2) AS percentual_total,
  COUNT(DISTINCT project.id) AS qtd_projetos
FROM 
  `seu-projeto.seu_dataset.gcp_billing_export_v1_XXXXXX`,
  UNNEST(labels) AS label
WHERE 
  DATE(usage_start_time) >= DATE_TRUNC(CURRENT_DATE(), MONTH)
  AND cost > 0
  -- Filtre por labels específicos, exemplo:
  -- AND label.key IN ('environment', 'cost-center', 'team')
GROUP BY 
  chave_label, valor_label
ORDER BY 
  custo_total_usd DESC
LIMIT 30;

-- ============================================

-- 10. ANOMALIAS DE CUSTO (VARIAÇÃO DIÁRIA > 50%)
WITH custos_diarios AS (
  SELECT 
    DATE(usage_start_time) AS data,
    project.id AS projeto,
    service.description AS servico,
    ROUND(SUM(cost), 2) AS custo_dia
  FROM 
    `seu-projeto.seu_dataset.gcp_billing_export_v1_XXXXXX`
  WHERE 
    DATE(usage_start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
    AND cost > 0
  GROUP BY 
    data, projeto, servico
)
SELECT 
  data,
  projeto,
  servico,
  custo_dia,
  LAG(custo_dia) OVER(PARTITION BY projeto, servico ORDER BY data) AS custo_dia_anterior,
  ROUND(custo_dia - LAG(custo_dia) OVER(PARTITION BY projeto, servico ORDER BY data), 2) AS variacao_absoluta,
  ROUND((custo_dia - LAG(custo_dia) OVER(PARTITION BY projeto, servico ORDER BY data)) * 100 / 
    NULLIF(LAG(custo_dia) OVER(PARTITION BY projeto, servico ORDER BY data), 0), 2) AS variacao_percentual
FROM 
  custos_diarios
WHERE 
  LAG(custo_dia) OVER(PARTITION BY projeto, servico ORDER BY data) IS NOT NULL
  AND ABS((custo_dia - LAG(custo_dia) OVER(PARTITION BY projeto, servico ORDER BY data)) * 100 / 
    NULLIF(LAG(custo_dia) OVER(PARTITION BY projeto, servico ORDER BY data), 0)) > 50
  AND custo_dia > 10
ORDER BY 
  data DESC, ABS(variacao_percentual) DESC
LIMIT 50;

-- ============================================

-- 11. DASHBOARD RESUMO - KPIs PRINCIPAIS
SELECT 
  'KPIs do Mês Atual' AS metrica,
  ROUND(SUM(cost), 2) AS custo_total_usd,
  COUNT(DISTINCT project.id) AS total_projetos,
  COUNT(DISTINCT service.description) AS total_servicos,
  ROUND(SUM(CASE WHEN ARRAY_LENGTH(labels) > 0 THEN cost ELSE 0 END) * 100 / SUM(cost), 2) AS percentual_rotulado,
  ROUND(AVG(cost), 4) AS custo_medio_por_registro
FROM 
  `seu-projeto.seu_dataset.gcp_billing_export_v1_XXXXXX`
WHERE 
  DATE(usage_start_time) >= DATE_TRUNC(CURRENT_DATE(), MONTH)
  AND cost > 0;

========================

2- Dashboard: montar visuais:
custo diário (30d)
top serviços/SKUs
custo por região
% sem cost_center, env
custo por app/env
