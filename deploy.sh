#!/bin/bash

echo "terraform init"

terraform -chdir=vpc init \
&& terraform -chdir=eks init

echo "terraform apply"
terraform -chdir=vpc apply -auto-approve \
&& terraform -chdir=eks apply -auto-approve
