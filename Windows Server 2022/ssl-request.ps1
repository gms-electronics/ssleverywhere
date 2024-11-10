# run in .\PsExec64.exe -i -h -s powershell.exe
# Install Posh-Acme and Posh-Acme Deploy with all dependencies
Install-Module -Name Posh-ACME -Scope AllUsers -Force -SkipPublisherCheck
Install-Module -Name Posh-ACME.Deploy -Scope AllUsers -Force -SkipPublisherCheck

# To get the correct hostname use System.Net.Dns on a domain joined Server.
$certName = ([System.Net.Dns]::GetHostEntry([string]"localhost").HostName)

# Approach A: User Dialogue
$CFTokenMessage = 'Please enter the cloudflare token to manage the DNS zone of ' + $certname + ' via Cloudflare API!'
$CFtoken = Read-Host $CFTokenMessage
$token = ConvertTo-SecureString $CFtoken -AsPlainText -Force
# Enter the email for notifications if the cert is not renewed.
$certNotificationMessage = 'Please enter the email to contact if the request for renewal fails'
$certificateNotificationEmail = Read-Host $certNotificationMessage

# Approach B: Manual Entry of variables, uncomment for automazation
# $token = ConvertTo-SecureString 'nevercommittired' -AsPlainText -Force
# $certificateNotificationEmail = 'email@example.com' # Email for notifications if the cert is not renewed. 

# The variable of the token effectively used to request DNS entry via API to Cloudflare.
$pArgs = @{CFToken=$token}

# The default certificate password is "poshacme", but we prefer some extra security. At this point you could also just use the CF token. 
$CertPass = '$token'

# Constructs all Cert Params for a successful request.
$certParams = @{
    Domain = $certName
    PfxPass = $CertPass
    DnsPlugin = 'Cloudflare'
    PluginArgs = $pArgs
    AcceptTOS = $true
    Install = $true
    Contact = $certificateNotificationEmail # optional
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
