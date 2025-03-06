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
* curl  
Windows 10 1709 及之后的 Windows 操作系统都内置了 curl。  
若使用早期的 Windows 操作系统，则需要自行安装 curl。

## 用法
1. 编辑脚本 `Find-BetterCloudflareIP.PS1`，按需求填写参数。
2. 运行脚本：
```PowerShell
.\Find-BetterCloudFlareIP.PS1 <CurrentIP>
```
将会根据 IP 地址类型遍历对应的 IP 地址池列表文件。从每个 CIDR 格式的 IP 地址范围中随机选取一个 IP 地址进行测试。  
如果发现更快且不丢包的 IP 地址，脚本将返回 `<BetterIP>`。  
如果所有 IP 地址池遍历完毕也没有找到更快且不丢包的 IP 地址，脚本将返回 `<CurrentIP>`。