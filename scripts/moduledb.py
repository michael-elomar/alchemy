#
# Module database helpers.
#

import xml.dom.minidom

#===============================================================================
#===============================================================================
def getNodeContent(node):
	if node.childNodes is not None and len(node.childNodes) == 1:
		return node.childNodes[0].nodeValue
	else:
		return ""

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
			if valueNodes is not None and len(valueNodes) == 1:
				# Get value in the first child of the 'value' node
				fieldValue = getNodeContent(valueNodes[0])
				self.fields[fieldName] = fieldValue

	def __repr__(self):
		return "[name=%s fields=%s]" % (self.name, str(self.fields))

#===============================================================================
#===============================================================================
class CustomMacro(object):
	def __init__(self, macroNode):
		self.name = macroNode.getAttribute("name")
		self.value = getNodeContent(macroNode)

#===============================================================================
#===============================================================================
class ModuleDb(object):
	def __init__(self):
		self._modules = {}
		self.targetVars = {}
		self.customMacros = {}

	def append(self, module):
		self._modules[module.name] = module

	def appendCustomMacro(self, macro):
		self.customMacros[macro.name] = macro

	def __getitem__(self, key):
		return self._modules[key]

	def __iter__(self):
		return iter([self._modules[key] for key in sorted(self._modules.keys())])

#===============================================================================
#===============================================================================
def loadXml(xmlPath):
	# Parse xml file
	xmlDom = xml.dom.minidom.parse(xmlPath)

	modules = ModuleDb()

	# Load TARGET_xxx variables
	targetNodes = xmlDom.documentElement.getElementsByTagName("target")
	if targetNodes is not None and len(targetNodes) == 1:
		varNodes = targetNodes[0].getElementsByTagName("var")
		for varNode in varNodes:
			varName = varNode.getAttribute("name")
			valueNodes = varNode.getElementsByTagName("value")
			# Normally only one 'value' node
			if valueNodes is not None and len(valueNodes) == 1:
				# Get value in the first child of the 'value' node
				varValue = getNodeContent(valueNodes[0])
				modules.targetVars[varName] = varValue

	# Load modules
	moduleNodes = xmlDom.documentElement.getElementsByTagName("module")
	for moduleNode in moduleNodes:
		modules.append(Module(moduleNode))

	# Load custom macros
	macroNodes = xmlDom.documentElement.getElementsByTagName("macro")
	for macroNode in macroNodes:
		modules.appendCustomMacro(CustomMacro(macroNode))

	# Return list of loaded modules
	return modules
