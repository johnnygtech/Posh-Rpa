#runas administrator: Install-Package AForge#

$CSharpCodeBlock=@"
using System;
using Aforge.Imaging;
using System.Drawing;
using 
#// create template matching algorithm's instance
#// (set similarity threshold to 92.5%)
ExhaustiveTemplateMatching tm = new ExhaustiveTemplateMatching( 0.925f );
#// find all matchings with specified above similarity
TemplateMatch[] matchings = tm.ProcessImage( sourceImage, template );
#// highlight found matchings
BitmapData data = sourceImage.LockBits(
    new Rectangle( 0, 0, sourceImage.Width, sourceImage.Height ),
    ImageLockMode.ReadWrite, sourceImage.PixelFormat );
foreach ( TemplateMatch m in matchings )
{
    Drawing.Rectangle( data, m.Rectangle, Color.White );
    // do something else with matching
}
sourceImage.UnlockBits( data );
"@

