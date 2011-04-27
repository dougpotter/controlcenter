''' Aml is a pre/post-processor for shpaml. It extends shpaml syntax
with shortcuts useful when shpaml output is a jinja template.

Aml module can be imported into a Python program and used as follows:
jinja_template_text = convert_text_aml(aml_template_text)

Alternatively, py can be invoked from the command line to perform
the conversion, as follows:

python py [-o output] [input]

If input is not specified or is - (dash), standard input is read.
If output is not specified or is -, processed text is written to
standard output.

Aml depends on other modules as follows:

shpaml does most of the work. It is patched at runtime so arbitrary
versions of it are unlikely to work.

runtime provides functions for hooking into modules, used to inject
code into shpaml at runtime.

filter provides command line argument handling. It is only used when
py is invoked from command line.

'''

import re

# Aml works with unmodified shpaml but certain versions may be required
# depending on shortcuts used since aml patches shpaml's code at runtime.
# A version of shpaml that is known to work is bundled with aml.
import sys
shpaml = sys.modules[__name__]

class IndentError(ValueError):
    ''' Raised when text given to aml uses tabs for indentation.
    
    Mixing tabs and spaces in aml templates can have disastrous consequences,
    therefore indenting with tabs is prohibited.
    '''

class NotConfiguredError(ValueError):
    ''' Raised when attempting to convert text with aml without first
    choosing template engine and whitespace removal options.'''

class AlreadyConfiguredError(ValueError):
    ''' Raised when attempting to configure aml more than once per process.
    
    Since aml runtime-patches shpaml, a single process may have only one
    aml configuration.
    '''

def configure(template_engine, remove_whitespace=True):
    if configuration.configured:
        raise AlreadyConfiguredError
    
    template_engine.install()
    configuration.active_shortcuts = template_engine
    
    if remove_whitespace:
        WhitespaceRemoval.install()
        configuration.active_shortcuts.POST_TRANSLATORS = \
            configuration.active_shortcuts.POST_TRANSLATORS_WITHOUT_WHITESPACE
    
    configuration.configured = True

def convert_text_aml(text):
    ''' Converts text to html. Text must be in aml template format (at).
    
    Aml templates are mostly comprised of shpaml syntax with shortcuts
    added for jinja. Please refer to install_jinja_shortcuts for syntax
    details.
    
    Whitespace removal is enabled; please refer to install_whitespace_removal
    for details on what whitespace is removed. Whitespace removal is not
    necessary to generate valid html from aml templates.
    
    Whitespace removal is an experimental feature.
    
    Indentation in aml is significant, and only spaces are allowed for
    indentation. If tabs are found in text at the beginning of any lines,
    IndentError will be raised.
    '''
    
    if not configuration.configured:
        raise NotConfiguredError
    
    text = configuration.active_shortcuts.convert_text_pre(text)
    text = convert_text_shpaml(text)
    text = configuration.active_shortcuts.convert_text_post(text)
    return text

# Only implementation is beyond this point.

class Configuration:
    def __init__(self):
        self.configured = False
        self.active_shortcuts = None

configuration = Configuration()

TAB_INDENT = re.compile(r'^ *\t', re.M)

def fixup(regex, flags, replacement):
    if flags is not None:
        options = [flags]
    else:
        options = []
    regex = re.compile(regex, *options)
    return (regex, replacement)

class ShortcutsBase:
    active_post_translators = None
    
    @classmethod
    def convert_text_pre(cls, text):
        ''' Performs pre-processing pass on text before handing it off to shpaml.
        
        First, indentation is checked and if tabs are used for indentation
        IndentError is raised.
        
        Then, jinja shortcuts in text are replaced with expanded equivalents.
        '''
        
        if TAB_INDENT.search(text):
            raise IndentError('Text uses tabs for indentation')
        
        for translator in cls.PRE_TRANSLATORS:
            text = translator[0].sub(translator[1], text)
        
        return text
    
    @classmethod
    def convert_text_post(cls, text):
        ''' Performs post-processing pass on text after it is processed by shpaml.
        
        Post-processing fixes up things like if/endif/else/endelse into if/else/endif.'
        '''
        
        for translator in cls.POST_TRANSLATORS:
            text = translator[0].sub(translator[1], text)
        
        return text
HTML_COMMENT_SYNTAX = '<!-- %s -->'

