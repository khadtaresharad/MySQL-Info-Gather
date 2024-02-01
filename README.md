# Steps To-Do:

# Pre-requisites
Supported Operating System 
Windows - Windows 10, Windows Server 2012, Windows Server 2012 R2 and above
Linux   - RHEL v7 & above, Ubuntu v14 & above

Azure CLI (Install) 
Windows - https://aka.ms/installazurecliwindows 
Linux   - https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux/ 

MySQL Client (Install)
Windows - https://dev.mysql.com/downloads/installer/
Linux   - https://dev.mysql.com/doc/mysql-shell/8.0/en/mysql-shell-install-linux-quick.html

Note:-
- Add Azure CLI PATH in Enviornment Variables ( e.g. C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin )
- Add MySQL Client PATH in Enviornment Variables ( e.g. C:\Program Files\MySQL\bin )

## Azure CLI
1.	Download the package zip file named `MySQL-Info-Gather.zip`
2.	Extract the `unzip MySQL-Info-Gather.zip` file.
3.	Run `rename rename.txt rename.bat` and Execute the `rename.bat` ( Windows ) 
4. Run `sh ./rename-linux.txt` ( Linux )
5.	Open the Input file `Azure_Subscription.csv` and provide the Tenant ID & Subscription ID 
6.	Execute `powershell.exe .\CMF-MySQL-CLI-Windows.ps1` (Windows)
7. Execute `pwsh ./CMF-MySQL-CLI-Linux.ps1` (Linux)
8.	Once the execution completed, you can check the output & Logs folder.

## Azure VM/On-premises
. Please refer to document “CMF-ON-Prem_Server_Info_gather.docx” from the zip folder and share the details.

## Update CMF_MySQL_Server_Input_file.csv 
 "**Host_Name**","Resource_Group","**Port**","VCore","Auth_Type","**User_ID**","**Password**","**DB_Name**","Tenant","Subscription_ID","**Approval_Status**","SSL_Mode"

 Note:- **Mandatory Fields** 
## Server Info Gathering:
1.	Execute `powershell.exe .\CMF-MySQL-Windows.ps1` ( Windows )
2. Execute `pwsh ./CMF-MySQL-Linux.ps1` ( Linux )
3.	Once the execution completed, you can check the output & Logs folder.

## Zip and share output & log folders 

Kindly follow the execution instructions mentioned in attached documents. 
If there is/are any queries, please let us know, we will connect and check.
