import os
import sys
import fnmatch
import ConfigParser

SConscript ( '#/config/libraryFinder/AbstractLibraryFinder.py' )

Import( '*')

LibrariesPath = "/usr"

class LinuxLibraryFinder(AbstractLibraryFinder):
	def __init__(self, libName, checkLibParameters, includePath=[], libPath=[] ):
		AbstractLibraryFinder.__init__(self, libName, checkLibParameters)	
	
	def checkForLibraries(self):
		self.libName = self.libName.lower()
		print 'Platform:'+platform
		print 'Configuration:'+ configuration
		print 'Search here for the settings of library:' + self.libName

		if(self.libName == 'glut'):
			self.libName = 'freeglut'

		libNames = []

		if(os.path.isdir(LibrariesPath)):
			libraryIncludePath = os.path.join(LibrariesPath, "include")
			if(os.path.isdir(libraryIncludePath)):
				self.includePath = libraryIncludePath

			libraryLibPath = os.path.join(LibrariesPath, "lib")
			if (self.libName =="freeglut"):
				libraryLibPath = os.path.join(libraryLibPath, "x86_64-linux-gnu")

			if(os.path.isdir(libraryLibPath)):
				self.libPath = libraryLibPath

				prefixLibrary = "lib" + self.libName
				if(self.libName == 'freeglut'):
					prefixLibrary = "libglut"
				
				if( self.libName == "boost"):
					libNames = [ files for files in os.listdir(libraryLibPath) if fnmatch.fnmatch(files, '%s*-mt.so' % prefixLibrary)]
				else:
					libNames = [ files for files in os.listdir(libraryLibPath) if fnmatch.fnmatch(files, '%s*.so' % prefixLibrary)]


				self.setIfValueExists('INCLUDEPATH', self.includePath)
				self.setIfValueExists('LIBPATH', self.libPath)
				self.setIfValueExists('LIBS', libNames)

				if(self.libName == 'freeglut'):
					self.libName = 'GLUT'

				self.libName = self.libName.upper()

			else:
				print "==> Couldn't find %s library" % self.libName
				print "==> You can install it with: 'apt-get install %s'" %self.libName

		else:
			print "==> couldn't find %s PATH" %LibrariesPathPrefix

		
		self.tryFindingLibs()
		
		return self.getLibraryOptions()

Export('LinuxLibraryFinder')      