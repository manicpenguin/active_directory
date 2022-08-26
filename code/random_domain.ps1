param( [Parameter(Mandatory=$true)] $OutputJSONFile)

$group_names = [System.Collections.ArrayList](Get-Content "data\group_names.txt")
$first_names = [System.Collections.ArrayList](Get-Content "data\first_names.txt")
$last_names = [System.Collections.ArrayList](Get-Content "data\last_names.txt")
$passwords = [System.Collections.ArrayList](Get-Content "data\passwords.txt")

$groups = @()
$users = @()

$num_groups = 10
for ( $i = 0; $i -lt $num_groups; $i++){
    $group_name = (get-random -InputObject $group_names)
    $group = @{"name" = "$group_name"}
    $groups += $group
    $group_names.Remove($new_group)
}

#$groups += @{"name"=(get-random -InputObject $group_names -count 10)}


$num_users = 100
for ( $i = 0; $i -lt $num_users; $i++){
    $first_name = (Get-Random -InputObject $first_names)
    $last_name = (Get-Random -InputObject $last_names)
    $password = (Get-Random -InputObject $passwords)
    $new_user = @{
        "name"="$first_name $last_name"
        "password"="$password"
        "groups"=@( (Get-Random -InputObject $groups).name )
        }
    $users += $new_user
    $first_names.Remove($first_name)
    $last_names.Remove($last_name)
    $passwords.Remove($password)
}

echo @{
    "domain" = "xyz.com"
    "groups" = $groups
    "users" = $users
} | ConvertTo-Json | Out-File $OutputJSONFile