$dir="C:\Temp\MyDonkeyApp"
$file=Join-Path $dir "my_powershell_gen_file.txt" 
New-Item -ItemType File -Path $file -ErrorAction SilentlyContinue
$date=Get-Date
Add-Content -Value "hellow world from powershell $date" $file