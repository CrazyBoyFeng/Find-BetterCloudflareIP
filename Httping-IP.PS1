Param($CheckDomain, $IP)
$result = (curl.exe --head https://$CheckDomain/cdn-cgi/trace --resolve $CheckDomain:443:$IP --write-out '%{time_total}' --output NUL)
$time = try { [float] $result } catch { 0 }
Return $time
