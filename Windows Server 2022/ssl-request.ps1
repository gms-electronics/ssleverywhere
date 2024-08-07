# run in .\PsExec64.exe -i -h -s powershell.exe
# Install Posh-Acme and Posh-Acme Deploy with all dependencies
Install-Module -Name Posh-ACME -Scope AllUsers -Force -SkipPublisherCheck
Install-Module -Name Posh-ACME.Deploy -Scope AllUsers -Force -SkipPublisherCheck

# Cloud Flare requires a simple API token, securing the string to keep it safe
$token = ConvertTo-SecureString 'C9kSy_bifnISIcOpTLyYbF9n5o8orJhJcn-hQtNC' -AsPlainText -Force
$pArgs = @{CFToken=$token}

# The default certificate password is "poshacme", but we prefer some extra security. At this point you could also just use the CF token. 
$CertPass = '$token'

# To get the correct hostname independent of features installed, use System.Net.Dns (does not work on linux).
$certName = ([System.Net.Dns]::GetHostEntry([string]"localhost").HostName)

# This notification email is contacted if the certificate is close to expiration date.
$notifyEmail = 'it@gmservice.app'

# Constructs all Cert Params for a successful request.
$certParams = @{
    Domain = $certName
    PfxPass = $CertPass
    DnsPlugin = 'Cloudflare'
    PluginArgs = $pArgs
    AcceptTOS = $true
    Install = $true
    Contact = $notifyEmail  # optional
    Verbose = $true         # optional
}

New-PACertificate @certParams 

# Sets the certificate also for RDP Host Listener
Set-PAOrder $certName
Get-PACertificate $certName | Set-RDSHCertificate -Verbose

# Sets the scheduler to check and renew certificate when due
$taskname = "Renew SSL Server Certificate"
$taskdesc = "Renews the Let's Encrypt certificate installed on this server."
$actionArg = '-C "Start-Transcript $env:LOCALAPPDATA\cert-renewal.log -Append; $name=([System.Net.Dns]::GetHostEntry([string]"localhost").HostName); $oldCert=gci Cert:\LocalMachine\My | ?{ $_.Subject -eq \"CN=$name\" } | sort -d NotAfter | select -f 1; if (Submit-Renewal -Verbose) { Get-PACertificate | Set-RDSHCertificate; $oldCert | ri; Restart-Service ADWS } Stop-Transcript; exit $LASTEXITCODE"'
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $actionArg
$trigger =  New-ScheduledTaskTrigger -Daily -At 2am -RandomDelay (New-TimeSpan -Minutes 30)
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 30)
Register-ScheduledTask $taskname -Action $action -Trigger $trigger -User 'System' -Settings $settings -Desc $taskdesc
