#!/bin/bash

echo "terraform init"

terraform -chdir=vpc init \
&& terraform -chdir=eks init

echo "terraform destroy"
terraform -chdir=eks destroy -auto-approve
# && terraform -chdir=vpc destroy -auto-approve
