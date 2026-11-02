$password = Read-Host "Temporary password for new users" -AsSecureString

$users = Import-Csv .\users.csv
$results = @() 
foreach ($row in $users) {
    $first = $row.FirstName
    $last = $row.LastName
    $initial = $first[0]
    $username = "$initial$last".ToLower()
    $UPN = $username + "@corp.lab"
    $OU = $row.Department
    $group = "SG-$($row.Department)"
    $found = Get-ADUser -Filter "SamAccountName -eq '$username'"
    if ($found) {
        Write-Host "$username already exists" -ForegroundColor Yellow
        $results += [PSCustomObject]@{
            Username = $username
            Status = "Skipped"
            Message = "Already Exists"
        }
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
        UserPrincipalName = $UPN
        Department = $row.Department
    }
    try {
        New-ADUser @params -ErrorAction Stop
        Add-ADGroupMember -Identity $group -Members $username -ErrorAction Stop
        Write-Host "Created" -ForegroundColor Green
        $status = "Created"
        $message = "Created"
    } 
    catch {
        Write-Host "Failed: $($_.Exception.Message)" -ForegroundColor Red 
        $status = "Failed"
        $message = $_.Exception.Message
    }
    $results += [PSCustomObject]@{
        Username = $username
        Status = $status
        Message = $message
    }

}
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmm"
$results | Export-Csv ".\results_$timestamp.csv" -NoTypeInformation
$results | Format-Table
