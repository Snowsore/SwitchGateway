$adapterName = "以太网"
$ip1 = "192.168.2.10"
$ip2 = "192.168.2.10"
$gateway1 = "192.168.2.1"
$gateway2 = "192.168.2.11"

$currentGateway = (netsh interface ipv4 show config name="$adapterName" | Select-String "默认网关" | ForEach-Object { $_.ToString().Split(":")[1].Trim() })

if ($currentGateway -eq $gateway1) {
    $newGateway = $gateway2
    $newIP = $ip2
} elseif ($currentGateway -eq $gateway2) {
    $newGateway = $gateway1
    $newIP = $ip1
} else {
    Write-Host "未找到可用的默认网关"
    exit
}

$staticParams = "name=$adapterName source=static $newIP 255.255.255.0 $newGateway"
$dnsParams = "name=$adapterName source=static addr=$newGateway register=primary"
$setAddressCommand = "netsh interface ipv4 set address $staticParams"
$setDnsCommand = "netsh interface ipv4 set dns $dnsParams"
Invoke-Expression -Command $setAddressCommand
Invoke-Expression -Command $setDnsCommand

New-BurntToastNotification -Text "已将网络配置更改为:", "地址: $newIP", "网关: $newGateway"
