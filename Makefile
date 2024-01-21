
.PHONY: default deploy destroy

default:

deploy:
	terraform init \
		&& terraform apply -auto-approve -input=false \
		&& export DEMO_DDB_TABLE_NAME="$$(terraform output -raw demo_table_name)" \
		&& node scripts/init-data.js

destroy:
	terraform destroy -auto-approve -input=false
