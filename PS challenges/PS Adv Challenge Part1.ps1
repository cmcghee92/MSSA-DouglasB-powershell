# Part 1 of MSSA Advanced PS Challenge
# Create an OU named London OU; Londan // Domain DC=Adatum,DC=com // Pat: OU=OUName,DomainDN


Get-Module -ListAvailable ActiveDirectory # Check if Active Directory module is available
#Variables (All)
$OUName = "London"
$DomainDN = "DC=Adatum,DC=Com"
$OUPath = "OU=$OUName,$DomainDN"

$GroupName = "London Users"
$GroupDN = "OU=$OUName,$DomainDN"

$ExistingOU = Get-ADOrganizationalUnit -Filter "Name -eq '$OUName'" -SearchBase $DomainDN -ErrorAction SilentlyContinue
if ($ExistingOU) {
    Write-Host "The OU '$OUName' already exists"
} else {
    Write-Host "The OU '$OUName' does not exist. Creating it now..."
    New-ADOrganizationalUnit -Name $OUName -Path $DomainDN
    Write-Host "The OU '$OUName' has been created successfully."
}
Get-ADOrganizationalUnit -Filter * -SearchBase "DC=Adatum,DC=Com" | Sort-Object Name

#Part 2 of MSSA Advanced PS Challenge
#Create a global London security group and move all Sales users living in London to the London OU. Add the London OU to London Sec Group

$SalesOU = "OU=Sales,$DomainDN"
$GroupName = "London Users"
$GroupSearch = Get-ADGroup -Filter "Name -eq '$GroupName'" -SearchBase $OUPath -ErrorAction SilentlyContinue

if ($GroupSearch) {Write-Host "The '$GroupName' group already exists"}
else
 { 
    New-ADGroup -Name $GroupName -GroupScope Global -GroupCategory Security -Path $OUPath 
    Write-Host "created group $GroupName"
}

$LondonSalesUsers = Get-ADUser -Filter "City -eq 'London'" -SearchBase $SalesOU 
Write-Host "Found $($LondonSalesUsers.Count) users in Sales OU with City = London"
foreach ($user in $LondonSalesUsers) {
    Move-ADObject -Identity $user.distinguishedName -TargetPath $OUPath
    Write-Host "Moved user: $($user.SamAccountName)"
}

Add-ADGroupMember -Identity $GroupDN -Members $LondonSalesUsers
Write-Host "added $($LondonSalesUsers.Count) users to Group: $GroupName"