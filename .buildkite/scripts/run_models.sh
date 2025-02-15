#!/bin/bash

set -euo pipefail

apt-get update
apt-get install libsasl2-dev

python3 -m venv venv
. venv/bin/activate
pip install --upgrade pip setuptools
pip install -r integration_tests/requirements.txt
mkdir -p ~/.dbt
cp integration_tests/ci/sample.profiles.yml ~/.dbt/profiles.yml

db=$1
echo `pwd`
cd integration_tests
dbt deps
dbt seed --target "$db" --full-refresh
dbt run --target "$db" --full-refresh
dbt test --target "$db"            
dbt run --vars '{hubspot_marketing_enabled: true, hubspot_sales_enabled: false}' --target "$db"
dbt run --vars '{hubspot_marketing_enabled: true, hubspot_contact_merge_audit_enabled: true, hubspot_sales_enabled: false}' --target "$db"
dbt run --vars '{hubspot_marketing_enabled: false, hubspot_sales_enabled: true}' --target "$db"
dbt run --vars '{hubspot_marketing_enabled: false, hubspot_sales_enabled: false}' --target "$db"
dbt test --target "$db"
