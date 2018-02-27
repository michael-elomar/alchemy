import json
import logging
import os
import subprocess
import sys

def setup_argparse(parser):
    pass

def _dump_defines(binary):
    ret = subprocess.run([binary, '-dM', '-E', '-'],
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

def _dump_search_paths(binary):
    ret = subprocess.run([binary, '-E', '-xc++', '-', '-v'],
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


def _update_props(project, includes, defines):
    props = os.path.join(project.workspace_dir, '.vscode', 'c_cpp_properties.json')
    if not os.path.exists(props):
        logging.error('file {} must exist. Launch vscode once and launch "C/Cpp: Edit Configurations..." task'.format(props))
        sys.exit(1)

    compiler = project.get_target_var('CC')

    defs = _dump_defines(compiler)
    defs.update(defines)
    incs = _dump_search_paths(compiler)
    compiler_incs = set(incs)
    incs.update(includes)

    with open(props, 'r') as f:
        data = json.load(f)
        configs = data['configurations']
        for c in configs:
            c['includePath'] = sorted(incs)
            c['defines'] = sorted(defs)
            #c['browse']['path'] = sorted(['{}/*'.format(x) for x in incs])
            c['browse']['path'] = ['${workspaceRoot}'] + sorted(['{}/*'.format(x) for x in compiler_incs])
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
        task['group'] = { 'kind': 'build', 'isDefault': True }
    else:
        task['group'] = 'build'
    return task

def _package_tasks(name, build_args):
    bsh_fmt = '${{workspaceFolder}}/build.sh {} {}{}'
    return [
        _single_task(name, bsh_fmt.format(build_args, name, '')),
        _single_task('{}-clean'.format(name), bsh_fmt.format(build_args, name, '-clean')),
        _single_task('{}-dirclean'.format(name), bsh_fmt.format(build_args, name, '-dirclean')),
        _single_task('{}-codecheck'.format(name), bsh_fmt.format(build_args, name, '-codecheck'))
    ]

def _gen_tasks(project, build_args, modules):
    _, product, _ = build_args.split(' ')
    tasks_path = os.path.join(project.workspace_dir, '.vscode', 'tasks.json')
    with open(tasks_path, 'w') as f:
        data = {}
        data['version'] = '2.0.0'
        tasks = list()
        data['tasks'] = tasks
        tasks.append(_single_task('full_build', '${{workspaceFolder}}/build.sh -p {} -t build -j/1'.format(product), default=True))
        tasks.append(_single_task('clean', '${{workspaceFolder}}/build.sh -p {} -t clean'.format(product)))
        for name in modules:
            tasks.extend(_package_tasks(name, build_args))
        json.dump(data, f, indent='\t')

def generate(project):

    if len(project.modules) > 1 and not project.options.merge:
        logging.error('Multiple modules selected. Please use "-merge" option !')
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
