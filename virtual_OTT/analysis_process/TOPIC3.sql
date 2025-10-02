-- Topic3: 시청 횟수가 많은 고객일수록 유료 플랜을 오래 유지하는가?
WITH retention AS (
    SELECT  member_id,
            COUNT(DISTINCT period) AS kept_months
    FROM    subscription
    WHERE   plan_id IN ('B','P')
    GROUP BY member_id
),
viewing_stats AS (
    SELECT  member_id,
            COUNT(*) / (MONTHS_BETWEEN(MAX(watch_date), MIN(watch_date)) + 1) AS avg_monthly_views
    FROM    viewing_history
    GROUP BY member_id
),
grouped AS (
    SELECT  member_id,
            CASE 
                WHEN NTILE(3) OVER (ORDER BY avg_monthly_views) = 1 THEN 'Low'
                WHEN NTILE(3) OVER (ORDER BY avg_monthly_views) = 2 THEN 'Medium'
                ELSE 'High'
            END AS view_group
    FROM    viewing_stats
)
SELECT  g.view_group,
        ROUND(AVG(r.kept_months), 2) AS avg_kept_months,
        ROUND(AVG(v.avg_monthly_views), 2) AS avg_monthly_views
FROM    grouped g
JOIN    retention r
ON      g.member_id = r.member_id
JOIN    viewing_stats v
ON      g.member_id = v.member_id
GROUP BY g.view_group
ORDER BY 3;
