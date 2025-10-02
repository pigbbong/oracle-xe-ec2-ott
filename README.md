```bash
# 1. SSH 접속 (키 파일이 있는 경로에서 실행)
ssh -i "<your-key.pem>" ec2-user@<public-ip-address>

# 2. 시스템 업데이트
sudo dnf update -y

# 3. 필요한 패키지 설치
sudo dnf install -y oracle-database-preinstall-21c wget unzip

# 4. Oracle XE 설치 파일 업로드 (로컬 → EC2)
scp -i "<your-key.pem>" <local-path-to-rpm>/oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm ec2-user@<public-ip-address>:/tmp/

# 5. rpm 패키지 설치 (EC2 내부)
cd /tmp
sudo dnf localinstall -y oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm

# 6. 초기 설정 및 비밀번호 지정
sudo /etc/init.d/oracle-xe-21c configure

# 7. 서비스 상태 확인
ps -ef | grep pmon
ps -ef | grep tnslsnr
sudo ss -ltnp | grep 1521

# 8. 방화벽 설정 (필요 시)
sudo firewall-cmd --add-port=1521/tcp --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --list-all

# 9. Oracle Developer 접속 후 DB 상태 확인
# Connection Name: EC2-OracleXE (예시)
# Username: system (또는 movies)
# Password: 초기 설정에서 지정한 비밀번호
# Hostname: EC2 퍼블릭 IPv4 주소
# Port: 1521
# Service Name: xepdb1

# 접속 후 상태 확인 쿼리
SELECT host_name, instance_name, version FROM v$instance;

# 10. CSV 파일 업로드 및 권한 설정
mkdir -p /home/ec2-user/csv_dir
scp -i "<your-key.pem>" <local-path-to-csv>/*.csv ec2-user@<public-ip-address>:/home/ec2-user/csv_dir/
sudo cp /home/ec2-user/csv_dir/*.csv /opt/oracle/admin/XE/dpdump/
sudo chown oracle:oinstall /opt/oracle/admin/XE/dpdump/*.csv
sudo chmod 644 /opt/oracle/admin/XE/dpdump/*.csv
sudo ls -l /opt/oracle/admin/XE/dpdump/ | grep csv
</details>


<details>
<summary><h2>분석 프로세스</h2></summary>


<summary><h3>Topic 1: 고객들의 플랜 업그레이드 비율</h3></summary>

**분석 항목**  
1-1. Free → Basic/Premium 업그레이드율  
1-2. Free 가입자가 처음 업그레이드하기까지 걸린 시간  
1-3. 업그레이드 후 3개월 이상 유지율  

**분석 결과 요약**  
- Free 신규 가입자의 다음 달 유료 전환율 ≈ 77~78%  
- Free 가입자의 약 79%가 1개월 내 전환, 95% 이상이 2개월 내 전환  
- 업그레이드 후 3개월 이상 연속 유료 유지 비율 ≈ 70%


<summary><h3>Topic 2: 무료 가입 고객의 시청 패턴 변화</h3></summary>

**분석 항목**  
- 무료 가입자의 업그레이드 전 평균 시청 횟수  
- 유료 업그레이드 직후 시청 횟수 변화율  
- 유료 콘텐츠 비중  

**분석 결과 요약**  
- 무료 가입자는 평균 1.4편 → 유료 전환 직후 2.1편 (65% 증가)  
- 전환 직후 유료 콘텐츠 비중은 약 3.8%  


<summary><h3>Topic 3: 시청 횟수와 유료 플랜 유지 기간의 관계</h3></summary>

**분석 항목**  
- 고객을 시청 횟수 기준 Low / Medium / High 3그룹으로 분류  
- 그룹별 유료 플랜 유지 개월 수 비교  

**분석 결과 요약**  
- High: 단기 집중 후 빠른 해지 ("폭식형")  
- Medium: 평균적 유지  
- Low: 시청 적지만 장기 유지 ("깜빡 구독")  


<summary><h3>Topic 4: 수익 기여도 분석</h3></summary>

**분석 항목**  
4-1. 플랜별 수익 기여도  
4-2. 연령대별 ARPU(1인당 평균 매출)  
> *가중치 산식: 구독료 + 0.1 × 시청 횟수*

**분석 결과 요약**  
- Premium ≈ 1억7천만 / Basic ≈ 9천만 / Free ≈ 65만  
- 20~30대가 전체 매출을 주도, ARPU 세대별 차이는 크지 않음  


</details>


<details>
<summary><h3>정리</h3></summary>


## 한계점
- 가상 데이터는 일정한 형식과 가중치를 부여해 생성되었기 때문에, 실제 서비스 환경에서 발생하는 **비정형적/비선형적 데이터 패턴**을 완전히 반영하지 못함  
- Oracle XE 무료 버전 환경에서는 **파티션, 병렬 처리, 고급 튜닝 기능** 등을 지원하지 않아  대규모 OLAP 환경에서의 **병렬 처리 성능 비교나 파티션 전략 실험**을 수행할 수 없었음  

## 의의
- AWS EC2 환경에 **Oracle Linux + Oracle XE 21c**를 직접 구축하고, 외부 데이터를 ETL 파이프라인으로 적재하여 **엔드투엔드 데이터 분석 흐름**을 실습한 경험  
- OTT 서비스 ERD 모델링부터 가상 데이터 생성, CSV 업로드, 외부 테이블 → 내부 테이블 변환, 제약조건 적용, SQL 분석 프로세스 실행까지의 **데이터 분석 사이클 전체를 구현**  
- 데이터베이스 기반 분석에서 **설계 → 데이터 준비 → 분석 → 결과 도출**의 전 과정을 경험하며,  
  이후 실제 대용량 환경에서의 확장 및 최적화 방향(병렬, 파티셔닝, 인덱스 튜닝 등)을 고민할 수 있는 토대 마련
</details>