def parse_arguments():
    ''' Parses options and arguments for filter scripts.
    
    Without arguments, converts stdin to stdout.
    With a single argument converts specified filename to stdout,
    unless filename is - in which case stdin is converted.
    Accepts one option, -o output-file which causes output
    to be written to output-file instead of stdout.
    
    Returns a tuple (input, output) where input is None
    to use standard input or file name, and output is None
    to use standard output or file name.
    '''
    
    import optparse
    
    usage = 'Usage: %prog [options] [input-file]'
    parser = optparse.OptionParser(usage=usage)
    parser.add_option('-o', '--output', metavar='FILE',
        help='Write output to FILE')
    parser.add_option('-g', '--generated-warning', action='store_true',
        help='Add generated file warning to output')
    parser.add_option('-c', '--comment-syntax', metavar='FORMAT',
        help='Comment syntax to use (e.g. "<!-- %s -->" for HTML comments, which is the default). %s will be replaced with comment text. Literal percent signs should be doubled like so: %%')
    
    options, args = parser.parse_args()
    
    # if file name is given convert file, else convert stdin.
    # - is alias for stdin.
    if len(args) == 1:
        input = args[0]
        if input == '-':
            input = None
    elif len(args) == 0:
        input = None
    else:
        parser.print_help()
        exit(2)
    
    # allow - as alias for stdout.
    output = options.output
    if output == '-':
        output = None
    
    return (input, output, options)

def perform_conversion(convert_func, forward_arguments=False, pass_input_name=False):
    ''' Converts text in input file or standard input using
    convert_func and writes results to output file or
    standard output as specified by program options.
    
    Options are parsed with parse_arguments.
    
    If forward_arguments is False (default), convert_func
    should be a function accepting a single string argument
    and returning a string.
    
    If forward_arguments is True, convert_func should be a
    function accepting a string positional argument and
    input and output keyword arguments. input and output
    will be set to None or file names if provided by user.
    
    If pass_input_name is True, input file is not opened.
    Instead its name (either None for standard input or
    file name or path specified by user) is given to
    convert_func. If forward_arguments is True, convert_func
    is also given an output keyword argument.
    '''
    
    import sys
    
    input, output, options = parse_arguments()
    
    if pass_input_name:
        if forward_arguments:
            output_text = convert_func(input, output=output)
        else:
            output_text = convert_func(input)
    else:
        if input is None:
            input_text = sys.stdin.read()
        else:
            f = open(input)
            try:
                input_text = f.read()
            finally:
                f.close()
        
        if forward_arguments:
            output_text = convert_func(input_text, input=input, output=output)
        else:
            output_text = convert_func(input_text)
    
    assert output_text, "convert_func did not return anything to perform_conversion"
    
    if options.generated_warning:
        comment_syntax = options.comment_syntax or HTML_COMMENT_SYNTAX
        warning = comment_syntax % 'Generated file - DO NOT EDIT' + "\n"
        if input is not None:
            warning += comment_syntax % ('Created from: %s' % input) + "\n"
        output_text = warning + output_text
    
    if output is None:
        sys.stdout.write(output_text)
    else:
        f = open(output, 'w')
        try:
            f.write(output_text)
        finally:
            f.close()
import sys

def hook_module_function(module, function_name, replacement_function):
    ''' Hooks a function in designated module.
    
    function with function_name in specified module will be replaced with
    replacement_function. replacement_function should accept original
    function object plus the same arguments that original function accepts.
    
    module can be a module name, which must then be importable, or a
    module object.
    '''
    
    if isinstance(module, basestring):
        __import__(module)
        module = sys.modules[module]
    function = getattr(module, function_name)
    def hooked(*args, **kwargs):
        return replacement_function(function, *args, **kwargs)
    setattr(module, function_name, hooked)
import re

__version__ = '0.99b'

def convert_text_shpaml(in_body):
    '''
    You can call convert_text_shpaml directly to convert shpaml markup
    to HTML markup.
    '''
    return convert_shpaml_tree(in_body)

PASS_SYNTAX = 'PASS'
FLUSH_LEFT_SYNTAX = '|| '
FLUSH_LEFT_EMPTY_LINE = '||'
TAG_WHITESPACE_ATTRS = re.compile('(\S+)([ \t]*?)(.*)')
TAG_AND_REST = re.compile(r'((?:[^ \t\.#]|\.\.)+)(.*)')
CLASS_OR_ID = re.compile(r'([.#])((?:[^ \t\.#]|\.\.)+)')
COMMENT_SYNTAX = re.compile(r'^::comment$')

DIV_SHORTCUT = re.compile(r'^(?:#|(?:\.(?!\.)))')

