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
Run the script:
```PowerShell
.\Find-BetterCloudflareIP.PS1 -CurrentIP <IP> [-AllIP] [-Count <Int>] [-Timeout <Int>] [-CheckDomain <String>]
```

The script will traverse the corresponding IP address pool list file based on the IP address type. It will randomly select one IP address from each CIDR-formatted IP range for testing.  
If a faster and lossless IP address is found, the script will return `<BetterIP>`.  
If no faster and lossless IP address is found after traversing all IP address pools, the script will return `<CurrentIP>`.

### Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `-CurrentIP` | Yes | - | Current Cloudflare IP to compare |
| `-AllIP` | No | - | Check both IPv4 and IPv6 |
| `-Count` | No | 5 | Number of httping requests per IP |
| `-Timeout` | No | 5 | Timeout threshold in seconds |
| `-CheckDomain` | No | cf.xiu2.xyz | Domain to check, recommend using your own |

### Examples
```PowerShell
# Basic usage
.\Find-BetterCloudflareIP.PS1 -CurrentIP "1.1.1.1"

# Check both IPv4 and IPv6
.\Find-BetterCloudflareIP.PS1 -CurrentIP "1.1.1.1" -AllIP

# Custom parameters
.\Find-BetterCloudflareIP.PS1 -CurrentIP "1.1.1.1" -Count 10 -Timeout 3.0 -CheckDomain "your-domain.com"
```

### Httping-CloudflareIP.PS1
This script is called by `Find-BetterCloudflareIP.PS1` internally. You can also use it directly:
```PowerShell
.\Httping-CloudflareIP.PS1 -IP <IP> [-Count <Int>] [-Timeout <Int>] [-CheckDomain <String>]
```

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `-IP` | Yes | - | IP address to test |
| `-Count` | No | 5 | Number of httping requests |
| `-Timeout` | No | 5 | Timeout in seconds |
| `-CheckDomain` | No | cf.xiu2.xyz | Domain to check |
