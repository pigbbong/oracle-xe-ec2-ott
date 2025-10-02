-- Topic4: 수익 기여도 분석
-- 구독료 + 0.1 * 시청 횟수 (시청 활동을 금액화해서 가중치 반영)

-- 4-1: 플랜별 수익 기여도 
SELECT  plan_type,
        ROUND(subscription_fee + (0.1 * view_cnt)) AS plan_value
FROM    (
    SELECT  
            p.plan_type,
            SUM(p.price) AS subscription_fee,
            COUNT(v.movie_id) AS view_cnt
    FROM    plans p
    JOIN    subscription s
    ON      p.plan_id = s.plan_id
    JOIN    members m
    ON      s.member_id = m.member_id
    JOIN    viewing_history v
    ON      m.member_id = v.member_id
    GROUP BY p.plan_type
)
ORDER BY 2 DESC;


-- 4-2: 연령대별, ARPU (평균 매출/인당) 수익 기여도
SELECT  age_group || '대' AS age_group,
        ROUND(subscription_fee + (0.1 * view_cnt)) AS age_value,
        ROUND((subscription_fee + (0.1 * view_cnt)) / age_cnt, 2) AS age_per_value,
        RANK () OVER (ORDER BY subscription_fee + (0.1 * view_cnt) DESC) AS rnk
FROM    (
    SELECT  
            TRUNC(m.age, -1) AS age_group,
            COUNT(*) AS age_cnt,
            SUM(p.price) AS subscription_fee,
            COUNT(v.movie_id) AS view_cnt
    FROM    members m
    JOIN    subscription s
    ON      m.member_id = s.member_id
    JOIN    plans p
    ON      s.plan_id = p.plan_id
    JOIN    viewing_history v
    ON      m.member_id = v.member_id
    GROUP BY TRUNC(m.age, -1)
)
ORDER BY 4;
