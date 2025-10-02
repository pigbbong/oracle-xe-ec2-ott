-- Topic1: 고객들의 플랜 업그레이드 비율

-- 1-1: 가입 다음 달에 Free → Basic/Premium으로 업그레이드한 비율
WITH free_join AS (
    SELECT  m.member_id,
            TO_CHAR(m.join_date, 'YYYY-MM') AS join_month
    FROM    members m
    JOIN    subscription s
    ON      m.member_id = s.member_id
    WHERE   s.is_new = 'Y'
    AND     s.plan_id = 'F'
    AND     m.join_date < TO_DATE('2024-12', 'YYYY-MM')
),
upgrade AS (
    SELECT  f.member_id,
            f.join_month,
            TO_CHAR(s.period, 'YYYY-MM') AS upgrade_month
    FROM    free_join f
    JOIN    subscription s
    ON      f.member_id = s.member_id
    WHERE   s.plan_id IN ('B', 'P')
    AND     s.period = TO_CHAR(ADD_MONTHS(TO_DATE(f.join_month, 'YYYY-MM'), 1))
)

SELECT  f.join_month,
        COUNT(DISTINCT f.member_id) AS free_join_members,
        COUNT(DISTINCT u.member_id) AS upgrade_members,
        ROUND(COUNT(DISTINCT u.member_id) / COUNT(DISTINCT f.member_id) * 100, 2) AS upgrade_pct
FROM    free_join f
LEFT JOIN upgrade u
ON      f.member_id = u.member_id
GROUP BY f.join_month
ORDER BY 1;


-- 1-2: free로 가입한 멤버들이 처음 업그레이드 하기까지 걸린 시간
WITH free_join AS (
    SELECT  m.member_id,
            TRUNC(m.join_date, 'mm') AS join_month
    FROM    members m
    JOIN    subscription s
    ON      m.member_id = s.member_id
    WHERE   s.is_new = 'Y'
    AND     s.plan_id = 'F'
    AND     m.join_date < TO_DATE('2024-12', 'YYYY-MM')
),
upgrade AS (
    SELECT  f.member_id,
            f.join_month,
            MIN(s.period) AS first_upgrade_month
    FROM    free_join f
    JOIN    subscription s
    ON      f.member_id = s.member_id
    WHERE   s.plan_id IN ('B', 'P')
    AND     s.period > f.join_month
    GROUP BY f.member_id, f.join_month
)
SELECT  MONTHS_BETWEEN(first_upgrade_month, join_month) AS months_to_upgrade,
        COUNT(*) AS cnt,
        ROUND(RATIO_TO_REPORT (COUNT(*)) OVER () * 100, 2) AS rate
FROM    upgrade
GROUP BY MONTHS_BETWEEN(first_upgrade_month, join_month)
ORDER BY 1;


-- 1-3: 처음 업그레이드한 후(신규 가입한 달 포함) 3개월 이상 연속으로 Basic 이상 지속하는 회원들의 비율
WITH upgrade AS (
    SELECT  member_id,
            period
    FROM    subscription
    WHERE   plan_id IN ('B', 'P')
),
grouping AS (
    SELECT  member_id,
            ADD_MONTHS(period, - ROW_NUMBER() OVER (PARTITION BY member_id ORDER BY period)) AS grp
    FROM    upgrade
),
consecutive AS (
    SELECT  member_id,
            grp,
            COUNT(*) AS cnt
    FROM    grouping
    GROUP BY member_id, grp
),
max_consecutive AS (
    SELECT  member_id,
            MAX(cnt) AS max_consecutive_month
    FROM    consecutive
    GROUP BY member_id
)
SELECT  ROUND(SUM(CASE WHEN max_consecutive_month >= 3 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) || '%' AS rate
FROM    max_consecutive;
