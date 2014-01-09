import os
import sys
import ConfigParser
import json

#SConscript ( '#/config/libraryFinder/UbitrackEnvironmentLibraryFinder.py' )

SConscript ( '#/config/libraryFinder/LibraryFinderChain.py' )


Import( '*')
	

# save and load library configurations in a human readable format. Uses a library finder if the current configuration is not valid
class SimpleLibraryConfiguration:
	libName = ''
	lib_options = ConfigParser.SafeConfigParser()	
	configFile = ''	
	section = sys.platform+'_'+platform+'_'+configuration
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
			if GetOption('config') == "force":
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



standardLibFinder = LibraryFinderChain
standardLibConfig = SimpleLibraryConfiguration
		
#if sys.platform == 'win32':
	#standardLibFinder = LibraryFinderChain
	#standardLibConfig = SimpleLibraryConfiguration
#else:
	#standardLibFinder = LibraryFinderChain
	#standardLibConfig = SimpleLibraryConfiguration

Export('standardLibFinder', 'standardLibConfig')

	
