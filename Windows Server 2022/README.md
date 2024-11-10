# DNS Requierements 
* Cloudflare as domain DNS server
* A Cloudflare API Token 

# System Requierements
The script assumes the following: 
* A Windows 2022 Server that is domain joined (not tested against other versions, but might work)
* [PSExec Installed](https://learn.microsoft.com/en-us/sysinternals/downloads/psexec)
* The deployment Script [win22-server-ssl-deploy.ps1]([url](https://github.com/gms-electronics/ssleverywhere/blob/main/Windows%20Server%202022/ssl-request.ps1))

# Following dependencies are installed directly by the script
* [NuGet]([url](https://www.powershellgallery.com/packages/NuGet/1.3.3))
* [POSH-ACME]([url](https://poshac.me/docs/latest/))
* [POSH-ACME.deploy]([url](https://poshac.me/docs/latest/))

# Instructions
1. Download psexec from Microsoft and copy to System32
2. Copy the SSL request script and copy it to System32
3. Execute `.\PsExec64.exe -i -h -s powershell.exe` from the Powershell
4. Execute `ssl-request.ps1` from the elevated shell

# Future Iterations
- [X] Download Scripts Automatically into System32
- [X] Ask for Token
- [ ] Launch automatically into psexec
