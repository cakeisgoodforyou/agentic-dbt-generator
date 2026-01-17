#!/bin/bash
#
# Copy TPC-H files from AWS public bucket to your own bucket
# with proper folder structure for Athena/Glue
#

set -e

cd terraform

# Configuration
SOURCE_BUCKET="s3://redshift-downloads/TPC-H/2.18/10GB"
DEST_BUCKET="s3://$(terraform output -raw dbt_projects_bucket)/tpch-data"

echo "======================================"
echo "Reorganizing TPC-H Data"
echo "======================================"
echo ""
echo "Source: $SOURCE_BUCKET"
echo "Destination: $DEST_BUCKET"
echo ""

# List of tables
TABLES="customer lineitem nation orders part partsupp region supplier"

for TABLE in $TABLES; do
    echo "Copying ${TABLE}.tbl..."
    
    # Create folder for table and copy file into it
    aws s3 cp "${SOURCE_BUCKET}/${TABLE}.tbl" "${DEST_BUCKET}/${TABLE}/${TABLE}.tbl"
    
    if [ $? -eq 0 ]; then
        echo "✓ Copied $TABLE"
    else
        echo "✗ Failed to copy $TABLE"
        # exit 1
    fi
done

echo ""
echo "======================================"
echo "File structure created:"
echo "======================================"
echo ""

aws s3 ls "${DEST_BUCKET}/" --recursive | grep -E '\.tbl$'

echo ""
echo "✓ All files reorganized!"
echo ""
echo "New structure:"
echo "  ${DEST_BUCKET}/customer/customer.tbl"
echo "  ${DEST_BUCKET}/lineitem/lineitem.tbl"
echo "  ${DEST_BUCKET}/nation/nation.tbl"
echo "  etc..."
echo ""
echo "You can now point Glue Crawler at: ${DEST_BUCKET}/"