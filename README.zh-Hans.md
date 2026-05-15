# Find-BetterCloudflareIP
脚本：通过 HTTPing 查找更好的 Cloudflare IP。

## 简介
本项目不采用大文件测速的方式来检验 IP，也不采用多并发连接来进行检测，将来也不打算添加这些特性。  
这是因为以上特性有以下缺点：
* 会对系统造成负担。
* 会对 ISP 造成负担导致被 ISP 限制。
* 会对 Cloudflare 造成负担导致被 Cloudflare 判定为滥用。

## 运行环境
* PowerShell  
Windows Vista 及之后的 Windows 操作系统都内置了 PowerShell。

## 用法
运行脚本：
```PowerShell
.\Find-BetterCloudflareIP.PS1 -CurrentIP <IP> [-AllIP] [-Count <Int>] [-Timeout <Int>] [-CheckDomain <String>]
```

将会根据 IP 地址类型遍历对应的 IP 地址池列表文件。从每个 CIDR 格式的 IP 地址范围中随机选取一个 IP 地址进行测试。  
如果发现更快且不丢包的 IP 地址，脚本将返回 `<BetterIP>`。  
如果所有 IP 地址池遍历完毕也没有找到更快且不丢包的 IP 地址，脚本将返回 `<CurrentIP>`。

### 参数说明

| 参数 | 必填 | 默认值 | 说明 |
|------|------|--------|------|
| `-CurrentIP` | 是 | - | 当前 Cloudflare IP，用于比较 |
| `-AllIP` | 否 | - | 同时检测 IPv4 和 IPv6 |
| `-Count` | 否 | 5 | 每个 IP 的 httping 次数 |
| `-Timeout` | 否 | 5 | 超时阈值（秒） |
| `-CheckDomain` | 否 | cf.xiu2.xyz | 检测用域名，建议使用自己的域名 |

### 使用示例
```PowerShell
# 基本用法
.\Find-BetterCloudflareIP.PS1 -CurrentIP "1.1.1.1"

# 同时检测 IPv4 和 IPv6
.\Find-BetterCloudflareIP.PS1 -CurrentIP "1.1.1.1" -AllIP

# 自定义参数
.\Find-BetterCloudflareIP.PS1 -CurrentIP "1.1.1.1" -Count 10 -Timeout 3.0 -CheckDomain "your-domain.com"
```

### Httping-CloudflareIP.PS1
此脚本由 `Find-BetterCloudflareIP.PS1` 内部调用，也可单独使用：
```PowerShell
.\Httping-CloudflareIP.PS1 -IP <IP> [-Count <Int>] [-Timeout <Int>] [-CheckDomain <String>]
```

| 参数 | 必填 | 默认值 | 说明 |
|------|------|--------|------|
| `-IP` | 是 | - | 要检测的 IP 地址 |
| `-Count` | 否 | 5 | httping 次数 |
| `-Timeout` | 否 | 5 | 超时阈值（秒） |
| `-CheckDomain` | 否 | cf.xiu2.xyz | 检测用域名 |
