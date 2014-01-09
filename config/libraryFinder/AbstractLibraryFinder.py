import os
import sys

Import( '*')

# helper classes for setup up external library dependencies

# base class for checking if a library config is valid
class AbstractLibraryFinder:
	libName = ''
	options_para = {}
	checkLibParameters = []
	debug_tags = []
	option_key_names = { 'INCLUDEPATH' : 'CPPPATH', 'LIBPATH' : 'LIBPATH', 'LIBS' : 'LIBS', 'DEFINES' : 'CPPDEFINES'}
	
	# {NameOfLibrary e.b. boost}{compile check, array [ {additional compile settings}, {include files}, {language (C++)},{library to link against (optional)}, {source code (optional)}]}{ tags within the lib names to identify debug libraries}
	def __init__(self, libName, checkLibParameters, debug_tags = ['-d', '_d', '-gd', '_debug']):
		self.libName = libName
		self.checkLibParameters = checkLibParameters
		self.debug_tags = debug_tags

	def setIfValueExists(self, key, value):				
		exists = True
		key = self.option_key_names[key]
		if key == 'LIBS':
			if isinstance( value, list ):											
				self.options_para[ key ] = value
			else:
				self.options_para[ key ] =  value.split() 
		else:
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
		key = self.option_key_names[key]
		if self.options_para.has_key(key):
			options[ key ] = self.options_para[key]

	def getLibraryOptions(self):
		return self.options_para

	def tryFindingLibs(self):
		libs_	= []
		if self.options_para.has_key('LIBS') :
			print 'Using predefinded LIBS'
			libs_ =  self.options_para['LIBS']
		elif self.options_para.has_key('LIBPATH') :			
			lowername = self.libName.lower()

			libEnding = ''
			if platform == 'android':
				libEnding = '.a'
				libPrefix = 'lib'				
			elif sys.platform.startswith( 'linux' ):
				libEnding = '.so'
				libPrefix = 'lib'
			elif sys.platform == 'darwin':
				libEnding = '.dylib'
				libPrefix = 'lib'
			else :
				libEnding = '.lib'
				libPrefix = ''

			for libPath in self.options_para[ 'LIBPATH']:
				dirList=os.listdir(libPath)
				
				
				for fname in dirList: # check all files in libpath directory
					# is this one of the searched libraries?
					# starts with prefix, contains name of the library
					if not fname.lower().startswith(libPrefix) or not fname.endswith(libEnding):
						continue
						
					isDebugLib = False
					for debug_tag in self.debug_tags:						
						if fname.find(debug_tag) > 0 :
							isDebugLib = True
							break						

					if not configuration == "debug" and not isDebugLib:
						libs_.append(fname)
					elif configuration == "debug" and isDebugLib:
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
		
Export('AbstractLibraryFinder')