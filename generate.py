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
    'int': 'i32',
    'unsigned int': 'u32',
    'short': 'i16',
    'unsigned short': 'u16',
    'float': 'f32',
    'double': 'f64',
    'void*': '?*c_void',
    'const void*': '?*const c_void',
    'bool': 'bool',
    'char': 'u8',
    'unsigned char': 'u8',
    'size_t': 'usize',
    'ImS8': 'i8',
    'ImS16': 'i16',
    'ImS32': 'i32',
    'ImS64': 'i64',
    'ImU8': 'u8',
    'ImU16': 'u16',
    'ImU32': 'u32',
    'ImU64': 'u64',
    'ImGuiCond': 'CondFlags',
}

MightBeArray = (
    'ImVec2',
    'ImVec4',
    'ImWchar'
)

Structure = namedtuple('Structure', ['zigName', 'fieldsDecl', 'functions'])
TemplateInfo = namedtuple('TemplateInfo', ['zigName', 'implementations', 'functions'])
TemplateImpl = namedtuple('TemplateImpl', ['zigFullType', 'zigInnerType', 'variant', 'map', 'functions'])

class ZigData:
    def __init__(self):
        self.opaqueTypes = {}
        """ {cName: True} """

        self.templates = {}
        """ {cName: TemplateInfo} """

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
        
        self.reverseTemplateMap = {}
        """ {cName : zigDecl} """

        self.context = []
    
    def addTemplate(self, name, info):
        self.context = [name]
        generic = info['generic']
        implementations = info['implementations']
        zigName = self.convertTypeName(name)
        savedImpls = {}
        for cType in implementations:
            variant = implementations[cType]
            self.context.append(variant)
            cVariant = name+'_'+variant
            zigType = self.convertComplexType(cType, False)
            zigFullType = zigName+'('+zigType+')'
            self.reverseTemplateMap[cVariant] = zigFullType
            templateMap = {}
            templateMap[generic] = zigType
            templateMap[name] = zigFullType
            savedImpls[cVariant] = TemplateImpl(zigFullType, zigType, variant, templateMap, [])
            self.context.pop()
        self.templates[name] = TemplateInfo(zigName, savedImpls, [])

    def addTypedef(self, name, definition):
        self.context = [name]

        # don't generate known type conversions
        if name in typeConversions: return
        
        if name in ('const_iterator', 'iterator', 'value_type'): return

        if definition.endswith(';'): definition = definition[:-1]

        # don't generate redundant C typedefs
        if definition == 'struct '+name:
            self.opaqueTypes[name] = True
            return
        
        decl = 'pub const '+self.convertTypeName(name)+' = '+self.convertComplexType(definition, False)+';'
        self.typedefs[name] = decl
        
    def addFlags(self, name, jsonValues):
        self.context = [name]
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
        self.context = [name]
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
        self.context = [name]
        self.opaqueTypes.pop(name, None)
        zigName = self.convertTypeName(name)
        decl = ''
        for field in jsonFields:
            fieldName = field['name']
            self.context.append(fieldName)
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
        self.context = []
        stname = jFunc['stname'] if 'stname' in jFunc else None
        if 'templated' in jFunc and jFunc['templated'] == True:
            info = self.templates[stname]
            instantiations = info.implementations
            for cVariant in instantiations:
                instance = instantiations[cVariant]
                self.makeFunction(jFunc, rawName.replace(stname, cVariant), cVariant, instantiations, instance.map)
            info.functions.append(self.makeZigFunctionName(jFunc, rawName, stname))
        else:
            self.makeFunction(jFunc, rawName, stname, self.structures)
    
    def makeFunction(self, jFunc, rawName, stname, parentTable, template=None):
        if 'ret' in jFunc:
            retType = jFunc['ret']
        else:
            retType = 'void'
        self.context.append(rawName)
        params = []
        for arg in jFunc['argsT']:
            if arg['type'] == 'va_list':
                self.context.pop()
                return # skip this function entirely
            if arg['type'] == '...': params.append('...')
            else:
                self.context.append(arg['name'])
                params.append(arg['name']+': '+self.convertComplexType(arg['type'], True, template))
                self.context.pop()
        rawDecl = '    pub extern fn '+rawName+'('+', '.join(params)+') '+self.convertComplexType(retType, False, template)+';'
        self.context.pop()
        self.rawCommands.append(rawDecl)
        if stname:
            declName = self.makeZigFunctionName(jFunc, rawName, stname)
            decl = '    pub const '+declName+' = raw.'+rawName+';'
            parentTable[stname].functions.append(decl)
        else:
            assert(rawName[0:2] == 'ig')
            decl = 'pub const '+rawName[2:]+' = raw.'+rawName+';'
            self.rootFunctions.append(decl)

    def makeZigFunctionName(self, jFunc, rawName, struct):
        declName = rawName.replace(struct+'_', '')
        if 'constructor' in jFunc:
            declName = declName.replace(struct, 'init')
        elif 'destructor' in jFunc:
            declName = declName.replace('destroy', 'deinit')
        return declName
        
    def convertComplexType(self, type, forFunction, template=None):
        """ template is (templateMacro, templateInstance) """
        # remove trailing const, it doesn't mean anything to Zig
        if type.endswith('const'):
            type = type[:-5].strip()

        buffers = ''
        bufferNeedsPointer = False
        while type.endswith(']'):
            start = type.rindex('[')
            buffer = type[start:]
            type = type[:start].strip()
            bufferNeedsPointer = buffer != '[]'
            if not bufferNeedsPointer:
                buffer = '[*]'
            buffers = buffer + buffers
        if bufferNeedsPointer and forFunction:
            buffers = '*' + buffers
        if type.endswith('const'):
            type = type[:-5].strip()
            buffers += 'const'


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
                self.context.append(paramName)
                zigParams.append(paramName + ': ' + self.convertComplexType(paramType, False, template))
                self.context.pop()
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
                while paramName.startswith('*'):
                    paramType += '*'
                    paramName = paramName[1:].strip()
                self.context.append(paramName)
                zigParams.append(paramName + ': ' + self.convertComplexType(paramType, True, template))
                self.context.pop()
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
        if numPointers > 0:
            zigValue += self.getPointers(numPointers, valueType, forFunction)
        if valueConst and not zigValue.endswith('const'):
            zigValue += 'const'

        innerType = self.convertTypeName(valueType, template)
        if innerType[0].isalpha() and len(zigValue) > 0 and zigValue[-1].isalpha():
            zigValue += ' '
        zigValue += innerType
            
        return zigValue

    def getPointers(self, numPointers, valueType, forFunction):
        pointers = ''

        if len(self.context) > 0 and 'out' in self.context[-1] or numPointers > 1 and forFunction:
            pointers += '*'
            numPointers -= 1

        if numPointers > 1:
            for i in range(numPointers-1):
                pointers += '[*]'
            pointers += '*'
        elif numPointers == 1:
            if valueType == 'char' or valueType == 'ImWchar':
                pointers += '[*]'
            elif valueType.startswith('Im') and not (valueType in MightBeArray):
                pointers += '*'
            elif len(self.context) > 0:
                name = self.context[-1]
                if name == 'self':
                    pointers += '*'
                else:
                    pointers += '[*c]'
            else:
                pointers += '[*c]'
        return pointers

    def convertTypeName(self, cName, template=None):
        """ template is (templateMacro, templateInstance) """
        if template and cName in template:
            return template[cName]
        elif cName in typeConversions:
            return typeConversions[cName]
        elif cName in self.reverseTemplateMap:
            return self.reverseTemplateMap[cName]
        elif cName.startswith('ImGui'):
            return cName[len('ImGui'):]
        elif cName.startswith('Im'):
            return cName[len('Im'):]
        else:
            print("Couldn't convert type "+repr(cName))
            return cName
            
    def writeFile(self, f):
        for t in self.opaqueTypes:
            f.write('pub const '+self.convertTypeName(t)+' = @OpaqueType();\n')

        for v in self.typedefs.values():
            f.write(v + '\n')
        f.write('\n')

        for b in self.bitsets:
            f.write(b + '\n\n')
            
        for e in self.enums:
            f.write(e + '\n\n')

        for s in self.structures.values():
            f.write('pub const '+s.zigName+' = extern struct {\n')
            f.write(s.fieldsDecl+'\n')
            if s.functions:
                f.write('\n')
            for func in s.functions:
                f.write(func+'\n')
            f.write('};\n\n')
        
        for t in self.templates:
            info = self.templates[t]
            for impl in info.implementations:
                implInfo = info.implementations[impl]
                f.write('const FTABLE_'+impl+' = struct {\n')
                for func in implInfo.functions:
                    f.write(func+'\n')
                f.write('};\n\n')
            f.write('fn getFTABLE_'+t+'(comptime T: type) type {\n')
            for impl in info.implementations:
                implInfo = info.implementations[impl]
                f.write('    if (T == '+implInfo.zigInnerType+') return FTABLE_'+impl+';\n')
            f.write('    @compileError("Invalid '+info.zigName+' type");\n')
            f.write('}\n\n')
            f.write('pub fn '+info.zigName+'(comptime T: type) type {\n')
            f.write('    return extern struct {\n')
            f.write('        //@TODO: fill in fields\n')
            f.write('        size: i32,\n')
            f.write('        capacity: i32,\n')
            f.write('        items: [*]T,\n')
            f.write('\n')
            f.write('        const FTABLE = getFTABLE_'+t+'(T);\n')
            for func in info.functions:
                f.write('        pub const '+func+' = FTABLE.'+func+';\n')
            f.write('    };\n')
            f.write('}\n\n')

        for func in self.rootFunctions:
            f.write(func+'\n')
        f.write('\n')

        f.write('pub const raw = struct {\n')
        for r in self.rawCommands:
            f.write(r+'\n')
        f.write('};\n')

        if False:
            f.write("""
test "foo" {
    var cb: DrawCallback = undefined;
    const std = @import("std");
    _ = std.meta.fields(@This());
    _ = std.meta.fields(raw);
    var vec: Vector(f32) = undefined;
    vec.init();
}
""");


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
    
    for template in jsonTemplates:
        info = jsonTemplates[template]
        data.addTemplate(template, info)
    
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
    