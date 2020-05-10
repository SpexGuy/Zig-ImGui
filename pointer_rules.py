import re

## Context Types
CT_STRUCT = 1
CT_FIELD = 2
CT_FUNCTION = 3
CT_PARAM = 4
CT_TEMPLATE = 5
CT_TYPEDEF = 6

class Context:
    def __repr__(self):
        result = [
            'Struct',
            'Field',
            'Function',
            'Param',
            'Template',
            'Typedef'
        ][self.type-1] + ' '

        if self.name:
            result += self.name
        else:
            result += '<anon>'

        if self.parent is None:
            return result
        return repr(self.parent) + ' ' + result

def TemplateContext(name, parent=None):
    ctx = Context()
    ctx.type = CT_TEMPLATE
    ctx.parent = parent
    ctx.name = name
    return ctx

def TypedefContext(name, parent=None):
    ctx = Context()
    ctx.type = CT_TYPEDEF
    ctx.parent = parent
    ctx.name = name
    return ctx

def StructContext(name, parent=None):
    ctx = Context()
    ctx.type = CT_STRUCT
    ctx.parent = parent
    ctx.name = name
    return ctx

def FieldContext(name, parent):
    assert(parent.type == CT_STRUCT)
    ctx = Context()
    ctx.type = CT_FIELD
    ctx.parent = parent
    ctx.name = name
    return ctx

def FunctionContext(name, stname='', parent=None):
    ctx = Context()
    ctx.type = CT_FUNCTION
    ctx.parent = parent
    ctx.name = name
    ctx.stname = stname
    return ctx

def ParamContext(name, parent):
    assert(parent.type == CT_FUNCTION)
    ctx = Context()
    ctx.type = CT_PARAM
    ctx.parent = parent
    ctx.name = name
    return ctx


class Always:
    def __eq__(self, test):
        return True

class Not:
    def __init__(self, match):
        self.match = match
        
    def __eq__(self, text):
        return not (self.match == text)

class Contains:
    def __init__(self, text):
        self.text = text
    
    def __eq__(self, test):
        return self.text in test
        
class StartsWith:
    def __init__(self, text):
        self.text = text
    
    def __eq__(self, test):
        return test.startswith(self.text)
        
class EndsWith:
    def __init__(self, text):
        self.text = text
    
    def __eq__(self, test):
        return test.endswith(self.text)

class Regex:
    def __init__(self, regexStr):
        self.re = re.compile(r'\A' + regexStr + r'\Z')
    
    def __eq__(self, test):
        return self.re.match(test)
        
