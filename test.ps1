Remove-Module scrapingtools
remove-module inputtools
import-module ./scrapingtools.psm1
import-module ./inputtools.psm1

#New-Item -ItemType Directory -Name screenshots

#take full screen
#New-ScreenShot -path "./screenshots/fullscreen.bmp"
#$threshold = 0.95
#Test 1
$testparameters=0,0,35,35
#take partial screen
#New-ScreenShot -path "./screenshots/partialscreen.bmp" -startx $testparameters[0] -starty $testparameters[1] -endx $testparameters[2] -endy $testparameters[3]
#$found=Find-BitmapInBitmap -toFind ./screenshots/partialscreen.bmp -findIn "./screenshots/fullscreen.bmp"
$found=Get-BitmapLocationInBitmap -toFind "./DiscordIcon.bmp" -findIn "./tmp8927.tmp.bmp"

Write-host "Test 1 - " -NoNewline
write-verbose "found x is = $($found[1].xlocation)"
write-verbose "expected   = $($testParameters[0])"
write-verbose "found y is = $($found[1].ylocation)"
write-verbose "expected   = $($testParameters[1])"
if(($found[1].xlocation -eq $testparameters[0]) -and ($found[1].yLocation -eq $testparameters[1])){Write-Host -ForegroundColor Green "Success"}else{Write-Host -ForegroundColor Red "False"}

#test 2
$testparameters=100,100,135,135
#take partial screen
New-ScreenShot -path "./screenshots/partialscreen.bmp" -startx $testparameters[0] -starty $testparameters[1] -endx $testparameters[2] -endy $testparameters[3]
$found=Find-BitmapInBitmap -toFind ./screenshots/partialscreen.bmp -findIn ./screenshots/fullscreen.bmp
Write-host "Test 2 - " -NoNewline
write-verbose "found x is = $($found[1].xlocation)"
write-verbose "expected   = $($testParameters[0])"
write-verbose "found y is = $($found[1].ylocation)"
write-verbose "expected   = $($testParameters[1])"
if(($found[1].xlocation -eq $testparameters[0]) -and ($found[1].yLocation -eq $testparameters[1])){Write-Host -ForegroundColor Green "Success"}else{Write-Host -ForegroundColor Red "False"}
