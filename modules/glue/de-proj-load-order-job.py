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
AmazonS3_node1756404267276 = glueContext.create_dynamic_frame.from_options(format_options={}, connection_type="s3", format="parquet", connection_options={"paths": ["s3://naya-de-rds-cdc-s3/silver_data/dev/Orders/"], "recurse": True}, transformation_ctx="AmazonS3_node1756404267276")

# Script generated for node Amazon Redshift
AmazonRedshift_node1756404344350 = glueContext.write_dynamic_frame.from_options(frame=AmazonS3_node1756404267276, connection_type="redshift", connection_options={"redshiftTmpDir": "s3://aws-glue-assets-672711092573-us-east-1/temporary/", "useConnectionProperties": "true", "dbtable": "sales.fact_orders", "connectionName": "redshift-connection", "preactions": "CREATE TABLE IF NOT EXISTS sales.fact_orders (dms_timestamp VARCHAR, order_id_ VARCHAR, order_customer_id VARCHAR, order_date DATE, payment_method VARCHAR, order_platform VARCHAR, created_at TIMESTAMP, updated_at TIMESTAMP, order_year INTEGER, order_month INTEGER, ingestion_date DATE);"}, transformation_ctx="AmazonRedshift_node1756404344350")

job.commit()