import os
import sys
import ConfigParser

SConscript ( '#/config/libraryFinder/AbstractLibraryFinder.py' )

Import( '*')

opts.Add( 'EXTERNAL_LIBRARIES', 'Path to external libraries like boost, opencv, ...', 'external_libraries' )

class UbitrackLibraryFinder(AbstractLibraryFinder):
	includePath=[]
	libPath=[]	
	std_lib_paths ={ 'x86_debug' : [ 'lib_debug'] ,'x86_release' : [ 'lib'] , 'x64_debug' : ['lib_debug'], 'x64_release' : ['lib'], 'android_debug' : ['lib_debug'], 'android_release' : ['lib'] }
	std_system_names = { 'win32' : 'windows', 'linux2' : 'linux', 'darwin' : 'macos'}
	
	def __init__(self, libName, checkLibParameters, includePath=[], libPath=[] ):
		AbstractLibraryFinder.__init__(self, libName, checkLibParameters)	
		
		opts.Add( self.getKeyNameForOpts('ROOT'), 'Path to '+libName+' root directory')
		opts.Add( self.getKeyNameForOpts('INCLUDEPATH'), 'Path to '+libName+' include directory')
		opts.Add( self.getKeyNameForOpts('LIBPATH'), 'Path to '+libName+' library directory')
		opts.Add( self.getKeyNameForOpts('LIBS'), 'List of library files from '+libName+' to link against')
		opts.Add( self.getKeyNameForOpts('DEFINES'), 'C++ Defines passed to the compiler')
		
		if len(includePath) == 0:
			self.includePath = ['include']
		else:
			self.includePath = includePath

		if len(libPath) == 0:
			self.libPath = self.std_lib_paths[platform+'_'+configuration]
		else:
			self.libPath = libPath

	def getKeyNameForOpts(self, key):
		paraExtension = '';		
		if platform == 'x86':
			paraExtension += '_X86'
		elif platform == 'android':
			paraExtension += '_ANDROID'
		if configuration == 'debug':
			paraExtension += '_DEBUG'
		
		return self.libName+'_'+key+paraExtension;
	
	def checkPaths(self, valueKey, rootPath, searchPaths ):
		found = False				
		for p1 in searchPaths:		
			testPath = os.path.join( rootPath , p1) 	
			if self.setIfValueExists(valueKey, testPath ):					
				found = True										
		
		return found
	
	def checkRootPath(self, value):		
		self.checkPaths('INCLUDEPATH', value, self.includePath)
		self.checkPaths('LIBPATH', value, self.libPath)				
		return
	
	def checkEnviroment(self, valueKey, value):
		if os.environ.has_key(value):
			envPath = os.environ[value]						
			self.setIfValueExists(valueKey, envPath )		
		return
		
	def checkOpts(self, valueKey, value):		
		if value in opts:
			optsPath = opts[value]									
			self.setIfValueExists(valueKey, optsPath )		
		return
		
		
	def checkForLibraries(self):
		paraExtension = '';		
		if platform == 'x86':
			paraExtension += '_X86'
		elif platform == 'android':
			paraExtension += '_ANDROID'
		if configuration == 'debug':
			paraExtension += '_DEBUG'

		rootPaths = ['_ROOT', '_PATH']
		extraPaths = ['INCLUDEPATH', 'LIBPATH', 'LIBS', 'DEFINES' ]


		# check enviroment variables
		
		#for rp in rootPaths:
		#	checkPara = self.libName+rp+paraExtension
		#	if os.environ.has_key(checkPara):			
		#		self.checkRootPath(os.environ[checkPara])
		#	elif configuration == 'debug':
		#		checkPara = self.libName+rp
		#		if os.environ.has_key(checkPara):			
		#			self.checkRootPath(os.environ[checkPara])

		#for rp in extraPaths:
		#	checkPara = self.libName+'_'+rp
		#	self.checkEnviroment(rp, checkPara)

		#	if configuration == 'debug' or platform == 'x86':				
		#		checkPara += paraExtension
		#		self.checkEnviroment(rp, checkPara)


		# check opts variable
		for rp in rootPaths:
			checkPara = self.libName+rp
			if checkPara in opts :
				self.checkRootPath(opts[checkPara])	
	
			if configuration == 'debug' or not platform == 'x64':
				checkPara += paraExtension
				if checkPara in opts :
					self.checkRootPath(opts[checkPara])	

		for rp in extraPaths:
			checkPara = self.libName+'_'+rp						
			self.checkOpts(rp, checkPara)

			if configuration == 'debug' or not platform == 'x64':
				checkPara += paraExtension
				self.checkOpts(rp, checkPara)

		
		if  len (self.options_para) == 0 or ( len(self.options_para) == 1 and self.options_para.has_key("LIBS")):	
			extLibDir = opts['EXTERNAL_LIBRARIES']		
			platformDir = self.std_system_names[sys.platform] + '_' + platform
			rootPath = os.path.join( Dir('#').abspath, extLibDir ,platformDir, self.libName.lower())
			testLibPath = os.path.join(rootPath , self.libPath[0] ) 
			if not os.path.exists(testLibPath):
				self.libPath = self.std_lib_paths[platform+'_'+'release']
			print "Checking in ubitrack default library structure: %s"%rootPath
			self.checkRootPath(rootPath)
				
		
		self.tryFindingLibs()
		
		return self.options_para
		
Export('UbitrackLibraryFinder')        