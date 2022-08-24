# Active Directory Setup

1. Use 'sconfig' to:
    - Change the hostname
    - Change the IP address to static
    - Change the DNS server to our oown IP address

2. Install the Active Directory Windows Feature

```shell
 Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

```