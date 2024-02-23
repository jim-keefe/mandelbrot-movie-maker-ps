#=============================================
# Functions
#=============================================
function ValidateCreateFolder {

    param (
        $path,
        $failiffound = $false
    )

    If(!(test-path -PathType container $path))
    {
        Logupdate -message "$path path not found"
        Logupdate -message "Creating path $path"
        New-Item -ItemType Directory -Path $path -ErrorAction SilentlyContinue
        If(!(test-path -PathType container $path)){
            Logupdate -message "Unable to create path $path. Check to make sure the drive exists, the account has permissions to the drive, or if a file by the same name exists." -type "Error"
            return $false
        } else {
            Logupdate -message "Path created successfully $path"
        }
    } else {
        Logupdate -message "$path path found"
        if ($failiffound){
            LogUpdate -message "A path by this name already exists ($path). Choose another name." -type "Error"
            return $false
        }
    }

    return $true

}

function Logupdate {

    param(
        $message,
        $type = "Info"
    )

    Write-Host "$(get-date)`t$type`t$message"

}

# This function was provided by ChatGPT 3.5. It calculates the iterations for c.
function MandelbrotIterations([System.Numerics.Complex]$c, [int]$maxIterations) {
    $z = [System.Numerics.Complex]::Zero
    $n = 0
    while ($n -lt $maxIterations -and $z.Magnitude -lt 4) {
        $z = $z * $z + $c
        $n++
    }
    return $n
}

# This function was provided by ChatGPT 3.5. It takes the x, y, zoom and max iteration parameters and renders a bitmap image
function PlotMandelbrot([int]$width, [int]$height, [int]$maxIterations, [double]$zoom, [double]$xOffset, [double]$yOffset, [int]$frame) {
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
            $color = if ($iterations -eq $maxIterations) { [System.Drawing.Color]::Black } else { [System.Drawing.Color]::FromArgb(($iterations +55)*.7,($iterations +55),($iterations +55)*.7) }
            $bitmap.SetPixel($x, $y, $color)
            
        }
        Logupdate -message "Frame: $frame X: $x Y: $y"
    }

    $outFile = "$imageDir\$('{0:d5}' -f [int]$frame).png"
    $bitmap.Save($outFile, [System.Drawing.Imaging.ImageFormat]::Png)
    # Invoke-Item $outfile
}