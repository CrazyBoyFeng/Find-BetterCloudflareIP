Param($CurrentIP = '')
$count = 5 # httping count of each ip
$loss_rate = 0.0 
$check_domain = 'cf.xiu2.xyz' # Recommend to use your own

Set-Location -Path $PSScriptRoot

Httping-IP {
    Param($CheckDomain, $IP)
    $result = (curl.exe --head https://$CheckDomain/cdn-cgi/trace --resolve $CheckDomain:443:$IP --write-out '%{time_total}' --output NUL)
    $time = try { [float] $result } catch { 0 }
    return $time
}
