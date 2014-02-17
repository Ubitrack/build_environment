buildenvironment
================

Clone this repository if you want to build Ubitrack from the source code.
All other repositories are added as submodules to this repository

How to build Ubitrack
---------------------
###1. Required build tools
- C++ Compiler like gcc or MSVC
- Python (at least Version 2.7, e.g. [PythonXY](http://code.google.com/p/pythonxy/)  )
- [Scons](http://www.scons.org/)

###2. Clone buildenvironment
e.g. git clone https://github.com/Ubitrack/buildenvironment.git {YourDirectory}
###3. Add additional components (repositories) as submodules into the folder {YourDirectory}/modules as you need them
Usually you will need utcore, utvision, utdataflow, utfacade, utcomponents and utvisioncomponents

Example: git submodule add https://github.com/Ubitrack/utcore.git modules/utcore

To simplify this task there are scripts that will do that for you in {YourDirectory}/misc/setup/[windows|linux]

Example for Windows: open a Git Console, go to {YourDirectory}, execute misc/setup/windows/addStandardModules.bat

###4. Configure the needed libraries
Mandatory

- [Boost](http://www.boost.org/) (> 1.35)

Optional 

- Lapack
- [OpenCV](http://opencv.org/)
- Glut (or [Freeglut](http://freeglut.sourceforge.net/))

There are 3 options to configure the libraries Ubitrack depends on:
####4.1 Make use of the Ubitrack library finder
Ubitrack is able to find libraries that are in a specific folder structure that looks like this:

{LibrariesDirectory}/{Operating System _ Architecture}/{Library Name}/[bin|include|lib|lib_debug]. 

An example would be external\_libraries/windows\_x64/boost with the subdirectories bin, include, lib and lib_debug.

The library finder will take all library files in the lib folders and link against them. So you can't place release and debug libraries in the same folder.

You can download ready to use library packages for windows here:

- [Minimal (Boost and Lapack)](http://campar.in.tum.de/personal/pankratz/UbiTrack/external_libraries_min.zip)
- [All (Boost,Lapack, OpenCV, Freeglut)](http://campar.in.tum.de/personal/pankratz/UbiTrack/external_libraries_all.zip)

You can extract the archive into {YourDirectory}. The resulting structure should look like this: {YourDirectory}/external\_libraries/windows_...

You can also place the libraries somewhere else. In that case you have to specify where Ubitrack should search for the libraries using the EXTERNAL_LIBRARIES parameter in the scons call. E.g. 

scons EXTERNAL_LIBRARIES={WhereYouPlacedTheLibs}

Optionally you can write the paramerters into a config.cache file in {YourDirectory}

Example:

EXTERNAL_LIBRARIES={WhereYouPlacedTheLibs}

Like that your can easily add you own libraries that you need for your modules to Ubitrack.

####4.2 Configure the libraries using command line options and library finder
The option is used in the scons call like with the EXTERNAL_LIBRARIES. Optionally you can write the paramerters into a config.cache file in {YourDirectory} as well. 

The basic syntax for these parameters looks like this

{LIBNAME}\_{PARAMERTER}\_{PLATFORM}\_{CONFIGURATION}

Examples:

{LIBNAME}: 

- BOOST, OPENCV, LAPACK, GLUT 

{PARAMETER}: 

- INCLUDEPATH (path to include files)

- LIBPATH (path to library files)

- LIBS ( comma separated list of library files to link against)

- DEFINES ( C++ defines passed to the compiler )

{PLATFORM}: 
 
- x64 (64bit)
- x86 (32bit)
- android (for armeabi-v7)

{CONFIGURATION}: release (in this case empty) or DEBUG

Full Examples for library configurations:

BOOST\_LIBPATH={SomePath}

BOOST\_LIBPATH\_DEBUG={SomePath}

BOOST\_LIBPATH\_X86\_DEBUG={SomePath}

BOOST\_LIBPATH_ANDROID={SomePath}

OPENCV\_LIBS="opencv\_stitching242.lib, opencv\_legacy242.lib"

####4.3 Set everything by hand
Run the scons command once. After that the library configurations are stored in {YourDirectory}/config/configStorage . Edit the files and set Include/Library Paths and Libraries to link against. 

Set havelib to true

add "HAVE_{LIBNAME}" to CPPDEFINES

Example:

[x64_release]

havelib = true

cpppath = ["C:\\Libraries\\freeglut\\freeglut-2.8.0\\include"]

libpath = ["C:\\Libraries\\freeglut\\freeglut-2.8.0\\lib\\x64"]

libs = ["freeglut.lib"]

cppdefines = ["HAVE_GLUT"]

###5. Compile Ubitrack
Run: scons install-all

You can see all command line parameters by calling: scons -h

Clean the build by calling: scons -c

Speed up the build process for parallel builds: -j{NumProcessors} 

Create a Visual Studio Project: scons vcproj
