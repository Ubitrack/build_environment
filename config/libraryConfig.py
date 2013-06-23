import os
import sys
import ConfigParser
import json

Import( '*')
  	

# helper classes for setup up external library dependencies

# base class for checking if a library config is valid
class AbstractLibraryFinder:
	libName = ''
	options_para = {}
	checkLibParameters = []

	
	# {NameOfLibrary e.b. boost}{compile check, array [ {additional compile settings}, {include files}, {language (C++)},{library to link against (optional)}, {source code (optional)}]}{ tags within the lib names to identify debug libraries}
	def __init__(self, libName, checkLibParameters):
		self.libName = libName
		self.checkLibParameters = checkLibParameters

	def setIfValueExists(self, key, value):				
		exists = True
		if isinstance( value, list ):			
			for val1 in value:
				exists = exists and os.path.exists(val1)

			if exists:
				self.options_para[ key ] = value

		else:
			if os.path.exists(value):
				self.options_para[ key ] = [ value ]
			else:
				exists = False					
		return exists

	def setIfContains(self, options, key):
		if self.options_para.has_key(key):
			options[ key ] = self.options_para[key]


	def getLibraryOptions(self):
		return self.options_para

	def tryFindingLibs(self):
		libs_	= []
		if self.options_para.has_key('LIBPATH') :			
			lowername = self.libName.lower()

			libEnding = ''
			if platform == 'android':
				libEnding = '.a'
				libPrefix = 'lib'				
			elif sys.platform.startswith( 'linux' ):
				libEnding = '.so'
				libPrefix = 'lib'
			else :
				libEnding = '.lib'
				libPrefix = ''

			for libPath in self.options_para[ 'LIBPATH']:
				dirList=os.listdir(libPath)
				lib_release = []
				lib_debug = []
				
				for fname in dirList: # check all files in libpath directory
					# is this one of the searched libraries?
					# starts with prefix, contains name of the library
					if fname.lower().startswith(libPrefix) and fname.endswith(libEnding):
						libs_.append(fname)

	

		
		print self.libName + "    Testing .... "
		if self.options_para.has_key('CPPPATH'):
			print "Include Path :" +  str(self.options_para['CPPPATH'])
		else:
			print "Include Path : -"
		
		if self.options_para.has_key('LIBPATH'):
			print "Library Path :" +  str(self.options_para['LIBPATH'])
		else:
			print "Library Path : -"
		self.options_para['LIBS'] = libs_
		self.options_para['HAVELIB'] = self.isLibraryAvailable()
		if self.options_para['HAVELIB']:
			self.options_para['CPPDEFINES'] = [ 'HAVE_'+self.libName]
			
		
			

	def isLibraryAvailable(self):
		cenv = masterEnv.Clone()		
		cenv.Append( **self.checkLibParameters[0] )
		cenv.Append( **self.getLibraryOptions() )
		conf = Configure( cenv )
		have_lib = False
		#{additional compile settings}, {include files}, {language (C++)},{library to link against (optional)}, {source code (optional)}]
		# just check header
		if len(self.checkLibParameters) == 3:			
			have_lib = conf.CheckHeader( self.checkLibParameters[1], language = self.checkLibParameters[2])					
		# check 
		elif len(self.checkLibParameters) == 4:						
			if self.checkLibParameters[1] == '':				
				have_lib = conf.CheckLib( self.options_para['LIBS'], self.checkLibParameters[3], language = self.checkLibParameters[2],  autoadd = 0 )			
			else:				
				have_lib = conf.CheckLib( self.checkLibParameters[1],  self.checkLibParameters[3], language = self.checkLibParameters[2],  autoadd = 0 )
		else:
			if self.checkLibParameters[1] == '':				
				have_lib = conf.CheckLibWithHeader( self.options_para['LIBS'], self.checkLibParameters[1], self.checkLibParameters[2], self.checkLibParameters[4], autoadd = 0 )
			else:
				have_lib = conf.CheckLibWithHeader( self.checkLibParameters[3], self.checkLibParameters[1], self.checkLibParameters[2], self.checkLibParameters[4], autoadd = 0 )
		conf.Finish()
		return have_lib

		



