Param(
$appName="MyTigerApp",
$appVersion="18",
$s3SourceBucket="my-build-artifact",
$s3SourceKey="MyTigerAppDeliveries/MyTigerApp.zip",
$appEnvName="MyTigerApp-Dev",
$sleepTime=5
)
$appDescription="Application to demonstrate AWS Elastic Beanstalk"
$app=Get-EBApplication -ApplicationName $appName

if($app -eq $null){
    Write-Host "Creating a new EB application $appName"
    New-EBApplication -ApplicationName $appName -Description $appDescription
}

$currentApp=Get-EBApplicationVersion -ApplicationName $appName -VersionLabel $appVersion
if($currentApp -eq $null){
    Write-Host "Creating a new EB application version $appVersion"
    New-EBApplicationVersion -ApplicationName $appName -VersionLabel $appVersion -Description $appName -AutoCreateApplication $false -SourceBundle_S3Bucket $s3SourceBucket -SourceBundle_S3Key $s3SourceKey  -Force -Process $true
    while ((Get-EBApplicationVersion -ApplicationName $appName -VersionLabel $appVersion | Select-Object Status -ExpandProperty Status) -ne "Processed"){
     Start-Sleep -s $sleepTime
     Write-Host "Waiting $appName status changed to processed"
    }
    Write-Host "$appName version $appVersion status changed to processed"
}

$isEnvTermating=$false

do{
    $appEnv=(Get-EBEnvironment -ApplicationName $appName -EnvironmentName $appEnvName -IncludeDeleted $false)
    if($appEnv -eq $null){
        Write-Host "Creating a new environment"
        New-EBEnvironment -ApplicationName $appName -EnvironmentName $appEnvName -Description "$appEnvName for $appName" -SolutionStackName "64bit Windows Server Core 2019 v2.5.6 running IIS 10.0" -OptionSetting @{Namespace="aws:autoscaling:launchconfiguration";OptionName="InstanceType";Value="t3.small"} , @{Namespace="aws:autoscaling:asg";OptionName="MaxSize";Value="2"} -VersionLabel $appVersion -Force
    
        while(((Get-EBEnvironment -ApplicationName $appName -EnvironmentName $appEnvName -IncludeDeleted $false)| select -ExpandProperty Status) -ne "Ready"){
            Write-Host "Waiting the environment $appEnvName become ready for $appName"
        }
        Write-Host "$appName version $appVersion is ready at http://"$appEnv.EndpointURL    
        }

    if($appEnv -ne $null -and $appEnv.Status -ne "Terminating" -and $appEnv.Status -ne "Terminated"){
        Write-Host "Updating the environment"
        Update-EBEnvironment -ApplicationName $appName -EnvironmentName $appEnvName -VersionLabel $appVersion -OptionSetting @{Namespace="aws:autoscaling:launchconfiguration";OptionName="InstanceType";Value="t3.small"} , @{Namespace="aws:autoscaling:asg";OptionName="MaxSize";Value="2"} -Description "Deployed by Azure DevOps" -Force
        while(( (Get-EBEnvironment -ApplicationName $appName -EnvironmentName $appEnvName -IncludeDeleted $false) | select -ExpandProperty Status) -ne "Ready"){
            Write-Host "Waiting the environment $appEnvName become ready for $appName after deploying the version $appVersion"
        }
        Write-Host "$appName version $appVersion is ready at http://"$appEnv.EndpointURL
    }

    $isEnvTerminating=($appEnv.Status -eq "Terminating")
    if($isEnvTerminating){
     Write-Host "The environment $appEnvName of the app $appName is terminating, I will try to create a one once it is terminated"
     Start-Sleep -s $sleepTime
    }

}while($isEnvTerminating)



