Set-ExecutionPolicy RemoteSigned
New-Item -Path "c:\Temp" -ItemType "directory" -Force
Invoke-WebRequest -Uri https://aws-codedeploy-ap-southeast-2.s3.amazonaws.com/latest/codedeploy-agent.msi -OutFile C:\temp\codedeploy-agent.msi
c:\Temp\codedeploy-agent.msi /quiet /l c:\Temp\host-agent-install-log.txt
Get-Service -Name codedeployagent