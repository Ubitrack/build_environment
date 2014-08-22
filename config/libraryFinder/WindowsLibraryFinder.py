import os
import sys
import fnmatch
import ConfigParser

SConscript ( '#/config/libraryFinder/AbstractLibraryFinder.py' )

Import( '*')

LibrariesPathPrefix = "C:\\"
CompilerName = "vc10"

class WindowsLibraryFinder(AbstractLibraryFinder):
	def __init__(self, libName, checkLibParameters, includePath=[], libPath=[] ):
		AbstractLibraryFinder.__init__(self, libName, checkLibParameters)	
	
	def checkForLibraries(self):
		self.libName = self.libName.lower()
		print 'Platform:'+platform
		print 'Configuration:'+ configuration
		print 'Search here for the settings of library:' + self.libName
		
		self.tryFindingLibs()
		
		return self.getLibraryOptions()
		
		if(self.libName == 'glut'):
			self.libName = 'freeglut'
		
		libraryPath = ""
		if (self.libName == "boost"):
			if(platform == "x64"):
				libraryPath = os.path.join(LibrariesPathPrefix, "Program Files\\Boost")
			else:
				libraryPath = os.path.join(LibrariesPathPrefix, "Program Files (x86)\\Boost")
		elif (self.libName == "lapack"):
			libraryPath = os.path.join(LibrariesPathPrefix,"%s_%s" %(self.libName,platform))
		elif (self.libName == "opencv"):
			libraryPath = os.path.join(LibrariesPathPrefix,"%s\\build" %self.libName)
		else:
			libraryPath = os.path.join(LibrariesPathPrefix, self.libName)
			
		self.includePath = []
		libraryIncludePath = os.path.join(libraryPath, "include")
		if(os.path.isdir(libraryIncludePath)):
			self.includePath = libraryIncludePath	
				
		libraryLibPath = ""
		if(self.libName == "opencv"):
			libraryLibPath = os.path.join(libraryPath, "%s\\%s\\lib" %(platform,CompilerName))
		else:
			libraryLibPath = os.path.join(libraryPath, "lib")
		
		if(self.libName == "freeglut" and platform == "x64"):
			libraryLibPath = os.path.join(libraryLibPath, platform)
			
		if(os.path.isdir(libraryLibPath)):
			self.libPath = libraryLibPath
		
		if(self.libName == "boost"):
			if(configuration == "release"):
				libNames = [files for files in os.listdir(libraryLibPath) if fnmatch.fnmatch(files, '*-mt-[0-9]*.lib')]# opts['BOOST_SUFFIX'])]
			else:
				libNames = [files for files in os.listdir(libraryLibPath) if fnmatch.fnmatch(files, '*-mt-gd*.lib')]
		elif (self.libName == "opencv"):
			if(configuration == "release"):
				libNames = [files for files in os.listdir(libraryLibPath) if fnmatch.fnmatch(files, '*[0-9].lib')]
			else:
				libNames = [files for files in os.listdir(libraryLibPath) if fnmatch.fnmatch(files, '*d.lib')]
		else:
			libNames = [files for files in os.listdir(libraryLibPath) if fnmatch.fnmatch(files, '*.lib')]
		
		if (len(self.includePath) != 0):
			self.setIfValueExists('INCLUDEPATH', self.includePath)
		if(len(self.includePath) != 0):
			self.setIfValueExists('LIBPATH', self.libPath)
			self.setIfValueExists('LIBS', libNames)

		if(self.libName == 'freeglut'):
			self.libName = 'GLUT'

		self.libName = self.libName.upper()
				
		self.tryFindingLibs()
		
		return self.getLibraryOptions()

Export('WindowsLibraryFinder')        