#!/usr/bin/python3

STRUCT_JSON_FILE = 'cimgui/generator/output/structs_and_enums.json'
TYPEDEFS_JSON_FILE = 'cimgui/generator/output/typedefs_dict.json'
COMMANDS_JSON_FILE = 'cimgui/generator/output/definitions.json'
TEMPLATES_JSON_FILE = 'cimgui/generator/output/templates.json'
IMPL_JSON_FILE = 'cimgui/generator/output/definitions_impl.json'

OUTPUT_DIR = 'zig'
OUTPUT_FILE = 'imgui.zig'

import json
from collections import namedtuple
from os import makedirs

typeConversions = {
    'int': 's32',
    'unsigned int': 'u32',
    'short': 's16',
    'unsigned short': 'u16',
    'float': 'f32',
    'double': 'f64',
    'void*': '?*c_void',
    'const void*': '?*const c_void',
    'bool': 'bool',
    'char': 'u8',
    'unsigned char': 'u8',
    'size_t': 'usize',
    'ImS8': 's8',
    'ImS16': 's16',
    'ImS32': 's32',
    'ImS64': 's64',
    'ImU8': 'u8',
    'ImU16': 'u16',
    'ImU32': 'u32',
    'ImU64': 'u64',
    'ImGuiCond': 'CondFlags',
}

vectorDef = """pub fn Vector(comptime T: type) type {
    return extern struct {
        size: i32,
        capacity: i32,
        data: [*]T,
    };
}"""

Structure = namedtuple('Structure', ['zigName', 'fieldsDecl', 'functions'])

