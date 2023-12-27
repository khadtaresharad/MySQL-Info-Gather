#---------------------------------------------------------------------------------------------------------------------------*
#  Purpose        : Script for Information gathering of Azure MySQL Single Server
#  Schedule       : Ad-Hoc / On-Demand
#  Date           : 19-July-2023
#  Author         : Rackimuthu Kandaswamy , Sireesha , ArunKumar , Saby , Lekshmy MK
#  Version        : 1.1
#   
#  INPUT          : NONE
#  VARIABLE       : NONE
#  PARENT         : NONE
#  CHILD          : NONE
#---------------------------------------------------------------------------------------------------------------------------*
#---------------------------------------------------------------------------------------------------------------------------*
#
#  IMPORTANT NOTE : The script has to be run on Non-Mission-Critical systems ONLY and not on any production server...
#
#---------------------------------------------------------------------------------------------------------------------------*
#---------------------------------------------------------------------------------------------------------------------------*
# Usage:
# Powershell.exe -File .\CMF-Azure-MySQL-Info-gathering_V1.1.ps1
#
<#
    Change Log
    ----------
•	Customer consent to install ImportExcel PS Module and Azure CLI
•	Excluded Flexi server Azure CLI commands.
•	Excluded Azure CLI commands Json file generation for single servers except Server list.
•	Incorporated Vcore column in INPUT EXCEL  Sheet  CMF-MySQL_Server_Input_file.xlsx file (Server_List Worksheet)
•	Incorporated servername in DB_List, Config_Details,AD Admin and Firewall-rule List  CLI commands output in output.xlsx
•	No column Filter applied when exporting AZURE CLI Commands output to output.xlsx file
•	Included az mysql server replica list CLI

        
#>
Set-ExecutionPolicy Bypass -Scope currentuser
CLS


#---------------------------------------------------------PROGRAM BEGINS HERE----------------------------------------------------------

write-host "                                                                            " -BackgroundColor DarkMagenta
Write-Host "     Welcome to CMF - Azure_MySQL_Info_Gathering_Automation                 " -ForegroundColor white -BackgroundColor DarkMagenta
write-host "                     (OSS DB Migration Factory)                             " -BackgroundColor DarkMagenta
write-host "                              V1.1                                          " -BackgroundColor DarkMagenta
Write-Host " "

$folder = $PSScriptRoot

Write-Host "`n======================================================================================="
Start-Transcript -path  $folder\Logs\CMF-Azure-MySQL-Info-gathering.txt -Append
Write-Host "`n======================================================================================="

function exitCode
{
    Write-Host "-Ending Execution"
    Stop-Transcript
    exit
}

function createFolder([string]$newFolder) 
{
   if(Test-Path $newFolder)
    {
        Write-Host "-Folder'$newFolder' Exist..."
    }
    else
    {
        New-Item $newFolder -ItemType Directory
        Write-Host "-$newFolder folder created..."
    }
}



createFolder $folder\Downloads\
createFolder $folder\Logs\
createFolder $folder\Output\
createFolder $folder\Output\Single\


# Read the input config Excel and validate
$inputfile = $PSScriptRoot+"\Azure_Subscription.csv" 
Write-Host "Input file is $inputfile." -ForegroundColor Green
Write-Host "===================================================================="  


if (-not(Test-Path -Path $inputfile -PathType Leaf)) {
    try {    
         Write-Host "======================================================================================="  
         Write-Host "Unable to read the input file [$inputfile]. Check file & its permission...  "  -BackgroundColor Red
         Write-Host "======================================================================================="  
         Write-Host "Please see the error below Execution has been stopped          "  
         throw $_.Exception.Message                      
    }
    catch {
         throw $_.Exception.Message
    }
 }
else
{
     try {
         $ConfigList = Import-Csv -Path $inputfile #-WorksheetName Azure_Subscription 

         }

         catch {
         Write-Host "=================================================================================="  
         Write-Host "The file [$inputfile] does not have the woksheet named Azure_Subscription "  -BackgroundColor Red 
         Write-Host "=================================================================================="  
         #Write-Host "Please see the error below & Azure MySQL Info-Gathering has been stopped          "  
         #throw $_.Exception.Message
         exitcode
        }

 }    
 
 $ColumnList=$ConfigList | Get-Member -MemberType NoteProperty | %{"$($_.Name)"}
     if (($ColumnList.Contains("Tenant")) -and
        ($ColumnList.Contains("Subscription_ID"))){

        Write-Host "Input validation is done successfully " 
        }
     else {Write-Host "There are mismatches in the input columns. Kindly check and retrigger the automation "  -BackgroundColor Red
           exitCode}

