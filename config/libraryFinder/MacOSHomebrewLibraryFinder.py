import os
import sys
import ConfigParser

SConscript ( '#/config/libraryFinder/AbstractLibraryFinder.py' )

Import( '*')


class MacOSHomebrewLibraryFinder(AbstractLibraryFinder):
	def __init__(self, libName, checkLibParameters, includePath=[], libPath=[] ):
		AbstractLibraryFinder.__init__(self, libName, checkLibParameters)	
	
	def checkForLibraries(self):
		print 'Platform:'+platform
		print 'Configuration:'+ configuration
		print 'Search here for the settings of library:' + self.libName
		self.setIfValueExists('INCLUDEPATH', ['/somepath/include'])
		self.setIfValueExists('LIBPATH', ['/somepath/libs'])
		self.setIfValueExists('LIBS', ['lib1.lib', 'lib2.lib'])
		
		self.tryFindingLibs()
		
		return self.getLibraryOptions()

Export('MacOSHomebrewLibraryFinder')        