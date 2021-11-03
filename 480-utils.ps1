Function Read-HostDefault([string]$prompt, [string]$default)
{
    if(!prompt){
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
        $msg = "connected to: {0}" -f $conn

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
    Get-VMHost | Select-Object Name
    $vsphere_host = Read-Host "Pick a server to host vm ["$global:config.vm_host"]"
    Read-HostDefault($vsphere_host)
    if (!vsphere_host) {
        $global:vm_host = Get-VMHost -Name $global:config.vm_host
    } else {
        $global:vm_host = Get-VMHost -Name $vsphere_host
    }
}

function pick_vm([string] $folder)
{
    Get-Folder | -Type VM | Select-Object Name
    $folder = Read-Host "Which folder you want to clone a VM ["$global:config.base_folder"]"
    Read-HostDefault($folder)
    if(!$folder){
        $basefolder = Get-Folder -Name $global:config.base_folder
    } else {
        $basefolder = Get-Folder -Name $folder 
    }
    $vm_list = $basefolder | Get-VM
    foreach ($vm in $vm_list)
    {
        Write-Host $vm.Name
    }
}

function pick_datastore()
{
    Get-Datastore | Select-Object Name
    $datastore = Read-Host "Choose the datastore ["$global:config.datastore"]"
    Read-HostDefault($datastore)
    if (!$datastore){
        $global:datastore = Get-VMHost -Name $global:config.datastore
    } else {
        $global:datastore = Get-VMHost -Name $datastore
    }
    $datastore_list = $datastore | Get-Datastore
    foreach ($datastore in $datastore_list)
    {
        Write-Host $datastore.Name
    }
}

function pick_network([string] $network)
{
    Get-NetworkAdapter | -Type Network | Select-Object Name
    $network = Read-Host "choose the network you want to have ["$global:config.network"]"
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
    $server = Read-Host "Which server would you like to chopose? ["$global:config.vcenter_server"]"
    Read-HostDefault($server)
    connect($server)
    pick_host
    pick_datastore
    pick_vm
    pick_network
}

#temporary main
cloner -config_path *./480-utils.json*