quotedText = r"""(?:(?:'(?:\\'|[^'])*')|(?:"(?:\\"|[^"])*"))"""
AUTO_QUOTE = re.compile("""([ \t]+[^ \t=]+=)(""" + quotedText + """|[^ \t]+)""")
def AUTO_QUOTE_ATTRIBUTES(attrs):
    def _sub(m):
        attr = m.group(2)
        if attr[0] in "\"'":
            return m.group(1) + attr
        return m.group(1) + '"' + attr + '"'
    return re.sub(AUTO_QUOTE, _sub,attrs)

def syntax(regex):
    def wrap(f):
        f.regex = re.compile(regex)
        return f
    return wrap

@syntax('([ \t]*)(.*)')
def INDENT(m):
    prefix, line = m.groups()
    line = line.rstrip()
    if line == '':
        prefix = ''
    return prefix, line

@syntax('^([<{]\S.*)')
def RAW_HTML(m):
    return m.group(1).rstrip()

@syntax('^\| (.*)')
def TEXT(m):
    return m.group(1).rstrip()

@syntax('(.*?) > (.*)')
def OUTER_CLOSING_TAG(m):
    tag, text = m.groups()
    text = convert_line(text)
    return enclose_tag(tag, text)

@syntax('(.*?) \| (.*)')
def TEXT_ENCLOSING_TAG(m):
    tag, text = m.groups()
    return enclose_tag(tag, text)

@syntax('> (.*)')
def SELF_CLOSING_TAG(m):
    tag = m.group(1).strip()
    return '<%s />' % apply_jquery(tag)[0]

@syntax('(.*)')
def RAW_TEXT(m):
    return m.group(1).rstrip()

LINE_METHODS = [
        RAW_HTML,
        TEXT,
        OUTER_CLOSING_TAG,
        TEXT_ENCLOSING_TAG,
        SELF_CLOSING_TAG,
        RAW_TEXT,
        ]


def convert_shpaml_tree(in_body):
    return indent(in_body,
            branch_method=html_block_tag,
            leaf_method=convert_line,
            pass_syntax=PASS_SYNTAX,
            flush_left_syntax=FLUSH_LEFT_SYNTAX,
            flush_left_empty_line=FLUSH_LEFT_EMPTY_LINE,
            indentation_method=find_indentation)

def html_block_tag(output, block, recurse):
    append = output.append
    prefix, tag = block[0]
    if RAW_HTML.regex.match(tag):
        append(prefix + tag)
        recurse(block[1:])
    elif COMMENT_SYNTAX.match(tag):
        pass
    else:
        start_tag, end_tag = apply_jquery_sugar(tag)
        append(prefix + start_tag)
        recurse(block[1:])
        append(prefix + end_tag)

def convert_line(line):
    prefix, line = find_indentation(line.strip())
    for method in LINE_METHODS:
        m = method.regex.match(line)
        if m:
            return prefix + method(m)

def apply_jquery_sugar(markup):
    if DIV_SHORTCUT.match(markup):
        markup = 'div' + markup
    start_tag, tag = apply_jquery(markup)
    return ('<%s>' % start_tag, '</%s>' % tag)

def apply_jquery(markup):
    tag, whitespace, attrs = TAG_WHITESPACE_ATTRS.match(markup).groups()
    tag, rest = tag_and_rest(tag)
    ids, classes = ids_and_classes(rest)
    attrs = AUTO_QUOTE_ATTRIBUTES(attrs)
    if classes:
        attrs += ' class="%s"' % classes
    if ids:
        attrs += ' id="%s"' % ids
    start_tag = tag + whitespace + attrs
    return start_tag, tag

def ids_and_classes(rest):

    if not rest: return '', ''

    ids = []
    classes=[];

    def _match(m):
        if m.group(1) == '#':
            ids.append(m.group(2))
        else:
            classes.append(m.group(2))

    CLASS_OR_ID.sub(_match, rest)
    return jfixdots(ids), jfixdots(classes)

def jfixdots(a): return fixdots(' '.join(a))
def fixdots(s): return s.replace('..', '.')


def tag_and_rest(tag):
    m = TAG_AND_REST.match(tag)
    if m:
        return fixdots(m.group(1)), m.group(2)
    else:
        return fixdots(tag), None

def enclose_tag(tag, text):
    start_tag, end_tag = apply_jquery_sugar(tag)
    return start_tag + text + end_tag

def find_indentation(line):
    return INDENT(INDENT.regex.match(line))

############ Generic indentation stuff follows

def get_indented_block(prefix_lines):
    prefix, line = prefix_lines[0]
    len_prefix = len(prefix)
    i = 1
    while i < len(prefix_lines):
        new_prefix, line = prefix_lines[i]
        if line and len(new_prefix) <= len_prefix:
            break
        i += 1
    while i-1 > 0 and prefix_lines[i-1][1] == '':
        i -= 1
    return i

