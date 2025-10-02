개요
- AWS EC2에 Oracle Linux 8 + Oracle Database XE 21c 설치
- OTT 서비스 ERD 설계 및 가상 데이터 생성
- CSV 업로드 → 외부 테이블 적재 → 내부 테이블 변환 및 제약조건 추가
- SQL 분석 프로세스 (구독 전환율, 유지율, 시청 패턴, 수익 기여도) 수행


ERD
![ERD](./image/ERD.png)

## EC2 인스턴스 생성

Step 1: EC2 인스턴스 시작  
![EC2 Step1](./image/EC2_instance_step1.png)

Step 2-1: AMI 선택  
![EC2 Step2-1](./image/EC2_instance_step2-1.png)

Step 2-2: AMI 상세  
![EC2 Step2-2](./image/EC2_instance_step2-2.png)

Step 3: 인스턴스 유형 선택  
![EC2 Step3](./image/EC2_instance_step3.png)

Step 4: 키 페어 생성  
![EC2 Step4](./image/EC2_instance_step4.png)

Step 4-2: 키 페어 상세  
![EC2 Step4-2](./image/EC2_instance_step4-2.png)

Step 5: 네트워크 설정  
![EC2 Step5](./image/EC2_instance_step5.png)

Step 6: 스토리지 설정  
![EC2 Step6](./image/EC2_instance_step6.png)


# EC2 환경 구축

## 1. SSH 접속 (키 파일이 있는 경로에서 실행)
ssh -i "<your-key.pem>" ec2-user@<public-ip-address>

## 2. 시스템 업데이트
sudo dnf update -y

## 3. 필요한 패키지 설치
sudo dnf install -y oracle-database-preinstall-21c wget unzip

## 4. Oracle XE 설치 파일 업로드 (로컬 → EC2)
scp -i "<your-key.pem>" <local-path-to-rpm>/oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm ec2-user@<public-ip-address>:/tmp/

## 5. rpm 패키지 설치 (EC2 내부)
1. cd /tmp
2. sudo dnf localinstall -y oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm

## 6. 초기 설정 및 비밀번호 지정
sudo /etc/init.d/oracle-xe-21c configure

## 7. 서비스 상태 확인
1. ps -ef | grep pmon
2. ps -ef | grep tnslsnr
3. sudo ss -ltnp | grep 1521

## 8. 방화벽 설정 (필요 시)
1. sudo firewall-cmd --add-port=1521/tcp --permanent
2. sudo firewall-cmd --reload
3. sudo firewall-cmd --list-all

## 9. Oracle Developer 접속 후 DB 상태 확인
SQL> SELECT host_name, instance_name, version FROM v$instance;

## 10. CSV 파일 업로드 및 권한 설정
1. mkdir -p /home/ec2-user/csv_dir
2. scp -i "<your-key.pem>" <local-path-to-csv>/*.csv ec2-user@<public-ip-address>:/home/ec2-user/csv_dir/
3. sudo cp /home/ec2-user/csv_dir/*.csv /opt/oracle/admin/XE/dpdump/
4. sudo chown oracle:oinstall /opt/oracle/admin/XE/dpdump/*.csv
5. sudo chmod 644 /opt/oracle/admin/XE/dpdump/*.csv
6. sudo ls -l /opt/oracle/admin/XE/dpdump/ | grep csv
