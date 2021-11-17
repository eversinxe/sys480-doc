Function Read-HostDefault([string]$prompt, [string]$default)
{
    if(!$prompt){
        Write-Host "Within the default value"
    }else {
        Write-Host "You chose:" $prompt
    }
}

Function connect([string] $server)
{
    $conn = $global:DefaultVIServer
    # to see if connected
    if ($conn){
        $msg = "connected to:{0}" -f $conn

        Write-Host $msg
    }else
    {
        $conn = Connect-VIServer -Server $server
    }
    return $conn
}

## function check_index([int]$selection.[int]$max)
{
    
}
function pick_host()
{
    $global:vm_host = $null
    Get-VMHost | Select-Object Name
    $vsphere_host = Read-Host "Host Name:[]"
    Read-HostDefault($vsphere_host)
    if (!$vsphere_host) {
        $global:vm_host = Get-VMHost -Name $global:config.vm_host
    } else {
        $global:vm_host = Get-VMHost -Name $vsphere_host
    }
}

function pick_folder([string] $folder)
{
    $global:config.base_folder = $null
    Get-Folder | Select-Object Name
    $folder = Read-Host "Folder Name:[]"
    Read-HostDefault(!$folder)
    if(!$folder){
        $basefolder = Get-Folder -Name $global:config.base_folder
    } else {
        $basefolder = Get-Folder -Name $folder 
    }
    $folder_list = $basefolder | Get-Folder
    foreach ($segment in $folder_list)
    {
        Write-Host $segment.Name
    }
}

function pick_vm([string] $vm)
{
    Get-VM | Select-Object Name
    $vm = Read-Host "VM Name:[]"
    Read-HostDefault(!$vm)
    if(!$vm){
        $basevm = Get-VM -Name $global:config.basevm
    } else {
        $basevm = Get-VM -Name $vm
    }
    $vm_list = $basevm | Get-VM
    foreach ($virtmachine in $vm_list)
    {
        Write-Host $virtmachine.Name
    }
}

function pick_snapshot([string] $snapshot)
{
    Get-Snapshot | Select-Object Name
    $snapshot = Read-Host "Snapshot Name:[]"
    Read-HostDefault(!$snapshot)
    
    $snapshot = Get-Snapshot -VM $basevm -Name "Base"

}
function pick_datastore()
{
    $global:datastore = $null
    Get-Datastore | Select-Object Name
    $datastore = Read-Host "Datastore Name:[]"
    Read-HostDefault($datastore)
    if (!$datastore){
        $global:datastore = Get-Datastore -Name $global:config.datastore
    } else {
        $global:datastore = Get-Datastore -Name $datastore
    }
    $datastore_list = $datastore 
    foreach ($datastore in $datastore_list)
    {
        Write-Host $datastore.Name
    }
}

function create_clone([string] $clone)
{
    $choice = Read-Host "Linked Clone or Full Clone [F/L]: []"
    If($choice -eq 'F' -or $choice -eq 'f' )
    {
        $Tempname = "{0}.temp" -f $virtmachine.Name
        $Tempvm = New-VM -Name $Tempname -VM $virtmachine -LinkedClone -ReferenceSnapshot $snapshot -VMHost $vm_host -Datastore $datastore
        $newname = Read-Host "New VM Name:[]"

        $newvm = New-VM -Name $newname -VM $Tempvm -VMHost $vm_host -Datastore $datastore -Location $folder
        setNetwork -vm $newvm
        $newvm | new-snapshot -Name "Base"
        $Tempvm | Remove-VM

    }elseif ($choice -eq 'L' -or $choice -eq 'l' ) {
        $newname = "{0}.linked" -f $virtmachine.Name
        $newvm = New-VM -Name $newname -VM $virtmachine -LinkedClone -ReferenceSnapshot $snapshot -VMHost $vm_host -Datastore $dstore -Location $folder
        setNetwork -vm $newvm

    }else{
        throw "Select [L]inked Clone or [F]ull Clone: []"
    }
}
function pick_virtualswitch([string] $myVirtualSwitch)
{
    $global:config.switch = $null
    Get-VirtualSwitch | Select-Object Name
    $myVirtualSwitch = Read-Host "Switch Name:[]"
    Read-HostDefault($myVirtualSwitch)
    if (!$myVirtualSwitch){
        $virtualadapter = Get-VirtualSwitch -Name $global:config.switch 
    } else {
        $virtualadapter = Get-VirtualSwitch -Name $myVirtualSwitch
    }
    $virtswitch = $virtualadapter | Get-VirtualSwitch
    foreach ($virtswitch in $virtswitch_list)
    {
        Write-Host $virtswitch.Name
    }
}
function pick_network([string] $network)
{
    $global:config.network = $null
    Get-VirtualSwitch | Select-Object Name
    ##Get-NetworkAdapter | Select-Object Name
    $network = Read-Host "Network Name:[]"
    Read-HostDefault($network)
    if (!network){
        $networkadapter = Get-NetworkAdapter -Name $global:config.network 
    } else {
        $networkadapter = Get-NetworkAdapter -Name $network
    }
    $ntwrk = $networkadapter | Get-NetworkAdapter
    foreach ($ntwrk in $ntwrk_list)
    {
        Write-Host $ntwrk.Name
    }
}

function get_config([string] $config_path)
{
    $Global:config = (Get-Content $config_path) | ConvertFrom-Json
}

function cloner($config_path)
{
    get_config($config_path)
    $server = Read-Host "Server Name:["$global:config.vcenter_server"]"
    Read-HostDefault($server)
    connect($server)
    pick_host
    pick_datastore
    pick_folder
    pick_vm
    pick_snapshot
    create_clone
    pick_network
}

function createNetwork([string] $switch)
{
    $vmhost = Get-VMHost -Name MyVMHost1
    $myVirtualSwitch = Get-VirtualSwitch -VMHost $vmhost -Name BLUE13-WAN
    New-VMHostNetworkAdapter -VMHost $vmhost -PortGroup MyVMKernelPortGroup1 -VirtualSwitch $myVirtualSwitch -Mtu 4000

}

#temporary main
cloner -config_path 480-milestone-6/480-utils.json
