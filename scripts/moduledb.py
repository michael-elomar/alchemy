#
# Module database helpers.
#

import xml.dom.minidom

#===============================================================================
#===============================================================================
class Module(object):
	def __init__(self, moduleNode):
		self.name = moduleNode.getAttribute("name")
		self.build = (moduleNode.getAttribute("build") == "yes")
		fieldNodes = moduleNode.getElementsByTagName("field")
		self.fields = {}
		for fieldNode in fieldNodes:
			fieldName = fieldNode.getAttribute("name")
			valueNodes = fieldNode.getElementsByTagName("value")
			# Normally only one 'value' node
			if valueNodes != None and len(valueNodes) == 1:
				# get value in the first child of the 'value' node
				fieldValue = valueNodes[0].childNodes[0].nodeValue
				self.fields[fieldName] = fieldValue

	def __repr__(self):
		return "[name=%s fields=%s]" % (self.name, str(self.fields))

#===============================================================================
#===============================================================================
class ModuleDb(object):
	def __init__(self):
		self._modules = {}

	def append(self, module):
		self._modules[module.name] = module

	def __getitem__(self, key):
		return self._modules[key]

	def __iter__(self):
		return iter(self._modules.values())

#===============================================================================
#===============================================================================
def loadXml(xmlPath):
	# Parse xml file
	xmlDom = xml.dom.minidom.parse(xmlPath)

	# Load modules
	modules = ModuleDb()
	moduleNodes = xmlDom.documentElement.getElementsByTagName("module")
	for moduleNode in moduleNodes:
		modules.append(Module(moduleNode))

	# Return list of loaded modules
	return modules
