import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue import DynamicFrame

args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Script generated for node Amazon S3
AmazonS3_node1756398133935 = glueContext.create_dynamic_frame.from_options(format_options={}, connection_type="s3", format="parquet", connection_options={"paths": ["s3://naya-de-rds-cdc-s3/silver_data/dev/Product/"], "recurse": True}, transformation_ctx="AmazonS3_node1756398133935")

# Script generated for node Amazon Redshift
AmazonRedshift_node1756398254158 = glueContext.write_dynamic_frame.from_options(frame=AmazonS3_node1756398133935, connection_type="redshift", connection_options={"redshiftTmpDir": "s3://aws-glue-assets-672711092573-us-east-1/temporary/", "useConnectionProperties": "true", "dbtable": "sales.stage_dim_product", "connectionName": "redshift-connection", "preactions": "CREATE TABLE IF NOT EXISTS sales.stage_dim_product (cdc_operation VARCHAR, dms_timestamp VARCHAR, product_id VARCHAR, product_name VARCHAR, brand_name VARCHAR, product_description VARCHAR, product_price DECIMAL, product_category VARCHAR, created_at TIMESTAMP, updated_at TIMESTAMP, hash_value VARCHAR, record_start_ts TIMESTAMP, record_end_ts TIMESTAMP, active_flag INTEGER);"}, transformation_ctx="AmazonRedshift_node1756398254158")

job.commit()