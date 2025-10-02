DROP TABLE plans CASCADE CONSTRAINTS PURGE;
DROP TABLE movies CASCADE CONSTRAINTS PURGE;
DROP TABLE members CASCADE CONSTRAINTS PURGE;
DROP TABLE subscription CASCADE CONSTRAINTS PURGE;
DROP TABLE viewing_history CASCADE CONSTRAINTS PURGE;


------------------------------------------------------------
-- PLANS
------------------------------------------------------------
CREATE TABLE plans AS 
SELECT  TRIM(plan_id)       AS plan_id,
        TRIM(plan_type)     AS plan_type,
        price,
        TRIM(max_resolution) AS max_resolution,
        max_concurrent,
        TRIM(downloadable)  AS downloadable
FROM    plans_ext;

ALTER TABLE plans
    ADD CONSTRAINT plans_pk PRIMARY KEY (plan_id);



------------------------------------------------------------
-- MOVIES
------------------------------------------------------------
CREATE TABLE movies AS
SELECT  movie_id,
        TRIM(title)         AS title,
        TRIM(genre)         AS genre,
        TO_DATE(TRIM(open_dt), 'YYYY-MM-DD') AS open_dt,
        showtime,
        TRIM(is_not_free)   AS is_not_free
FROM    movies_ext;

ALTER TABLE movies
    ADD CONSTRAINT movies_pk PRIMARY KEY (movie_id);



------------------------------------------------------------
-- MEMBERS
------------------------------------------------------------
CREATE TABLE members AS
SELECT  member_id,
        TRIM(name)          AS name,
        TRIM(email)         AS email,
        age,
        TO_DATE(TRIM(join_date), 'YYYY-MM-DD') AS join_date,
        TRIM(current_plan)  AS current_plan
FROM    members_ext;

ALTER TABLE members
    ADD CONSTRAINT members_pk PRIMARY KEY (member_id);



------------------------------------------------------------
-- SUBSCRIPTION
------------------------------------------------------------
CREATE TABLE subscription AS
SELECT  subscription_id,
        member_id,
        TRIM(plan_id)       AS plan_id,
        TO_DATE(TRIM(period), 'YYYY-MM') AS period,
        TRIM(is_new)        AS is_new
FROM    subscription_ext;

ALTER TABLE subscription
    ADD CONSTRAINT subscription_pk PRIMARY KEY (subscription_id);

ALTER TABLE subscription
    ADD CONSTRAINT subscription_fk1 FOREIGN KEY (member_id)
    REFERENCES members (member_id);
    
ALTER TABLE subscription
    ADD CONSTRAINT subscription_fk2 FOREIGN KEY (plan_id)
    REFERENCES plans (plan_id);



------------------------------------------------------------
-- VIEWING HISTORY
------------------------------------------------------------
CREATE TABLE viewing_history AS
SELECT  view_id,
        member_id,
        movie_id,
        TO_DATE(TRIM(watch_date), 'YYYY-MM-DD') AS watch_date,
        TRIM(watch_status)       AS watch_status,
        TRIM(main_device_type)   AS main_device_type
FROM    viewing_history_ext;

ALTER TABLE viewing_history 
    ADD CONSTRAINT viewing_history_pk PRIMARY KEY (view_id);
    
ALTER TABLE viewing_history
    ADD CONSTRAINT viewing_history_fk1 FOREIGN KEY (member_id)
    REFERENCES members (member_id);

-- orphan 데이터 제거 (movies에 없는 movie_id)
DELETE FROM viewing_history v
WHERE NOT EXISTS (
    SELECT 1 FROM movies m
    WHERE m.movie_id = v.movie_id
);
COMMIT;

ALTER TABLE viewing_history
    ADD CONSTRAINT viewing_history_fk2 FOREIGN KEY (movie_id)
    REFERENCES movies (movie_id);
    

