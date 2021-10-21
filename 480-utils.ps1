Function Read-HostDefault([string]$prompt, [string]$default)
{

}

Function connect([string] $server)
{
    $conn = $global:DefaultVIServer
    # are we connected?
    if ($conn){
        $msg = "connected to: {0}" -f $conn

        Write-Host $msg
    }else
    {
        $conn = Connect-VIServer -Server $server
    }
    return $conn
}