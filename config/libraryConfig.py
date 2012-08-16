import os
import sys
import json

Import( '*')

class DictWatch(dict):
    def __init__(self, *args, **kwargs):
        self.update(*args, **kwargs)

    def __getitem__(self, key):
    	key += '_'+platform+'_'+configuration
        val = dict.__getitem__(self, key)
        #print 'GET', key
        return val

    def __setitem__(self, key, val):
    	key += '_'+platform+'_'+configuration
        #print 'SET', key, val
        dict.__setitem__(self, key, val)

    def __repr__(self):
        dictrepr = dict.__repr__(self)
        return '%s(%s)' % (type(self).__name__, dictrepr)

	def __contains__(self, item):
		item += '_'+platform+'_'+configuration
		#print 'has_key', item
        return dict.has_key(self, item)
    
    def has_key(self, item):
    	item += '_'+platform+'_'+configuration		
        return dict.has_key(self, item)

    def update(self, *args, **kwargs):
        #print 'update', args, kwargs
        for k, v in dict(*args, **kwargs).iteritems():
			dict.__setitem__(self,k, v)       	


class AbstractLibraryFinder:
	libName = ''
	options_para = DictWatch()
	checkLibParameters = []

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

	def checkForLibraries(self):
		return self.options_para

	def getParaSuffix(self):
		return '_'+platform+'_'+configuration

	def getParaWithSuffix(self, para):
		return para + self.getParaSuffix()

	def getLibraryOptions(self):
		result = {}
		self.setIfContains(result, 'CPPPATH')
		self.setIfContains(result, 'LIBPATH')
		self.setIfContains(result, 'LIBS')
		self.setIfContains(result, 'CPPDEFINES')		
		return result

	def tryFindingLibs(self):
		libs_	= []
		if self.options_para.has_key('LIBPATH') :			
			libEnding = ''
			if sys.platform.startswith( 'linux' ):
				libEnding = '.o'
			else :
				libEnding = '.lib'

			for libPath in self.options_para[ 'LIBPATH']:
				dirList=os.listdir(libPath)
				lib_release = []
				lib_debug = []
				debug_tags = ['-d', '_d', '-gd', '_debug']

				for fname in dirList: # check all files in libpath directory
					isDebugLib = False
					for debug_tag in debug_tags:
						#if fname.endswith(debug_tag+libEnding)  :
						if fname.find(debug_tag) > 0 :
							isDebugLib = True
							break
						elif fname.endswith('d'+libEnding): # might be a problem for libraries ending with d
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
		
		self.options_para['LIBS'] = libs_			
		self.options_para['configured'] = True
		self.options_para['haveLib'] = self.isLibraryAvailable()
		if self.options_para['haveLib']:
			self.options_para['CPPDEFINES'] = [ 'HAVE_'+self.libName]
			

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
				# TODO why always same lib?
				for currentLib in self.options_para['LIBS']:
					print "checking with lib: "+currentLib + ' in path: ' +str(self.options_para['LIBPATH'])
					have_lib = conf.CheckLib( currentLib, self.checkLibParameters[3], language = self.checkLibParameters[2],  autoadd = 0 )			
					if have_lib:
						break
			else:				
				have_lib = conf.CheckLib( self.checkLibParameters[1],  self.checkLibParameters[3], language = self.checkLibParameters[2],  autoadd = 0 )						
		else:
			if self.checkLibParameters[1] == '':
				for currentLib in self.options_para['LIBS']:
					print "checking with lib: "+currentLib + ' in path: ' +str(self.options_para['LIBPATH'])
					have_lib = conf.CheckLibWithHeader( currentLib, self.checkLibParameters[2], self.checkLibParameters[3], self.checkLibParameters[4], 0 )			
					if have_lib:
						break
			else:
				have_lib = conf.CheckLibWithHeader( self.checkLibParameters[1], self.checkLibParameters[2], self.checkLibParameters[3], self.checkLibParameters[4], 0 )			
		conf.Finish()
		return have_lib

		



