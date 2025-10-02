<details>
<summary><h2>개요</h2></summary>
· AWS EC2에 Oracle Linux 8 + Oracle Database XE 21c 설치
  <br>
· OTT 서비스 ERD 설계 및 가상 데이터 생성
  <br>
· CSV 업로드 → 외부 테이블 적재 → 내부 테이블 변환 및 제약조건 추가
  <br>
· SQL 분석 프로세스 (구독 전환율, 유지율, 시청 패턴, 수익 기여도) 수행

</details>

<details>
<summary><h2>폴더 구조 및 실행 순서</h2></summary>

<br>

- project/
  - image/
  - virtual_OTT/
    - data_pipeline/ : 가상 데이터 생성 및 CSV → DB 적재 스크립트
      - fake_data.ipynb
      - SYS.sql
      - ETL.sql
      - DDL.sql
    - analysis_process/ : SQL 분석 프로세스 및 결과
      - TOPIC1.sql
      - TOPIC2.sql
      - TOPIC3.sql
      - TOPIC4.sql


**실행 순서**  
1. fake_data.ipynb 에서 가상 데이터 생성 (csv 파일 생성)
2. EC2 인스턴스 생성 과정 확인  
3. EC2 환경 구축 확인
4. ETL, DDL에서 CSV 파일 적재 및 외부 테이블 → 내부 테이블 변환  
6. virtual_OTT/analysis_process/에서 SQL 분석 프로세스 실행 및 결과 확인  

</details>




<details>
<summary><h2>ERD 모델링</h2></summary>

<br>

![ERD](./image/ERD.png)

</details>



<details>
<summary><h2>EC2 인스턴스 생성</h2></summary>

## Step 1: EC2 인스턴스 시작  
![EC2 Step1](./image/EC2_instance_step1.png)

## Step 2-1: AMI 선택  
![EC2 Step2-1](./image/EC2_instance_step2-1.png)

## Step 2-2: 구독한 AMI  
![EC2 Step2-2](./image/EC2_instance_step2-2.png)

## Step 3: 인스턴스 유형 선택  
![EC2 Step3](./image/EC2_instance_step3.png)

## Step 4: 키 페어 생성  
![EC2 Step4](./image/EC2_instance_step4.png)

## Step 4-2: 키 페어 상세  
![EC2 Step4-2](./image/EC2_instance_step4-2.png)

## Step 5: 네트워크 설정  
![EC2 Step5](./image/EC2_instance_step5.png)

## Step 6: 스토리지 설정  
![EC2 Step6](./image/EC2_instance_step6.png)

</details>


<details>
<summary><h2>EC2 환경 구축</h2></summary>

``` 
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

SQL Developer에서 새로운 연결(New Connection)을 생성

- Connection Name: 임의로 지정 (예: `EC2-OracleXE`)
- Username: system (또는 생성한 사용자 계정명, 예: `movies`)
- Password: 설치 시 `sudo /etc/init.d/oracle-xe-21c configure` 단계에서 설정한 비밀번호
- Hostname: EC2 퍼블릭 IPv4 주소 (예: `16.xxx.xxx.xxx`)
- Port: 1521
- Service Name: xepdb1

연결 후 SQL Worksheet에서 아래 쿼리를 실행해 DB 상태를 확인
SQL> SELECT host_name, instance_name, version FROM v$instance;

# 10. CSV 파일 업로드 및 권한 설정

1. 업로드 받을 디렉토리 생성 (ec2-user 홈 디렉토리)
mkdir -p /home/ec2-user/csv_dir
2. 로컬 PC → EC2로 CSV 업로드
scp -i "<your-key.pem>" <local-path-to-csv>/*.csv ec2-user@<public-ip-address>:/home/ec2-user/csv_dir/
3. Oracle XE가 접근할 수 있는 디렉토리로 복사
sudo cp /home/ec2-user/csv_dir/*.csv /opt/oracle/admin/XE/dpdump/
4. 소유자와 그룹 변경 (oracle:oinstall)
sudo chown oracle:oinstall /opt/oracle/admin/XE/dpdump/*.csv
5. 퍼미션 설정 (읽기 가능)
sudo chmod 644 /opt/oracle/admin/XE/dpdump/*.csv
6. 최종 확인
sudo ls -l /opt/oracle/admin/XE/dpdump/ | grep csv

</details>


