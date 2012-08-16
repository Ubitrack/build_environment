# some code taken from scons.Options

import SCons.Errors
import os.path

class NoEnvOptions( dict ):
	"""
	Provides a dictionary of options, similar to SCons.Options, but wit the following differences:
	* values are not stored in an environment, but in the NoEnvOptions object itself
	* values can be retrieved like from a dictionary
	"""

	def __init__( self, filename = None, args = None ):
		self.help = {}
		self.defaults = {}

		# read cached options from files
		if filename is not None and os.path.exists( filename ):
			execfile( filename, self )

		# remove keys that start with "__" (artefacts from execfile)
		for key in self.keys():
			if key.startswith( '__' ):
				del self[ key ]

		if '__builtins__' in self:
			del self[ '__builtins__' ]

		# finally, apply command line arguments
		if args is not None:
			self.update( args )

	def Add( self, key, help = "", default = None ):
		# add default value if no value is present
		if  not key in self and default:
			self[ key ] = default

		self.defaults[ key ] = default
		self.help[ key ] = help

	def Save( self, filename ):
		try:
			fh = open( filename, 'w' )
			for key in self.keys():
				if not key in self.defaults or self[ key ] != self.defaults[ key ]:
					fh.write( '%s = %s\n' % ( key, repr( self[ key ] ) ) )

			fh.close()
		except IOError, x:
			raise SCons.Errors.UserError, 'Error writing options to file: %s\n%s' % (filename, x)
			
	def IsSet( self, key ):
		return key in self and ( not key in self.defaults or self[ key ] != self.defaults[ key ] )

	def GenerateHelpText( self ):
		help_text = "The following build options are available:\n"

		# create a help text for all options that have an associated help text
		sorted_keys = self.help.keys()
		sorted_keys.sort()
		for key in sorted_keys:
			# default value to display
			if key in self.defaults:
				default = repr( self.defaults[ key ] )
			else:
				default = 'None'

			# actual value to display
			if key in self:
				value = repr( self[ key ] )
			else:
				value = 'None'

			help_text = help_text + '\n%s: %s\n   default: %s\n   actual : %s\n' % ( key, self.help[ key ], default, value )

		return help_text
