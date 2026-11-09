# Azure Active Directory Lab
A small company network: Active Directory domain controller with group policy objects and a Powershell user provisioning script.

I built this to practice the Windows and AD admin work done in IT Operations.

## Architecture

```mermaid
flowchart LR
    mac["My Mac (browser)"] -->|HTTPS| bastion["Azure Bastion<br/>Developer tier"]

    subgraph azure["Azure: rg-adlab"]
        subgraph vnet["vnet-adlab 10.0.0.0/24"]
            dc["DC01<br/>Server Core<br/>AD DS + DNS<br/>10.0.0.4"]
            ws["WS01<br/>Admin workstation<br/>RSAT + GPMC"]
        end
    end

    bastion -->|RDP| dc
    bastion -->|RDP| ws
    ws -->|DNS, Kerberos, LDAP, SMB, WinRM| dc
```

## Build Summary
- Azure: Cloud used to host the lab
- Resource Group (rg-adlab): Folder holding every piece of the lab
- Virtual Network(vnet-adlab): Private network used by the VMs
- DC01 (Domain Controller): The sever running Active Directory in the lab
- WS01: Admin workstation and employee computer for the lab
- GPOs: Rules I defined in the domain controller that pushed to machines and users
- Powershell Script: Automates new user onboarding

## AD structure
- **Organizational Units:**
- Workstations, Disabled Users, Departments, IT, Finance, HR
- WS01 sits in the `Workstations` OU instead of the default `Computers` folder because the `Computers` folder isn't an OU so GPO's cannot be linked to it
- **Groups:**
- SG-IT, SG-Finance, SG-HR
![OUs](azure-ad-lab-screenshots/Organizational-Units.png)

## Group Policy Objects
**1. Account Lockout Policy**
- After 5 invalid login attempts accounts is locked out for 15 minutes. Login attempt counter is reset after 15 minutes
- Lockout settings are set at the domain level because password and lockout rules for domain accounts only take effect from there
![Lockout GPO](azure-ad-lab-screenshots/Group-Policy-Objects.png)
**2. Workstation Logging**
- Logs PowerShell Script Block Logging, scheduled task creation, and failed logins
![Logging](azure-ad-lab-screenshots/Workstation-Logging.png)

## Lockout Test
- In the IT OU, created a test account called `testuser` and ran a mini brute-force attack (failing its login 6 times in a row) on it to test whether or not the lockout policy actually works.
![Lockout Test](azure-ad-lab-screenshots/BruteForce.png)

## Provisioning Script
- The Powershell provisioning script reads a file called `users.csv` that has each person's name, department and title. It then creates each user in their department’s OU, adds them to the department group, and sets a temporary password they must change at first login. It skips users who already exist and logs what it did
**1st run output:**
![1st run output](azure-ad-lab-screenshots/FirstRun.png)
**2nd run output(Once accounts are already created):**
![2nd run output](azure-ad-lab-screenshots/SecondRun.png)

## Troubleshooting & Choices
- Tracked down the hidden Azure reigon policy which did not allow e to deploy the virtual network because I was in the wrong reigon for my subscription
- Chose B2als_v2 for its 4 GB of RAM
- System error 1219 ("Multiple connections to a server or shared resource by the same user, using more than one user name, are not allowed") came up when attempting to test the lockout,causing bad passwords to not be checked. Fixed this by targeting the domain controller's IP
- Repeating the same wrong password only raised the bad-logon count, so I instead used a different password each time to lock the account
- Used Bastion so that neither VM needs a public IP and nothing is exposed to the internet
