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
	debug_tags = []

	
	def __init__(self, libName, checkLibParameters, debug_tags = ['-d', '_d', '-gd', '_debug']):
		self.libName = libName
		self.checkLibParameters = checkLibParameters
		self.debug_tags = debug_tags

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
			libEnding = ''
			if sys.platform.startswith( 'linux' ):
				libEnding = '.so'
			else :
				libEnding = '.lib'

			for libPath in self.options_para[ 'LIBPATH']:
				dirList=os.listdir(libPath)
				lib_release = []
				lib_debug = []
				
				for fname in dirList: # check all files in libpath directory
					isDebugLib = False
					for debug_tag in self.debug_tags:
						#if fname.endswith(debug_tag+libEnding)  :
						if fname.find(debug_tag) > 0 :
							isDebugLib = True
							break
						elif (fname.endswith('d'+libEnding) and not (self.libName.endswith('d') or self.libName.endswith('D'))) or fname.endswith('dd'+libEnding)or fname.endswith('Dd'+libEnding): # is a problem for libraries ending with d
							isDebugLib = True
							break

					if fname.endswith(libEnding):
						if isDebugLib :
							lib_debug.append(fname)
						else: #  for now we assume the rest are release libs
							lib_release.append(fname)

				
				if lib_debug.count == 0: # use release libs if no debug libs are found
					lib_debug = lib_release			
		
			libs_ = lib_release 
			if configuration == 'debug':	
				libs_ = lib_debug
		
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
	#else:
	#	print self.libName + "   no library path available   "
	#	self.options_para['HAVELIB'] = False
			
		
			

	def isLibraryAvailable(self):
		cenv = masterEnv.Clone()		
		cenv.Append( **self.checkLibParameters[0] )
		cenv.Append( **self.getLibraryOptions() )
		conf = Configure( cenv )
		have_lib = False		
		if len(self.checkLibParameters) == 3:			
			have_lib = conf.CheckHeader( self.checkLibParameters[1], language = self.checkLibParameters[2])			
		elif len(self.checkLibParameters) == 4:						
			if self.checkLibParameters[1] == '':				
				have_lib = conf.CheckLib( self.options_para['LIBS'], self.checkLibParameters[3], language = self.checkLibParameters[2],  autoadd = 0 )			
			else:				
				have_lib = conf.CheckLib( self.checkLibParameters[1],  self.checkLibParameters[3], language = self.checkLibParameters[2],  autoadd = 0 )						
		else:
			if self.checkLibParameters[1] == '':				
				have_lib = conf.CheckLibWithHeader( self.options_para['LIBS'], self.checkLibParameters[2], self.checkLibParameters[3], self.checkLibParameters[4], 0 )		
			else:
				have_lib = conf.CheckLibWithHeader( self.checkLibParameters[1], self.checkLibParameters[2], self.checkLibParameters[3], self.checkLibParameters[4], 0 )			
		conf.Finish()
		return have_lib

		



class SimpleEnviromentLibraryFinder(AbstractLibraryFinder):
	includePath=[]
	libPath=[]
	debug_tags = []
	envExtensions = []
	
	def __init__(self, libName, checkLibParameters, includePath=['','include'], libPath=['lib'],  debug_tags = ['-d', '_d', '-gd', '_debug'], envExtensions={ 'x86' : [ '', '32','x86'] , 'x64' : ['', '64','x64'] }):
		AbstractLibraryFinder.__init__(self, libName, checkLibParameters)		
		self.includePath = includePath
		self.libPath = libPath
		self.debug_tags = debug_tags
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

	
