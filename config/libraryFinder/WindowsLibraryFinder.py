import os
import sys
import ConfigParser

SConscript ( '#/config/libraryFinder/AbstractLibraryFinder.py' )

Import( '*')


class WindowsLibraryFinder(AbstractLibraryFinder):
	def __init__(self, libName, checkLibParameters, includePath=[], libPath=[] ):
		AbstractLibraryFinder.__init__(self, libName, checkLibParameters)	
	
	def checkForLibraries(self):
		print 'Platform:'+platform
		print 'Configuration:'+ configuration
		print 'Search here for the settings of library:' + self.libName
		self.setIfValueExists('INCLUDEPATH', ['C:\\Libraries\\Boost\\include'])
		self.setIfValueExists('LIBPATH', ['C:\\Libraries\\Boost\\lib'])
		self.setIfValueExists('LIBS', ['lib1.lib', 'lib2.lib'])
		
		self.tryFindingLibs()
		
		return self.getLibraryOptions()

Export('WindowsLibraryFinder')        