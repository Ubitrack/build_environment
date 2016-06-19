buildenvironment
================

Clone this repository if you want to build Ubitrack from the source code.

All other repositories are added as submodules to this repository

How to build Ubitrack
---------------------

###1. Required tools
In order to build ubitrack the following tools have to be installed:

- Git

- C++ Compiler like gcc or MSVC

- Python (at least Version 2.7, e.g. [PythonXY](http://code.google.com/p/pythonxy/)  )

- [Scons](http://www.scons.org/)

- cmake (only required for Ubitrack for Android)

You can compile Ubitrack for Windows, Linux and Android on the appropriate system. However, the cross-compilation for Android is only possible on Linux. If there are any differences to the compilation for the Linux, they are explained in the appropriate Linux sections.


###1.1 How to install build-tools
<TODO: WINDOWS>


**Ubitrack-Compilation for Linux/Android on Linux**

Ubuntu is shipped with gcc and python pre-installed, to install Git and Scons, open up a terminal and type:

    sudo apt-get install git scons
**Ubitrack-Compilation for Android on Linux**

Android-NDK-Toolchain:

In addition to scons, for the compilation of Ubitrack for Android we need to compile an Android standalone-toolchain.
Therefore, you have to download the Android-NDK. This HowTo will use a certain repository-files for the Boost-for-Android compilation, which needs the Android-NDK-Version 8e. If you are able to port Boost to Android on your own, feel free to download the newest [Android-NDK](http://developer.android.com/tools/sdk/ndk/index.html), otherwise please download [Android-NDK-Version-r8e](http://dl.google.com/android/ndk/android-ndk-r8e-linux-x86_64.tar.bz2), extract it in a folder of your choice, open up a terminal and change to appropriate directory where you extracted the android-ndk. In case of ndk-r8e:

    cd ~/Downloads/android-ndk-r8e/
Afterwards, just run the sh-script in the following way which will install the standalone-toolchain of the defined Android-API level (--platform=android-9) in the folder of your choice (install-dir=/home/\<username>/android/android-ndk-toolchain):

    sh build/tools/make-standalone-toolchain.sh --platform=android-9 --install-dir=/home/far/android/android-ndk-toolchain --system=linux-x86_64
    
Android-SDK:

In addition to the android-ndk-toolchain, we need the android-sdk for the compilation of Lapack which is described later on. Download and extract the [Android-SDK](http://developer.android.com/sdk/index.html) to a folder of your choice e.g. /home/\<username\>/android/.
    

###2. Setting up buildenvironment
Change your current directory to the folder where you want to clone ubitrack.

    git clone https://github.com/Ubitrack/buildenvironment.git ubitrack
    cd ubitrack

###3. Adding additional components as submodules
There are several components represented by repositories which can be added as submodules to ubitrack. These components have to be placed in the  \<ubitrack\>/modules folder. Usually you will need utcore, utvision, utdataflow, utfacade, utcomponents and utvisioncomponents:

<table>
  <tr>
    <th>Component</th><th>Description</th><th>Repository</th>
  </tr>
  <tr>
    <td>utvisualization</td><td>contains a standalone 3D rendering module. Mostly for quick visualizations and debugging</td><td>https://github.com/Ubitrack/utvisualization.git</td>
  </tr>
  <tr>
     <td>utvisioncomponents</td><td>contains algorithms working on (mostly) camera images.</td><td>https://github.com/Ubitrack/utvisioncomponents.git</td>
  </tr>

  <tr>
     <td>utfacade</td><td>contains frontend adapters for ubitrack dataflow networks. Also contains the utConsole.</td><td>https://github.com/Ubitrack/utfacade.git</td>
  </tr>

  <tr>
     <td>utdataflow</td><td>contains the dataflow network and related graph methods.</td><td>https://github.com/Ubitrack/utdataflow.git</td>
  </tr>

  <tr>
     <td>utcore</td><td>contains fundamental datastructures and algorithms. Needed by all other modules.</td><td>https://github.com/Ubitrack/utcore.git</td>
  </tr>

  <tr>
     <td>utcomponents</td><td>contains basic dataflow modules. These cover most common tracking and registration cases.</td><td>https://github.com/Ubitrack/utvisioncomponents.git</td>
  </tr>

  <tr>
     <td>directshow</td><td>contains MS Windows specific directshow framegrabber</td><td>https://github.com/Ubitrack/directshow.git</td>
  </tr>

  <tr>
     <td>buildenvironment</td><td> contains general build scripts </td><td>https://github.com/Ubitrack/utvisualization.git</td>
  </tr>

</table>
You can pick the submodules manually or alternatively add all existing components at once by executing a script.
####3.a Manually adding submodules
This example will create the \<ubitrack\>/module/utcore directory and add utcore as submodule.

    git submodule add https://github.com/Ubitrack/utcore.git modules/utcore


####3.b Automized adding submodules
<scripts that will do that for you in {YourDirectory}/misc/setup/[windows|linux]>

**Ubitrack-Compilation for Windows:**

For Windows open a Git Console, change to the <ubitrack> and execute

    misc/setup/windows/addStandardModules.bat

**Ubitrack-Compilation for Linux/Android on Linux:**

In order to add all components, just execute the following script for linux:

    sh misc/setup/linux/addStandardModules.sh





###4. Configure the needed libraries
Ubitrack is based on the following libraries:

Mandatory

- [Boost](http://www.boost.org/) (> 1.35)

Optional 

- Lapack

- [OpenCV](http://opencv.org/)

- Glut (or [Freeglut](http://freeglut.sourceforge.net/))

These libraries have to be downloaded and configured. In order to do that there exist 3 ways, the first one described in 4.1 offers ready-to-use download packages and uses the Ubitrack library finder, which needs all the libraries in one specific folder. 4.2 configures the libraries with the command line and in 4.3 each possible configuration and path is set manually by editing a textfile. 


####4.1 Make use of the Ubitrack library finder

Ubitrack is able to find libraries which have a specific folder structure that looks like this:


    <LibrariesDirectory>/[linux|windows|android]_[x64|x86]/LibraryName/[bin|include|lib|lib_debug]. 


An example for windows would be:

    external_libraries/windows_x64/boost
    external_libraries/windows_x64/boost/include
    external_libraries/windows_x64/boost/lib
    external_libraries/windows_x64/boost/lib_debug
     

The Ubitrack library finder will take all library files in the "lib" and "lib_debug" folders and link to their paths. So you have to separate the release and debug libraries in different folders.

**Ubitrack-Compilation for Windows:**


You can download ready-to-use library packages for windows and extract them e.g. in the \<ubitrack\> folder:

- [Minimal (Boost and Lapack)](http://campar.in.tum.de/personal/pankratz/UbiTrack/external_libraries_min.zip)
- [All (Boost,Lapack, OpenCV, Freeglut)](http://campar.in.tum.de/personal/pankratz/UbiTrack/external_libraries_all.zip)

This results in a structure that should look like this:
    
    <ubitrack>/external_libraries/windows_x64/
    <ubitrack>/external_libraries/windows_x86/


**Ubitrack-Compilation for Linux on Linux:**

If you haven't already done, yet, you can download and install BOOST, LAPACK and Freeglut with the terminal:

    sudo apt-get update
    sudo apt-get install libboost-all-dev libblas-dev liblapack-dev libopencv-dev freeglut3-dev
As these libraries are installed to the /usr/lib/ folder, an easy way to result in the Ubitrack library finder required folder structure is to link from the external\_libraries folder to the /usr/local/include/. This example shows how it is done for linux\_x64-architecture:

    cd /path/to/external_libraries
    mkdir -p linux_x64/boost/lib/
    mkdir -p linux_x64/boost/include/


    //linking for boost
    ln -s /usr/lib/libboost_filesystem.* boost/include/lib/
    ln -s /usr/lib/libboost_program_options.* boost/include/lib/
    ln -s /usr/lib/libboost_regex.* boost/include/lib/
    ln -s /usr/lib/libboost_serialization.* boost/include/lib/
    ln -s /usr/lib/libboost_system.* boost/include/lib/
    ln -s /usr/lib/libboost_thread.* boost/include/lib/

    ln -s /usr/include/boost boost/include/include/

    //linking for lapack
    mkdir -p lapack/lib
    ln -s /usr/lib/lapack/liblapack.a lapack/lib/
    ln -s /usr/lib/lapack/liblapack.so lapack/lib/
    ln -s /usr/lib/lapack/libblas.a lapack/lib/
    ln -s /usr/lib/lapack/llibblas.so lapack/lib/

    //linking for freeglut
    mkdir -p glut/lib
    mkdir -p glut/include
    ln -s /usr/lib/x86_64-linux-gnu/libglut* glut/lib/
    ln -s /usr/include/GL/ glut/include/

For OpenCV have a look at the official Guide [OpenCV Installation in Linux](http://docs.opencv.org/doc/tutorials/introduction/linux_install/linux_install.html) or a special Ubuntu-Guide [OpenCV on Ubuntu](https://help.ubuntu.com/community/OpenCV). After that, the libraries and includes can be linked to the external\_libraries folder:

    //linking for opencv
    mkdir -p opencv/lib
    mkdir -p opencv/include
**Ubitrack-Compilation for Android on Linux:**

In order to build Ubitrack for Android, you have to place BOOST, LAPACK and OpenCV for Android in the external\_libraires\android folder.

BOOST for Android:

Because there is no official BOOST for Android available, we will use a build-script from a certain repository which does porting for us. Therefore, clone the repository in a folder of your choice and run the build-android.sh script with the path to the extracted android-ndk-8e as argument. The script will download and compile boost.

    cd ~/Downloads/
    git clone https://github.com/inetic/Boost-for-Android.git
    cd Boost-for-Android/
    sh build-android.sh ~/Downloads/android-ndk-r8e/

After the successful compilation, you will find the compiled Boost-libraries in the \<boost\>\build\lib\ subfolder and include files in the \<boost\>\build\include\boost-\<boost-version\>\ -folder. Then, link or copy the files to your external\_libraries\android\boost directory:

     cp -r build/lib /path/to/external_libraries/android/boost/
     cp -r build/include/boost-1_53/ /path/to/external_libraries/android/boost/include/    

LAPACK for Android:

Similar to the compilation of Boost for Android, for Lapack we need to clone a certain repository. After that, we build the Android-library files with the previously downloaded Android-NDK which was downloaded to the ~/Downloads/android-ndk-r8e/ folder.

    
    cd ~/Downloads/
    git clone https://github.com/simonlynen/android_libs.git
    //android_libs/lapack folder was created
    cd android-ndk-r8e/
    //tells the ndk where to look for the lapack-project we want to compile
    export NDK_PROJECT_PATH=~/Downloads/android_libs/lapack/
    ./ndk-build

After that, we can copy or link the Lapack-libraries from the android_libs/lapack/obj/local/armeabi-v7a folder to the created external\_libraries/android/lapack/bin directory.

    cd /path/to/external_libraries/
    mkdir -p android/lapack/lib/
    cp -r ~/Downloads/android_libs/lapack/obj/local/armeabi-v7a/*.a android/lapack/lib/
     
OpenCV for Android:

<The last library we need for the Ubitrack for Android is OpenCV for Android which can be downloaded precompiled from the official [OpenCV-page](http://opencv.org/downloads.html). Extract the downloaded zip-archive on a destination of your choice (here in ~/Downloads) and copy the libraries and include files from the appropriate directory to the external\_libraries/android/opencv/ folder. Instead, you can compile and link OpenCV for Android on your own which will not be explained here.>

The last library we need for the Ubitrack for Android is OpenCV for Android. Similar to the previous external\_libraries, clone and compile OpenCV4Android in the following way:

NOTE: For further information or if any problems occur have a look at the official [Building OpenCV4Android-Guide](http://code.opencv.org/projects/opencv/wiki/Building_OpenCV4Android_from_trunk).

    cd ~/Downloads/
    git clone git://code.opencv.org/opencv.git
    //opencv folder was created
    
    //path to the previously compiled android-standalone-toolchain, here ~/android/android-standalone-toolchain
    export ANDROID_STANDALONE_TOOLCHAIN=~/android/android-ndk-toolchain/
    cd opencv/platforms
    sh ./scripts/cmake_android_arm.sh
    cd build_android_arm
    make -j2

    cd path/to/external_libraries/
    mkdir -p android/opencv/lib/
    mkdir -p android/opencv/include/
    cp -r  ~/Downloads/opencv/platforms/build_android_arm/lib/armeabi-v7a/* android/opencv/lib/
    cp -r  ~/Downloads/opencv/include/* linux_android/opencv/include/


<cp -r ~/Downloads/OpenCV-2.4.8-android-sdk/sdk/native/libs/armeabi-v7a/* android/opencv/lib/>
<cp -r ~/Downloads/OpenCV-2.4.8-android-sdk/sdk/native/jni/include/* android/opencv/include/>

**Ubitrack-Compilation for Windows/Android/Linux:**

If you have placed the libraries in a different folder to \<ubitrack\>/external\_libraries, you have to specify the path where Ubitrack has to search for the libraries. This can be done by executing the following command in the \<ubitrack\> folder:

**Windows example:**
<TODO>

    scons EXTERNAL_LIBRARIES=/home/user/path/to/all/external/libraries/

**Linux example:**

    scons EXTERNAL_LIBRARIES=/home/user/path/to/all/external/libraries/

Alternatively, you can execute

    scons

and afterwards add the following line manually to the \<ubitrack\>/config.cache file:
Note: The first time this document may be empty.

**Windows example:**
<TODO>

    EXTERNAL_LIBRARIES = '/home/user/path/to/all/external_libraries/'

**Linux example:**

    EXTERNAL_LIBRARIES = '/home/user/path/to/all/external_libraries/'


Taking similar steps, you can easily extend Ubitrack with additional libraries for your own need.

####4.2 Configure the libraries using command line options and library finder

In this option the library configuration is done by appending parameters to a scons call similar to the previous section. This method gives you the ability to define your own library-folder structure as you may have already installed some of the libraries in different directories. Just like in the previous section, you can write the paramerters into a \<ubitrack\>\config.cache document, alternatively. For the library files, have a look at section 4.1. 

The basic syntax for these parameters looks like this:

    {LIBNAME}_{PARAMERTER}_{PLATFORM}_{CONFIGURATION}

**Examples:**

    {LIBNAME}: 

     - BOOST, OPENCV, LAPACK, GLUT



    {PARAMETER}: 

    - INCLUDEPATH (path to include files)

    - LIBPATH (path to library files)

    - LIBS (comma separated list of library files to link against)

    - DEFINES (C++ defines passed to the compiler )



    {PLATFORM}: 

    - x64 (64bit)

    - x86 (32bit)

    - android (armeabi-v7a)



    {CONFIGURATION}:

    - RELEASE (in this case empty) 

    - DEBUG

**Full Examples for library configurations by a scons call:**

    scons BOOST_LIBPATH=/path/to/boost/lib

    scons BOOST_LIBPATH_DEBUG=/path/to/boost/lib_debug

    scons BOOST_LIBPATH_X86_DEBUG=/path/to/boost/x64/debug

    scons BOOST_LIBPATH_ANDROID=/path/to/boost/android/lib

    scons OPENCV_LIBS="opencv_stitching242.lib, opencv_legacy242.lib"

####4.3 Set everything by hand

Run the scons command once. After that the library configurations are stored in \<ubitrack\>/config/configStorage. Edit the files and set Include/Library Paths and Libraries to link against. 

Set havelib to true

add "HAVE_{LIBNAME}" to CPPDEFINES

**Example:**

    [x64_release]
    havelib = true
    cpppath = ["C:\\Libraries\\freeglut\\freeglut-2.8.0\\include"]
    libpath = ["C:\\Libraries\\freeglut\\freeglut-2.8.0\\lib\\x64"]
    libs = ["freeglut.lib"]
    cppdefines = ["HAVE_GLUT"]

###5. Compile Ubitrack

For the compilation of Ubitrack for Windows/Linux run:

    scons install-all
For the compilation of Ubitrack for Android you have to specify the android-platform once. This configuration will stay until it is changed by e.g. PLATFORM=x64.

    scons PLATFORM=android
    scons install-all

Speed up the build process for parallel builds:

    scons install-all -j{NumProcessors} 
Clean the build by calling:

    scons -c
You can see all command line parameters by calling:

    scons -h

Create a Visual Studio Project:

    scons vcproj





# Notes for compiling on Mac (New for Version 1.3)

1. install homebrew
2. add repository for build-scripts: brew tap ulricheck/homebrew-science
3. install boost, tbb: brew install boost; brew install tbb
3. install opencv dependency: brew install --build-from-source opencv3ut --with-cuda --with-opengl --with-tbb
4. install ubitrack: brew install --build-from-source ubitrack --c++11
