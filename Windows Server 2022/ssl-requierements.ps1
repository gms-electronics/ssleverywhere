# Download and unpack PSExec to your local system32 folder including checking
# Download and Install requiered PS Modules from the gallery
Install-Module -Name Posh-ACME -Scope AllUsers
Install-Module -Name Posh-ACME.Deploy -RequiredVersion 1.6.0
