**First Login to the consol**

Create a IAM user with Programmatic access  and copy the Access key and Secret Key.

Create a s3 bucket named **moheim-terraform-remote-state**

**Command to use for Infrastructure** 

 terraform init -backend-config="infrastructure-prod.config"

 terraform plan -var-file="production.tfvars"

 terraform apply -var-file="production.tfvars"




**Command to use for Instances** 

Create a keypair named **myEC2Keypair**  first and than start execute below commands


terraform init -backend-config="backend-prod.config"

 terraform plan -var-file="production.tfvars"

 terraform apply -var-file="production.tfvars"