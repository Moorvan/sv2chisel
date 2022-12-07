import argparse
import sys
from typing import *
import svinst
from svmodule.moddict import ModDict


# svinst fix
def process_syntax_tree(result):
    retval = []
    if result is None:
        return []
    for elem in result:
        if svinst.defchk.is_token(elem):
            retval.append(svinst.defchk.SyntaxToken(elem['Token'], elem['Line']))
        else:
            items = list(elem.items())
            if len(items) != 1:
                err_str = ''
                err_str += f'Expected dictionary of length 1, found:\n'
                err_str += svinst.defchk.pformat(elem, indent=2)
                raise Exception(err_str)
            retval.append(
                svinst.defchk.SyntaxNode(
                    items[0][0],
                    process_syntax_tree(items[0][1])
                )
            )
    return retval


def get_syntax_tree(files, includes=None, defines=None, ignore_include=False,
                    separate=False, show_macro_defs=False, explain_error=True):
    single = svinst.defchk.is_single_file(files)

    out = svinst.defchk.call_svinst(files=files, includes=includes, defines=defines,
                                    ignore_include=ignore_include, separate=separate,
                                    show_macro_defs=show_macro_defs, explain_error=explain_error,
                                    full_tree=True)

    retval = [process_syntax_tree(elem['syntax_tree']) for elem in out['files']]

    if single:
        retval = retval[0]

    return retval


class Port:
    def __init__(self, name: str, dir: str, width: int):
        self.name = name
        self.dir = dir
        self.width = width


class SV2Chisel:
    def __init__(self, file: str):
        self.file = file
        self.content = ""
        self.mods = self.getModulesFromFile()
        # for k in self.mods:
        #     print(k, self.mods[k])

    def getModulesFromFile(self) -> Dict[str, Tuple[int, int]]:
        with open(self.file, "r") as f:
            self.content = f.read()
        tree = get_syntax_tree(self.file)[0]
        names, lines = list[str](), list[int]()
        defs = svinst.get_defs(self.file)
        for d in defs:
            names.append(d.name)

        def dfs(cur):
            if not hasattr(cur, 'children'):
                lines.append(cur.line - 1)
                return
            dfs(cur.children[0])

        for mod in tree.children:
            dfs(mod)
        mods = dict[str, Tuple[int, int]]()
        for i in range(len(names) - 1):
            mods[names[i]] = (lines[i], lines[i + 1])
        mods[names[-1]] = (lines[-1], -1)
        return mods

    def getIODefinition(self, mod_name: str) -> List[Port]:
        if self.mods.get(mod_name) is None:
            raise ValueError("No such module")
        start, end = self.mods[mod_name]
        mod_content = getFileFromTo(self.file, start, end)
        m = ModDict()
        m.parse(mod_content)
        ports = m.parsed_module['ports']
        res = list[Port]()
        for p in ports:
            width = 1
            if p['packed'] != '':
                width = int(p['packed'].split(':')[0][1:]) + 1
            dir = 'Input' if p['direction'] == 'input' else 'Output'
            res.append(Port(p['name'], dir, width))
        return res

    def chiselGen(self, mod_name: str) -> str:
        IOs = self.getIODefinition(mod_name)
        res = f'class {mod_name} extends BlackBox with HasBlackBoxResource {{\n'
        res += f'  val io = IO(new Bundle {{\n'
        for p in IOs:
            t = 'Bool()' if p.width == 1 else f'UInt({p.width}.W)'
            res += f'    val {p.name} = {p.dir}({t})\n'
        res += f'  }})\n'
        res += f'  addResource("{self.file}")\n'
        res += f'}}\n'
        return res


def getFileFromTo(file: str, from_line, end_line: int) -> str:
    with open(file, 'r') as f:
        lines = f.readlines()
        if end_line == -1:
            return ''.join(lines[from_line:])
        return ''.join(lines[from_line:end_line])


def run(file, mod_name: str):
    gen = SV2Chisel(file)
    chisel = gen.chiselGen(mod_name)
    with open(f'{mod_name}.scala', 'w') as f:
        f.write(chisel)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('file', help='Verilog file')
    parser.add_argument('mod_name', help='Module name')
    args = parser.parse_args()
    file, mod_name = args.file, args.mod_name
    run(file, mod_name)


if __name__ == '__main__':
    main()
    # run('examples/Counter.sv', 'Counter2')
