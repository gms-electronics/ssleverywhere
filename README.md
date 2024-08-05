# SSL Everywhere
Instructions and Scripts to Deploy SSL Certificates virtually everywhere. 

# Introduction
The set of scripts and instructions in this repository allow to deploy SSL certificates in the environments our Company GMS uses including environments that do not allow HTTP validation via let's encrypt as most of our systems are not exposed to the internet. We centralized our domain management on cloudflare and these scripts, while they can frequently adapted to other systems, are not made for anything else than Cloudflare.

# Requierements
1. Cloudflare DNS Account (Free);
2. In case of Windows Deployments the following scripts: [PSExec]([url](https://learn.microsoft.com/en-us/sysinternals/downloads/psexec)), [POSH-ACME]([url](https://github.com/rmbolger/Posh-ACME)), [POSH-ACME.DEploy]([url](https://github.com/rmbolger/Posh-ACME.Deploy));

# Covered Systems
Right now we cover following systems: 
1. Windows Server 2022 including RDP Host (Work in Progress), Terminal Server, IIS (Work in Progress), LDAPS and AD FS (Work in Progress)
2. The installation of a centralized server to deploy certificates to additional systems
2. iDrac from a centralized server (work in progress)
3. vCenter from a centralized server (work in progress)
4. vSphere from a centralized server (work in progress)

# Contributors 
Willingfully or not, some people have significantly contributed to the creation of the scripts.
[Ryan Bolger]([url](https://github.com/rmbolger)), who wrote an amazing collection of tools regarding the implementation of let's encrypt on windows via powershell