$tenant=$ConfigList[0].'Tenant'
if ([string]::IsNullOrWhitespace($tenant)){
Write-Host "'Tenant' is not valid in the input. Kindly check and retrigger the automation  "  -BackgroundColor Red 
exitCode
}

$Subscription=$ConfigList[0].'Subscription_ID'
if ([string]::IsNullOrWhitespace($Subscription)){
Write-Host "'Subscription_ID' is not valid in the input. Kindly check and retrigger the automation  "  -BackgroundColor Red 
exitCode
}


Unblock-File $folder/Validation_Scripts/Check_PowerShell_Version.ps1
Unblock-File $folder/Validation_Scripts/azurecli.ps1
      
# Check PowerShell version
$Validation=@()
$Outfiledata=@()
$Outputexcel=@()
$DBListData=@()
$AdAdminData=@()

$alldata =@()
$row=@{}
$FWData=@()
$ServerConfigData=@()
$Validation+=& "$folder/Validation_Scripts/Check_PowerShell_Version.ps1"
$Validation+=& "$folder/Validation_Scripts/azurecli.ps1"

Write-Host "======================================================================================="  
Write-Host "Below are the Validation Results"  -ForegroundColor Green  
Write-Host "======================================================================================="  
Write-Host ($Validation | select Validation_Type,Status,Comments | Format-Table | Out-String)

If($Validation.Status.Contains("FAILED"))
{
 Write-Host "There are errors during validation . Terminating the execution ."  -ForegroundColor Red
 exitcode  
}


#Function to convert json value to hashtable

    function ConvertTo-Hashtable {
    [CmdletBinding()]
    [OutputType('hashtable')]
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
          )

        process {
        if ($null -eq $InputObject) 
        {
            return $null
         }
        
        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string])
        {
            $collection = @(
                foreach ($object in $InputObject) {
                    ConvertTo-Hashtable -InputObject $object
                }
                )

         Write-Output -NoEnumerate $collection
        }
        elseif ($InputObject -is [psobject]) 
        {
            $hash = @{}
            
            foreach ($property in $InputObject.PSObject.Properties) 
            {
                $hash[$property.Name] = ConvertTo-Hashtable -InputObject $property.Value
            }
            
             $hash
        } 
        else 
        {
            $InputObject
        }
        }
    }

    #Functions to fetch the json paths
    function CMF-Read-Hashtable ([Hashtable]$InputHashTable){
    	foreach ($h in $InputHashTable.GetEnumerator() ){
		if ($h.Value -is [Array]){
			CMF-Read-Nested-Array $h.Name $h.Value
		}elseif ($h.Value -is [Hashtable]){
			CMF-Read-Nested-Hashtable $h.Name $h.Value
		}else{
           
			$global:row.Add($h.Name, $h.Value)
		}
	}
	$global:alldata += $global:row
	$global:row =@{}
    }

    function CMF-Read-Nested-Hashtable ([String]$prefix,[Hashtable]$InputNestedHashTable){
	foreach ($h in $InputNestedHashTable.GetEnumerator()){
		if ($h.Value -is [Array]){
			CMF-Read-Nested-Array $h.Name $h.Value
		}elseif ($h.Value -is [Hashtable]){
            $newPrefix=-join($prefix,".",$h.Name)
			CMF-Read-Nested-Hashtable $newPrefix $h.Value
		}else{
			$global:row.Add(-join($prefix,".",$h.Name), $h.Value)
		}
	    }
    }

    function CMF-Read-Array ([Array]$InputArray){
    foreach ($a in $InputArray){
		if($a -is [Hashtable]){
			CMF-Read-Hashtable $a
		}elseif ($a.Value -is [Array]){
		    CMF-Read-Nested-Array $a.Name $a.Value 
		}elseif ($a -is [Array]){
			CMF-Process-Nested-Array $null $a	
		}elseif($a.Value -is [Hashtable]){
			CMF-Read-Nested-Hashtable $a.Name $a.Value
		}else{
			Write-Host "Process-Array :$($a.Value.pstypenames)"
		}
	    }
    }

    function CMF-Read-Nested-Array ([String]$prefix,[Array]$InputArray){
    foreach ($a in $InputArray){
		if($a -is [Hashtable]){
		    CMF-Read-Nested-Hashtable $prefix $a
		}elseif ($a.Value -is [Array]){
			CMF-Read-Nested-Array $prefix $a.Value 
		}elseif ($a -is [Array]){
			CMF-Read-Nested-Array $prefix $a
		}elseif($a.Value -is [Hashtable]){
			CMF-Read-Nested-Hashtable $a.Name $a.Value
		}else{
			$global:row.Add(-join($prefix,".",$h.Name), $h.Value)
		}
	    }
    }


