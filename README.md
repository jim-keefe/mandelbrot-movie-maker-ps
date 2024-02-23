# mandelbrot-movie-maker-ps

## Summary
Mandelbrot movie maker will create a movie of the Mandelbrot set from starting and ending specifications. The specifications used are the x offset, the y offset the zoom level and the max iterations. Using these specs a movie can depict panning and zooming to a particular location in the set.

## Requirements
* Powershell
* .Net framework for the Drawing Assembly (Need to determine whether that is core or full. This may effect MacOS or Linux compatability.)
* FFMPEG should be installed and available from the path where the script is running
* A folder to store movie artifacts (i.e. e:\mbmovies). Note that each time the script is executed it will create a new folder with a unique name in the movie folder, so you do not need to make a new folder each time.
* The mb_functions.ps1 file should be in the same folder as the movie maker script.

## Usage
* set the starting and ending values in the $mbplan object (Consider using a low resolution, frame count , and max iterations first to preview the movie)
* Execute the script from a powershell console or VScode.

## Example Parameters
```
$mbplan = @{
    name = "ZoomToMiniMandel"
    # Movie Height and width in pixels
    width = 1920
    height = 1080
    # Starting Frame... zoom, x offset, y offset and maximum iterations
    zoomstart = 2
    xoffsetstart = 0
    yoffsetstart = 0
    maxitstart = 30
    # Ending Frame... zoom, x offset, y offset and maximum iterations
    zoomend = .012
    xoffsetend = -.159
    yoffsetend = 1.035
    maxitend = 200
    # Some basic movie specifications
    movieinseconds = 30
    frames = 100
}
```

## Output Example
![alt text](images/output_10fs.gif)

## Techniques Used
* Chat GPT 3.5 did the boilerplate math functions for plotting the mandelbrot set.
* Leading Zeros are used for file names.
* Idempotent directory creation.
* Extend the functionality of the current ps1 by sourcing in another ps1 (i.e. add functions.ps1 to moviemaker.ps1).
* Used the .Net Drawing Assembly to create still frames.
* FFMPEG was used to assemble still frames into a movie.

## Future Enhancements
* Add color controls.
* Add the ability to animate colors.
* Read the movie plan parameters from json.
* Write the current movie plan parameters to a json file.
* Create a Forms interface to edit parameters.
* Try this in other languages.

