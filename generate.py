#!/usr/bin/python3

import sys
if sys.version_info[0] != 3:
    print ("Error: This script requires python 3, current version is"), (sys.version)
    sys.exit(1)

STRUCT_JSON_FILE = 'cimgui/generator/output/structs_and_enums.json'
TYPEDEFS_JSON_FILE = 'cimgui/generator/output/typedefs_dict.json'
COMMANDS_JSON_FILE = 'cimgui/generator/output/definitions.json'
IMPL_JSON_FILE = 'cimgui/generator/output/definitions_impl.json'

OUTPUT_DIR = 'zig-imgui'
OUTPUT_FILE = 'imgui.zig'
TEMPLATE_FILE = 'template.zig'

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
    'void*': '?*anyopaque',
    'const void*': '?*const anyopaque',
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
    'FILE': 'anyopaque',
}

def isFlags(cName):
    return cName.endswith('Flags') or cName == 'ImGuiCond'

Structure = namedtuple('Structure', ['zigName', 'fieldsDecl', 'functions'])

class ZigData:
    def __init__(self):
        self.opaqueTypes = {}
        """ {cName: True} """

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
        if definition == 'struct '+name:
            self.opaqueTypes[name] = True
            return
        
        decl = 'pub const '+self.convertTypeName(name)+' = '+self.convertComplexType(definition, TypedefContext(name))+';'
        self.typedefs[name] = decl
        
    def addFlags(self, name, jsonValues):
        self.typedefs.pop(name, None)

        if name == 'ImGuiCond':
            rawName = name
            zigRawName = 'Cond'
        else:
            assert(name.endswith('Flags'))
            rawName = name[:-len('Flags')]
            zigRawName = self.convertTypeName(rawName)
        zigFlagsName = zigRawName + 'Flags'

        # list of (name, int_value)
        aliases = []

        bits = [None] * 32
        for value in jsonValues:
            valueName = value['name'].replace(name + '_', '')
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
            decl += '\n'
            for alias, intValue in aliases:
                values = [ '.' + bits[x] + '=true' for x in range(32) if (intValue & (1<<x)) != 0 ]
                if values:
                    init = '.{ ' + ', '.join(values) + ' }'
                else:
                    init = '.{}'
                decl += '    pub const ' + alias + ': @This() = ' + init + ';\n'
        decl += '\n    pub usingnamespace FlagsMixin(@This());\n'
            
        decl += '};'
        self.bitsets.append(decl)
        
    def addEnum(self, name, jsonValues):
        self.typedefs.pop(name, None)
        zigName = self.convertTypeName(name)
        sentinels = []
        decl = 'pub const '+zigName+' = enum (i32) {\n'
        for value in jsonValues:
            valueName = value['name'].replace(name + '_', '')
            if valueName[0] >= '0' and valueName[0] <= '9':
                valueName = '@"' + valueName + '"'
            valueValue = str(value['value'])
            if name in valueValue:
                valueValue = valueValue.replace(name+'_', '@This().')
            if valueName == 'COUNT' or valueName.endswith('_BEGIN') or valueName.endswith('_OFFSET') or valueName.endswith('_END') or valueName.endswith('_COUNT') or valueName.endswith('_SIZE'):
                sentinels.append('    pub const '+valueName+' = '+valueValue+';')
            else:
                decl += '    '+valueName+' = '+valueValue+',\n'
        decl += '    _,\n'
        if sentinels:
            decl += '\n' + '\n'.join(sentinels) + '\n'
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
                buffers.append(self.convertArrayLen(bufferLen))
            buffers.reverse()
            fieldType = field['type']
            templateType = field['template_type'] if 'template_type' in field else None
            zigType = self.convertComplexType(fieldType, FieldContext(fieldName, structContext))
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
            pass
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
    
    def makeFunction(self, jFunc, baseName, rawName, stname, parentTable):
        functionContext = FunctionContext(rawName, stname)
        if 'ret' in jFunc:
            retType = jFunc['ret']
        else:
            retType = 'void'
        params = []
        isVarargs = False
        for arg in jFunc['argsT']:
            udtptr = 'udtptr' in arg and arg['udtptr']
            if arg['type'] == 'va_list':
                return # skip this function entirely
            if arg['type'] == '...':
                params.append(('...', '...', False))
                isVarargs = True
            else:
                argName = arg['name']
                argType = self.convertComplexType(arg['type'], ParamContext(argName, functionContext, udtptr))
                if argName == 'type':
                    argName = 'kind'
                params.append((argName, argType, udtptr))

        paramStrs = [ '...' if typeStr == '...' else (name + ': ' + typeStr) for name, typeStr, udtptr in params ]
        retType = self.convertComplexType(retType, ParamContext('return', functionContext))

        rawDecl = '    pub extern fn '+rawName+'('+', '.join(paramStrs)+') callconv(.C) '+retType+';'
        self.rawCommands.append(rawDecl)

        declName = self.makeZigFunctionName(jFunc, baseName, stname)

        wrappedName = declName
        needsWrap = False
        beforeCall = []
        wrappedRetType = retType
        returnExpr = None
        returnCapture = None

        defaultParamStrs = []
        defaultPassStrs = []
        hasDefaults = False

        paramStrs = []
        passStrs = []

        jDefaults = jFunc['defaults']

        if wrappedRetType.endswith('FlagsInt'):
            needsWrap = True
            wrappedRetType = wrappedRetType[:-len('Int')]
            returnCapture = '_retflags'
            returnExpr = wrappedRetType + '.fromInt(_retflags)'

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
            returnExpr = 'out'

        for name, typeStr, udtptr in params:
            if name == 'type':
                name = 'kind'
            wrappedType = typeStr
            wrappedPass = name

            if typeStr.endswith('FlagsInt') and not ('*' in typeStr):
                needsWrap = True
                wrappedType = typeStr.replace('FlagsInt', 'Flags')
                wrappedPass = name + '.toInt()'
            elif udtptr:
                needsWrap = True
                wrappedType = typeStr[len('*const '):]
                wrappedPass = '&' + name

            paramStrs.append(name + ': ' + wrappedType)
            passStrs.append(wrappedPass)

            if name in jDefaults:
                hasDefaults = True
                defaultPassStrs.append(self.convertParamDefault(jDefaults[name], wrappedType, ParamContext(name, functionContext)))
            else:
                defaultParamStrs.append(paramStrs[-1])
                defaultPassStrs.append(name) # pass name not wrappedPass because we are calling the wrapper

        wrapper = []

        if not isVarargs and hasDefaults:
            defaultsName = wrappedName
            wrappedName += 'Ext'

        if not isVarargs and needsWrap:
            wrapper.append('pub inline fn '+wrappedName+'(' + ', '.join(paramStrs) + ') '+wrappedRetType+' {')
            for line in beforeCall:
                wrapper.append('    ' + line)
            callStr = 'raw.'+rawName+'('+', '.join(passStrs)+');'
            if returnExpr is None:
                wrapper.append('    return '+callStr)
            else:
                if returnCapture is None:
                    wrapper.append('    '+callStr)
                else:
                    wrapper.append('    const '+returnCapture+' = '+callStr)
                wrapper.append('    return '+returnExpr+';')
            wrapper.append('}')
        else:
            wrapper.append('/// '+wrappedName+'('+', '.join(paramStrs)+') '+wrappedRetType)
            wrapper.append('pub const '+wrappedName+' = raw.'+rawName+';')

        if not isVarargs and hasDefaults:
            wrapper.append('pub inline fn '+defaultsName+'('+', '.join(defaultParamStrs)+') '+wrappedRetType+' {')
            wrapper.append('    return @This().'+wrappedName+'('+', '.join(defaultPassStrs)+');')
            wrapper.append('}')


        if stname:
            wrapperStr = '    ' + '\n    '.join(wrapper);
            parentTable[stname].functions.append(wrapperStr)
        else:
            self.rootFunctions.append('\n'.join(wrapper))

    def makeZigFunctionName(self, jFunc, baseName, struct):
        if struct:
            declName = baseName.replace(struct+'_', '')
            if 'constructor' in jFunc:
                declName = 'init_' + declName
            elif 'destructor' in jFunc:
                declName = declName.replace('destroy', 'deinit')
        else:
            assert(baseName[0:2] == 'ig')
            declName = baseName[2:]

        return declName

    def convertParamDefault(self, defaultStr, typeStr, context):
        if typeStr == 'f32':
            if defaultStr.endswith('f'):
                floatStr = defaultStr[:-1]
                if floatStr.startswith('+'):
                    floatStr = floatStr[1:]
                try:
                    floatValue = float(floatStr)
                    return floatStr
                except:
                    pass
            if defaultStr == 'FLT_MAX':
                return 'FLT_MAX'
            if defaultStr == '-FLT_MIN':
                return '-FLT_MIN'
            if defaultStr == '0':
                return '0'
            if defaultStr == '1':
                return '1'

        if typeStr == 'f64':
            try:
                floatValue = float(defaultStr)
                return defaultStr
            except:
                pass

        if typeStr == 'i32' or typeStr == 'u32' or typeStr == 'usize' or typeStr == 'ID':
            if defaultStr == "sizeof(float)":
                return '@sizeOf(f32)'
            try:
                intValue = int(defaultStr)
                return defaultStr
            except:
                pass

        if typeStr == 'bool':
            if defaultStr in ('true', 'false'):
                return defaultStr

        if typeStr == 'Vec2' and defaultStr.startswith('ImVec2('):
            params = defaultStr[defaultStr.index('(')+1 : defaultStr.index(')')]
            items = params.split(',')
            assert(len(items) == 2)
            return '.{.x='+self.convertParamDefault(items[0], 'f32', context) + \
                ',.y='+self.convertParamDefault(items[1], 'f32', context)+'}'

        if typeStr == 'Vec4' and defaultStr.startswith('ImVec4('):
            params = defaultStr[defaultStr.index('(')+1 : defaultStr.index(')')]
            items = params.split(',')
            assert(len(items) == 4)
            return '.{.x='+self.convertParamDefault(items[0], 'f32', context) + \
                ',.y='+self.convertParamDefault(items[1], 'f32', context) + \
                ',.z='+self.convertParamDefault(items[2], 'f32', context) + \
                ',.w='+self.convertParamDefault(items[3], 'f32', context)+'}'

        if defaultStr.startswith('"') and defaultStr.endswith('"'):
            return defaultStr
        if ((typeStr.startswith("?") or typeStr.startswith("[*c]") or typeStr.endswith("Callback"))
            and (defaultStr == '0' or defaultStr == 'NULL')):
            return 'null'
        if typeStr == 'MouseButton':
            if defaultStr == '0':
                return '.Left'
            if defaultStr == '1':
                return '.Right'
        if typeStr == 'PopupFlags' and defaultStr == '1':
            return '.{ .MouseButtonRight = true }'
        if typeStr.endswith("Flags") and not ('*' in typeStr):
            if defaultStr == "0":
                return '.{}'
            if defaultStr == 'ImDrawCornerFlags_All':
                return 'DrawCornerFlags.All'

        if defaultStr == '(((ImU32)(255)<<24)|((ImU32)(255)<<16)|((ImU32)(255)<<8)|((ImU32)(255)<<0))' and typeStr == 'u32':
            return '0xFFFFFFFF'
        print("Warning: Couldn't convert default value "+defaultStr+" of type "+typeStr+", "+repr(context))
        return defaultStr
        
    def convertComplexType(self, type, context):
        # remove trailing const, it doesn't mean anything to Zig
        if type.endswith('const'):
            type = type[:-5].strip()

        pointers = ''
        arrays = ''
        arrayModifier = ''
        bufferNeedsPointer = False
        while type.endswith(']'):
            start = type.rindex('[')
            length = type[start + 1:-1].strip()
            type = type[:start].strip()
            if length == '':
                pointers += '[*]'
            else:
                bufferNeedsPointer = True
                arrays = '[' + self.convertArrayLen(length) + ']' + arrays
        if bufferNeedsPointer and context.type == CT_PARAM:
            pointers = '*' + pointers
        if type.endswith('const'):
            type = type[:-5].strip()
            arrayModifier = 'const'

        if type.startswith('union'):
            anonTypeContext = StructContext('', context)
            # anonymous union
            paramStart = type.index('{')+1
            paramEnd = type.rindex('}')-1
            params = [x.strip() for x in type[paramStart:paramEnd].split(';') if x.strip()]
            zigParams = []
            for p in params:
                if p == "...":
                    zigParams.append("...")
                else:
                    spaceIndex = p.rindex(' ')
                    paramName = p[spaceIndex+1:]
                    paramType = p[:spaceIndex]
                    zigParams.append(paramName + ': ' + self.convertComplexType(paramType, FieldContext(paramName, anonTypeContext)))
            return 'extern union { ' + ', '.join(zigParams) + ' }'

        if '(*)' in type:
            # function pointer
            index = type.index('(*)')
            returnType = type[:index]
            funcContext = FunctionContext('', '', context)
            zigReturnType = self.convertComplexType(returnType, ParamContext('return', funcContext))
            params = type[index+4:-1].split(',')
            zigParams = []
            for p in params:
                if p == "...":
                    zigParams.append("...")
                else:
                    spaceIndex = p.rindex(' ')
                    paramName = p[spaceIndex+1:]
                    paramType = p[:spaceIndex]
                    while paramName.startswith('*'):
                        paramType += '*'
                        paramName = paramName[1:].strip()
                    zigParams.append(paramName + ': ' + self.convertComplexType(paramType, ParamContext(paramName, funcContext)))
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
        
        zigValue = pointers
        zigValue += arrayModifier

        if numPointers > 0:
            zigValue += getPointers(numPointers, valueType, context)

        if valueConst and not zigValue.endswith('const'):
            # Special case: ColorPicker4.ref_col is ?*const[4] f32
            # getPointers returns ?*const[4], don't put another const after that.
            if not (context.name == 'ref_col' and context.parent.name == 'igColorPicker4'):
                zigValue += 'const'

        if numPointers > 0 and isFlags(valueType):
            if zigValue[-1].isalpha():
                zigValue += ' '
            zigValue += 'align(4) '

        zigValue += arrays

        if len(zigValue) > 0 and zigValue[-1].isalpha():
            zigValue += ' '

        innerType = self.convertTypeName(valueType)
        zigValue += innerType
        
        if numPointers == 0 and isFlags(valueType):
            if context.type == CT_PARAM:
                zigValue += 'Int'
            if context.type == CT_FIELD:
                zigValue += ' align(4)'
            
        return zigValue

    def convertArrayLen(self, length):
        try:
            int_val = int(length)
            return length
        except:
            pass

        if length.endswith('_COUNT'):
            bufferIndexEnum = length[:-len('_COUNT')]
            zigIndexEnum = self.convertTypeName(bufferIndexEnum)
            return zigIndexEnum + '.COUNT'
        
        if length == 'ImGuiKey_KeysData_SIZE':
            return 'Key.KeysData_SIZE'
        
        #print("Couldn't convert array size:", length)
        return length

    def convertTypeName(self, cName):
        if cName in typeConversions:
            return typeConversions[cName]
        elif cName.startswith('ImVector_'):
            rest = cName[len('ImVector_'):]
            prefix = 'Vector('
            if rest.endswith('Ptr'):
                rest = rest[:-len('Ptr')]
                prefix += '?*'
            return prefix + self.convertTypeName(rest) + ')'
        elif cName.startswith('ImGui'):
            return cName[len('ImGui'):]
        elif cName.startswith('Im'):
            return cName[len('Im'):]
        else:
            print("Couldn't convert type "+repr(cName))
            return cName
            
    def writeFile(self, f):
        with open(TEMPLATE_FILE) as template:
            f.write(template.read())

        for t in self.opaqueTypes:
            f.write('pub const '+self.convertTypeName(t)+' = opaque {};\n')

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
                for func in s.functions:
                    f.write('\n')
                    f.write(func+'\n')
            f.write('};\n\n')

        for func in self.rootFunctions:
            f.write('\n')
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
        
    data = ZigData()
    
    for typedef in jsonTypedefs:
        data.addTypedef(typedef, jsonTypedefs[typedef])
    
    jsonEnums = jsonStructs['enums']
    for enumName in jsonEnums:
        # enum name in this data structure ends with _, so strip that.
        actualName = enumName
        if actualName.endswith('_'):
            actualName = actualName[:-1]
        if isFlags(actualName):
            data.addFlags(actualName, jsonEnums[enumName])
        else:
            data.addEnum(actualName, jsonEnums[enumName])
    
    jsonStructures = jsonStructs['structs']
    for structName in jsonStructures:
        data.addStruct(structName, jsonStructures[structName])
        
    for overrides in jsonCommands.values():
        data.addFunctionSet(overrides)
    
    # remove things that are manually defined in template.zig
    del data.structures['ImVec2']
    del data.structures['ImVec4']
    del data.structures['ImColor']

    makedirs(OUTPUT_DIR, exist_ok=True)
    with open(OUTPUT_DIR+'/'+OUTPUT_FILE, "w", newline='\n') as f:
        data.writeFile(f)
    
    warnForUnusedRules()
    