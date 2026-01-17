-- CUSTOMER
CREATE EXTERNAL TABLE raw.customer_tbl (
  c_custkey bigint,
  c_name string,
  c_address string,
  c_nationkey bigint,
  c_phone string,
  c_acctbal double,
  c_mktsegment string,
  c_comment string
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
LOCATION 's3://<s3-bucket>/customer/';

-- LINEITEM
CREATE EXTERNAL TABLE raw.lineitem_tbl (
  l_orderkey bigint,
  l_partkey bigint,
  l_suppkey bigint,
  l_linenumber bigint,
  l_quantity double,
  l_extendedprice double,
  l_discount double,
  l_tax double,
  l_returnflag string,
  l_linestatus string,
  l_shipdate string,
  l_commitdate string,
  l_receiptdate string,
  l_shipinstruct string,
  l_shipmode string,
  l_comment string
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
LOCATION 's3://<s3-bucket>/lineitem/';

-- NATION
CREATE EXTERNAL TABLE raw.nation_tbl (
  n_nationkey bigint,
  n_name string,
  n_regionkey bigint,
  n_comment string
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
LOCATION 's3://<s3-bucket>/nation/';

-- ORDERS
CREATE EXTERNAL TABLE raw.orders_tbl (
  o_orderkey bigint,
  o_custkey bigint,
  o_orderstatus string,
  o_totalprice double,
  o_orderdate string,
  o_orderpriority string,
  o_clerk string,
  o_shippriority bigint,
  o_comment string
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
LOCATION 's3://<s3-bucket>/orders/';

-- PART
CREATE EXTERNAL TABLE raw.part_tbl (
  p_partkey bigint,
  p_name string,
  p_mfgr string,
  p_brand string,
  p_type string,
  p_size bigint,
  p_container string,
  p_retailprice double,
  p_comment string
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
LOCATION 's3://<s3-bucket>/part/';

-- PARTSUPP
CREATE EXTERNAL TABLE raw.partsupp_tbl (
  ps_partkey bigint,
  ps_suppkey bigint,
  ps_availqty bigint,
  ps_supplycost double,
  ps_comment string
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
LOCATION 's3://<s3-bucket>/partsupp/';

-- REGION
CREATE EXTERNAL TABLE raw.region_tbl (
  r_regionkey bigint,
  r_name string,
  r_comment string
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
LOCATION 's3://<s3-bucket>/region/';

-- SUPPLIER
CREATE EXTERNAL TABLE raw.supplier_tbl (
  s_suppkey bigint,
  s_name string,
  s_address string,
  s_nationkey bigint,
  s_phone string,
  s_acctbal double,
  s_comment string
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
LOCATION 's3://<s3-bucket>/supplier/';

--  confirm table counts 
SELECT 'customer_tbl' as table_name, COUNT(*) as row_count FROM raw.customer_tbl
UNION ALL
SELECT 'lineitem_tbl', COUNT(*) FROM raw.lineitem_tbl
UNION ALL
SELECT 'nation_tbl', COUNT(*) FROM raw.nation_tbl
UNION ALL
SELECT 'orders_tbl', COUNT(*) FROM raw.orders_tbl
UNION ALL
SELECT 'part_tbl', COUNT(*) FROM raw.part_tbl
UNION ALL
SELECT 'partsupp_tbl', COUNT(*) FROM raw.partsupp_tbl
UNION ALL
SELECT 'region_tbl', COUNT(*) FROM raw.region_tbl
UNION ALL
SELECT 'supplier_tbl', COUNT(*) FROM raw.supplier_tbl
ORDER BY table_name;