# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure (Udacity nd082 P1)

### Introduction
This project deploy a scalable web server in Azure according to IaC (Infrastructure as Code) principles.

### Getting Started
1. Clone this repository
2. Install the required dependencies
3. Follow the instructions to deploy the IaaS web server in Azure

### Dependencies
* Create an [Azure Account](https://portal.azure.com) 
* Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
* Install [Packer](https://www.packer.io/downloads)
* Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
1. CD to this project directory

2. Login to your Azure account with the Cli
``` bash
az login
```

3. Create and deploy an Azure Policy
``` bash
az policy definition create --name tagging-policy --display-name "Deny untagged resources deployement" --description "This policy check if a tag is present on a resource and deny deployement otherwise" --rules policy.rules.json --mode All
```

4. Assign the policy to your subscription
``` bash
az policy assignment create --name 'tagging-policy-assignment' --display-name "Deny untagged resources deployement Assignment" --scope /subscriptions/<subscriptionId> --policy /subscriptions/<subscriptionId>/providers/Microsoft.Authorization/policyDefinitions/tagging-policy
```

5. Run Packer
``` bash
packer build -var 'subscription_id=<subscriptionId>' server.json
```

6. Run Terraform
``` bash
terraform plan -out solution.plan
```

7. Deploy the solution in Azure
``` bash
terraform apply solution.plan
```

8. Show the deployed infrastructure
``` bash
terraform show
```

9. Destroy all remote objects
``` bash
terraform destroy
```

> :warning: **Don't forget to destroy all unused ressources in Azure to avoid unwanted costs!**
