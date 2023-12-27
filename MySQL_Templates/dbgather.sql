-- SET @dbname = 'singledb';
--  SELECT CONCAT("-- Info gathered for ",@dbname, " Please change this DB name appropriately ") db_name;
-- SELECT ' -- Status Info -- ';
-- SELECT ' ';
-- SHOW STATUS;
SELECT VERSION();
SELECT ' -- Variable Info -- ';
SELECT ' ';
SHOW VARIABLES;

SELECT ' -- InnoDB Info -- ';
SELECT ' ';
SET @SCH = IF(VERSION()<'5.7','information_schema','performance_schema');

SET @SQLSTMT=CONCAT("SELECT variable_value INTO @SERVER_COLLATION        FROM ",@SCH,".global_variables WHERE variable_name='collation_server'");
PREPARE s FROM @SQLSTMT; EXECUTE s ; DEALLOCATE PREPARE s;

SET @SQLSTMT=CONCAT("SELECT variable_value INTO @HOSTNAME        FROM ",@SCH,".global_variables WHERE variable_name='hostname'");
PREPARE s FROM @SQLSTMT; EXECUTE s ; DEALLOCATE PREPARE s;

SET @SQLSTMT=CONCAT("SELECT variable_value INTO @IBP_SIZE        FROM ",@SCH,".global_variables WHERE variable_name='innodb_buffer_pool_size'");
PREPARE s FROM @SQLSTMT; EXECUTE s ; DEALLOCATE PREPARE s;

SET @SQLSTMT=CONCAT("SELECT variable_value INTO @IBP_PAGES_DATA  FROM ",@SCH,".global_status    WHERE variable_name='Innodb_buffer_pool_pages_data'");
PREPARE s FROM @SQLSTMT; EXECUTE s ; DEALLOCATE PREPARE s;

SET @SQLSTMT=CONCAT("SELECT variable_value INTO @IBP_PAGES_FREE  FROM ",@SCH,".global_status    WHERE variable_name='Innodb_buffer_pool_pages_free'");
PREPARE s FROM @SQLSTMT; EXECUTE s ; DEALLOCATE PREPARE s;

SET @SQLSTMT=CONCAT("SELECT variable_value INTO @IBP_PAGES_MISC  FROM ",@SCH,".global_status    WHERE variable_name='Innodb_buffer_pool_pages_misc'");
PREPARE s FROM @SQLSTMT; EXECUTE s ; DEALLOCATE PREPARE s;

SET @SQLSTMT=CONCAT("SELECT variable_value INTO @IBP_PAGES_TOTAL FROM ",@SCH,".global_status    WHERE variable_name='Innodb_buffer_pool_pages_total'");
PREPARE s FROM @SQLSTMT; EXECUTE s ; DEALLOCATE PREPARE s;

SET @SQLSTMT=CONCAT("SELECT variable_value INTO @IBP_PAGE_SIZE   FROM ",@SCH,".global_status    WHERE variable_name='Innodb_page_size'");
PREPARE s FROM @SQLSTMT; EXECUTE s ; DEALLOCATE PREPARE s;

SET @IBP_PCT_DATA = 100.00 * @IBP_PAGES_DATA / @IBP_PAGES_TOTAL;
SET @IBP_PCT_FREE = 100.00 * @IBP_PAGES_FREE / @IBP_PAGES_TOTAL;
SET @IBP_PCT_MISC = 100.00 * @IBP_PAGES_MISC / @IBP_PAGES_TOTAL;
SET @IBP_PCT_FULL = 100.00 * (@IBP_PAGES_TOTAL - @IBP_PAGES_FREE) / @IBP_PAGES_TOTAL;
SET @initpad = 19;
SET @padding = IF(LENGTH(@HOSTNAME)>@initpad,LENGTH(@HOSTNAME),@initpad);
SET @decimal_places = 5; SET @KB = 1024; SET @MB = POWER(1024,2); SET @GB = POWER(1024,3);

-- SELECT @IBP_SIZE, @GB;
SELECT       'innodb_buffer_pool_size' as 'Option',LPAD(FORMAT(@IBP_SIZE,0),@padding,' ') Value
UNION SELECT 'innodb_buffer_pool_size GB',LPAD(FORMAT(@IBP_SIZE / @GB,0),@padding,' ');

