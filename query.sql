WITH session_data AS (
  SELECT
    -- Extract session ID from nested event parameters
    CONCAT(user_pseudo_id, '-', (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id')) AS session_id,
    traffic_source.source AS source,
    traffic_source.medium AS medium,
    device.category AS device_category,
    event_name,
    event_value_in_usd
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE
    _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
)

SELECT
  IFNULL(source, '(direct)') AS traffic_source,
  IFNULL(medium, '(none)') AS traffic_medium,
  device_category,
  COUNT(DISTINCT session_id) AS total_sessions,
  COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN session_id END) AS total_purchases,
  ROUND(
    SAFE_DIVIDE(
      COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN session_id END),
      COUNT(DISTINCT session_id)
    ) * 100, 
    2
  ) AS conversion_rate_pct,
  ROUND(SUM(CASE WHEN event_name = 'purchase' THEN event_value_in_usd ELSE 0 END), 2) AS total_revenue_usd
FROM
  session_data
GROUP BY
  traffic_source,
  traffic_medium,
  device_category
HAVING
  total_sessions > 10
ORDER BY
  total_revenue_usd DESC;
