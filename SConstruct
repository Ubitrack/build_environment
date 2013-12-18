import glob
import sys
import os
import config
import string
import SCons

# tell old scons versions to use a single .consign file
SConsignFile()


#
# LOAD CONFIGURATIONS FROM CACHE / COMMAND LINE
#

# create an options environment
opts = config.NoEnvOptions( 'config.cache', ARGUMENTS )
Export( 'opts' )

# add platform option
opts.Add( 'PLATFORM', 'Platform configuration (x86, x64 or android)', 'x64' )
if opts[ 'PLATFORM' ] not in [ 'x86', 'x64', 'android' ]:
	print "Invalid value specified for option PLATFORM"
	Exit( 1 )
platform = opts[ 'PLATFORM' ]
print 'Platform: ' + platform
if platform == 'x86':
	platform_suffix = 'x86'
elif platform == 'x64':
	platform_suffix = 'x64'	
elif platform == 'android':
	platform_suffix = 'armeabi-v7a'	
	
Export( 'platform' )
Export( 'platform_suffix' )


# add configuration options
opts.Add( 'CONFIGURATION', 'Build configuration (release, debug)', 'release' )
if opts[ 'CONFIGURATION' ] not in [ 'release', 'debug']:
	print "Invalid value specified for option CONFIGURATION"
	Exit( 1 )
configuration = opts[ 'CONFIGURATION' ]
print 'Configuration: ' + configuration

if sys.platform == "win32":
	opts.Add( 'INSTALL_DIR_X86', 'installation directory for x86 builds', 'bin32' )
	opts.Add( 'INSTALL_DIR_X64', 'installation directory for x64 builds', 'bin' )
else:
	opts.Add( 'INSTALL_DIR_X86', 'installation directory for x86 builds', 'lib32' )
	opts.Add( 'INSTALL_DIR_X64', 'installation directory for x64 builds', 'lib' )

if sys.platform == "win32":
	opts.Add( 'CONFIGURATION_SUFFIX_MODE', 'suffix for libraries (["addConfiguration","addPlatform"])', [ 'addConfiguration'] )
# if the app has the same name as the directory i get an error
# TODO find cause and fix error
if platform == "android":
	opts.Add( 'CONFIGURATION_SUFFIX_MODE', 'suffix for libraries (["addConfiguration","addPlatform"])', [ 'addConfiguration'] )
else:
	opts.Add( 'CONFIGURATION_SUFFIX_MODE', 'suffix for libraries (["addConfiguration","addPlatform"])', [ 'addConfiguration' ] )

configuration_suffix = ''

if 'addConfiguration' in opts[ 'CONFIGURATION_SUFFIX_MODE' ]:	
	if configuration == 'release':
		configuration_suffix = ''
	else:
		configuration_suffix = '-d'
if 'addPlatform' in opts[ 'CONFIGURATION_SUFFIX_MODE' ]:
	configuration_suffix = '_'+platform_suffix+configuration_suffix



Export( 'configuration' )
Export( 'configuration_suffix' )



# import some helper functions
SConscript ( '#/config/SConsUtils' )
Import( 'globSourceFiles', 'globDirectories', 'pathListToStringList', 'toTopLevelPath', 'mergeOptions', 'installLibs', 'create_bld', 'test_bld', 'getCurrentPath')


#
# CREATE MASTER ENVIRONMENT
# COMPILER SPECIFIC OPTIONS
#
# MICRSOSOFT VS COMPILER
#if 'msvc' in masterEnv[ 'TOOLS' ]:
if sys.platform == 'win32':
	SConscript ( '#/config/UbiMSVCEnvSetup' )
#android on linux	
elif platform == 'android':
	SConscript ( '#/config/UbiLinuxAndroidEnvSetup' )			
# LINUX
elif sys.platform.startswith( 'linux' ):
	SConscript ( '#/config/UbiLinuxEnvSetup' )
else:
	print "System not supported. Build system only supports Windows or Linux"
	Exit( 1 )

Import( 'masterEnv')


if 'gcc' in masterEnv[ 'TOOLS' ]:
	# gcc by default does not align doubles to 64bit. This causes trouble with Lapack/Atlas on both Mac and Linux.
	# Note that applications that link against Ubitrack must have this flag set, too.
	masterEnv.Append( CPPDEFINES = [ 'BOOST_UBLAS_BOUNDED_ARRAY_ALIGN=__attribute__ ((aligned (16)))' ] )

# export the build environment
Export( 'masterEnv' )




SConscript ( '#/config/buildUtils' )
Import('createVisualStudioProject', 'setupComponentBuild',  'setupSingleComponentBuild' ,'setupLibraryBuild','setupStaticLibraryBuild', 'setupAppBuild', 'generateHelp', 'setupDocInstall', 'setupIncludeInstall')


