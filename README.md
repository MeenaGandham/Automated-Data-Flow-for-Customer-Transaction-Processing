# Real-time SCD Pipeline

## Overview
This project builds a real-time data streaming pipeline to handle customer data efficiently, enabling data ingestion, processing, and transformation using modern cloud-based technologies. The pipeline is designed to handle Slowly Changing Dimensions (SCD1 & SCD2) in Snowflake, leveraging Apache NiFi for real-time ingestion and Snowpipe for automated data loading.

![Architecture Diagram](resources/imgs/Real%20Time%20Pipeline.png)

## Key Features
- Real-time Data Generation using Python
- Automated Ingestion & Processing via Apache NiFi
- Cloud-based Storage with Amazon S3
- Snowpipe & Streams for Incremental Data Loading
- SCD1 & SCD2 Data Management in Snowflake
- Dockerized Deployment for easy scalability

## Data Flow Process

### Data Generation (Python script generates synthetic customer data)
- Custom Python script using Faker library
- Docker containerization
- Volume mounting for data sharing
- Configurable data generation intervals

### Data Ingestion → Apache NiFi processes and transfers data to Amazon S3 and Cloud Storage → Data lands in Amazon S3 for staging.

- Apache NiFi for data flow management
- Apache ZooKeeper for distributed coordination
- AWS EC2 for hosting services
- S3 bucket for data lake storage

![NiFi Flow Configuration Screenshot](resources/imgs/nifi_flow_in_process.png)

### Automated Processing → Snowpipe loads new data into Snowflake, Change Data Capture (CDC) → Snowflake Streams capture data changes, Transformation → Snowflake Tasks apply SCD1 & SCD2 logic and Final Data Storage → Data is merged into historical and final tables.

- Snowflake for data warehousing
- Snowpipe for automated data loading
- Snow Stream for change data capture
- Scheduled data processing tasks

## Technical Design Decisions

### SCD1 and SCD2 Implementation
The project implements a dual-table strategy:
- **SCD1 Main Table**: 
  - Maintains current, accurate data
  - Optimizes query performance
  - Eliminates redundancy
  
- **SCD2 History Table**:
  - Tracks historical changes
  - Maintains data lineage
  - Enables point-in-time analysis

### Performance Optimization
- Separation of current and historical data reduces compute time
- Efficient merge operations for real-time updates
- Stream-based change capture minimizes processing overhead

### Scalability Considerations
- Containerized architecture enables easy scaling
- Cloud-based infrastructure allows for flexible resource allocation
- Parallel processing capability through Snowflake

## Real-World Applications

This pipeline architecture demonstrates enterprise-ready capabilities for:
- Customer data management systems
- Financial transaction tracking
- Product inventory management
- User profile management
- Compliance and audit systems

The separation of SCD1 and SCD2 tables reflects real-world requirements where:
- Business teams need quick access to current data
- Audit teams require historical tracking
- Analytics teams need point-in-time analysis capabilities

