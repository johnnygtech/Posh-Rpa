function Start-ScrapingLoop
{
    <#
        .DESCRIPTION
            Will eventually be used as a main loop for some automation logic
    #>
    param(
        $directory,
        $sleepTime
    );

    write-warning "untested/poorly implemented"

    if(-not $directory){$directory = $(New-TemporaryFile | Select-object -Property Directory)}

    while($true)
    {

        1..100 | %{
            #Maybe eventually ship to a shared process in memory/pointer instead of writing to disc?
            New-ScreenShot -path $_ -directory $directory
            Start-sleep $sleepTime
        }
    }
}

function New-ScreenShot
{
    <#
        .DESCRIPTION
            takes a snapshot starting and ending at the given pixel points of the indicated screen (main screen if not specified)
    #>
    param(
        [parameter()]$startx=0,
        [parameter()]$starty=0,
        [parameter()]$endx=1920,
        [parameter()]$endy=1080,
        [int]$screenindex,
        $path,
        $directory
    );
    if(-not $directory -or -not $path){
        $temp=$(New-TemporaryFile)
        if(-not $directory){$directory = $temp.DirectoryName}
        if(-not $path){$path = "$($temp.Name).bmp"}
        #$path = 
    }

    #Stolen from: https://stackoverflow.com/questions/2969321/how-can-i-do-a-screen-capture-in-windows-powershell
    [Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-null
    function screenshot([Drawing.Rectangle]$bounds, $path) {
        $bmp = New-Object Drawing.Bitmap $bounds.width, $bounds.height, $([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
        $graphics = [Drawing.Graphics]::FromImage($bmp)

        $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.size)

        $bmp.Save($path)

        $graphics.Dispose()
        $bmp.Dispose()
    }

    if($screenindex)
    {
        $objectscreens=[System.Windows.Forms.Screen]::AllSCreens
        $screenindexbounds=$objectscreens[$screenindex]
        $startx=$screenindexbounds.Left
        $starty=$screenindexbounds.Top
        $endx=$screenindexbounds.Right
        $endy=$screenindexbounds.Bottom
    }
    
    $bounds=[Drawing.Rectangle]::FromLTRB($startx,$starty,$endx,$endy)
    screenshot $bounds $path
    return $path
}

function Find-BitmapInBitmap
{
    param(
        $toFind,
        $findIn,
        $method,
        $sensitivity,
        [switch]$binary #returns true/false, not not the location
    );

    write-warning "untested/poorly implemented"


    [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms"); 
    $tofindLoaded = new-object System.Drawing.Bitmap $toFInd
    $findInLoaded = new-object System.Drawing.Bitmap $findin
    if($findInLoaded.PixelFormat -ne $tofindLoaded.PixelFormat){Write-Error "Image pixels are different formats: $($findInLoaded.PIxelFormat) and $($tofindloaded.PIxelFormat)"; return}
    $littlex=$littley=$bigx=$bigy=0

    $MatchWatcher=@{
        "maximumMatches"=$($tofindLoaded.Height * $tofindLoaded.Width)
        "currentMatches"=0;
        "sensitivyReached"=$false;
        "xlocation"=$null;
        "yLocation"=$null;
        "firstXlocation"=$null;
        "firstYlocation"=$null;
    }

    #two approaches possible.  Go Until you find a match of x% or better, or search all and report the best match, or go all and return all possible matches
    # fast, will have misses, slow, and slowest

    $Done = $false
    while(-not $Done)
    {
        if($littlex -ge $tofindLoaded.width -or $littley -ge $tofindLoaded.height){}else
        {
            $PixelsMatch = $tofindLoaded.GetPixel($littlex,$littley).Name -eq $findInLoaded.GetPixel($bigx,$bigy).Name
        }
        if($pixelsMatch)
        {
            $MatchWatcher.CurrentMatches++;
            $MatchWatcher.xLocation=$bigx;
            $matchWatcher.yLocation=$bigy;
            if(($MatchWatcher.firstXlocation = $null) -and ($MatchWatcher.firstYlocation = $null) ){
                $MatchWatcher.firstxLocation=$bigx;
                $matchWatcher.firstyLocation=$bigy;
            }
            #loop here for all "little images" pixels from current bigx/y location
            do{
                $littlex++;
                if($tofindLoaded.GetPixel($littlex,$littley).Name -eq $findInLoaded.GetPixel($bigx,$bigy).Name)
                {
                    $MatchWatcher.currentMatches++
                }
                if($littlex -eq $tofindloaded.width){$littley++;if(-not $($littley -ge $toFindLoaded.Height)){$littlex=0}}
            }until($littley -eq $toFindLoaded.height -and $littlex -eq $tofindLoaded.Width)

            $matchwatcher.sensitivtyReached = $($($MatchWatcher.CurrentMatches / $MatchWatcher.maximumMatches) * 100) -ge $sensitivty
            $PixelsMatch=$false

        }
        $bigx++;
        
        if($bigx -ge $findinloaded.width){$bigy++;if(-not $($bigy -eq $findinloaded.Height)){$bigx=0}}
        if($bigy -ge $findinloaded.height -and $bigx -ge $findinloaded.width){$Done=$true}
        if($matchwatcher.sensitivtyReached){$Done=$true}

    }

    if($($($MatchWatcher.CurrentMatches / $MatchWatcher.maximumMatches) * 100) -ge $sensitivty)
    {
        #returns x.y of top left corner within "big image" of match or null
        return $matchWatcher
    }
    else
    {
        return @{}    
    }

}

#memory nonsense is hard between powershell and c# it seems
function Get-PixelArray
{
    param([System.Drawing.Bitmap]$bitmap)

    write-warning "untested/poorly implemented"

    [int[][]]$result=0..$bitmap.height
    $bitmapdata = $bitmap.LockBits([system.drawing.rectangle]::new(0, 0, $bitmap.Width, $bitmap.height), "ReadOnly" ,$bitmap.PixelFormat)
    [System.IntPtr]$ptr = $bitmapdata.Scan0
    $bytes=0..[int]$($bitmapdata.stride)*$($bitmap.height)
    #https://stackoverflow.com/questions/6020406/travel-through-pixels-in-bmp
    $r = 0..$($bytes.Length/3)
    $g = 0..$($bytes.Length/3)
    $b = 0..$($bytes.Length/3)
    [system.runtime.interopservices.marshal]::copy($ptr,$Bytes,0,$bytes.length)
    $count=0
    $stride = $bitmapdata.Stride;

    for($column=0;$column -lt $bitmapdata.Height; $column++)
    {
        for($row=0;$row -lt $bitmapdata.Width; $row++)
        {
            $b[$count]=$bytes[($column*$stride) + ($row * 3)]
            $g[$count]=$bytes[($column*$stride) + ($row*3)+1]
            $r[$count++]=$bytes[($column*$stride) + ($row*3)+2]
        }
    }

    #for($y=0;$y -lt $bitmap.Height; ++$y)  
    #{
    #
    #    $result[$y] = @(0..$bitmap.Width);
    #    [system.runtime.interopservices.marshal]::copy(($bitmapdata.Scan0 + $bitmapdata.Stride),$result[$y],0,$result[$y].length)
    #}
    $bitmap.UnlockBits($bitmapdata);
    return $result;
}

function Find-FirstPixelTestResult
{
    # implementation found: https://codereview.stackexchange.com/questions/138011/find-a-bitmap-within-another-bitmap
    [cmdletbinding()]
    param(
        $toFind,
        $findIn
    )
    write-warning "untested/poorly implemented"

    [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null;
    $needle = new-object System.Drawing.Bitmap $toFInd
    $haystack = new-object System.Drawing.Bitmap $findin
    if($findInLoaded.PixelFormat -ne $tofindLoaded.PixelFormat){Write-Error "Image pixels are different formats: $($findInLoaded.PIxelFormat) and $($tofindloaded.PIxelFormat)"; return}
    #$currentneedlex=$currentneedley=$currenthaystackx=$currenthaystacky=0

    $haystackdata = $haystack.LockBits([system.drawing.rectangle]::new(0, 0, $haystack.Width, $haystack.height), "ReadOnly" ,$haystack.PixelFormat)
    $needledata = $needle.LockBits([system.drawing.rectangle]::new(0, 0, $needle.Width, $needle.height), "ReadOnly" ,$needle.PixelFormat)
    [System.IntPtr]$haystackptr = $haystackdata.Scan0
    [System.IntPtr]$needleptr = $needledata.Scan0
    $haystackbytes= New-object byte[] ($haystackdata.stride*$haystackdata.Height)
    $needlebytes= New-object byte[] ($needledata.stride*$needledata.Height)
    $y=0; #temporary disable y*data.stride until for loop used again
    #for($y=0;$y -lt $haystack.Height;$y++)
    #{
        [system.runtime.interopservices.marshal]::copy($haystackptr,[byte[]]$haystackbytes,[int]$($y*$haystackdata.stride),[int]($haystackdata.stride*$haystackdata.Height))
        [system.runtime.interopservices.marshal]::copy($needleptr,[byte[]]$needlebytes,[int]$($y*$needlebytes.stride),[int]($needledata.stride*$needledata.Height))

        #This is actually working to test if the given resultant array's are equal!
        $verboseoutput = Compare-Object @($haystackbytes[0..$needlebytes.Length]) @($needlebytes)
        $verboseoutput | %{ write-verbose $_ }
    #}  

    #after looping, unpin data
    $needle.UnlockBits($needledata);
    $haystack.UnlockBits($haystackdata);

    #todo; return the actual pixel location
    if($verboseoutput){return $false;}
    #for($i=0;$i -lt $needlebytes.Length; $i++)
    #{
    #    if($haystackbytes[$i] -ne $needlebytes[$i])
    #    {
    #        return $false;
    #    }
    #}
    return $true;
    #$bytes=0..[int]$($bitmapdata.stride)*$($bitmap.height)
}
#Find-BitmapInBitmap -toFind ./24color.bmp -findIn ./24color.bmp -sensitivity 80