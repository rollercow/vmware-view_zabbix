#################
# CONFIGURATION #
#################
#pools you care about
$pools = ('floating','dedicated','stata','course')

#load vmware snapin
. "C:\Program Files\VMware\VMware View\Server\extras\PowerShell\add-snapin.ps1"

#################
#   FUNCTIONS   #
#################
Function Send-Value {#send key value pair to zabbix
    param (
        [parameter(mandatory=$true)] $key,
        [parameter(mandatory=$true)] $value
    )
    $cmd = "C:\zabbix\zabbix_sender.exe -c C:\zabbix\zabbix_agentd.win.conf -k `"$key`" -o `"$value`""
    echo "$cmd"
    Invoke-Expression $cmd
}

Function Send-Pool { #the stuff we care about per pool
    param (
        [parameter(mandatory=$true)] $pool_id
    )
    #Float
    $value = @(Get-RemoteSession -pool_id $pool_id).count
    Send-Value vmware.view.session.$pool_id.count $value
    $value = @(Get-RemoteSession -state connected -pool_id $pool_id).count
    Send-Value vmware.view.session.$pool_id.connected.count $value
    $value = (Get-Pool -pool_ID $pool_id).maximumCount
    Send-Value vmware.view.session.$pool_id.max $value
}

#################
#  VIEW STATS   #
#################

#current sessions
$value = @(Get-RemoteSession).count
Send-Value vmware.view.session.count $value
#current connected sessions (all important licencing number!)
$value = @(Get-RemoteSession -state connected).count
Send-Value vmware.view.session.connected.count $value

foreach ($pool_id in $pools) {
    Send-Pool($pool_id)
}
