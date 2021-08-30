Function Use-Object {
#I stole this one from: https://consolelog.collaboratingplatypus.com/2019/07/01/csharp-using-statement-for-powershell/
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [AllowNull()]
        [Object]
        $InputObject,
        [Parameter(Mandatory = $true)]
        [scriptblock]
        $ScriptBlock
    )
    Process {
        try {
            . $ScriptBlock
        }
        finally {
            if ($null -ne $InputObject -and $InputObject -is [System.IDisposable]) {
                $InputObject.Dispose()
            }
        }
    }
}

function Set-PointerPosition
{
    <#
        .Description
            Given an x/y coordinate in pixels, move the cursor to that location
    #>
    param(
        $x,
        $y
    )
    [system.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | out-null
    [System.Windows.Forms.Cursor]::Position =  New-Object System.Drawing.Point($x,$y)
}

function Get-PointerPosition
{
    <#
        .Description
            Returns the current cursor location in x/y coordinates
    #>
    [system.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | out-null
    [System.Windows.Forms.Cursor]::Position
}

function Move-PointerPosition
{
    <#
        .Description
            Moves the cursor relative to its current location
            e.g. "up 10px, left 50px"
        .Synopsis
            Lol vector math.... maybe later since I was but a C student.
    #>
    [CmdletBinding(DefaultParameterSetName='numbers')]
    param(
        [parameter(mandatory=$true,position=0)][int]$magnitude,
        [parameter(parameterSetName='text',position=1)][Validateset("up","down","left","right","upleft","upright","downleft","downright")][string]$cardinaldirection,
        [parameter(parameterSetName='number',position=1)][int]$direction
    );
    Write-Warning "$($myInvocation.MyCommand) Not Yet Implemented"
}

function Invoke-PointerAction
{
    <#
        .Description
            Enum based actions for Left,Right,middle clicks and scroll up / down
    #>
param(
    [parameter()][validateSet("left","middle","right","leftdown","leftup","rightdown","rightup","middledown","middleup")]$Button,
    [parameter()]$durationmilliseconds
);

$signature=@' 
[DllImport("user32.dll",CharSet=CharSet.Auto, CallingConvention=CallingConvention.StdCall)]
public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExtraInfo);
'@ 

    Use-Object ( $SendMouseClick = Add-Type -memberDefinition $signature -name "Win32MouseEventNew" -namespace Win32Functions -passThru -ErrorAction silentlyContinue ){
        switch($Button) 
        {
            "left"
            {
                $SendMouseClick::mouse_event(0x00000002, 0, 0, 0, 0);
                $SendMouseClick::mouse_event(0x00000004, 0, 0, 0, 0);
            }

            "leftdown"
            {
                $SendMouseClick::mouse_event(0x00000002, 0, 0, 0, 0);
            }

            "leftup"
            {
                $SendMouseClick::mouse_event(0x00000004, 0, 0, 0, 0);
            }

            "right"
            {
                $SendMouseClick::mouse_event(0x00000008, 0, 0, 0, 0);
                $SendMouseClick::mouse_event(0x00000010, 0, 0, 0, 0);
            }

            "rightdown"
            {
                $SendMouseClick::mouse_event(0x00000008, 0, 0, 0, 0);
            }

            "rightup"
            {
                $SendMouseClick::mouse_event(0x00000010, 0, 0, 0, 0);
            }

            "middle"
            {
                $SendMouseClick::mouse_event(0x00000020, 0, 0, 0, 0);
                $SendMouseClick::mouse_event(0x00000040, 0, 0, 0, 0);
            }

            "middledown"
            {
                $SendMouseClick::mouse_event(0x00000020, 0, 0, 0, 0);
            }

            "middleup"
            {
                $SendMouseClick::mouse_event(0x00000040, 0, 0, 0, 0);
            }

            default {Write-Error "Action $Button not implemented"}
        }
    }
}