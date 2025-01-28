show streams;
select * from customer_table_changes;

--View Creation--
create or replace view v_customer_change_data as
-- This subquery figures out what to do when data is inserted into the customer table
-- An insert to the customer table results in an INSERT to the customer_HISTORY table
select CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, STREET, CITY,STATE,COUNTRY,
 start_time, end_time, is_current, 'I' as dml_type
from (
select CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, STREET, CITY,STATE,COUNTRY,
             update_timestamp as start_time,
             lag(update_timestamp) over (partition by customer_id order by update_timestamp desc) as end_time_raw,
             case when end_time_raw is null then '9999-12-31'::timestamp_ntz else end_time_raw end as end_time,
             case when end_time_raw is null then TRUE else FALSE end as is_current
      from (select CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, STREET, CITY,STATE,COUNTRY,UPDATE_TIMESTAMP
            from SCD_DEMO.SCD2.customer_table_changes
            where metadata$action = 'INSERT'
            and metadata$isupdate = 'FALSE')
  )
union
-- This subquery figures out what to do when data is updated in the customer table
-- An update to the customer table results in an update AND an insert to the customer_HISTORY table
-- The subquery below generates two records, each with a different dml_type
select CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, STREET, CITY,STATE,COUNTRY, start_time, end_time, is_current, dml_type
from (select CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, STREET, CITY,STATE,COUNTRY,
             update_timestamp as start_time,
             lag(update_timestamp) over (partition by customer_id order by update_timestamp desc) as end_time_raw,
             case when end_time_raw is null then '9999-12-31'::timestamp_ntz else end_time_raw end as end_time,
             case when end_time_raw is null then TRUE else FALSE end as is_current, 
             dml_type
      from (-- Identify data to insert into customer_history table
            select CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, STREET, CITY,STATE,COUNTRY, update_timestamp, 'I' as dml_type
            from customer_table_changes
            where metadata$action = 'INSERT'
            and metadata$isupdate = 'TRUE'
            union
            -- Identify data in customer_HISTORY table that needs to be updated
            select CUSTOMER_ID, null, null, null, null, null,null,null, start_time, 'U' as dml_type
            from customer_history
            where customer_id in (select distinct customer_id 
                                  from customer_table_changes
                                  where metadata$action = 'DELETE'
                                  and metadata$isupdate = 'TRUE')
     and is_current = TRUE))
union
-- This subquery figures out what to do when data is deleted from the customer table
-- A deletion from the customer table results in an update to the customer_HISTORY table
select ctc.CUSTOMER_ID, null, null, null, null, null,null,null, ch.start_time, current_timestamp()::timestamp_ntz, null, 'D'
from customer_history ch
inner join customer_table_changes ctc
   on ch.customer_id = ctc.customer_id
where ctc.metadata$action = 'DELETE'
and   ctc.metadata$isupdate = 'FALSE'
and   ch.is_current = TRUE;

select * from v_customer_change_data;