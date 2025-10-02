-- 관리자 계정으로 실행해야함

-- Oracle 21c XE는 기본적으로 CDB(Container DB)와 PDB(Pluggable DB) 구조를 가짐
-- 실제 업무/실습용 객체는 PDB(XEPDB1)에서 생성해야 하므로,
-- 세션을 XEPDB1 컨테이너로 전환.
ALTER SESSION SET CONTAINER = XEPDB1;

-- 권한 부여
GRANT CREATE SESSION, CONNECT, RESOURCE TO system;

-- USERS 테이블스페이스에 무제한 할당
ALTER USER system QUOTA UNLIMITED ON USERS;

-- 디렉토리 생성 권한 부여
GRANT CREATE ANY DIRECTORY TO system;
