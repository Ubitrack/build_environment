import sys

SConscript ( '#/config/libraryFinder/UbitrackLibraryFinder.py' )
SConscript ( '#/config/libraryFinder/MacOSHomebrewLibraryFinder.py' )
SConscript ( '#/config/libraryFinder/LinuxLibraryFinder.py' )
SConscript ( '#/config/libraryFinder/WindowsLibraryFinder.py' )

Import( '*')

class LibraryFinderChain:
	libFinderList=[]
		
	def __init__(self, libName, checkLibParameters, includePath=[], libPath=[] ):
		opts.Add(  libName+'_LIBFINDER', 'Which library finder should be used to search for '+libName+' (DEFAULT, UbitrackLibraryFinder, MacOSHomebrewLibraryFinder, LinuxLibraryFinder, WindowsLibraryFinder)', 'DEFAULT' )
		libFinder = opts[libName+'_LIBFINDER']
		
		if libFinder == 'DEFAULT':
			if sys.platform == 'win32':
				self.libFinderList.append(WindowsLibraryFinder(libName, checkLibParameters, includePath, libPath))
			elif sys.platform == 'linux2':
				self.libFinderList.append(LinuxLibraryFinder(libName, checkLibParameters, includePath, libPath))
			elif sys.platform == 'darwin':
				self.libFinderList.append(MacOSHomebrewLibraryFinder(libName, checkLibParameters, includePath, libPath))
			
			
			self.libFinderList.append(UbitrackLibraryFinder(libName, checkLibParameters, includePath, libPath))
		else :
			libFinderClass = globals()[libFinder]
			self.libFinderList.append(libFinderClass(libName, checkLibParameters, includePath, libPath))
		
	
	def checkForLibraries(self):
		for libFinder in self.libFinderList:
			print "Using library finder:" + libFinder.__class__.__name__
			foundOptions = libFinder.checkForLibraries()
			print "Result of "+ libFinder.__class__.__name__+": "+ str(foundOptions['HAVELIB'])
			if foundOptions['HAVELIB']:
				return foundOptions
		
		options_para = { 'HAVELIB': False }
		return options_para
		
Export('LibraryFinderChain')