class ZigData:
    def __init__(self):
        self.typedefs = {}
        """ {cName : zigDecl} """

        self.bitsets = []
        """ []zigDecl """

        self.enums = []
        """ []zigDecl """
        
        self.structures = {}
        """ {cName : Structure} """

        self.rawCommands = []
        """ []zigDecl """
        
        self.rootFunctions = []
        """ []zigDecl """
    
    def addTypedef(self, name, definition):
        # don't generate known type conversions
        if name in typeConversions: return
        
        if name in ('const_iterator', 'iterator', 'value_type'): return

        if definition.endswith(';'): definition = definition[:-1]

        # don't generate redundant C typedefs
        if definition == 'struct '+name: return
        
        decl = 'pub const '+self.convertTypeName(name)+' = '+self.convertComplexType(definition, False)+';'
        self.typedefs[name] = decl
        
    def addFlags(self, name, jsonValues):
        self.typedefs.pop(name[:-1], None)

        if name == 'ImGuiCond_':
            rawName = name[:-1]
            zigRawName = 'Cond'
        else:
            assert(name.endswith('Flags_'))
            rawName = name[:-len('Flags_')]
            zigRawName = self.convertTypeName(rawName)
        zigFlagsName = zigRawName + 'Flags'
        zigValuesName = zigRawName + 'FlagBits'
        decl = 'pub const '+zigFlagsName+' = u32;\n'
        decl += 'pub const '+zigValuesName+' = struct {\n'
        for value in jsonValues:
            valueName = value['name'].replace(name, '')
            valueValue = str(value['value']).replace(name, '')
            decl += '    pub const '+valueName+': '+zigFlagsName+' = '+valueValue+';\n'
        decl += '};'
        self.bitsets.append(decl)
        
    def addEnum(self, name, jsonValues):
        assert(name.endswith('_'))
        self.typedefs.pop(name[:-1], None)
        zigName = self.convertTypeName(name[:-1])
        countValue = None
        aliases = []
        decl = 'pub const '+zigName+' = extern enum {\n'
        for value in jsonValues:
            valueName = value['name'].replace(name, '')
            valueValue = str(value['value'])
            if valueName == 'COUNT':
                countValue = '    pub const COUNT = '+valueValue+';'
            elif name in valueValue:
                aliases.append('    pub const '+valueName+' = '+valueValue.replace(name, 'Self.')+';')
            else:
                decl += '    '+valueName+' = '+str(value['value'])+',\n'
        if countValue:
            decl += countValue + '\n'
        if aliases:
            decl += '\n'
            decl += '    pub const Self = @This();\n'
            decl += '\n'.join(aliases) + '\n'
        decl += '};'
        self.enums.append(decl)
        
    def addStruct(self, name, jsonFields):
        zigName = self.convertTypeName(name)
        decl = ''
        for field in jsonFields:
            fieldName = field['name']
            buffers = []
            while (fieldName.endswith(']')):
                start = fieldName.rindex('[')
                bufferLen = fieldName[start+1:-1]
                fieldName = fieldName[:start]
                if bufferLen.endswith('_COUNT'):
                    bufferIndexEnum = bufferLen[:-len('_COUNT')]
                    zigIndexEnum = self.convertTypeName(bufferIndexEnum)
                    bufferLen = zigIndexEnum + '.COUNT'
                buffers.append(bufferLen)
            buffers.reverse()
            fieldType = field['type']
            templateType = field['template_type'] if 'template_type' in field else None
            zigType = self.convertComplexType(fieldType, False, templateType)
            if len(fieldName) == 0:
                fieldName = 'value'
            decl += '    '+fieldName+': '
            for length in buffers:
                decl += '['+length+']'
            decl += zigType + ',\n'
        if decl: #strip trailing newline
            decl = decl[:-1]
        self.structures[name] = Structure(zigName, decl, [])
    
    def addFunction(self, jFunc):
        if 'nonUDT' in jFunc: return
        rawName = jFunc['ov_cimguiname']
        if 'constructor' in jFunc:
            retType = 'void'
        else:
            retType = jFunc['ret']
        if 'templated' in jFunc:
            stname = jFunc['stname']
            info = self.templates[stname]
            zigStname = self.convertTypeName(stname)
            macro = info['generic']
            instantiations = info['implementations']
            for cType in instantiations:
                variant = instantiations[cType]
                zigType = self.convertComplexType(cType, False)
                template = {}
                template[macro] = zigType
                template[stname] = zigStname+'('+zigType+')'
                params = []
                for arg in jFunc['argsT']:
                    if arg['type'] == '...': params.append('...')
                    else: params.append(arg['name']+': '+self.convertComplexType(arg['type'], True, template))
                rawDecl = '    pub extern fn '+rawName+'_'+variant+'('+', '.join(params)+') '+self.convertComplexType(retType, False, template)+';'
                self.rawCommands.append(rawDecl)
        else:
            params = []
            for arg in jFunc['argsT']:
                if arg['type'] == '...': params.append('...')
                else: params.append(arg['name']+': '+self.convertComplexType(arg['type'], True))
            rawDecl = '    pub extern fn '+rawName+'('+', '.join(params)+') '+self.convertComplexType(retType, False)+';'
            self.rawCommands.append(rawDecl)
            if 'stname' in jFunc and jFunc['stname']:
                struct = jFunc['stname']
                declName = rawName.replace(struct+'_', '')
                if 'constructor' in jFunc:
                    declName = declName.replace(struct, 'init')
                elif 'destructor' in jFunc:
                    declName = declName.replace('destroy', 'deinit')
                decl = '    pub const '+declName+' = raw.'+rawName+';'
                self.structures[struct].functions.append(decl)
        
    def convertComplexType(self, type, forFunction, template=None):
        """ template is (templateMacro, templateInstance) """
        buffers = ''
        bufferNeedsPointer = False
        while type.endswith(']'):
            start = type.rindex('[')
            buffer = type[start:]
            type = type[:start]
            bufferNeedsPointer = buffer != '[]'
            if not bufferNeedsPointer:
                buffer = '[*]'
            buffers = buffer + buffers
        if bufferNeedsPointer and forFunction:
            buffers = '*' + buffers
            

        if type.startswith('union'):
            # anonymous union
            paramStart = type.index('{')+1
            paramEnd = type.rindex('}')-1
            params = [x.strip() for x in type[paramStart:paramEnd].split(';') if x.strip()]
            zigParams = []
            for p in params:
                spaceIndex = p.rindex(' ')
                paramName = p[spaceIndex+1:]
                paramType = p[:spaceIndex]
                zigParams.append(paramName + ': ' + self.convertComplexType(paramType, False, template))
            return 'extern union { ' + ', '.join(zigParams) + ' }'

        if '(*)' in type:
            # function pointer
            index = type.index('(*)')
            returnType = type[:index]
            zigReturnType = self.convertComplexType(returnType, False, template)
            params = type[index+4:-1].split(',')
            zigParams = []
            for p in params:
                spaceIndex = p.rindex(' ')
                paramName = p[spaceIndex+1:]
                paramType = p[:spaceIndex]
                zigParams.append(paramName + ': ' + self.convertComplexType(paramType, True, template))
            return '?extern fn ('+', '.join(zigParams)+') '+zigReturnType
        
        valueConst = False
        if type.startswith('const'):
            valueConst = True
            type = type[6:]
        
        numPointers = 0
        while (type.endswith('*')):
            type = type[:-1]
            numPointers += 1
        
        valueType = type
        
        if valueType == 'void':
            if numPointers == 0: return 'void'
            else:
                if valueConst:
                    valueType = 'const void*'
                else:
                    valueType = 'void*'
                numPointers -= 1
                valueConst = False
        
        zigValue = buffers
        for _ in range(numPointers):
            zigValue += '[*c]'
        if valueConst:
            zigValue += 'const '

        zigValue += self.convertTypeName(valueType, template)
            
        return zigValue

    def convertTypeName(self, cName, template=None):
        """ template is (templateMacro, templateInstance) """
        if template and cName in template:
            return template[cName]
        elif cName in typeConversions:
            return typeConversions[cName]
        elif cName.startswith('ImGui'):
            return cName[len('ImGui'):]
        elif cName.startswith('Im'):
            return cName[len('Im'):]
        else:
            print("Couldn't convert type "+repr(cName))
            return cName
            
    def writeFile(self, f):
        for v in data.typedefs.values():
            f.write(v + '\n')
        f.write('\n')

        for b in data.bitsets:
            f.write(b + '\n\n')
            
        for e in data.enums:
            f.write(e + '\n\n')

        for s in data.structures.values():
            f.write('pub const '+s.zigName+' = extern struct {\n')
            f.write(s.fieldsDecl+'\n')
            if s.functions:
                f.write('\n')
            for func in s.functions:
                f.write(func+'\n')
            f.write('};\n\n')
            
        f.write('pub const raw = struct {\n')
        for r in data.rawCommands:
            f.write(r+'\n')
        f.write('};\n')


