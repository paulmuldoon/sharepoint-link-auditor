### Requirements: 
* PowerShell
* PnP PowerShell Module

### Example Usage: 
```powershell
.\sp_linkauditor.ps1 ` -u "contoso.sharepoint.com/training" ` -i "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" ` -o "contoso-training-audit-results.csv"
```
### Arguments:
* -u : The URL of the SharePoint site you would like to audit for broken links
* -i : The Client ID of the SharePoint site you are auditing (you can request this from your M365 administrator)
* -o : The file you would like to create and output the results of the audit to (must have a .csv extension)
#### Note: The -o argument is optional and the default results output file is broken-links.csv

