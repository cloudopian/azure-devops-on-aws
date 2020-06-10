Param(
$stackName="CatHome",
$templatePath="C:\Dev\MyCatApp\network.template"
)
Write-Host "Reading the template $templatePath"
$content = [IO.File]::ReadAllText($templatePath)
Write-Host "Testing the template"
$testResult=Test-CFNTemplate -TemplateBody $content

if ($testResult -eq $null){
    Exit 1
}else{
    $s=$null
    try{
        $s=Get-CFNStack -StackName $stackName
    }catch{

    }

    if($s -eq $null){
    $s=New-CFNStack -StackName $stackName -OnFailure ROLLBACK -ResourceType  "AWS::*"   -TemplateBody $content  -TimeoutInMinutes 10
    }else{

    try{
    Update-CFNStack -StackName $stackName -ResourceType "AWS::*" -TemplateBody $content  -ErrorAction SilentlyContinue
    }catch{
    
    }
    }
}

