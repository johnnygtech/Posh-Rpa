function Convertto-bitmap
{
    param(
        $filePath
    )
   # Load the PNG image
$file=Get-item $filePath
$image = [System.Drawing.Image]::FromFile($file.Fullname)

# Create a bitmap from the image
$bitmap = New-Object System.Drawing.Bitmap $image

# Save the bitmap as a file
$bitmap.Save($($file.DirectoryName+"\"+$file.BaseName+".bmp"), [System.Drawing.Imaging.ImageFormat]::Bmp)

# Dispose of the image and bitmap objects to free up memory
$image.Dispose()
$bitmap.Dispose() 
}

function Get-Pngasbmp
{
    param(
        $filePath
    )
    $file=Get-item $filePath
    $image = [System.Drawing.Image]::FromFile($file.Fullname)
    
    # Create a bitmap from the image
    New-Object System.Drawing.Bitmap $image

}