

Param(
    [string] $ResourceGroupName = 'DefaultResourceGroup-null',
    [string] $ResourceLocation = 'Canada East',
    [string] $api = 'salesforce',
    [string] $ConnectionName = 'salesforce',
    [string] $subscriptionId = 'a84bfa33-426b-40a9-aea7-d427040be66c',
    [bool] $createConnection =  $false
)
 #region mini window, made by Scripting Guy Blog

#login to get an access code 

Login-AzureRmAccount 

#select the subscription

$subscription = Select-AzureRmSubscription -SubscriptionId $subscriptionId

#if the connection wasn't alrady created via a deployment
if($createConnection)
{
    $connection = New-AzureRmResource -Properties @{"api" = @{"id" = "subscriptions/" + $subscriptionId + "/providers/Microsoft.Web/locations/" + $ResourceLocation + "/managedApis/" + $api}; "displayName" = $ConnectionName; } -ResourceName $ConnectionName -ResourceType "Microsoft.Web/connections" -ResourceGroupName $ResourceGroupName -Location $ResourceLocation -Force
}
#else (meaning the conneciton was created via a deployment) - get the connection
else{
$connection = Get-AzureRmResource -ResourceType "Microsoft.Web/connections" -ResourceGroupName $ResourceGroupName -ResourceName $ConnectionName
}
Write-Host "connection status: " $connection.Properties.Statuses[0]

$parameters = @{
	"parameters" = ,@{
	"parameterName"= "token";
	"redirectUrl"= "https://ema1.exp.azure.com/ema/default/authredirect"
	}
}

#get the links needed for consent
$consentResponse = Invoke-AzureRmResourceAction -Action "listConsentLinks" -ResourceId $connection.ResourceId -Parameters $parameters -Force

$url = $consentResponse.Value.Link 
Write-Host $url
