-- TOPIC2: 무료로 가입한 사람들 중 유료 플랜 업그레이드 전까지 본 평균 영화 수와 처음 유료로 업그레이드한 후 평균 영화 수 변화율 분석
WITH upgrade AS (
    SELECT  s.member_id,
            MIN(s.period) AS first_upgrade_month
    FROM    subscription s
    WHERE   s.plan_id IN ('B','P')
    GROUP BY s.member_id
),
free_join AS (
    SELECT  m.member_id,
            TRUNC(m.join_date, 'MM') AS join_month,
            u.first_upgrade_month
    FROM    members m
    JOIN    subscription s
      ON    m.member_id = s.member_id
     AND    s.plan_id = 'F'
     AND    s.is_new = 'Y'
    JOIN    upgrade u
      ON    m.member_id = u.member_id
    WHERE   m.join_date < DATE '2024-12-01'
)
SELECT  ROUND(AVG(free_view), 2) 
        AS avg_free_view_cnt,
        ROUND(AVG(first_upgrade_non_recent_view + first_upgrade_recent_view), 2) 
        AS avg_first_upgrade_view,
        ROUND(AVG(first_upgrade_recent_view), 2)
        AS avg_first_upgrade_recent_view,
        ROUND(AVG(free_view) / AVG (first_upgrade_non_recent_view + first_upgrade_recent_view) * 100, 2) || '%'
        AS pct_increase,
        ROUND(AVG(first_upgrade_recent_view / NULLIF(first_upgrade_non_recent_view + first_upgrade_recent_view, 0)) * 100, 2) || '%' 
        AS pct_recent_view
FROM    (
    SELECT  f.member_id,
            COUNT(CASE WHEN v.watch_date >= f.join_month 
               AND v.watch_date < f.first_upgrade_month THEN 1 END) AS free_view,
            COUNT(CASE 
                    WHEN v.watch_date >= f.first_upgrade_month 
                     AND v.watch_date < ADD_MONTHS(f.first_upgrade_month, 1) 
                    THEN 1 END) 
            AS first_upgrade_non_recent_view,
            COUNT(CASE 
                    WHEN v.watch_date >= f.first_upgrade_month 
                     AND v.watch_date < ADD_MONTHS(f.first_upgrade_month, 1) 
                     AND m.is_not_free = 'Y' 
                    THEN 1 END) 
            AS first_upgrade_recent_view
    FROM    free_join f
    JOIN    viewing_history v
    ON      f.member_id = v.member_id
    JOIN    movies m
    ON      v.movie_id = m.movie_id
    GROUP BY f.member_id 
    );