def indent(text,
            branch_method,
            leaf_method,
            pass_syntax,
            flush_left_syntax,
            flush_left_empty_line,
            indentation_method,
            get_block = get_indented_block,
            ):
    text = text.rstrip()
    lines = text.split('\n')
    output = []
    indent_lines(
            lines,
            output,
            branch_method,
            leaf_method,
            pass_syntax,
            flush_left_syntax,
            flush_left_empty_line,
            indentation_method,
            get_block = get_indented_block,
            )
    return '\n'.join(output) + '\n'

def indent_lines(lines,
            output,
            branch_method,
            leaf_method,
            pass_syntax,
            flush_left_syntax,
            flush_left_empty_line,
            indentation_method,
            get_block,
            ):
    append = output.append
    def recurse(prefix_lines):
        while prefix_lines:
            prefix, line = prefix_lines[0]
            if line == '':
                prefix_lines.pop(0)
                append('')
            else:
                block_size = get_block(prefix_lines)
                if block_size == 1:
                    prefix_lines.pop(0)
                    if line == pass_syntax:
                        pass
                    elif line.startswith(flush_left_syntax):
                        append(line[len(flush_left_syntax):])
                    elif line.startswith(flush_left_empty_line):
                        append('')
                    else:
                        append(prefix + leaf_method(line))
                else:
                    block = prefix_lines[:block_size]
                    prefix_lines = prefix_lines[block_size:]
                    branch_method(output, block, recurse)
        return
    prefix_lines = list(map(indentation_method, lines))
    recurse(prefix_lines)

import sys

shpaml = sys.modules[__name__]

class TextWithoutWhitespace(unicode):
    ''' Part of template that does not need whitespace.
    
    Whitespace removal assumes that:
    
    1. Whitespace can be removed between block tags and their children, and
    
    2. Leading whitespace on the lines of template instructions occupying entire lines
       can be removed.
    
    TextWithoutWhitespace is a marker class that propagates whitespace removal
    status of lines from which whitespace can be removed across string concatenations.
    '''

class WhitespaceRemoval:
    @classmethod
    def install(cls):
        ''' Installs smart whitespace removal logic.
        
        Shpaml provides for two syntaxes for putting text inside tags:
        
        a href=foo
            bar
        
        generates:
        
        <a href="foo">
            bar
        </a>
        
        and
        
        a href=foo |bar
        
        generates:
        
        <a href="foo">bar</a>
        
        "bar" in this example can become quite complex if a template engine
        is used and it is actually an expression. Furthermore jinja shortcuts
        above work on line level only.
        
        Whitespace removal allows this markup:
        
        a href=foo
            ~ bar
        
        to be converted to:
        
        <a href="foo">{% trans %}bar{% endtrans %}</a>
        
        instead of:
        
        <a href="foo">
            {% trans %}bar{% endtrans %}
        </a>
        
        The assumption is that whitespace can always be removed between a block
        tag and its children.
        
        Nested tags behave as expected:
        
        ul
            li
                a href=foo
                    bar
        
        generates:
        
        <ul><li><a href="foo">bar</a></li></ul>
        
        Significant whitespace may be emitted via tools provided by template
        engine, for example:
        
        a href=foo
            = ' bar'
        
        If whitespace removal is installed, leading whitespace on lines containing
        only template instructions (% shortcut) or that start with block tags will
        also be removed.
        '''
        
        class StartBlockTag(TextWithoutWhitespace):
            pass
        
        class EndBlockTag(TextWithoutWhitespace):
            pass
        
        class Line(TextWithoutWhitespace):
            pass
        
        def convert_line_with_whitespace_removal(convert_line_without_whitespace_removal, line):
            line = convert_line_without_whitespace_removal(line)
            return Line(line)
        
        def apply_jquery_sugar_with_whitespace_removal(apply_jquery_sugar_without_whitespace_removal, markup):
            start_tag, end_tag = apply_jquery_sugar_without_whitespace_removal(markup)
            return (StartBlockTag(start_tag), EndBlockTag(end_tag))
        
        class Indentation(unicode):
            def __add__(self, other):
                if isinstance(other, TextWithoutWhitespace):
                    return other
                else:
                    return unicode.__add__(self, other)
        
        def indent_lines_with_whitespace_removal(
            indent_lines_without_whitespace_removal,
            lines,
            output,
            branch_method,
            leaf_method,
            pass_syntax,
            flush_left_syntax,
            flush_left_empty_line,
            indentation_method,
            get_block,
        ):
            # output is modified
            indent_lines_without_whitespace_removal(
                lines,
                output,
                branch_method,
                leaf_method,
                pass_syntax,
                flush_left_syntax,
                flush_left_empty_line,
                indentation_method,
                get_block,
            )
            
            # need to modify output in place
            copy = list(output)
            while len(output) > 0:
                output.pop()
            while len(copy) > 1:
                first, second = copy[:2]
                if len(copy) >= 3:
                    third = copy[2]
                else:
                    third = None
                if isinstance(second, EndBlockTag):
                    if isinstance(third, EndBlockTag):
                        copy[1] = EndBlockTag(second + third)
                        copy.pop(2)
                    else:
                        output.append(first + second)
                        copy.pop(0)
                        copy.pop(0)
                elif isinstance(first, StartBlockTag):
                    cls = second.__class__
                    copy[0] = cls(first + second)
                    copy.pop(1)
                else:
                    output.append(first)
                    copy.pop(0)
            if len(copy) > 0:
                output.append(copy[0])
        
        def find_indentation_with_whitespace_removal(find_indentation_without_whitespace_removal, line):
            prefix, line = find_indentation_without_whitespace_removal(line)
            return (Indentation(prefix), line)
        
        hook_module_function(shpaml, 'convert_line', convert_line_with_whitespace_removal)
        hook_module_function(shpaml, 'apply_jquery_sugar', apply_jquery_sugar_with_whitespace_removal)
        hook_module_function(shpaml, 'indent_lines', indent_lines_with_whitespace_removal)
        hook_module_function(shpaml, 'find_indentation', find_indentation_with_whitespace_removal)
