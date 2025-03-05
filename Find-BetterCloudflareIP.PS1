Param($CurrentIP)
$count = 4 # httping count of each ip
$check_domain = 'cf.xiu2.xyz' # Recommend to use your own

Set-Location -Path $PSScriptRoot

Function Test-IP {
    Param($Count, $CheckDomain, $IP)
    Write-Host "Test IP: $IP"
    $time_sum = [float]0
    For ($i = 1; $i -lt $Count + 1; $i++) {        
        $time = .\Httping-IP.PS1 $CheckDomain $IP
        if ($time -eq 0) {
            Write-Host "Test $IP loss"
            return 0
        }
        else {
            $time_sum = $time_sum + $time
        }
        Start-Sleep 1
    }
    $time = $time_sum / $Count
    Write-Host "Test $IP time $time"
    return $time
}

function Get-RandomIPv4FromCidr {
    param (
        [string]$Cidr
    )

    # 提取网络地址和子网掩码
    $networkAddress = $Cidr.Split('/')[0]
    $subnetMaskLength = [int]($Cidr.Split('/')[1])

    # 计算网络地址的整数形式
    $ipBytes = [System.Net.IPAddress]::Parse($networkAddress).GetAddressBytes()
    $networkAddressInt = [System.BitConverter]::ToUInt32($ipBytes, 0)

    # 计算子网掩码
    $subnetMask = [System.Net.IPAddress]::Parse(([math]::Pow(2, 32) - [math]::Pow(2, 32 - $subnetMaskLength))).GetAddressBytes()
    $subnetMaskInt = [System.BitConverter]::ToUInt32($subnetMask, 0)

    # 计算网络地址和广播地址
    $networkStart = $networkAddressInt -band $subnetMaskInt
    $networkEnd = $networkStart -bor (-bnot $subnetMaskInt)

    # 随机生成一个 IP 地址
    $randomIPInt = Get-Random -Minimum $networkStart -Maximum $networkEnd
    $randomIPBytes = [System.BitConverter]::GetBytes($randomIPInt)
    $randomIP = [System.Net.IPAddress]::new($randomIPBytes).ToString()

    return $randomIP
}

function Get-RandomIPv6FromCidr {
    param (
        [string]$Cidr
    )

    # 提取网络地址和前缀长度
    $networkAddress = $Cidr.Split('/')[0]
    $prefixLength = [int]($Cidr.Split('/')[1])

    # 将 IPv6 地址转换为字节数组
    $ipBytes = [System.Net.IPAddress]::Parse($networkAddress).GetAddressBytes()

    # 计算掩码
    $maskBytes = New-Object byte[] 16
    for ($i = 0; $i -lt 16; $i++) {
        $bitsRemaining = [Math]::Max(0, $prefixLength - $i * 8)
        $maskBytes[$i] = if ($bitsRemaining -ge 8) { 0xFF } else { (-1 -shl (8 - $bitsRemaining)) -band 0xFF }
    }

    # 生成随机 IPv6 地址
    $randomBytes = New-Object byte[] 16
    for ($i = 0; $i -lt 16; $i++) {
        $networkByte = $ipBytes[$i]
        $maskByte = $maskBytes[$i]
        $randomByte = Get-Random -Minimum ($networkByte -band $maskByte) -Maximum 256
        $randomBytes[$i] = $randomByte
    }

    # 转换为 IPv6 地址
    $randomIP = [System.Net.IPAddress]::new($randomBytes).ToString()

    return $randomIP
}

$current_time = Test-IP $count $check_domain $CurrentIP
$test_time = [float]0
If ($CurrentIP.Contains('.')) {
    Get-Content -Path IPv4.Txt | ForEach-Object {
        If ($_.Contains('/')) {
            $test_ip = Get-RandomIPv4FromCidr $_
            $test_time = Test-IP $count $check_domain $test_ip
            if ($test_time -eq 0) {
                continue
            }
            elseif ($test_time -lt $current_time) {
                $current_time = Test-IP $count $check_domain $CurrentIP
                if ($current_time -eq 0 -or $test_time -lt $current_time) {
                    return $test_ip
                }
            }
        }
    }
}
ElseIf ($CurrentIP.Contains(':')) {
    Get-Content -Path IPv6.Txt | ForEach-Object {
        If ($_.Contains('/')) {
            $test_ip = Get-RandomIPv6FromCidr $_
            $test_time = Test-IP $count $check_domain $test_ip
            if ($test_time -eq 0) {
                continue
            }
            elseif ($test_time -lt $current_time) {
                $current_time = Test-IP $count $check_domain $CurrentIP
                if ($current_time -eq 0 -or $test_time -lt $current_time) {
                    return $test_ip
                }
            }
        }
    }
}
Else {
    Write-Error "Invalid IP $CurrentIP"
    Exit 1
}
Return $CurrentIP