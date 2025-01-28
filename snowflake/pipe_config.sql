-- Not disclosed for privacy concerns
-- create or replace storage integration s3_streaming_bucket
    -- type = external_stage
    -- storage_provider = S3
    -- enabled = true
    -- storage_aws_role_arn = ''
    -- storage_allowed_locations = ( 's3://realtimepipeline');

desc integration s3_streaming_bucket;

CREATE OR REPLACE FILE FORMAT SCD_DEMO.SCD2.CSV
TYPE = CSV,
FIELD_DELIMITER = ","
SKIP_HEADER = 1;

create or replace stage SCD_DEMO.SCD2.customer_ext_stage
url = 's3://realtimepipeline'
storage_integration = s3_streaming_bucket
file_format = SCD_DEMO.SCD2.CSV;

list @customer_ext_stage;

create or replace pipe customer_s3_pipe
auto_ingest = true
as
copy into customer_raw
file_format = SCD_DEMO.SCD2.CSV
from @SCD_PROJECT.SCD2.customer_ext_stage;

show pipes;
select SYSTEM$PIPE_STATUS('customer_s3_pipe');
SELECT count(*) FROM customer_raw limit 10;
TRUNCATE  customer_raw;