import re
import sys
shpaml = sys.modules[__name__]

class ErbShortcuts(ShortcutsBase):
    LINE_STATEMENT = fixup(r'^(\s*)%(\s*)(.*)$', re.M, r'\1<%\2\3\2%>')
    LINE_EXPRESSION = fixup(r'^(\s*)=(\s*)(.*)$', re.M, r'\1<%=\2\3\2%>')
    SELF_CLOSING_TAG = fixup(r'^(\s*)>(?=\w)', re.M, r'\1> ')
    END_ELSE = fixup(r'^(\s*)<%\s*end\s*%>\n(\1<%\s*else\s*%>)', re.M, r'\2')
    END_ELSE_WITHOUT_WHITESPACE = fixup(r'<%\s*end\s*%>\n(<%\s*else\s*%>)', None, r'\1')

    PRE_TRANSLATORS = [
        LINE_STATEMENT,
        LINE_EXPRESSION,
        SELF_CLOSING_TAG,
    ]

    POST_TRANSLATORS = [
        END_ELSE,
    ]
    
    POST_TRANSLATORS_WITHOUT_WHITESPACE = [
        END_ELSE_WITHOUT_WHITESPACE,
    ]
    
    @classmethod
    def install(cls):
        ''' Installs various shortcuts intended to be used with Embedded Ruby (ERb) templates.
        
        Specifically, allows for the following markup in templates:
        
        1. Automatic generation of appropriate closing tags for template instructions:
        
        % if
            ...
        % else
            ...
        
        2. '% stmt' shortcut as a replacement for '<% stmt %>', and corresponding
           shpaml-style self-closing tag:
        
        % for post in @posts
            ...
        
        % >content_for :foo do
        
        3. '>tag' is equivalent to '> tag'.
        
        4. '= expression' is equivalent to '<%= expression %>'
        '''
        
        @shpaml.syntax(r'<% > *((\w+).*)')
        def SELF_CLOSING_TEMPLATE_STATEMENT(m):
            tag = m.group(1).strip()
            return '<%% %s<%% end %%>' % (m.group(1))
        
        shpaml.LINE_METHODS.insert(0, SELF_CLOSING_TEMPLATE_STATEMENT)
        
        TEMPLATE_STATEMENT = re.compile(r'<% (\w+)')
        
        def html_block_tag_with_template_statement(html_block_tag_without_template_statement, output, block, recurse):
            append = output.append
            prefix, tag = block[0]
            if shpaml.RAW_HTML.regex.match(tag):
                match = TEMPLATE_STATEMENT.match(tag)
                if match:
                    append(prefix + TextWithoutWhitespace(tag))
                    recurse(block[1:])
                    append(prefix + TextWithoutWhitespace('<% end %>'))
                    return
            html_block_tag_without_template_statement(output, block, recurse)
        
        hook_module_function(shpaml, 'html_block_tag', html_block_tag_with_template_statement)

configure(ErbShortcuts)
convert_text = convert_text_aml


if __name__ == "__main__":
    perform_conversion(convert_text)
