#### Policies ####
# Create the Policy Definition (Subscription scope)
az policy definition create --name tagging-policy --display-name "Deny untagged resources deployement" --description "This policy check if a tag is present on a resource and deny deployement otherwise" --rules policy.rules.json --mode All

# Create the Policy Assignment
az policy assignment create --name 'tagging-policy-assignment' --display-name "Deny untagged resources deployement Assignment" --scope /subscriptions/<subscriptionId> --policy /subscriptions/<subscriptionId>/providers/Microsoft.Authorization/policyDefinitions/tagging-policy

#### ... ####