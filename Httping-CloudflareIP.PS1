Param(
    [Parameter(Mandatory=$true)]$IP,
    [int]$Count = 5,
    [int]$Timeout = 5,
    [string]$CheckDomain = "cf.xiu2.xyz"
)

Function Get-HttpPingTime {
    param(
        [string]$IP,
        [string]$CheckDomain,
        [int]$TimeoutSec
    )

    [System.Net.ServicePointManager]::Expect100Continue = $false

    try {
        $request = [System.Net.HttpWebRequest]::Create("https://${CheckDomain}/cdn-cgi/speculation")
        $request.Host = $CheckDomain
        $request.Timeout = $TimeoutSec * 1000
        $request.Method = "HEAD"

        $remoteEndPoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse($IP), 443)
        $request.ServicePoint.BindIPEndPointDelegate = {
            param($servicePoint, $remoteEndpoint, $localEndPoint, $state)
            return $remoteEndPoint
        }

        $stopwatch = [Diagnostics.Stopwatch]::StartNew()
        $response = $request.GetResponse()
        $stopwatch.Stop()

        $statusCode = [int]$response.StatusCode
        $response.Close()

        if ($statusCode -eq 200) {
            return $stopwatch.Elapsed.TotalSeconds
        }
        return 0
    }
    catch {
        return 0
    }
}

Write-Host "HTTPing Cloudflare IP: $IP"
$time_sum = [float]0
For ($i = 1; $i -lt $Count + 1; $i++) {
    $time = Get-HttpPingTime -IP $IP -CheckDomain $CheckDomain -TimeoutSec $Timeout
    if ($time -eq 0) {
        Write-Host "#$i loss"
        $time_sum = 0
        break
    }
    else {
        Write-Host "#$i time: ${time}s"
        $time_sum = $time_sum + $time
    }
    Start-Sleep 1
}
$time_avg = $time_sum / $Count
Write-Host "Average time: ${time_avg}s"
Write-Host ""
return $time_avg
