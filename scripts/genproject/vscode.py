import json
import logging
import os
import subprocess
import sys
import argparse


def setup_argparse(parser):
    pass


def _dump_defines(binary, flags=[]):
    cmd = [binary]
    cmd.extend(flags)
    cmd.extend(['-dM', '-E', '-'])
    ret = subprocess.run(cmd,
                         stdin=subprocess.DEVNULL,
                         stdout=subprocess.PIPE,
                         check=True)
    defs = set()
    for line in ret.stdout.decode('utf-8').splitlines():
        _, _, line = line.partition(' ')
        name, _, value = line.partition(' ')
        if value:
            defs.add('{}={}'.format(name, value))
        else:
            defs.add(name)
    return defs


def _dump_search_paths(binary, flags=[]):
    cmd = [binary]
    cmd.extend(flags)
    cmd.extend(['-E', '-xc++', '-', '-v'])
    ret = subprocess.run(cmd,
                         stdin=subprocess.DEVNULL,
                         stdout=subprocess.DEVNULL,
                         stderr=subprocess.PIPE,
                         check=True)
    paths = set()
    inside = False
    for line in ret.stderr.decode('utf-8').splitlines():
        if line.startswith('#include <...> search starts here:'):
            inside = True
            continue
        if not inside or line.endswith('(framework directory)'):
            continue
        if line.startswith('End of search list.'):
            inside = False
            continue

        paths.add(line.strip())
    return paths


class _cflag:
    def __init__(self, name, has_arg=False, multiple_args=False):
        self.name = name
        self.has_arg = has_arg
        self.multiple_args = multiple_args


def _parse_flags(cflags, flags_list):
    cfp = argparse.ArgumentParser()
    for f in flags_list:
        action = 'append' if f.has_arg and f.multiple_args else \
                 'store' if f.has_arg else \
                 'store_true'
        cfp.add_argument('-{}'.format(f.name), action=action)
    x, _ = cfp.parse_known_args(cflags)

    flags = []
    for f in flags_list:
        v = x.__dict__[f.name]
        if v is None:
            continue
        if f.has_arg:
            if f.multiple_args:
                for z in v:
                    flags.extend(['-{}'.format(f.name), z])
            else:
                flags.extend(['-{}'.format(f.name), v])
        else:
            flags.append('-{}'.format(f.name))
    return flags


def _update_props(project, includes, defines):
    props = os.path.join(project.workspace_dir, '.vscode',
                         'c_cpp_properties.json')
    if not os.path.exists(props):
        logging.error(
            'file {} must exist. Launch vscode once and launch "C/Cpp: Edit Configurations..." task'.format(props))
        sys.exit(1)

    compiler = project.get_target_var('CC')
    cflags = project.get_target_var('GLOBAL_CFLAGS').split()
    known_flags = [
        _cflag('arch', has_arg=True),
        _cflag('isysroot', has_arg=True),
    ]
    flags = _parse_flags(cflags, known_flags)

    defs = _dump_defines(compiler, flags)
    defs.update(defines)
    incs = _dump_search_paths(compiler, flags)
    compiler_incs = set(incs)
    incs.update(includes)

    with open(props, 'r') as f:
        data = json.load(f)
        configs = data['configurations']
        for c in configs:
            c['includePath'] = sorted(incs)
            c['defines'] = sorted(defs)
            # c['browse']['path'] = sorted(['{}/*'.format(x) for x in incs])
            if 'browse' not in c:
                c['browse'] = {}
            c['browse']['path'] = ['${workspaceRoot}'] + \
                sorted(['{}/*'.format(x) for x in compiler_incs])
            c['compilerPath'] = '{} {}'.format(compiler, ' '.join(flags))
    with open(props, 'w') as f:
        json.dump(data, f, indent='\t')


def _single_task(label, command, *, default=False):
    task = {
        'label': label,
        'type': 'shell',
        'command': command,
        'problemMatcher': ['$gcc'],
    }
    if default:
        task['group'] = {'kind': 'build', 'isDefault': True}
    else:
        task['group'] = 'build'
    return task


def _package_tasks(name, build_args):
    bsh_fmt = '${{workspaceFolder}}/build.sh {} {}{}'
    return [
        _single_task(name, bsh_fmt.format(build_args, name, '')),
        _single_task('{}-clean'.format(name),
                     bsh_fmt.format(build_args, name, '-clean')),
        _single_task('{}-dirclean'.format(name),
                     bsh_fmt.format(build_args, name, '-dirclean')),
        _single_task('{}-codecheck'.format(name),
                     bsh_fmt.format(build_args, name, '-codecheck'))
    ]


def _gen_tasks(project, build_args, modules):
    args = ' '.join(build_args.split(' ')[:-1])  # remove trailing -A
    tasks_path = os.path.join(project.workspace_dir, '.vscode', 'tasks.json')
    with open(tasks_path, 'w') as f:
        data = {}
        data['version'] = '2.0.0'
        tasks = list()
        data['tasks'] = tasks
        tasks.append(_single_task(
            'full_build', '${{workspaceFolder}}/build.sh {} -t build -j/1'.format(args), default=True))
        tasks.append(_single_task(
            'clean', '${{workspaceFolder}}/build.sh {} -t clean'.format(args)))
        for name in modules:
            tasks.extend(_package_tasks(name, build_args))
        json.dump(data, f, indent='\t')


def generate(project):

    if len(project.modules) > 1 and not project.options.merge:
        logging.error(
            'Multiple modules selected. Please use "-merge" option !')
        sys.exit(1)

    defines = set()
    for k, v in project.defines_c.items():
        if v:
            defines.add('{}={}'.format(k, v.replace('\\\"', '\"')))
        else:
            defines.add(k)
    for k, v in project.defines_cxx.items():
        if v:
            defines.add('{}={}'.format(k, v.replace('\\\"', '\"')))
        else:
            defines.add(k)

    _update_props(project, project.includes, defines)
    _gen_tasks(project, project.build_args, sorted(project.modules))