SELECT       'Hostname' Status                ,LPAD(@HOSTNAME,@padding,' ') Value
UNION SELECT 'This Moment'                    ,NOW()
UNION SELECT 'Innodb_page_size'               ,LPAD(FORMAT(@IBP_PAGE_SIZE,0),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_pages_data'  ,LPAD(FORMAT(@IBP_PAGES_DATA ,0),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_pages_free'  ,LPAD(FORMAT(@IBP_PAGES_FREE ,0),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_pages_misc'  ,LPAD(FORMAT(@IBP_PAGES_MISC ,0),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_pages_total' ,LPAD(FORMAT(@IBP_PAGES_TOTAL,0),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_bytes_data'  ,LPAD(FORMAT(@IBP_PAGES_DATA  * @IBP_PAGE_SIZE,0),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_bytes_free'  ,LPAD(FORMAT(@IBP_PAGES_FREE  * @IBP_PAGE_SIZE,0),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_bytes_misc'  ,LPAD(FORMAT(@IBP_PAGES_MISC  * @IBP_PAGE_SIZE,0),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_bytes_total' ,LPAD(FORMAT(@IBP_PAGES_TOTAL * @IBP_PAGE_SIZE,0),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_data GB'     ,LPAD(FORMAT(@IBP_PAGES_DATA  * @IBP_PAGE_SIZE / @GB,@decimal_places),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_free KB'     ,LPAD(FORMAT(@IBP_PAGES_FREE  * @IBP_PAGE_SIZE / @KB,@decimal_places),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_free MB'     ,LPAD(FORMAT(@IBP_PAGES_FREE  * @IBP_PAGE_SIZE / @MB,@decimal_places),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_free GB'     ,LPAD(FORMAT(@IBP_PAGES_FREE  * @IBP_PAGE_SIZE / @GB,@decimal_places),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_free GB'     ,LPAD(FORMAT(@IBP_PAGES_FREE  * @IBP_PAGE_SIZE / @GB,@decimal_places),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_misc KB'     ,LPAD(FORMAT(@IBP_PAGES_MISC  * @IBP_PAGE_SIZE / @KB,@decimal_places),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_misc MB'     ,LPAD(FORMAT(@IBP_PAGES_MISC  * @IBP_PAGE_SIZE / @MB,@decimal_places),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_misc GB'     ,LPAD(FORMAT(@IBP_PAGES_MISC  * @IBP_PAGE_SIZE / @GB,@decimal_places),@padding,' ')
UNION SELECT 'Innodb_buffer_pool_total GB'    ,LPAD(FORMAT(@IBP_PAGES_TOTAL * @IBP_PAGE_SIZE / @GB,@decimal_places),@padding,' ')
UNION SELECT 'Percentage Data'                ,LPAD(CONCAT(FORMAT(@IBP_PCT_DATA,2),' %'),@padding,' ')
UNION SELECT 'Percentage Free'                ,LPAD(CONCAT(FORMAT(@IBP_PCT_FREE,2),' %'),@padding,' ')
UNION SELECT 'Percentage Misc'                ,LPAD(CONCAT(FORMAT(@IBP_PCT_MISC,2),' %'),@padding,' ')
UNION SELECT 'Percentage Used'                ,LPAD(CONCAT(FORMAT(@IBP_PCT_FULL,2),' %'),@padding,' ')
;

SELECT ' -- Database Size Info -- ';
SELECT ' ';
SELECT table_schema as database_name, SUM(data_length + index_length)/1024/1024 AS total_mb, SUM(data_length)/1024/1024 AS data_mb, SUM(index_length)/1024/1024 AS index_mb, COUNT(*) AS tables, CURDATE() AS today 
FROM information_schema.tables 
GROUP BY table_schema ORDER BY 2 DESC ;


SELECT ' -- Data and Index Info -- ';
SELECT ' ';
select table_schema as database_name,
       table_name,
       round(1.0*data_length/1024/1024, 2) as data_size,
       round(index_length/1024/1024, 2) as index_size,
       round((data_length + index_length)/1024/1024, 2) as total_size
from information_schema.tables
where table_schema not in('information_schema', 'mysql',
                          'sys', 'performance_schema')
 --     and table_schema = @dbname
order by database_name,total_size desc;

SELECT ' -- Reference Key Info -- ';
SELECT ' ';
select concat(fks.constraint_schema, '.', fks.table_name) as foreign_table,
       '->' as rel,
       concat(fks.unique_constraint_schema, '.', fks.referenced_table_name)
              as primary_table,
       fks.constraint_name,
       group_concat(kcu.column_name
            order by position_in_unique_constraint separator ', ')
             as fk_columns
from information_schema.referential_constraints fks
join information_schema.key_column_usage kcu
     on fks.constraint_schema = kcu.table_schema
     and fks.table_name = kcu.table_name
     and fks.constraint_name = kcu.constraint_name
-- where fks.constraint_schema = @dbname COLLATE @SERVER_COLLATION
where  fks.constraint_schema not in('information_schema', 'mysql',
                          'sys', 'performance_schema')
group by fks.constraint_schema,
         fks.table_name,
         fks.unique_constraint_schema,
         fks.referenced_table_name,
         fks.constraint_name
order by fks.constraint_schema,
         fks.table_name;


SELECT ' -- Top 10 tables size wise Info -- ';
SELECT ' ';
SELECT CONCAT(table_schema, '.', table_name) table_name,
        CONCAT(ROUND(table_rows / 1000000, 2), 'M')                                    total_rows,
        CONCAT(ROUND(data_length / ( 1024 * 1024 * 1024 ), 2), 'G')                    DATA,
        CONCAT(ROUND(index_length / ( 1024 * 1024 * 1024 ), 2), 'G')                   idx,
        CONCAT(ROUND(( data_length + index_length ) / ( 1024 * 1024 * 1024 ), 2), 'G') total_size,
        ROUND(index_length / data_length, 2)                                           idxPct
 FROM   information_schema.TABLES
-- WHERE table_schema = @dbname
 WHERE table_schema not in('information_schema', 'mysql',
                          'sys', 'performance_schema')
 ORDER  BY data_length + index_length DESC
 LIMIT  10 ;


