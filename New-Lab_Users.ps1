$password = Read-Host "Temporary password for new users" -AsSecureString

$users = Import-Csv .\users.csv
$results = @() 
foreach ($row in $users) {
    Write-Host $row.FirstName
    $first = $row.FirstName
    $last = $row.LastName
    $initial = $first[0]
    $username = "$initial$last".ToLower()
    $UPN = $username + ".corp.lab"
    $OU = $row.Department
    $group = "SG-$($row.Department)"
    $found = Get-ADUser -Filter "SamAccountName -eq '$username'"
    if ($found) {
        Write-Host "Already Exists"
        continue
    }
    $params= @{
        Name = "$first $last"
        SamAccountName = $username
        Path = "OU=$OU,OU=Departments,DC=corp,DC=lab"
        Enabled = $true
        ChangePasswordAtLogon =$true
        AccountPassword = $password
        GivenName = $first
        Surname = $last
        Title = $row.Title
        Department = $row.Department
    }
    try {
        New-ADUser @params -ErrorAction Stop
        Write-Host "Created" -ForegroundColor Green
    } 
    catch {
        Write-Host "Failed: $($_.Exception.Message)" -ForegroundColor Red 
    }
    $results += [PSCustomObject]@{
        Username = $username
        Status = "Created"
        Message = ""

    }
}