#AZ login to corresponsing Tenant and subscription

$loginoutput=az login --tenant $tenant --only-show-errors
if (!$loginoutput) 
{
    Write-Error "Error connecting to Tenant: $tenant and Subscription: $Subscription"
    exitcode
}
else
{
    $Serverdata=@()
    $db_data=@()
    $DBList=@()
    $ServerConf=@()
    $confdata=@()
    $ADAdmin=@()
    $Admin=@()
    $Firewall=@()
    $Replica=@()
    $dbdata=@()

    #AZ Connect to provided subscription
    az account set --subscription $Subscription
     
    #Server list fetch for Single Server
    $Single_list_Out = az mysql server list | Out-File $folder\Output\Single\Single_Server_List.json 
    
    $ser_details = az mysql server list|ConvertFrom-Json
      
    $ser_list = az mysql server list |ConvertFrom-Json | ConvertTo-HashTable
    if($ser_list -is [Hashtable])
    {
        CMF-Read-Hashtable $ser_list
    }else
    {
	    CMF-Read-Array $ser_list
    }
    
    $Serverdata+=$alldata
    $alldata=@()

  foreach ($i in $ser_details)
  {
           
      #Updating input file with server details
      $ServerName= $i.name
      $Single_User_Name = $i.administratorLogin
      #createFolder $folder\Output\Single\$ServerName\
      $ser_rg = $i.resourceGroup  
      $domain_name = $i.fullyQualifiedDomainName
      $dom = $domain_name.Split(".")
      $ser_dom = $dom[0]
      $Logon_User=$Single_User_Name + "@" + $ser_dom
      $vcore=$i.sku.capacity

      $Outfiledata+=New-Object psobject -Property @{Host_Name=$domain_name;Resource_Group=$ser_rg;Port="5432";VCore=$vcore;Auth_Type="MySQL";User_ID=$Logon_User;Password="";DB_Name="mysql";Tenant=$tenant;Subscription_ID=$Subscription;Approval_Status=""}
          
    try
    {    
    #DB List
    
    #$db_list = az mysql db list -g $ser_rg -s $ser_dom  | Out-File $folder\Output\Single\$ServerName\${ServerName}_Single_DB_List.json               
    $dbdata = az mysql db list -g $ser_rg -s $ser_dom | ConvertFrom-Json | ForEach-Object { $_ | Add-Member -MemberType NoteProperty -Name 'Servername' -Value $ServerName -PassThru} | ConvertTo-Json
    $db_data= $dbdata  |ConvertFrom-Json |  ConvertTo-HashTable
    if($db_data -is [Hashtable])
    {
        CMF-Read-Hashtable $db_data
    }else
    {
	    CMF-Read-Array $db_data
    }
    $DBList+=$alldata
    $alldata=@()

    #Server Configuration
    
    #$conf_list = az mysql server configuration list -g $ser_rg --server-name $ser_dom | Out-File $folder\Output\Single\$ServerName\${ServerName}_Single_Server_Configuration.json
    $confdata = az mysql server configuration list -g $ser_rg -s $ser_dom | ConvertFrom-Json| ForEach-Object { $_ | Add-Member -MemberType NoteProperty -Name 'Servername' -Value $ServerName -PassThru} | ConvertTo-Json
    $confdata = $confdata|ConvertFrom-Json | ConvertTo-HashTable
    if($confdata -is [Hashtable])
    {
        CMF-Read-Hashtable $confdata
    }else
    {
	    CMF-Read-Array $confdata
    }
    
    $ServerConf+=$alldata
    $alldata=@()

    #AD Admin
    
    #$ad_admin = az mysql server ad-admin list -g $ser_rg -s $ser_dom | Out-File $folder\Output\Single\$ServerName\${ServerName}_Single_AD_Admin_List.json
    $ADAdmin=az mysql server ad-admin list -g $ser_rg -s $ser_dom | ConvertFrom-Json| ForEach-Object { $_ | Add-Member -MemberType NoteProperty -Name 'Servername' -Value $ServerName -PassThru} | ConvertTo-Json
    $ADAdmin = $ADAdmin|ConvertFrom-Json | ConvertTo-HashTable
    if($ADAdmin -is [Hashtable])
    {
        CMF-Read-Hashtable $ADAdmin
    }else
    {
	    CMF-Read-Array $ADAdmin
    }
     
    $Admin+=$alldata
    $alldata=@()
    
    #Firewall Rule
    
    #$FW_list = az mysql server firewall-rule list -g $ser_rg -s $ser_dom | Out-File $folder\Output\Single\$ServerName\${ServerName}_Single_FW_Rule.json
    $FWList=az mysql server firewall-rule list -g $ser_rg -s $ser_dom| ConvertFrom-Json| ForEach-Object { $_ | Add-Member -MemberType NoteProperty -Name 'Servername' -Value $ServerName -PassThru} | ConvertTo-Json
    $FWList = $FWList|ConvertFrom-Json | ConvertTo-HashTable
    if($FWList -is [Hashtable])
    {
        CMF-Read-Hashtable $FWList
    }else
    {
	    CMF-Read-Array $FWList
    }
    $Firewall+=$alldata
    $alldata=@()

    #Replica List
    
    $Replica_List=az mysql server replica list -g $ser_rg -s $ser_dom|ConvertFrom-Json| ConvertTo-HashTable
    if($Replica_List -is [Hashtable])
    {
        CMF-Read-Hashtable $Replica_List
    }else
    {
	    CMF-Read-Array $Replica_List
    }
    $Replica+=$alldata
    $alldata=@()
    
  }
  catch
  {
      throw $_.Exception.Message  
      throw  $_.Exception.Response.StatusCode.Value__
      exitcode
      }
      }
    $Serverdata| ForEach-Object {[PSCustomObject]$_}  | Export-Excel -Path $PSScriptRoot\Output\Output.xlsx -WorksheetName Server_List
    $DBList| ForEach-Object {[PSCustomObject]$_} | Export-Excel -Path $PSScriptRoot\Output\Output.xlsx -WorksheetName DB_Details
    $ServerConf| ForEach-Object {[PSCustomObject]$_} | Export-Excel -Path $PSScriptRoot\Output\Output.xlsx -WorksheetName Configuration_Data
    $Admin| ForEach-Object {[PSCustomObject]$_} | Export-Excel -Path $PSScriptRoot\Output\Output.xlsx -WorksheetName AD_Admin
    $Firewall| ForEach-Object {[PSCustomObject]$_} | Export-Excel -Path $PSScriptRoot\Output\Output.xlsx -WorksheetName FW_List
    $Replica| ForEach-Object {[PSCustomObject]$_} | Export-Excel -Path $PSScriptRoot\Output\Output.xlsx -WorksheetName Replica_List


    Write-Host "=============================================================================================================="  
    Write-Host "Information gathered ==> $folder\Output\Single\ " -ForegroundColor Green -BackgroundColor Black
    Write-Host "Output file created ==> $PSScriptRoot\Output\Output.xlsx " -ForegroundColor Green -BackgroundColor Black
    Write-Host "==============================================================================================================" 
  
  
  


    
    if($Outfiledata -ne $null){
    $Outfiledata | select Host_Name,Resource_Group,Port,VCore,User_ID,Password,Auth_Type,DB_Name,Tenant,Subscription_ID,Approval_Status,SSL_Mode | Export-Excel "$folder\Server_List.csv"
    }
    
}  
