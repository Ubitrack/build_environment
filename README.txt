Configure Libraries:
1. Download preconfigured library sets for your operating system from git repo

2. Create default folder structure
Create folder  {UbiTrack}/external_libraries/{arch}/{LIBNAME}
{arch} = x64, x86, android
{LIBNAME} = name of library
e.g.	{UbiTrack}/external_libraries/x64/boost
Lets call this directory {LIBROOT} from now on
Place include files into {LIBROOT}/include	
Place library files into {LIBROOT}/lib
Place library debug files into {LIBROOT}/lib_debug

3. Configure using command line options or config.cache file:
Default, x64, release :
{LIBNAME}_CPPPATH : Path to include files
{LIBNAME}_LIBPATH : Path to library files
{LIBNAME}_CPPDEFINES : Custom c++ preprocessor defines
{LIBNAME}_LIBS : Libraries to link agains e.g. 'test1.lib, test2.lib'

for x86 add _X86
e.g. BOOST_LIBPATH_X86 = '/foo/bar'

for debug libraries add _DEBUG
e.g. BOOST_LIBPATH_X86_DEBUG = '/foo/bar'


4. No checks, set everything by hand:
runs scons once
The library configurations are stored in {UbiTrack}/config/configStorage
Edit the files and set Include/Library Paths, Libraries to link against
Set havelib to true
add "HAVE_{LIBNAME}" to cppdefines
e.g.

[x64_release]
havelib = true
cpppath = ["C:\\Libraries\\freeglut\\freeglut-2.8.0\\include"]
libpath = ["C:\\Libraries\\freeglut\\freeglut-2.8.0\\lib\\x64"]
libs = ["freeglut.lib"]
cppdefines = ["HAVE_GLUT"]



build on ubuntu:
install
	boost-dev
	lapack-dev
	
http://docs.opencv.org/doc/tutorials/introduction/linux_install/linux_install.html

FIX, down't know why:
copy {opencv_build}/cvconfig.h to /usr/local/include

build android on ubuntu:

do requirements for build on ubuntu

download android ndk
READ {ANDROID_NDK}/doc/STANDALONE-TOOLCHAIN.html
build standalone toolchain

download precompiled libraries for ubitrack on android

scons ANDROID_NDK_STANDALONE_TOOLCHAIN={PATH_TO_YOUR_STANDALONE_TOOLCHAIN}


