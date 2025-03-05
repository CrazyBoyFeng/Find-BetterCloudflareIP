Param($IP, $Count = 4, $CheckDomain = "cf.xiu2.xyz")

Function Httping {
    Param($IP, $CheckDomain)
    $result = (curl.exe --head https://$CheckDomain/cdn-cgi/trace --resolve $CheckDomain:443:$IP --write-out '%{time_total}' --output NUL --silent)
    $time = try { [float] $result } catch { 0 }
    Return $time
}

Write-Host "HTTPing Cloudflare IP: $IP"
$time_sum = [float]0
$loss_sum = 0
For ($i = 1; $i -lt $Count + 1; $i++) {        
    $time = Httping $IP $CheckDomain
    if ($time -eq 0) {
        $loss_sum++
        Write-Host "#$i loss"
        Start-Sleep 1
        continue
    }
        Write-Host "#$i time: ${time}s"
        Write-Debug "#$i time: ${time}s"
        $time_sum = $time_sum + $time
    }
    Start-Sleep 1
}
$time_avg = $time_sum / ($Count - $loss_sum)
$loss_rate = [float]$loss_sum / $Count
Write-Host "Result: average time = ${time_avg}s, loss rate = $loss_rate"
return $time_avg, $loss_rate
