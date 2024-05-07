--- To create a kubernetes cluster using aws ec2 linux machines

--Prerequisites:
- Fist Configure your machine to connect to aws through aws configure
- Install terraform ( minimum version 1.3 )
 by default a cluster of one controller node and 2 worker is created in a vpc 10.0.0.0/16 and the subnet 10.0.1.0/16
 To customize these parameters  change the variables in terraform/variables.tf

```bash

cd terraform
terraform init
terraform plan
terraform apply --auto-approve
```