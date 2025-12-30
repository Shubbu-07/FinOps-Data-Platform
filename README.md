# 🏦 FinOps Data Platform

![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?logo=snowflake&logoColor=white)
![DBT](https://img.shields.io/badge/dbt-FF694B?logo=dbt&logoColor=white)
![Apache Airflow](https://img.shields.io/badge/Apache%20Airflow-017CEE?logo=apacheairflow&logoColor=white)
![Apache Kafka](https://img.shields.io/badge/Apache%20Kafka-231F20?logo=apachekafka&logoColor=white)
![Debezium](https://img.shields.io/badge/Debezium-EF3B2D?logo=apache&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?logo=git&logoColor=white)
![CI/CD](https://img.shields.io/badge/CI%2FCD-000000?logo=githubactions&logoColor=white)

---

## 📌 Project Overview
This project demonstrates a **production-grade**, end-to-end data engineering platform for a banking domain.
It implements real-time **CDC ingestion**, **batch ELT**, **SCD Type-2 modeling**, and **analytics-ready marts** using modern data engineering tools.

---

## 🏗️ Architecture  

<img width="5647" height="3107" alt="Architecture" src="https://github.com/user-attachments/assets/c0071a08-8af8-4611-9f78-c2ecae95c2d0" />


**Pipeline Flow:**
1. **Data Generator** → Simulates banking transactions, accounts & customers (via Faker).  
2. **Kafka + Debezium** → Streams change data (CDC) into MinIO (S3-compatible storage).  
3. **Airflow** → Orchestrates data ingestion & snapshots into Snowflake.  
4. **Snowflake** → Cloud Data Warehouse (Bronze → Silver → Gold).  
5. **DBT** → Applies transformations, builds marts & snapshots (SCD Type-2).  
6. **CI/CD with GitHub Actions** → Automated tests, build & deployment.  

---

## 🛠️ Tools & Technologies
- **Snowflake** → Cloud Data Warehouse  
- **DBT** → Transformations, testing, snapshots (SCD Type-2)  
- **Apache Airflow** → Orchestration & DAG scheduling  
- **Apache Kafka + Debezium** → Real-time streaming & CDC  
- **MinIO** → S3-compatible object storage  
- **Postgres** → Source OLTP system  
- **Python (Faker)** → Data simulation  
- **Docker & docker-compose** → Containerized setup  
- **Git & GitHub Actions** → CI/CD workflows  

---

## ✅ Key Features
- **PostgreSQL OLTP**: Source relational database with ACID guarantees (customers, accounts, transactions)  
- **Simulated banking system**: customers, accounts, and transactions  
- **Change Data Capture (CDC)** via Kafka + Debezium (capturing Postgres WAL)  
- **Raw → Staging → Fact/Dimension** models in DBT  
- **Snapshots for history tracking** (slowly changing dimensions)  
- **Automated pipeline orchestration** using Airflow  
- **CI/CD pipeline** with dbt tests + GitHub Actions  

---

## 📂 Repository Structure
```text
banking-modern-datastack/
├── .github/workflows/         # CI/CD pipelines (ci.yml, cd.yml)
├── banking_dbt/               # DBT project
│   ├── models/
│   │   ├── staging/           # Staging models
│   │   ├── marts/             # Facts & dimensions
│   │   └── sources.yml
│   ├── snapshots/             
│   └── dbt_project.yml        # SCD2 snapshots
├── consumer
│   └── kafka_to_minio.py
├── data-generator/            # Faker-based data simulator
│   └── faker_generator.py
├── docker/                    # Airflow DAGs, plugins, etc.
│   ├── dags/                  # DAGs (minio_to_snowflake, scd_snapshots)
├── kafka-debezium/            # Kafka connectors & CDC logic
│   └── generate_and_post_connector.py
├── postgres/                  # Postgres schema (OLTP DDL & seeds)
│   └── schema.sql
├── .gitignore
├── docker-compose.yml         # Containerized infra
├── dockerfile-airflow.dockerfile
├── requirements.txt
└── README.md
```

---

## ⚙️ Step-by-Step Implementation  

### **Prerequisites**
Before starting, ensure the following are installed on your system:  

##### **System Services**
- Docker & Docker Compose
- Python 3.10+
- Git
- Dbt
- Snowflake account (trial is sufficient)
---

##### **1. Clone the Repository**  

```text
git clone https://github.com/<your-username>/finops-data-platform.git
cd finops-data-platform
```
---

##### **2. Configure Environment Variables**  
```text
# ---------- Postgres (Banking OLTP) ----------
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=banking
POSTGRES_USER=banking_user
POSTGRES_PASSWORD=banking_pass

# ---------- Kafka ----------
KAFKA_BOOTSTRAP=kafka:9092
KAFKA_GROUP=banking-consumer-group

# ---------- MinIO ----------
MINIO_ENDPOINT=http://minio:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_BUCKET=banking-data
MINIO_LOCAL_DIR=/tmp/minio_downloads

# ---------- Snowflake ----------
SNOWFLAKE_ACCOUNT=xxxxxx.ap-south-1
SNOWFLAKE_USER=xxxx
SNOWFLAKE_PASSWORD=xxxx
SNOWFLAKE_WAREHOUSE=COMPUTE_WH
SNOWFLAKE_DB=BANKING
SNOWFLAKE_SCHEMA=RAW

# ---------- Airflow DB ----------
AIRFLOW_DB_USER=airflow
AIRFLOW_DB_PASSWORD=airflow
AIRFLOW_DB_NAME=airflow

# ---------- MinIO Root ----------
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin
```
---

##### **3. Start the Entire Infrastructure**  
This command launches
- PostgreSQL
- Kafka & Zookeeper  
- Debezium Connect  
- MinIO  
- Airflow (Webserver + Scheduler)
- Airflow Metadata DB

```text
docker-compose up -d
docker ps
```

---

##### **4. Connect to Postgres through Dbeaver**
- Download & Install [DBeaver](https://dbeaver.io/download/)
- Click New Database Connection → Select Postgres → Enter Details
- Create Schema (DDL) for **customers**, **accounts** & **transactions**  

---

##### **5. Generate Banking Data (Faker)**  
```text
pip install -r requirements.txt
``` 
###### Run Data Generator
```text
python data-generator/faker_generator.py
```
###### Note: After sufficient data is generated press **Ctrl + c** to exit iterations
---

##### **6. Create Debezium CDC Connector**  
###### This step enables Change Data Capture from Postgres to Kafka.
```text
python kafka-debezium/generate_and_post_connector.py
```
---

##### **7. Consume Kafka Events → MinIO**  
###### Run the Kafka consumer:
```text
python consumer/kafka_to_minio.py
```
###### What happens:
- Reads CDC events from Kafka
- Buffers records
- Writes Parquet files to MinIO
---

##### **8. Airflow: Load MinIO → Snowflake (RAW Layer)**
###### Access Airflow UI
```text
http://localhost:8081
```
###### Login:
- Username: airflow
- Password: airflow
###### Enable DAG
- DAG Name: minio_to_snowflake_banking
- Turn ON
- Trigger manually (or wait for schedule)
---

##### **9. Verify Data in Snowflake (RAW)**
```text
SELECT COUNT(*) FROM raw.customers;
UNION ALL
SELECT COUNT(*) FROM raw.accounts;
UNION ALL
SELECT COUNT(*) FROM raw.transactions;
```
---

##### **10. Verify Data in Snowflake (RAW)**
###### Inside Airflow Container (or locally)
```text
cd banking_dbt
dbt deps
dbt run
dbt test
```
###### This builds:
- Staging models
- Fact & dimension tables
---

##### **11. Run SCD Type-2 Snapshots**
###### Enable the Airflow DAG:
```text
DAG: SCD2_snapshots
```
###### DAG Steps
- dbt snapshot
- dbt run --select marts

###### Validate SCD Columns
```text
SELECT * FROM ANALYTICS.DIM_CUSTOMERS;
```
---
##### **12. Run SCD Type-2 Snapshots**
###### Final analytics tables:
- ANALYTICS.DIM_CUSTOMERS
- ANALYTICS.DIM_ACCOUNTS
- ANALYTICS.FACT_TRANSACTIONS

## 📊 Final Deliverables  
- **Automated CDC pipeline** from Postgres → Snowflake  
- **DBT models** (facts, dimensions, snapshots)  
- **Orchestrated DAGs in Airflow**  
- **Synthetic banking dataset** for demos  
- **CI/CD workflows** ensuring reliability  
---

**Author**: *Shubham Raju Mergu*  
**LinkedIn**: [shubham-mergu](https://www.linkedin.com/in/shubham-mergu/)  
**Contact**: [shubhammergu.work@gmail.com](mailto:shubhammergu.work@gmail.com)  