class WindowsEnviromentLibraryFinder(AbstractLibraryFinder):
	includePath=[]
	libPath=[]	
	envExtensions = []
	
	def __init__(self, libName, checkLibParameters, includePath=['','include'], libPath=['lib'],  debug_tags = ['-d', '_d', '-gd', '_debug'], envExtensions={ 'x86' : [ '', '32','x86'] , 'x64' : ['', '64','x64'], 'android' : [''] }):
		AbstractLibraryFinder.__init__(self, libName, checkLibParameters)		
		self.includePath = includePath
		self.libPath = libPath		
		self.envExtensions = envExtensions[platform]
	
	def checkPaths(self, valueKey, rootPath, searchPaths ):
		found = False				
		for p1 in searchPaths:		
			for p2 in self.envExtensions:
				testPath = os.path.join( rootPath , p1 , p2) 											
				if self.setIfValueExists(valueKey, testPath ):					
					found = True					
				testPath = os.path.join( rootPath , p1 + p2) 				
				if self.setIfValueExists(valueKey, testPath ):
					found = True					
		
		for p1 in self.envExtensions:
			if p1 == '':
				continue
			for p2 in searchPaths:
				testPath = os.path.join( rootPath , p1 , p2) 
				if self.setIfValueExists(valueKey, testPath ):
					found = True						
		return found
	
	def checkRootPath(self, value):		
		self.checkPaths('CPPPATH', value, self.includePath)
		self.checkPaths('LIBPATH', value, self.libPath)				
		return
	
	def checkEnviroment(self, valueKey, value):
		for p1 in self.envExtensions:
			checkPara = value + p1
			if os.environ.has_key(checkPara):
				envPath = os.environ[checkPara]						
				self.setIfValueExists(valueKey, envPath )		
		return
		
	def checkOpts(self, valueKey, value):
		for p1 in self.envExtensions:
			checkPara = value + p1
			if checkPara in opts:
				optsPath = opts[checkPara]						
				self.setIfValueExists(valueKey, optsPath )		
		return
		
		
	def checkForLibraries(self):		
		checkPara = self.libName+"_ROOT"		
		for p1 in self.envExtensions:
			value = checkPara + p1	
			if os.environ.has_key(value):			
				self.checkRootPath(os.environ[value])		
			
		checkPara = self.libName+"_PATH"
		for p1 in self.envExtensions:
			value = checkPara + p1	
			if os.environ.has_key(value):			
				self.checkRootPath(os.environ[value])
							
		self.checkEnviroment('CPPPATH', self.libName+"_INCLUDE")
		self.checkEnviroment('LIBPATH', self.libName+"_LIB")

		# check opts variable
		checkPara = self.libName+"_ROOT"
		if checkPara in opts :
			self.checkRootPath(opts[checkPara])	
		checkPara = self.libName+"_PATH"
		if checkPara in opts :
			self.checkRootPath(opts[checkPara])	
			
		checkPara = self.libName+"_ROOT"+platform
		for p1 in self.envExtensions:
			checkPara = value + p1
			if checkPara in opts :
				self.checkRootPath(opts[ checkPara ])
		
				
		self.checkOpts('CPPPATH', self.libName+"_INCLUDE")
		self.checkOpts('LIBPATH', self.libName+"_LIBS")
		
		self.tryFindingLibs()
		
		return self.options_para

class SimpleEnviromentLibraryFinder(AbstractLibraryFinder):
	includePath=[]
	libPath=[]	
	std_lib_paths ={ 'x86_debug' : [ 'lib_debug'] ,'x86_release' : [ 'lib'] , 'x64_debug' : ['lib_debug'], 'x64_release' : ['lib'], 'android_debug' : ['lib_debug'], 'android_release' : ['lib'] }
	
	def __init__(self, libName, checkLibParameters, includePath=[], libPath=[] ):
		AbstractLibraryFinder.__init__(self, libName, checkLibParameters)	
		if len(includePath) == 0:
			self.includePath = ['include']
		else:
			self.includePath = includePath

		if len(libPath) == 0:
			self.libPath = self.std_lib_paths[platform+'_'+configuration]
		else:
			self.libPath = libPath

	
	def checkPaths(self, valueKey, rootPath, searchPaths ):
		found = False				
		for p1 in searchPaths:		
			testPath = os.path.join( rootPath , p1) 	
			if self.setIfValueExists(valueKey, testPath ):					
				found = True										
		
		return found
	
	def checkRootPath(self, value):		
		self.checkPaths('CPPPATH', value, self.includePath)
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
		extraPaths = ['CPPPATH', 'LIBPATH']


		# check enviroment variables
		for rp in rootPaths:
			checkPara = self.libName+rp+paraExtension
			if os.environ.has_key(checkPara):			
				self.checkRootPath(os.environ[checkPara])
			elif configuration == 'debug':
				checkPara = self.libName+rp
				if os.environ.has_key(checkPara):			
					self.checkRootPath(os.environ[checkPara])

		for rp in extraPaths:
			checkPara = self.libName+'_'+rp
			self.checkEnviroment(rp, checkPara)

			if configuration == 'debug':
				checkPara += paraExtension
				self.checkEnviroment(rp, checkPara)


		# check opts variable
		for rp in rootPaths:
			checkPara = self.libName+rp
			if checkPara in opts :
				self.checkRootPath(opts[checkPara])	
	
			if configuration == 'debug':
				checkPara += paraExtension
				if checkPara in opts :
					self.checkRootPath(opts[checkPara])	

		for rp in extraPaths:
			checkPara = self.libName+'_'+rp
			self.checkOpts(rp, checkPara)

			if configuration == 'debug':
				checkPara += paraExtension
				self.checkOpts(rp, checkPara)

		
		if  len (self.options_para) == 0:
			rootPath = os.path.join( Dir('#').abspath, 'external_libraries',platform,self.libName.lower())
			print "Checking in ubitrack default library structure: %s"%rootPath
			self.checkRootPath(rootPath)
		
		self.tryFindingLibs()
		
		return self.options_para

	

