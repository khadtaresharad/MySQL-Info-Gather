# Steps To-Do:<br />

**OS Support**<br />

This script is compatible with the following operating systems:<br />
Windows 10 or later<br />
Linux RHEL v7 or later , Ubuntu v14 or later<br />

**Pre-requisites**<br />

Execute below prior running Powershell scripts<br />
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy bypass

***Windows***<br />
Powershell -   https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4<br /> 
MySQL Client - https://dev.mysql.com/downloads/installer/<br />
Azure CLI (For Single Server and Microsoft Entra ID authentication only) - https://aka.ms/installazurecliwindows )<br /> 

***Linux***<br />
Powershell - https://learn.microsoft.com/en-us/powershell/scripting/install/install-rhel?view=powershell-7.4<br /> 
MySQL Client - https://dev.mysql.com/doc/mysql-shell/8.0/en/mysql-shell-install-linux-quick.html<br />
Azure CLI (For Single Server and Microsoft Entra ID) - https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux/<br /> 

**Note**: - Add PATH in Enviornment Variables<br />

***Windows***<br />
Azure CLI  ( e.g. C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin )<br />
MySQL Client ( e.g. C:\Program Files\MySQL\bin )<br />

***Linux***<br />
Azure CLI  ( e.g. /usr/bin/az )<br />
MySQL Client ( e.g. /usr/bin/mysql )<br />

## Step1. Azure CLI Info Gathering (Only for Azure Database for MySQL Single Servers)
1.	Download the package zip file named `MySQL-Info-Gather.zip`
2.	Extract the `unzip MySQL-Info-Gather.zip` file.
3.	Run `rename rename.txt rename.bat` and Execute the `rename.bat` ( Windows ) 
4.  Run `sh ./rename-linux.txt` ( Linux )
5.	Open the Input file `Azure_Subscription.csv` and provide the Tenant ID & Subscription ID 
6.	Execute `powershell.exe .\CMF-MySQL-CLI-Windows.ps1` (Windows)
7.  Execute `pwsh ./CMF-MySQL-CLI-Linux.ps1` (Linux)
8.	Once the execution completed, you can check the output & Logs folder.

## Step2. Update CMF_MySQL_Server_Input_file.csv (For All Servers)
"**Host_Name**","Resource_Group","**Port**","VCore","Auth_Type","**User_ID**","**Password**","**DB_Name**","Tenant","Subscription_ID","**Approval_Status**","SSL_Mode"

**Note:-**<br />
. Highlighted are **Mandatory Fields**<br />
. Update Mandatory fields manually in case of Azure VM / On-premises Servers <br />
. If a **Password** is not provided, this requires interactive console input of the password for each server. 
. For credentials handling methods refer to [Passing credentials](#passing-credentials)
<br />

## Step3. MySQL Server Info Gathering (For All Servers)
1.	Execute `powershell.exe .\CMF-MySQL-Windows.ps1` ( Windows )
2.  Execute `pwsh ./CMF-MySQL-Linux.ps1` ( Linux )
3.	Once the execution completed, you can check the output & Logs folder.

## Step4. Azure VM/On-premises Servers  (Only for On-Premises / Azure VM / Other Cloud Servers)
. Refer document `CMF-ON-Prem_Server_Info_gather.docx` from the zip folder and update details and share document.<br />

Host-Name  | Cores | Memory | Storage Size | Storage Type | OS type | OS version | IOPS 

## Step5. Zip and share output, log folders (For All Servers) 
Kindly follow the execution instructions mentioned in attached documents. 
If there is/are any queries, please let us know, we will connect and check.


**Disclaimer:**
These scripts are intended for use of Info Gather Assessment utility and do not interact with the user databases or gather any sensitive information (e.g passwords, PI data etc.). 
These scripts are provided as-is to merely capture metadata information ONLY. While every effort has been made to ensure that accuracy and reliability of the scripts, 
it is recommended to review and test them in a non-production environment before deploying them in a production environment.
It is important to note that these scripts should be modified with consultation of Microsoft.


# Passing credentials
Credentials handling method depends on customer requirements and relevant `CMF_MySQL_Server_Input_file.csv` input file settings

* Default  
    * user - set `User_ID` field to user name  
    * password - leave  `Password` field empty for interactive password prompt during scrpt execution 
* Unattended
    * user - set `User_ID` field to user name  
    * password - set `Password` field to the user password
* Microsoft Entra ID 
    * user - set `User_ID` field to user name  (this has to be interactive user because script can get an access token for the current account only)
    * password - leave  `Password` field empty 
    * authentication type - set `Auth_Type` to `entraid` value

# Appendix - Manual script execution
Incase system don't have powershell installed or user dont have permission to install on host machine executing these script
Below batch file can be executed to gather the database level info.

Step1. Create and Update CMF_MySQL_Server_Input_file.csv (For All Servers)
"**Host_Name**","Resource_Group","**Port**","VCore","Auth_Type","**User_ID**","**Password**","**DB_Name**","Tenant","Subscription_ID","**Approval_Status**","SSL_Mode"
Step2. Open CMD prompt with Run as Admin  
Step3. Execute `CMF-Mysql-Manual-Windows.bat`( Windows )
        Execute `sh ./CMF-Mysql-Manual-Linux.txt`( Linux )
