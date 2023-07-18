$adapterName = "以太网"
$gateway1 = "192.168.1.1"
$gateway2 = "192.168.1.101"

$currentGateway = (netsh interface ipv4 show config name="$adapterName" | Select-String "默认网关" | ForEach-Object { $_.ToString().Split(":")[1].Trim() })

if ($currentGateway -eq $gateway1) {
    $newGateway = $gateway2
} elseif ($currentGateway -eq $gateway2) {
    $newGateway = $gateway1
} else {
    Write-Host "未找到可用的默认网关"
    exit
}

$staticParams = "name=$adapterName source=static 192.168.1.100 255.255.255.0 $newGateway"
$dnsParams = "name=$adapterName source=static addr=$newGateway register=primary"
$setAddressCommand = "netsh interface ipv4 set address $staticParams"
$setDnsCommand = "netsh interface ipv4 set dns $dnsParams"
Invoke-Expression -Command $setAddressCommand
Invoke-Expression -Command $setDnsCommand

$message = "已将默认网关更改为 $newGateway"
New-BurntToastNotification -Text $message