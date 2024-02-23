Add-Type -AssemblyName System.Drawing

function MandelbrotIterations([System.Numerics.Complex]$c, [int]$maxIterations) {
    $z = [System.Numerics.Complex]::Zero
    $n = 0
    while ($n -lt $maxIterations -and $z.Magnitude -lt 4) {
        $z = $z * $z + $c
        $n++
    }
    return $n
}

function PlotMandelbrot([int]$width, [int]$height, [int]$maxIterations, [double]$zoom, [double]$xOffset, [double]$yOffset) {
    $bitmap = New-Object System.Drawing.Bitmap($width, $height)
    $minX = -$zoom + $xOffset
    $maxX = $zoom + $xOffset
    $minY = -$zoom + $yOffset
    $maxY = $zoom + $yOffset

    for ($x = 0; $x -lt $width; $x++) {
        for ($y = 0; $y -lt $height; $y++) {
            $re = $minX + ($maxX - $minX) * $x / $width
            $im = $minY + ($maxY - $minY) * $y / $height
            $c = New-Object System.Numerics.Complex($re, $im)
            $iterations = MandelbrotIterations $c $maxIterations
            # $color = if ($iterations -eq $maxIterations) { [System.Drawing.Color]::Black } elseif ( ($iterations % 2) -eq 0) { [System.Drawing.Color]::FromArgb(128,128,128) } elseif ( ($iterations % 2) -eq 1) { [System.Drawing.Color]::FromArgb(255,255,255) }
            # $color = if ($iterations -eq $maxIterations) { [System.Drawing.Color]::Black } else { [System.Drawing.Color]::FromArgb((($iterations % 10) * 20 + 64),(($iterations % 10) * 20 + 64),(($iterations % 10) * 20 + 64)) }
            $color = if ($iterations -eq $maxIterations) { [System.Drawing.Color]::Black } else { [System.Drawing.Color]::FromArgb(($iterations +55),($iterations +55),($iterations +55)) }
            $bitmap.SetPixel($x, $y, $color)
            
        }
        write-host "X: $x Y: $y"
    }

    $outFile = "c:\temp\MB_" + (Get-Date -UFormat %Y%m%d_%H%M%S) + ".png"
    $bitmap.Save($outFile, [System.Drawing.Imaging.ImageFormat]::Png)
    Invoke-Item $outfile
}

$starttime = get-date
PlotMandelbrot -width (1920) -height (1080) -maxIterations 30 -zoom 2 -xOffset 0 -yOffset 0
#PlotMandelbrot -width (1920*8) -height (1080*8) -maxIterations 200 -zoom .012 -xOffset -.159 -yOffset 1.035
$endtime = Get-Date

Write-Host "Start: $starttime - End: $endtime - Threads: 1"