-- 경로 설정
CREATE OR REPLACE DIRECTORY csv_dir AS '/opt/oracle/admin/XE/dpdump';


-- 경로 설정 여부 확인
SELECT directory_path 
FROM dba_directories 
WHERE directory_name='CSV_DIR';



-- 테이블 초기화
DROP TABLE plans_ext PURGE;
DROP TABLE movies_ext PURGE;
DROP TABLE members_ext PURGE;
DROP TABLE subscription_ext PURGE;
DROP TABLE viewing_history_ext PURGE;


------------------------------------------------------------
-- PLANS
------------------------------------------------------------
CREATE TABLE plans_ext (
    plan_id         VARCHAR2(20),
    plan_type       VARCHAR2(50),
    price           NUMBER,
    max_resolution  VARCHAR2(50),
    max_concurrent  NUMBER,
    downloadable    VARCHAR2(10)
)
ORGANIZATION EXTERNAL
(
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY csv_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        NOBADFILE NOLOGFILE NODISCARDFILE
        FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
        RTRIM            -- ← 캐리지리턴/공백 제거
    )
    LOCATION ('plans.csv')
)
REJECT LIMIT UNLIMITED;


------------------------------------------------------------
-- MOVIES
------------------------------------------------------------
CREATE TABLE movies_ext (
    movie_id    NUMBER,
    title       VARCHAR2(400),
    genre       VARCHAR2(200),
    open_dt     VARCHAR2(50),
    showtime    NUMBER,
    is_not_free VARCHAR2(10)
)
ORGANIZATION EXTERNAL
(
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY csv_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'movies.bad'
        LOGFILE 'movies.log'
        DISCARDFILE 'movies.dsc'
        FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
        RTRIM
    )
    LOCATION ('movies.csv')
)
REJECT LIMIT UNLIMITED;


------------------------------------------------------------
-- MEMBERS
------------------------------------------------------------
CREATE TABLE members_ext (
    member_id       NUMBER,
    name            VARCHAR2(100),
    email           VARCHAR2(200),
    age             NUMBER,
    join_date       VARCHAR2(50),
    current_plan    VARCHAR2(20)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY csv_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        NOBADFILE NOLOGFILE NODISCARDFILE
        FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
        RTRIM
    )
    LOCATION ('members.csv')
)
REJECT LIMIT UNLIMITED;


------------------------------------------------------------
-- SUBSCRIPTION
------------------------------------------------------------
CREATE TABLE subscription_ext (
    subscription_id NUMBER,
    member_id       NUMBER,
    period          VARCHAR2(20),
    plan_id         VARCHAR2(20),
    is_new          VARCHAR2(20)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY csv_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        NOBADFILE NOLOGFILE NODISCARDFILE
        FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
        RTRIM
    )
    LOCATION ('subscription.csv')
)
REJECT LIMIT UNLIMITED;


------------------------------------------------------------
-- VIEWING HISTORY
------------------------------------------------------------
CREATE TABLE viewing_history_ext (
    view_id             NUMBER,
    member_id           NUMBER,
    movie_id            NUMBER,
    watch_date          VARCHAR2(50),
    watch_status        VARCHAR2(50),
    main_device_type    VARCHAR2(50)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY csv_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        NOBADFILE NOLOGFILE NODISCARDFILE
        FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
        RTRIM
    )
    LOCATION ('viewing_history.csv')
)
REJECT LIMIT UNLIMITED;


-- 로컬 PC DBMS는 문자열 길이에 좀 더 관대하거나 자동 truncate → 문제 없었던 것.
-- Oracle XE는 엄격하게 길이 체크 → 초과 시 ORA-12899.
-- 따라서 EC2 환경(Oracle XE)에서는 VARCHAR2 길이를 넉넉히 잡는 게 안전합니다.