if __name__ == '__main__':
    with open(STRUCT_JSON_FILE) as f:
        jsonStructs = json.load(f)
    with open(TYPEDEFS_JSON_FILE) as f:
        jsonTypedefs = json.load(f)
    with open(COMMANDS_JSON_FILE) as f:
        jsonCommands = json.load(f)
    with open(TEMPLATES_JSON_FILE) as f:
        jsonTemplates = json.load(f)
        
    data = ZigData()
    
    data.templates = jsonTemplates
    
    for typedef in jsonTypedefs:
        data.addTypedef(typedef, jsonTypedefs[typedef])
    
    jsonEnums = jsonStructs['enums']
    for enumName in jsonEnums:
        if enumName.endswith('Flags_') or enumName == 'ImGuiCond_':
            data.addFlags(enumName, jsonEnums[enumName])
        elif enumName.endswith('_'):
            data.addEnum(enumName, jsonEnums[enumName])
        else:
            assert(False)
    
    jsonStructures = jsonStructs['structs']
    for structName in jsonStructures:
        data.addStruct(structName, jsonStructures[structName])
        
    for overrides in jsonCommands.values():
        for func in overrides:
            data.addFunction(func)
    
    makedirs(OUTPUT_DIR, exist_ok=True)
    with open(OUTPUT_DIR+'/'+OUTPUT_FILE, "w", newline='\n') as f:
        data.writeFile(f)
    