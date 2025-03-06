# Find-BetterCloudflareIP
Script: Find a better Cloudflare IP through HTTPing.

## Other Languages
- [简体中文](README.zh-Hans.md)

## Introduction
This project does not use large file speed test to seek IPs, nor does it use multiple concurrent connections for seeking, and there are no plans to add these features in the future.  
This is because the aforementioned features have the following drawbacks:
* They can place a burden on the system.
* They can cause ISPs to impose restrictions due to the load.
* They can burden Cloudflare and lead to being flagged as abusive by Cloudflare.

## Requirements
* PowerShell  
PowerShell is built into Windows Vista and later versions of Windows.
* curl  
curl is built into Windows 10 1709 and later versions of Windows.
For earlier versions of Windows, you need to install curl manually.

## Usage
1. Edit the script `Find-BetterCloudflareIP.PS1` and fill in the parameters as needed.
2. Run the script:
```PowerShell
.\Find-BetterCloudFlareIP.PS1 <CurrentIP>
```

The script will traverse the corresponding IP address pool list file based on the IP address type. It will randomly select one IP address from each CIDR-formatted IP range for testing.  
If a faster and lossless IP address is found, the script will return `<BetterIP>`.  
If no faster and lossless IP address is found after traversing all IP address pools, the script will return `<CurrentIP>`.