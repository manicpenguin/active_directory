param( [Parameter(Mandatory=$true)] $JSONFile)

function CreateADGroup(){
    param( [Parameter(Mandatory=$true)] $groupObject )

    $name = $groupObject.name 
    New-ADGroup -name $name -GroupScope Global 
}

function RemoveADGroup(){
    param( [Paremeter(Mandatory=$true)] $groupObject )

    $name = $groupObject.name
    Remove-ADGroup -Identity $name -Confirm:$false
}

function RemoveADUser(){
    param( [Paremeter(Mandatory=$true)] $userObject )

    $name = $userObject.name
    $firstname, $lastname = $name.split(" ")
    $username = ($firstname[0] + $lastname).toLower()
    $SamAccountName = $username
    Remove-ADUser -Identity $SamAccountname -Confirm:$false
}

function CreateADUser(){
    param( [Parameter(Mandatory=$true)] $userObject )

    # Pull out the name from the JSON object 
    $name = $userObject.name
    $password = $userObject.password

    # Generate a "first initial, last name" structure for username
    $firstname, $lastname = $name.split(" ")
    $username = ($firstname[0] + $lastname).toLower()
    $SamAccountName = $username
    $principalname = $username


    # Create the AD User
    New-ADUser -Name "$name" -GivenName $firstname -Surname $lastname -SamAccountName $SamAccountName -UserPrincipalName $principalname@$Global:Domain -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PassThru | Enable-ADAccount 
    
    # Add the user to its appropriate groups
    foreach($group_name in $userObject.groups) {
        try {
            Get-ADGroup -Identity $group_name
            Add-ADGroupMember -Identity $group_name -Members $username
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
        {
            Write-Warning “User $name NOT added to group $group_name because it does not exist”
        }
    }
}

function WeakPasswordPolicy(){
    secedit /export /cfg c:\Windows\Tasks\secpol.cfg
    (Get-Content C:\Windows\Tasks\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0").replace("MinimumPasswordLength = 7", "MinimumPasswordLength = 1") | Out-File C:\Windows\Tasks\secpol.cfg
    secedit /configure /db c:\windows\security\local.sdb /cfg c:\Windows\Tasks\secpol.cfg /areas SECURITYPOLICY
    remove-item -force c:\Windows\Tasks\secpol.cfg -confirm:$false
}

function StrengthenPasswordPolicy(){
    secedit /export /cfg c:\Windows\Tasks\secpol.cfg
    (Get-Content C:\Windows\Tasks\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0", "MinimumPasswordLength = 7") | Out-File C:\Windows\Tasks\secpol.cfg
    secedit /configure /db c:\windows\security\local.sdb /cfg c:\Windows\Tasks\secpol.cfg /areas SECURITYPOLICY
    remove-item -force c:\secpol.cfg -confirm:$false
}


WeakPasswordPolicy

$json = (Get-Content $JSONFile | ConvertFrom-JSON)

$Global:Domain = $json.domain 

foreach ($group in $json.groups){
    CreateADGroup $group
}

foreach ($user in $json.users){
    CreateADUser $user
}