#
# GRAB ALL MODULES IN THE MODULE FOLDER TO BUILD
#

modules = globDirectories ( os.path.join( 'modules', '*' ) )
#TODO hack to set build order. In future, each module should have a module dependency set
#modules = [ 'modules/utvision', 'modules/utcore']
ubitrackBuildOrder = [os.path.join( 'modules', 'utcore' )  ,os.path.join( 'modules', 'utvision' )  ,
os.path.join( 'modules', 'utdataflow' )  ,os.path.join( 'modules', 'utfacade' ) ,os.path.join( 'modules', 'utcomponents' ) ,os.path.join( 'modules', 'utvisioncomponents' ),os.path.join( 'modules', 'utvisualization' )]
allmodules = modules[:]
modules = set(modules) - set(ubitrackBuildOrder)

#
# CONFIGURATION SCRIPTS
#

# Define a settings variable to allow single modules to set global compiler defines
global_settings = {}
global_settings[ 'CPPDEFINES' ] = []
Export ('global_settings')


for module in ubitrackBuildOrder:
	configFiles = globSourceFiles( os.path.join( module, 'config', '*') )
	configFiles = sorted( configFiles )
	for configFile in configFiles:		
			SConscript( configFile )

for module in modules:	
	configFiles = globSourceFiles( os.path.join( module, 'config', '*') )
	for configFile in configFiles:		
			SConscript( configFile )

masterEnv.Append(**global_settings)
	
# save configuration values
opts.Save( 'config.cache' )

	
# generate help text for command line
Help( opts.GenerateHelpText() )
	

#
# BUILD STAGE
#

# set build directory paths
# look for BUILD_PATH variable  and set the build path if available
# can be used for example to speed up your build process using a ram drive
opts.Add( 'BUILD_PATH', 'Build path for intermediate compiler output', 'build' )
buildPathParent = os.path.dirname(os.path.abspath(opts[ 'BUILD_PATH' ]))

if not os.path.exists(buildPathParent):
	print 'build path "' + buildPathParent + '" does not exist'
	Exit(1)
buildPath = opts[ 'BUILD_PATH' ]

buildPath = os.path.join( buildPath, platform_suffix )

	
if configuration == 'release':
	buildPath = os.path.join( buildPath, "rls" )
else:
	buildPath = os.path.join( buildPath, "dbg" )

for module in ubitrackBuildOrder:
	# Look for optional 3rd party components inside the modules
	thirdPartyPath = os.path.join (module, '3rd', 'SConscript')
	if ( os.path.exists( thirdPartyPath ) ):
		SConscript( thirdPartyPath, variant_dir = os.path.join( buildPath, module, '3rd' ), duplicate = 0 )
	# Compile the source code	
	currentFile = os.path.join (module, 'src', 'SConscript')
	success = True
	if os.path.exists(currentFile):
		success = SConscript( currentFile, variant_dir = os.path.join( buildPath, module, 'src' ), duplicate = 0 )
	#if not success:
	#	print 'Failed to build', module, '. '#Exiting.
	#	Exit ( 1 )

for module in modules:
	# Look for optional 3rd party components inside the modules
	thirdPartyPath = os.path.join (module, '3rd', 'SConscript')
	if ( os.path.exists( thirdPartyPath ) ):
		SConscript( thirdPartyPath, variant_dir = os.path.join( buildPath, module, '3rd' ), duplicate = 0 )
	# Compile the source code	
	success = SConscript( os.path.join (module, 'src', 'SConscript'), variant_dir = os.path.join( buildPath, module, 'src' ), duplicate = 0 )
	#if not success:
	#	print 'Failed to build', module, '. '#Exiting.
		#Exit ( 1 )

#
# Apps, Document and Test STAGE
#		
additionalStages = ['apps', 'doc', 'tests' ]
for stage in additionalStages:
	for module in allmodules:
		test = os.path.join( Dir( '.' ).srcnode().abspath, module , stage, 'SConscript' )
		if os.path.exists( test ):
			success = SConscript( test, variant_dir = os.path.join( buildPath, module, stage ), duplicate = 0 )		


# #generate a Visual Studio Solution that contains all other projects
if 'vcproj' in COMMAND_LINE_TARGETS:
	Import( 'msvsTopDirProjects' )
	vcsln = masterEnv.MSVSSolution( '#/vcproj/Ubitrack' + masterEnv[ 'MSVSSOLUTIONSUFFIX' ], projects = msvsTopDirProjects )
	Depends( vcsln, msvsTopDirProjects )
	Alias( 'vcproj', vcsln )
