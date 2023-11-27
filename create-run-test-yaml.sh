# Create and run a load test and download results

#subscription="43d4dcea-8c79-4797-9e06-44006577b8b6" # add subscription here
resourceGroup="DeveloperVelocity"
location="East US"
loadTestResource="JP-ALT"
testId="myloadtest"

az config set extension.use_dynamic_install=yes_without_prompt


# Create a resource if not already exists
#az load create --name $loadTestResource --location $location

# Create a test with Load Test config YAML file
loadTestConfig="config.yaml"

if [[ $(az load test list --resource-group $resourceGroup --load-test-resource $loadTestResource  --query "[?testId=='$testId'] | length(@)") > 0 ]]
then
  echo "ALT Test exists.. updating"
  az load test update --load-test-resource $loadTestResource --resource-group $resourceGroup --test-id $testId --load-test-config-file $loadTestConfig 
else
  echo "ALT Test doesn't exist.. creating"
  az load test create --load-test-resource  $loadTestResource --resource-group $resourceGroup --test-id $testId --load-test-config-file $loadTestConfig --display-name $loadTestConfig --description "Created using Az CLI YAML" 
fi


## Optional if you want to add Azure resource to server-side metrics 
# Add an app component
#az load test app-component add --load-test-resource  $loadTestResource --test-id $testId --app-component-id "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/samplerg/providers/Microsoft.Web/sites/demo-podcastwebapp" --app-component-type "Microsoft.Web/sites" --app-component-name "demo-podcastwebapp"
# Create a server metric for the app component
#az load test server-metric add --load-test-resource $loadTestResource --test-id $testId --metric-id "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/samplerg/providers/Microsoft.Web/sites/demo-podcastwebapp/providers/microsoft.insights/metricdefinitions/Http4xx" --metric-name "Http4xx" --metric-namespace "Microsoft.Web/sites" --app-component-id "/subscriptions/7c71b563-0dc0-4bc0-bcf6-06f8f0516c7a/resourceGroups/demo-podcast/providers/Microsoft.Web/sites/demo-podcastwebapp" --app-component-type "Microsoft.Web/sites" --aggregation "Average"

# Run the test
testRunId="run_"`date +"%Y%m%d%_H%M%S"`
displayName="Run"`date +"%Y/%m/%d_%H:%M:%S"`

az load test-run create --load-test-resource $loadTestResource --resource-group $resourceGroup --test-id $testId --test-run-id $testRunId --display-name $displayName --description "Test run from CLI"

# Download results
az load test-run download-files --load-test-resource $loadTestResource --resource-group $resourceGroup --test-run-id $testRunId --path "Results" --result --force

# Get test run client-side metrics
az load test-run metrics list --load-test-resource $loadTestResource --resource-group $resourceGroup --test-run-id $testRunId --metric-namespace LoadTestRunMetrics 