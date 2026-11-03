# Azure Active Directory Lab
An Active Directory domain controller with group policy objects and a Powershell user provisioning script to automate new user onboarding.

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
- DC01 (Domain Controller): The sever running Active Directory
- WS01: Admin workstation and employee computer
- GPOs:
- Powershell Script:

## AD structure

## Group Policy

## Lockout Test

## Provisioning Script

## Troubleshooting

## Cost + Security Choices