# save and load library configurations in a human readable format. Uses a library finder if the current configuration is not valid
class SimpleLibraryConfiguration:
	libName = ''
	lib_options = ConfigParser.SafeConfigParser()	
	configFile = ''	
	section = platform+'_'+configuration
	parameter = [ 'CPPPATH', 'LIBPATH', 'LIBS', 'CPPDEFINES' ]

	def __init__(self, libName, libraryFinder):
		self.libName = libName
		self.libraryFinder = libraryFinder		
		configDir = self.checkOutputDirectory()
		self.lib_options  = ConfigParser.SafeConfigParser()
		self.configFile = os.path.join( configDir, libName+".cfg" ) 		
		self.loadConfigSettings()		
		# start reconfiguration
		

		# check if configuration is needed
		if self.lib_options.has_section(self.section) :
			if 'reconfigure' in COMMAND_LINE_TARGETS:
				self.setOptionBool('HAVELIB' , False)
			if not self.haveLib() :
				self.configure()
		else:
			self.lib_options.add_section(self.section)
			self.setOptionBool('HAVELIB' , False)
			for para in self.parameter:			
				self.setOptionArray(para , [])
			
			self.configure()
		
		if self.haveLib():
			print libName + " available"
		else:
			print libName + " UNAVAILABLE"
			

	def haveLib(self):
		return self.getOptionBool('HAVELIB')
		
	def checkOutputDirectory(self):
		configDir = os.path.join( Dir('#').abspath, 'config', 'configStorage')
		if not os.path.exists(configDir):
			os.mkdir(configDir)

		return configDir

	def configure(self):
		print self.libName + "    trying to configure library... "
		foundOptions = self.libraryFinder.checkForLibraries()		
		
		for para in self.parameter:
			if foundOptions.has_key(para):
				self.setOptionArray(para, foundOptions[para])
		self.setOptionBool('HAVELIB', foundOptions['HAVELIB'])
		
		self.saveConfigSettings()


	def getLibraryOptions(self):
		result = {}
		for para in self.parameter:
			try:
				result[para] = self.getOptionArray(para)
			except ValueError:
				print "Could not load library option: section="+self.section+ " key="+para
		return result

	def hasOption(self, key):
		return self.lib_options.has_option(self.section, key)
		
	def getOption(self, key):
		return self.lib_options.get(self.section, key)

	def setOption(self, key, value):				
		self.lib_options.set(self.section, key, value)					
		return	

	def getOptionArray(self, key):
		return json.loads(self.lib_options.get(self.section, key))

	def setOptionArray(self, key, value):						
		self.lib_options.set(self.section, key, json.dumps(value))					
		return

	def getOptionBool(self, key):
		return self.lib_options.getboolean(self.section, key)

	def setOptionBool(self, key, value):				
		if value :
			self.setOption(key, 'true')
		else:
			self.setOption(key, 'false')				
		return		
		
	def loadConfigSettings(self):
		if os.path.exists(self.configFile):
			self.lib_options.read(self.configFile)
			
			
		return

	def saveConfigSettings(self):	
		fp = open(self.configFile, 'w+')	
		self.lib_options.write(fp)
		fp.close
		return



if sys.platform == 'win32':
	standardLibFinder = SimpleEnviromentLibraryFinder
	standardLibConfig = SimpleLibraryConfiguration
else:
	standardLibFinder = SimpleEnviromentLibraryFinder
	standardLibConfig = SimpleLibraryConfiguration

Export('standardLibFinder', 'standardLibConfig')

	
