Param(
    [Parameter(Mandatory=$true, HelpMessage='Current Cloudflare IP to compare')]$CurrentIP,
    [Parameter(HelpMessage='Check both IPv4 and IPv6')][switch]$AllIP,
    [Parameter(HelpMessage='Number of httping requests per IP')][int]$Count = 5,
    [Parameter(HelpMessage='Timeout threshold in seconds')][double]$Timeout = 5.0,
    [Parameter(HelpMessage='Domain to check, recommend using your own')][string]$CheckDomain = 'cf.xiu2.xyz'
)

Set-Location -Path $PSScriptRoot

function Get-RandomIPv4FromCidr {
    param (
        [string]$Cidr # CIDR格式的IPv4范围,如"192.168.1.0/24"
    )
    # 解析CIDR格式
    $parts = $Cidr.Split('/')
    $networkAddress = $parts[0]
    $subnetMaskLength = [int]$parts[1]
    # 将网络地址转换为32位整数
    $networkBytes = [System.Net.IPAddress]::Parse($networkAddress).GetAddressBytes()
    [Array]::Reverse($networkBytes)
    $networkInt = [System.BitConverter]::ToUInt32($networkBytes, 0)
    # 计算主机位数
    $hostBits = 32 - $subnetMaskLength
    # 计算网络掩码
    $mask = 0xFFFFFFFF -shl $hostBits
    # 计算网络起始地址
    $networkStart = $networkInt -band $mask
    # 随机选择一个主机号
    $maxHost = [int][math]::Pow(2, $hostBits)
    $hostNumber = Get-Random -Minimum 0 -Maximum $maxHost
    # 生成最终IP地址
    $randomIPInt = $networkStart + $hostNumber
    # 转换回IP地址字符串
    $randomBytes = [System.BitConverter]::GetBytes($randomIPInt)
    [Array]::Reverse($randomBytes)
    # 构建IP地址字符串
    $randomIP = "$($randomBytes[0]).$($randomBytes[1]).$($randomBytes[2]).$($randomBytes[3])"
    return $randomIP
}

function Get-RandomIPv6FromCidr {
    param (
        [string]$Cidr # CIDR格式的IPv6范围,如"2606:4700::/32"
    )
    # 提取网络地址和前缀长度
    $networkAddress = $Cidr.Split('/')[0]
    $prefixLength = [int]($Cidr.Split('/')[1])
    # 将IPv6地址转换为字节数组
    $ipBytes = [System.Net.IPAddress]::Parse($networkAddress).GetAddressBytes()
    # 生成随机IPv6地址
    $randomBytes = New-Object byte[] 16
    for ($i = 0; $i -lt 16; $i++) {
        $bytePosition = $i * 8
        if ($bytePosition + 8 -le $prefixLength) {
            # 网络部分保持不变
            $randomBytes[$i] = $ipBytes[$i]
        }
        elseif ($bytePosition -le $prefixLength) {
            # 处理跨越字节边界的位
            $bitsInByte = $prefixLength - $bytePosition
            $mask = (0xFF -shl (8 - $bitsInByte)) -band 0xFF
            $randomBytes[$i] = ($ipBytes[$i] -band $mask) -bor (Get-Random -Minimum 0 -Maximum (1 -shl (8 - $bitsInByte)))
        }
        else {
            # 主机部分随机生成
            $randomBytes[$i] = Get-Random -Minimum 0 -Maximum 256
        }
    }    
    # 转换为IPv6地址字符串
    $randomIP = [System.Net.IPAddress]::new($randomBytes).ToString()
    return $randomIP
}

function Test-IP {
    param(
        [string]$FilePath,
        [scriptblock]$GetIP
    )
    Get-Content -Path $FilePath | ForEach-Object {
        If ($_.Contains('/')) {
            $test_ip = & $GetIP $_
            $test_time = .\Httping-CloudflareIP.PS1 $test_ip $Count $Timeout $CheckDomain
            if ($test_time -eq 0) {
                return
            }
            elseif ($current_time -eq 0 -or $test_time -lt $current_time) {
                $current_time = .\Httping-CloudflareIP.PS1 $CurrentIP $Count $Timeout $CheckDomain
                if ($current_time -eq 0 -or $test_time -lt $current_time) {
                    Write-Host "Better Cloudflare IP: $test_ip"
                    Write-Output $test_ip
                    exit
                }
            }
        }
    }
}

function Test-IPv4 {
    Test-IP CloudflareIPv4.Txt ${function:Get-RandomIPv4FromCidr}
}

function Test-IPv6 {
    Test-IP CloudflareIPv6.Txt ${function:Get-RandomIPv6FromCidr}
}

Write-Host "Current Cloudflare IP: $CurrentIP"
$current_time = .\Httping-CloudflareIP.PS1 $CurrentIP $Count $Timeout $CheckDomain

If ($AllIP) {
    Test-IPv6
    Test-IPv4
}
ElseIf ($CurrentIP.Contains(':')) {
    Test-IPv6
}
Else {
    Test-IPv4
}
Write-Host "No better Cloudflare IP"
Return $CurrentIP