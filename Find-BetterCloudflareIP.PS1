Param($CurrentIP = '')
$count = 5 # httping count of each ip
$check_domain = 'cf.xiu2.xyz' # Recommend to use your own

Set-Location -Path $PSScriptRoot

Httping-IP {
    Param($CheckDomain, $IP)
    $result = (curl.exe --head https://$CheckDomain/cdn-cgi/trace --resolve $CheckDomain:443:$IP --write-out '%{time_total}' --output NUL)
    $time = try { [float] $result } catch { 0 }
    Return $time
}

Test-IP {
    Param($Count, $CheckDomain, $IP)
    Write-Host "Test IP: $IP"
    $time_sum = [float]0
    $loss_sum = 0
    For ($i = 1; $i -lt $Count + 1; $i++) {        
        $time = Httping-IP $CheckDomain $IP
        if ($time -eq 0) {
            $loss_sum++
            Write-Host "Test $IP loss"
            break
        }
        else {
            $time_sum = $time_sum + $time
        }
        Start-Sleep 1
    }
    $time = $time_sum / ($Count - $loss_sum)
    Write-Host "Test $IP time $time"
    return $time
}