class SimpleEnviromentLibraryFinder(AbstractLibraryFinder):
	includePath=''
	libPath=''
	def __init__(self, libName, checkLibParameters, includePath='include', libPath='lib'):
		AbstractLibraryFinder.__init__(self, libName, checkLibParameters)		
		self.includePath = includePath
		self.libPath = libPath
	
	def checkForLibraries(self):		
		checkPara = self.libName+"_ROOT"
		if os.environ.has_key(checkPara):
			envPath = os.environ[checkPara]						
			self.setIfValueExists('CPPPATH', os.path.join( envPath, self.includePath) )
			self.setIfValueExists('LIBPATH', os.path.join( envPath, self.libPath) )			

		checkPara = self.libName+"_INCLUDE"	
		if os.environ.has_key(checkPara):
			envPath = os.environ[checkPara]						
			self.setIfValueExists('CPPPATH', envPath )		

		checkPara = self.libName+"_LIB"
		if os.environ.has_key(checkPara):
			envPath = os.environ[checkPara]						
			self.setIfValueExists('LIBPATH', envPath )	
		checkPara = self.libName+"_LIB64"
		if platform == 'x64' and os.environ.has_key(checkPara):
			envPath = os.environ[checkPara]						
			self.setIfValueExists('LIBPATH', envPath )	

		# check opts variable
		checkPara = self.libName+"_PATH"
		if checkPara in opts :
			self.setIfValueExists('CPPPATH', os.path.join( opts[ checkPara ], self.includePath ) )
			self.setIfValueExists('LIBPATH', os.path.join( opts[ checkPara ], self.libPath ) )		
		
		checkPara = self.libName+"_PATH"+platform
		if checkPara in opts :
			self.setIfValueExists('CPPPATH', os.path.join( opts[ checkPara ], self.includePath ) )
			self.setIfValueExists('LIBPATH', os.path.join( opts[ checkPara ], self.libPath ) )
		
		checkPara = self.libName+"_INCLUDE"
		if checkPara in opts :
			self.setIfValueExists('CPPPATH', opts[ checkPara ].split( os.pathsep ) )
		
		checkPara = self.libName+"_INCLUDE"+platform
		if checkPara in opts :
			self.setIfValueExists('CPPPATH', opts[ checkPara ].split( os.pathsep ) )
		
		checkPara = self.libName+"_LIBS"
		if checkPara in opts :
			self.setIfValueExists('LIBPATH', opts[ checkPara ].split( os.pathsep ) )	

		checkPara = self.libName+"_LIBS"+platform
		if checkPara in opts :
			self.setIfValueExists('LIBPATH', opts[ checkPara ].split( os.pathsep ) )

		self.tryFindingLibs()
		if self.options_para['haveLib'] :
			return self.options_para

		if not self.options_para['haveLib'] and self.options_para.has_key('LIBPATH') and platform == "x64":
			#print self.options_para['LIBPATH']	
			newLibPath = []		
			for libtemp in self.options_para['LIBPATH']:
				newLibPath.append(os.path.join( libtemp, "x64"))
			#print newLibPath
			if self.setIfValueExists('LIBPATH', newLibPath ):
				self.tryFindingLibs()

		return self.options_para


	


class SimpleLibraryConfiguration:
	libName = ''
	lib_options = DictWatch()
	configFile = ''	

	def __init__(self, libName, libraryFinder):
		self.libName = libName
		self.libraryFinder = libraryFinder		
		configDir = self.checkOutputDirectory()
		self.configFile = os.path.join( configDir, libName ) 		
		self.loadConfigSettings()

		# start reconfiguration
		if 'reconfigure' in COMMAND_LINE_TARGETS:
			self.lib_options['configured'] = False

		# check if configuration is needed
		if self.lib_options.has_key('configured'):			
			if self.lib_options['configured'] :				
				if self.lib_options['haveLib'] :
					print "Library "+self.libName+" available"
				else:
					self.configure()
			else :			
				self.configure()
		else:
				
			self.configure()

	def haveLib(self):
		return self.lib_options['haveLib']
		
	def checkOutputDirectory(self):
		configDir = os.path.join( Dir('#').abspath, 'config', 'configStorage')
		if not os.path.exists(configDir):
			os.mkdir(configDir)

		return configDir

	def configure(self):
		print "trying to configure library "+self.libName
		foundOptions = self.libraryFinder.checkForLibraries()
		self.lib_options.update(foundOptions)
		self.saveConfigSettings()


	def getLibraryOptions(self):
		result = {}
		self.setIfContains(result, 'CPPPATH')
		self.setIfContains(result, 'LIBPATH')
		self.setIfContains(result, 'LIBS')
		self.setIfContains(result, 'CPPDEFINES')
		return result

	def hasOption(self, key):
		return self.lib_options.has_key(key)
	def getOption(self, key):
		return self.lib_options[key]

	def setOption(self, key, value):
		self.lib_options[key] = [value]
		return		

	def loadConfigSettings(self):
		if os.path.exists(self.configFile):
			fp = open(self.configFile, 'r')
			self.lib_options = DictWatch(json.load(fp))
			fp.close()
		else :
			self.lib_options = DictWatch()
		return

	def saveConfigSettings(self):		
		fp = open(self.configFile, 'w+')
		json.dump(self.lib_options, fp)
		fp.close()
		return

	def setIfContains(self, options, key):
		if self.lib_options.has_key(key):
			options[ key ] = self.lib_options[key]


if sys.platform == 'win32':
	standardLibFinder = SimpleEnviromentLibraryFinder
	standardLibConfig = SimpleLibraryConfiguration
else:
	standardLibFinder = SimpleEnviromentLibraryFinder
	standardLibConfig = SimpleLibraryConfiguration

Export('standardLibFinder', 'standardLibConfig')

	