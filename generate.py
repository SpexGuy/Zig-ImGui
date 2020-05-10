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
from collections import defaultdict
from os import makedirs
from pointer_rules import *

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

def isFlags(cName):
    return cName.endswith('Flags') or cName == 'ImGuiCond'

Structure = namedtuple('Structure', ['zigName', 'fieldsDecl', 'functions'])
TemplateInfo = namedtuple('TemplateInfo', ['zigName', 'implementations', 'functions'])
TemplateImpl = namedtuple('TemplateImpl', ['zigFullType', 'zigInnerType', 'nogenerate', 'variant', 'map', 'functions'])

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
    
    def addTemplate(self, name, info):
        generic = info['generic']
        implementations = info['implementations']
        nogen = info['nogenerate']
        zigName = self.convertTypeName(name)
        savedImpls = {}
        for cType in implementations:
            variant = implementations[cType]
            nogenerate = []
            for func in nogen:
                if variant in nogen[func]:
                    nogenerate.append(func)
            cVariant = name+'_'+variant
            zigType = self.convertComplexType(cType, TemplateContext(name))
            zigFullType = zigName+'('+zigType+')'
            self.reverseTemplateMap[cVariant] = zigFullType
            templateMap = {}
            templateMap[generic] = zigType
            templateMap[name] = zigFullType
            savedImpls[cVariant] = TemplateImpl(zigFullType, zigType, nogenerate, variant, templateMap, [])
        self.templates[name] = TemplateInfo(zigName, savedImpls, [])

    def addTypedef(self, name, definition):
        # don't generate known type conversions
        if name in typeConversions: return
        
        if name in ('const_iterator', 'iterator', 'value_type'): return

        if definition.endswith(';'): definition = definition[:-1]

        # don't generate redundant C typedefs
        if definition == 'struct '+name:
            self.opaqueTypes[name] = True
            return
        
        decl = 'pub const '+self.convertTypeName(name)+' = '+self.convertComplexType(definition, TypedefContext(name))+';'
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

        # list of (name, int_value)
        aliases = []

        bits = [None] * 32
        for value in jsonValues:
            valueName = value['name'].replace(name, '')
            intValue = value['calc_value']
            if intValue != 0 and (intValue & (intValue - 1)) == 0:
                bitIndex = -1;
                while (intValue):
                    intValue >>= 1
                    bitIndex += 1
                if bits[bitIndex] == None:
                    bits[bitIndex] = valueName
                else:
                    aliases.append((valueName, 1<<bitIndex))
            else:
                aliases.append((valueName, intValue))

        for i in range(32):
            if bits[i] is None:
                bits[i] = '__reserved_bit_%02d' % i

        decl = 'pub const '+zigFlagsName+'Int = FlagsInt;\n'
        decl += 'pub const '+zigFlagsName+' = packed struct {\n'
        for bitName in bits:
            decl += '    ' + bitName + ': bool = false,\n'
        if aliases:
            decl += '\n    const Self = @This();\n'
            for alias, intValue in aliases:
                values = [ '.' + bits[x] + '=true' for x in range(32) if (intValue & (1<<x)) != 0 ]
                if values:
                    init = 'Self{ ' + ', '.join(values) + ' }'
                else:
                    init = 'Self{}'
                decl += '    pub const ' + alias + ' = ' + init + ';\n'
            decl += '\n    pub usingnamespace FlagsMixin(Self);\n'
        else:
            decl += '\n    pub usingnamespace FlagsMixin(@This());\n'
            
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
        self.opaqueTypes.pop(name, None)
        zigName = self.convertTypeName(name)
        decl = ''
        structContext = StructContext(name)
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
            zigType = self.convertComplexType(fieldType, FieldContext(fieldName, structContext), templateType)
            if len(fieldName) == 0:
                fieldName = 'value'
            decl += '    '+fieldName+': '
            for length in buffers:
                decl += '['+length+']'
            decl += zigType + ',\n'
        if decl: #strip trailing newline
            decl = decl[:-1]
        self.structures[name] = Structure(zigName, decl, [])
    
    def addFunction(self, name, jFunc):
        rawName = jFunc['ov_cimguiname']
        stname = jFunc['stname'] if 'stname' in jFunc else None
        if 'templated' in jFunc and jFunc['templated'] == True:
            info = self.templates[stname]
            instantiations = info.implementations
            for cVariant in instantiations:
                instance = instantiations[cVariant]
                if not(rawName in instance.nogenerate):
                    self.makeFunction(jFunc, name.replace(stname, cVariant), rawName.replace(stname, cVariant), cVariant, instantiations, instance.map)
            info.functions.append(self.makeZigFunctionName(jFunc, rawName, stname))
        else:
            self.makeFunction(jFunc, name, rawName, stname, self.structures)

    def addFunctionSet(self, jSet):
        byName = {}
        for func in jSet:
            if 'nonUDT' in func:
                if func['nonUDT'] == 1:
                    rootName = func['ov_cimguiname'].replace('_nonUDT', '')
                    byName[rootName] = func
            else:
                rootName = func['ov_cimguiname']
                if not (rootName in byName):
                    byName[rootName] = func

        for name, func in byName.items():
            self.addFunction(name, func);
    
    def makeFunction(self, jFunc, baseName, rawName, stname, parentTable, template=None):
        functionContext = FunctionContext(rawName, stname)
        if 'ret' in jFunc:
            retType = jFunc['ret']
        else:
            retType = 'void'
        params = []
        isVarargs = False
        for arg in jFunc['argsT']:
            if arg['type'] == 'va_list':
                return # skip this function entirely
            if arg['type'] == '...':
                params.append(('...', '...'))
                isVarargs = True
            else:
                argName = arg['name']
                argType = self.convertComplexType(arg['type'], ParamContext(argName, functionContext), template)
                params.append((argName, argType))

        paramStrs = [ '...' if typeStr == '...' else (name + ': ' + typeStr) for name, typeStr in params ]
        retType = self.convertComplexType(retType, ParamContext('return', functionContext), template)

        rawDecl = '    pub extern fn '+rawName+'('+', '.join(paramStrs)+') callconv(.C) '+retType+';'
        self.rawCommands.append(rawDecl)

        wrapper = self.makeWrapper(jFunc, baseName, rawName, stname, params, retType, isVarargs, template)
        if stname:
            wrapperStr = '    ' + '\n    '.join(wrapper);
            parentTable[stname].functions.append(wrapperStr)
        else:
            self.rootFunctions.append('\n'.join(wrapper))

    def makeWrapper(self, jFunc, baseName, rawName, stname, params, retType, isVarargs, template):
        declName = self.makeZigFunctionName(jFunc, baseName, stname)

        if not isVarargs:
            wrappedName = declName
            needsWrap = False
            beforeCall = []
            wrappedRetType = retType
            returnName = None

            paramStrs = []
            passStrs = []

            if 'Flags' in wrappedRetType:
                print("Warning: flags return type not supported for "+baseName);

            if 'nonUDT' in jFunc and jFunc['nonUDT'] == 1:
                assert(retType == 'void')
                needsWrap = True

                returnParam = params[0];
                params = params[1:]

                assert(returnParam[0] == 'pOut')
                wrappedRetType = returnParam[1]
                # strip one pointer
                assert(wrappedRetType[0] == '*')
                wrappedRetType = wrappedRetType[1:]

                beforeCall.append('var out: '+wrappedRetType+' = undefined;')
                passStrs.append('&out')
                returnName = 'out'

            for name, typeStr in params:
                if typeStr.endswith('FlagsInt') and not ('*' in typeStr):
                    needsWrap = True
                    paramStrs.append(name + ': ' + typeStr.replace('FlagsInt', 'Flags'))
                    passStrs.append(name + '.toInt()')
                else:
                    paramStrs.append(name + ': ' + typeStr)
                    passStrs.append(name)

            if needsWrap:
                wrapper = []
                wrapper.append('pub inline fn '+wrappedName+'(' + ', '.join(paramStrs) + ') '+wrappedRetType+' {')
                for line in beforeCall:
                    wrapper.append('    ' + line)
                callStr = 'raw.'+rawName+'('+', '.join(passStrs)+');'
                if returnName is None:
                    wrapper.append('    return '+callStr)
                else:
                    wrapper.append('    '+callStr)
                    wrapper.append('    return '+returnName+';')
                wrapper.append('}')
                return wrapper


        return ['pub const '+declName+' = raw.'+rawName+';']

    def makeZigFunctionName(self, jFunc, baseName, struct):
        if struct:
            declName = baseName.replace(struct+'_', '')
            if 'constructor' in jFunc:
                declName = declName.replace(struct, 'init')
            elif 'destructor' in jFunc:
                declName = declName.replace('destroy', 'deinit')
        else:
            assert(baseName[0:2] == 'ig')
            declName = baseName[2:]

        return declName
        
    def convertComplexType(self, type, context, template=None):
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
        if bufferNeedsPointer and context.type == CT_PARAM:
            buffers = '*' + buffers
        if type.endswith('const'):
            type = type[:-5].strip()
            buffers += 'const '


        if type.startswith('union'):
            anonTypeContext = StructContext('', context)
            # anonymous union
            paramStart = type.index('{')+1
            paramEnd = type.rindex('}')-1
            params = [x.strip() for x in type[paramStart:paramEnd].split(';') if x.strip()]
            zigParams = []
            for p in params:
                spaceIndex = p.rindex(' ')
                paramName = p[spaceIndex+1:]
                paramType = p[:spaceIndex]
                zigParams.append(paramName + ': ' + self.convertComplexType(paramType, FieldContext(paramName, anonTypeContext), template))
            return 'extern union { ' + ', '.join(zigParams) + ' }'

        if '(*)' in type:
            # function pointer
            index = type.index('(*)')
            returnType = type[:index]
            funcContext = FunctionContext('', '', context)
            zigReturnType = self.convertComplexType(returnType, ParamContext('return', funcContext), template)
            params = type[index+4:-1].split(',')
            zigParams = []
            for p in params:
                spaceIndex = p.rindex(' ')
                paramName = p[spaceIndex+1:]
                paramType = p[:spaceIndex]
                while paramName.startswith('*'):
                    paramType += '*'
                    paramName = paramName[1:].strip()
                zigParams.append(paramName + ': ' + self.convertComplexType(paramType, ParamContext(paramName, funcContext), template))
            return '?fn ('+', '.join(zigParams)+') callconv(.C) '+zigReturnType
        
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
            zigValue += getPointers(numPointers, valueType, context)
            if isFlags(valueType):
                zigValue += 'align(4) '
        if valueConst and not zigValue.endswith('const '):
            zigValue += 'const '

        innerType = self.convertTypeName(valueType, template)
        zigValue += innerType
        
        if numPointers == 0 and isFlags(valueType):
            if context.type == CT_PARAM:
                zigValue += 'Int'
            if context.type == CT_FIELD:
                zigValue += ' align(4)'
            
        return zigValue


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
        f.write('const assert = @import("std").debug.assert;\n\n')
        for t in self.opaqueTypes:
            f.write('pub const '+self.convertTypeName(t)+' = @OpaqueType();\n')

        for v in self.typedefs.values():
            f.write(v + '\n')
        f.write('\n')
        
        f.write('pub const DrawCallback_ResetRenderState = @intToPtr(DrawCallback, ~@as(usize, 0));\n')
        f.write('pub const VERSION = "1.75";\n')
        f.write('pub fn CHECKVERSION() void {\n')
        f.write('    if (@import("builtin").mode != .ReleaseFast) {\n')
        f.write('        @import("std").debug.assert(raw.igDebugCheckVersionAndDataLayout(VERSION, @sizeOf(IO), @sizeOf(Style), @sizeOf(Vec2), @sizeOf(Vec4), @sizeOf(DrawVert), @sizeOf(DrawIdx)));\n')
        f.write('    }\n')
        f.write('}\n')
        
        f.write('\n')
        f.write("""pub const FlagsInt = u32;
pub fn FlagsMixin(comptime FlagType: type) type {
    comptime assert(@sizeOf(FlagType) == 4);
    return struct {
        pub fn toInt(self: FlagType) FlagsInt {
            return @bitCast(Flags, self);
        }
        pub fn fromInt(value: FlagsInt) FlagType {
            return @bitCast(FlagType, value);
        }
        pub fn with(a: FlagType, b: FlagType) FlagType {
            return fromInt(toInt(a) | toInt(b));
        }
        pub fn only(a: FlagType, b: FlagType) FlagType {
            return fromInt(toInt(a) & toInt(b));
        }
        pub fn without(a: FlagType, b: FlagType) FlagType {
            return fromInt(toInt(a) & ~toInt(b));
        }
        pub fn hasAllSet(a: FlagType, b: FlagType) bool {
            return (toInt(a) & toInt(b)) == toInt(b);
        }
        pub fn hasAnySet(a: FlagType, b: FlagType) bool {
            return (toInt(a) & toInt(b)) != 0;
        }
        pub fn isEmpty(a: FlagType) bool {
            return toInt(a) == 0;
        }
    };
}

""")


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
            f.write('        len: i32,\n')
            f.write('        capacity: i32,\n')
            f.write('        items: [*]T,\n')
            f.write('\n')
            f.write('        pub usingnamespace getFTABLE_'+t+'(T);\n')
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
        # enum name in this data structure ends with _, so strip that.
        if isFlags(enumName[:-1]):
            data.addFlags(enumName, jsonEnums[enumName])
        elif enumName.endswith('_'):
            data.addEnum(enumName, jsonEnums[enumName])
        else:
            assert(False)
    
    jsonStructures = jsonStructs['structs']
    for structName in jsonStructures:
        data.addStruct(structName, jsonStructures[structName])
        
    for overrides in jsonCommands.values():
        data.addFunctionSet(overrides)
    
    makedirs(OUTPUT_DIR, exist_ok=True)
    with open(OUTPUT_DIR+'/'+OUTPUT_FILE, "w", newline='\n') as f:
        data.writeFile(f)
    