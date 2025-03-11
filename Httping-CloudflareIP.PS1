Param($IP, $Count = 5, $Timeout = 5, $CheckDomain = "cf.xiu2.xyz")

Function Httping {
    # 获取连接时间和HTTP状态码
    $result = (curl.exe --head https://${CheckDomain}/cdn-cgi/trace --resolve ${CheckDomain}:443:${IP} --max-time ${Timeout} --write-out '%{time_total} %{http_code}' --output NUL --silent)
    $parts = $result.Split(' ')
    $time = try { [float] $parts[0] } catch { 0 }
    $status = try { [int] $parts[1] } catch { 0 }
    Return $time, $status
}

Write-Host "HTTPing Cloudflare IP: $IP"
$time_sum = [float]0
For ($i = 1; $i -lt $Count + 1; $i++) {        
    $time, $status = Httping $IP $CheckDomain $Timeout
    if ($time -eq 0 -or $status -ne 200) {
        Write-Host "#$i loss (Status: $status)"
        $time_sum = 0
        break
    }
    else {
        Write-Host "#$i time: ${time}s (Status: ${status})"
        $time_sum = $time_sum + $time
    }
    Start-Sleep 1
}
$time_avg = $time_sum / $Count
Write-Host "Average time: ${time_avg}s"
Write-Host ""
return $time_avg