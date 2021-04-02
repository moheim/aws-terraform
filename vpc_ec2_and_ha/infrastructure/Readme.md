**First Login to the consol**

-Create a IAM user with Programmatic access  and copy the Access key and Secret Key.

-Create a s3 bucket named **moheim-terraform-remote-state**

**Command to use**

 -terraform init -backend-config="infrastructure-prod.config"
 -terraform plan -var-file="production.tfvars" 
 -terraform apply -var-file="production.tfvars"
