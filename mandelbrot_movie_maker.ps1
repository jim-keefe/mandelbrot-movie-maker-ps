# source the Drawing Assembly so we can create bitmap images
Add-Type -AssemblyName System.Drawing

# source in the functions
$myscriptpath = $MyInvocation.MyCommand.Path
$myscriptpathparent = (get-item $myscriptpath).Directory
. "$myscriptpathparent\mb_functions"

#=============================================
# Variables
#=============================================

# Set the movie plan here! The mbplan has the starting and ending values for x and y offset as well as zoom and maxiterations(depth).
# Making the movie is just a matter of iterating through frames and incrementing x,y and zoom values to get from the starting view to the end view.

$mbplan = @{
    name = "ZoomToMiniMandel"
    # Movie Height and width in pixels
    width = 160
    height = 100
    # Starting Frame... zoom, x offset, y offset and maximum iterations
    zoomstart = 1.5
    xoffsetstart = .3
    yoffsetstart = .75
    maxitstart = 30
    # Ending Frame... zoom, x offset, y offset and maximum iterations
    zoomend = .012
    xoffsetend = -.159
    yoffsetend = 1.035
    maxitend = 200
    # Some basic moview specifications
    movieinseconds = 5
    frames = 10
}

# this object will store the current values x,y,zoom and itereation values as we progress through frames
$mbstatus = @{
    maxitstep = ($mbplan.maxitend - $mbplan.maxitstart) / $mbplan.frames
    zoomstep = ($mbplan.zoomend - $mbplan.zoomstart) / $mbplan.frames
    xoffsetstep = ($mbplan.xoffsetend - $mbplan.xoffsetstart) / $mbplan.frames
    yoffsetstep = ($mbplan.yoffsetend - $mbplan.yoffsetstart) / $mbplan.frames
    maxitcurrent = $mbplan.maxitstart
    zoomcurrent = $mbplan.zoomstart
    xoffsetcurrent = $mbplan.xoffsetstart
    yoffsetcurrent = $mbplan.yoffsetstart
}

# Set up the folder structure to store artifacts
$datestamp = Get-Date -UFormat %Y%m%d_%H%M%S
$baseDir = "c:\temp"
$workDir = "$baseDir\$($mbplan.name)_$datestamp"
$imageDir = "$workDir\images"
ValidateCreateFolder -path "$baseDir\$($mbplan.name)_$datestamp\images" -failiffound $true

$starttime = get-date

# create a still image for each frame
for ($i = 0; $i -le $mbplan.frames; $i++) {

    # Provide the current x,y,zoom and itereation values for the current frame. The frame is rendered and saved.
    PlotMandelbrot -width $mbplan.width -height $mbplan.height -maxIterations ($mbstatus.maxitcurrent) -zoom $mbstatus.zoomcurrent -xOffset $mbstatus.xoffsetcurrent -yOffset $mbstatus.yoffsetcurrent -frame $i

    # Increment the x,y,zoom and itereation values
    $mbstatus.yoffsetcurrent = $mbstatus.yoffsetcurrent + $mbstatus.yoffsetstep
    $mbstatus.xoffsetcurrent = $mbstatus.xoffsetcurrent + $mbstatus.xoffsetstep
    $mbstatus.zoomcurrent = $mbstatus.zoomcurrent + $mbstatus.zoomstep
    $mbstatus.maxitcurrent = $mbstatus.maxitcurrent + $mbstatus.maxitstep

}

# ================================
# Make the MP4
# ================================

# This code is adapted from another use case. I might clean it up later.

$startPath = $imageDir
$secondsPerSlide = $mbplan.movieinseconds / $mbplan.frames

# Calculated values
if (Test-Path $startPath){"$startPath found"} else {"$startPath NOT found" ; break}
Set-Location -Path $startPath
$folderName = (Get-Item -Path $startPath).name
$dateStr = (get-date).ToString("yyyyMMddhhmmss")
$mp4outputpath = "$($folderName)_$dateStr.mp4"
$inputlist = "$startpath\$($folderName)_$dateStr.txt"
$files = Get-ChildItem -Path $startPath -Filter "*.png"
$i = 0

# check for ffmpeg. Make sure it is installed and accsible from current path.
if ($(invoke-command {ffmpeg -version}) -like "ffmpeg version *"){LogUpdate -message "FFMPEG found"} else {LogUpdate -message "FFMPEG not found" ; break}

# find jpegs in the specified folder
if ($files){
    foreach ($file in $files){
        LogUpdate -message "Adding $($file.FullName) to list for slideshow"
        out-file -FilePath $inputlist -InputObject "file $($file.Name)`r`nduration $secondsPerSlide" -Append ascii
    }

    # per ffmpeg documentation add the last file again without a duration
    out-file -FilePath $inputlist -InputObject "file $($file.Name)" -Append ascii

    LogUpdate -message "Creating slideshow at $mp4outputpath"
    $ffScriptBlock = {ffmpeg -f concat -i $args[0] -vf "scale=$($args[2]):$($args[3])" -vcodec libx264 -x264opts frame-packing=3 $args[1]}
    Invoke-command -ScriptBlock $ffScriptBlock -ArgumentList $inputlist,$mp4outputpath,$($mbplan.width),$($mbplan.height)

} else { LogUpdate -message "No files found" ; break}

$endtime = Get-Date
LogUpdate -message  "Start: $starttime - End: $endtime"