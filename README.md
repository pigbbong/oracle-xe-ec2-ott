개요
- AWS EC2에 Oracle Linux 8 + Oracle Database XE 21c 설치
- OTT 서비스 ERD 설계 및 가상 데이터 생성
- CSV 업로드 → 외부 테이블 적재 → 내부 테이블 변환 및 제약조건 추가
- SQL 분석 프로세스 (구독 전환율, 유지율, 시청 패턴, 수익 기여도) 수행


ERD
![ERD](./image/ERD.png)


EC2 인스턴스 생성과 환경 구축
EC2 인스턴스는 Oracle Linux 8 (AMI) 기반으로 구성했습니다.  
[ec2-instance](./image/EC2 인스턴스 생성)