## Rules is a dictionary.  The first key is the number of indirections.  The second is the C value type.
## The value of that lookup is an array of rules.  Each rule is a tuple (match, zigPointerStr).  match is
## an array of comparisons to perform at each level, with the rightmost member of the array being the most
## specific.  So for example, ['format'] matches any field or parameter named 'format'.  ['Foo', 'format']
## would only match fields or params named 'format' in a struct or function named 'Foo'.
Rules = {
    1: [
        ("char", [
            (['ImGuiTextFilter_ImGuiTextFilter', 'default_filter'], '?[*:0]'),
            (['igInputTextWithHint', 'hint'], '?[*:0]'),
            (['igSetClipboardText', 'text'], '?[*:0]'),
            (['igBeginCombo', 'preview_value'], '?[*:0]'),
            (['igCombo', 'items'], '[*:0]'),
            (['igListBoxStr_arr', 'items'], '[*:0]'),
            (['igColumns', 'id'], '?[*:0]'),
            (['ImGuiTextBuffer_append', 'str'], '?[*]'),

            (['GetClipboardTextFn', '', 'return'], '?[*:0]'),
            (['SetClipboardTextFn', '', 'text'], '?[*:0]'),

            (['ImFont_CalcWordWrapPositionA', 'return'], '?[*]'),
            (['igSaveIniSettingsToMemory', 'return'], '?[*:0]'),
            (['ImGuiTextBuffer_begin', 'return'], '[*]'),
            (['ImGuiTextBuffer_end', 'return'], '[*]'),
            (['ImGuiTextBuffer_c_str', 'return'], '[*:0]'),
            (['igGetClipboardText', 'return'], '?[*:0]'),
            (['igGetVersion', 'return'], '?[*:0]'),

            ([EndsWith('Name'), 'return'], '?[*:0]'),

            (['type'], '?[*:0]'),

            (['compressed_font_data_base85'], '?[*]'),
            (['items_separated_by_zeros'], '?[*]'),
            (['text'], '?[*]'),
            (['fmt'], '?[*:0]'),
            (['prefix'], '?[*:0]'),
            (['shortcut'], '?[*:0]'),
            (['overlay'], '?[*:0]'),
            (['overlay_text'], '?[*:0]'),
            (['buf'], '?[*]'),
            (['Buf'], '?[*]'),

            ([EndsWith('id')], '?[*:0]'),
            ([EndsWith('label')], '?[*:0]'),
            ([EndsWith('str')], '?[*:0]'),
            ([Contains('format')], '?[*:0]'),
            ([Contains('name')], '?[*:0]'),
            ([Contains('Name')], '?[*:0]'),
            ([Contains('begin')], '?[*]'),
            ([Contains('end')], '?[*]'),
            ([EndsWith('data')], '?[*]'),

            (['ImGuiTextRange', Always()], '?[*]'),
            (['ImGuiTextRange_ImGuiTextRangeStr', Always()], '?[*]'),
        ]),
        (Always(), [
            ([Regex('ImGuiStorage_Get.*Ref'), 'return'], '?*')
        ]),
        ('float', [
            (['igColorPicker4', 'ref_col'], '?*[4]'),
            ([Regex('out_[rgbhsv]')], '*'),
        ]),
        ('int', [
            (['current_item'], '?*'),
        ]),
        ('unsigned int', [
            (['igCheckboxFlags', 'flags'], '?*'),
        ]),
        ('ImWchar', [
            (['ranges'], '?[*:0]'),
            (['glyph_ranges'], '?[*:0]'),
            (['GlyphRanges'], '?[*:0]'),
        ]),
        ('ImFontAtlas', [
            ([EndsWith('Atlas')], '?*'),
            ([EndsWith('atlas')], '?*'),
            (['ImGuiIO', 'Fonts'], '?*'),
        ]),
        ('ImVec2', [
            (['igIsMousePosValid', 'mouse_pos'], '*'),
            (['points'], '?[*]'),
        ]),
        ('ImVector', [
            ([Regex('ImVector_.*_swap'), 'rhs'], '*'),
        ]),
        ('T', [
            (['it'], '[*]'),
            (['it_last'], '[*]'),
            ([Regex('ImVector_.*_front(_const)?'), 'return'], '*'),
            ([Regex('ImVector_.*_back(_const)?'), 'return'], '*'),
            ([Regex('ImVector_.*_begin(_const)?'), 'return'], '[*]'),
            ([Regex('ImVector_.*_end(_const)?'), 'return'], '[*]'),
            ([Regex('ImVector_.*_find(_const)?'), 'return'], '[*]'),
            ([Regex('ImVector_.*_insert'), 'return'], '[*]'),
            ([Regex('ImVector_.*_erase(_unsorted|TPtr)?'), 'return'], '[*]'),
        ]),
        (StartsWith("Im"), [
            ([EndsWith('Ptr')], '?[*]'),
            (['igGetIO', 'return'], '*'),
            (['igGetDrawData', 'return'], '*'),
            ([Not(EndsWith('s'))], '?*'),
        ]),
        (Always(), [
            ([StartsWith('TexPixels')], '?[*]'),
            ([StartsWith('p_')], '?*'),
            ([StartsWith('v')], '*'),
            ([StartsWith('v_')], '*'),
            ([StartsWith('out_')], '*'),
        ]),
    ],
    2: [
        (Always(), [
            (['items_getter', '', 'out_text'], '*?[*:0]'),
            ([StartsWith('ImFontAtlas_GetTexData'), 'out_pixels'], '*?[*]'),
            (['ImDrawData', 'CmdLists'], '?[*]*'),
            (['ImFont_CalcTextSizeA', 'remaining'], '?*?[*:0]'),
            (['ImFont_CalcTextSizeA_nonUDT', 'remaining'], '?*?[*:0]'),
        ]),
    ],
}

def ruleMatches(rule, context):
    for matchValue in reversed(rule):
        if context is None or not (matchValue == context.name):
            return False
        context = context.parent
    return True

def getPointers(numPointers, valueType, context):
    ## Type-independent rules
    if numPointers == 1:
        if context.type == CT_TEMPLATE:
            return '*'
        if context.type == CT_PARAM and context.parent.stname and context.name == 'self':
            return '*'
        if context.type == CT_PARAM and context.name == 'pOut' and context.parent.name.endswith('_nonUDT'):
            return '*'
            
    ## Search for a matching rule
    rulesByDepth = Rules.get(numPointers)
    if rulesByDepth:
        for typeRules in rulesByDepth:
            if typeRules[0] == valueType:
                for rule in typeRules[1]:
                    if ruleMatches(rule[0], context):
                        return rule[1]
    
    print("no matching pointer rules for", repr(context), '*' * numPointers + valueType)
    pointers = ''
    for i in range(numPointers):
        pointers += '[*c]'
    return pointers
