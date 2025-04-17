#!/usr/bin/env python3

import argparse
import json
import logging
import os
import re
import subprocess
import sys


_ANALYZE_OPTIONS_LIST = [
    # Delete analysis reports stored in the output directory.
    "--clean",

    # Perform Cross Translation Unit (CTU) analysis, both 'collect' and 'analyze' phases.
    "--ctu",

    # Filter out reports from files that were skipped from the analysis.
    "--drop-reports-from-skipped-files",

    # There are some implicit include paths which are only used by GCC (include-fixed).
    # This flag determines whether these should be kept among the implicit include paths.
    "--keep-gcc-include-fixed"
]

_CLANG_OPTIONS_REPLACEMENT_MAP = {
    '--sysroot /': '--sysroot=/',
    '-include -f': '-f',
    '-include -Wa,': '-Wa,',
    '-include -D': '-D',
    '-include -g': '-g',
    '-include -std': '-std',
    '-include -o': '',
    '-fdump-preamble': '',
    '-fexpensive-optimizations': ''
}

_DISABLE_LIST = []

_EXCLUDE_SUBDIRS_LIST = [".git", "docs", "host"]


_PRJ_PATH = os.path.join(os.getcwd(), "prj")

_OUT_PATH = os.path.join(os.getcwd(), "out")

_SDK_USR_PATH = os.path.join(os.getcwd(), "sdk", "usr")

_SDK_HOST_USR_PATH = os.path.join(os.getcwd(), "sdk", "host", "usr")


_QCOM_LLVM_BIN_PATH = os.path.join("/", "opt", "qcom", "llvm-arm-toolchain", "10.0", "bin")

_JENKINS_LOCAL_BIN_PATH = os.path.join(os.getenv("HOME"), ".local", "bin")


#===============================================================================
#===============================================================================
def _exec_cmd(cmd: str) -> None:
    """
    Execute command in current directory and ignore errors.
    """
    cwd = os.getcwd()
    logging.info("In '%s': %s", cwd, cmd)

    # Detect windows platform to force using msys shell (through 'sh')
    # instead of default shell (cmd.exe)
    try:
        if sys.platform == "win32":
            process = subprocess.Popen(f"sh -c '{cmd}'", cwd=cwd, shell=False)
        else:
            process = subprocess.Popen(cmd, cwd=cwd, shell=True)
        process.wait()
        if process.returncode != 0:
            logging.warning(f"Command failed (ret={process.returncode})")
    except OSError as ex:
        logging.error(f"Exception caught ([err={ex.errno}] {ex.strerror})")
        sys.exit(1)


#===============================================================================
#===============================================================================
def _export_cpath() -> None:
    """
    Export CPATH env variable to include project and SDK directories that contain headers
    as part of the cross-translation unit analysis.
    """
    cpath = os.environ["CPATH"].split(":") if os.getenv("CPATH") else []
    cwd = os.getcwd()

    cpath.append(os.path.join(_SDK_USR_PATH, "include"))
    cpath.append(os.path.join(_SDK_HOST_USR_PATH, "include"))

    for subpath in [_PRJ_PATH, _SDK_USR_PATH]:

        for root, dirs, files in os.walk(subpath, topdown=True):
            dirs[:] = [d for d in dirs if d not in _EXCLUDE_SUBDIRS_LIST]
            filtered_files = list(filter(lambda v: re.match('^.*(\.h|\.hpp)$', v), files))
            if not filtered_files:
                continue

            # add subfolders under prj/
            if subpath == _PRJ_PATH:
                cpath.append(root)
                continue

            if subpath != _SDK_USR_PATH:
                continue

            # add subfolders containing headers under sdk/usr/
            if os.path.basename(os.path.dirname(root)) in ["config", "gen", "generated"]:
                cpath.append(os.path.dirname(root))
                continue

            root_relpath = root.replace(_SDK_USR_PATH, '')

            res = re.match("^(.*/include).*$", root_relpath)
            if res and res.group(1):
                include_path = res.group(1)[1:] if res.group(1).startswith('/') else res.group(1)
                cpath.append(os.path.join(_SDK_USR_PATH, include_path))

    os.environ["CPATH"] = ":".join(list(set(cpath)))


#===============================================================================
#===============================================================================
def _resolve_clang() -> None:
    """
    Determine which 'clang' binary we want to use for the 'CodeChecker analyze'
    command, depending of the build target and current environment.

    In case of yocto/qrb5165, we want to use the 'clang' binary provided by the
    qcom toolchain as it supports extra flags that the standard LLVM one doesn't
    (e.g. -fdump-preamble).
    """
    if os.getenv("TARGET_OS_FLAVOUR") == "yocto" \
            and os.getenv("TARGET_CPU") == "qrb5165" \
            and os.path.isdir(_QCOM_LLVM_BIN_PATH):

        os.makedirs(_JENKINS_LOCAL_BIN_PATH, exist_ok=True)
        os.environ["PATH"] = f"{_JENKINS_LOCAL_BIN_PATH}:{os.getenv('PATH')}"

        clang_binaries = [f for f in os.listdir(_QCOM_LLVM_BIN_PATH) if re.match(r'^clang.*', f)]

        for clangbin in clang_binaries:
            if os.path.islink(os.path.join(_JENKINS_LOCAL_BIN_PATH, clangbin)):
                os.unlink(os.path.join(_JENKINS_LOCAL_BIN_PATH, clangbin))

            os.symlink(os.path.join(_QCOM_LLVM_BIN_PATH, clangbin),
                os.path.join(_JENKINS_LOCAL_BIN_PATH, clangbin))


#===============================================================================
#===============================================================================
def _get_autoconf_headers() -> list:
    autoconf_headers = []

    for root, dirs, files in os.walk(_OUT_PATH, topdown=True):
        filtered_files = list(filter(lambda v: re.match('^autoconf-.*\.h$', v), files))
        if filtered_files:
            autoconf_headers.append(os.path.join(root, filtered_files[0]))

    return autoconf_headers


#===============================================================================
#===============================================================================
def _format_command(command_attr: str) -> str:
    autoconf_headers_str = ' '.join([f"-include {h}" for h in _get_autoconf_headers()])

    for option, replacement in _CLANG_OPTIONS_REPLACEMENT_MAP.items():
        command = command_attr
        if re.search(option, command):
            # replace error-prone option with a valid substitute or empty string
            command_attr = re.sub(option, replacement, command)

    command = command_attr
    if re.findall(r"-D.*=\\\"(.*(\.h|\.hpp))\\\" ", command):
        # -D variable with header value found: needs proper <> surroundings
        command_attr = re.sub(r"-D(.*)=\\\"(.*(\.h|\.hpp))\\\" ", r'-D\1="<\2>" ', command)

    command = command_attr
    if re.search("--sysroot", command):
        # add required autoconf headers
        command_attr = re.sub(r"(.*)(--\bsysroot\b.*)", r"\1 {} \2".format(autoconf_headers_str), command)

    command = command_attr
    std_flags = re.findall(r"-std=(c\++\d(\d|x))", command)
    if std_flags:
        # use highest std flag
        std_flags.sort()
        highest_std_flag = std_flags[-1]
        command_attr = re.sub(r"-std=(c\++\d(\d|x))", r"-std={}".format(highest_std_flag[0]), command)

    return command_attr


#===============================================================================
#===============================================================================
def _format_file(file_attr: str) -> str:
    files = file_attr.split(' ')
    if len(files) <= 1:
        return file_attr

    for filename in files:
        if filename.endswith('.h'):
            continue
        file_attr = filename
        break

    return file_attr


#===============================================================================
#===============================================================================
def _validate_jsondb(jsondb_filepath: str) -> None:
    """
    Parse json DB file and override the clang commands containing specific error-prone options.
    """
    if not jsondb_filepath or not os.path.isfile(jsondb_filepath):
        return

    jsondb_data = None
    with open(jsondb_filepath, 'r') as f:
        jsondb_data = json.load(f)
        for entry in jsondb_data:

            # format 'command' attr of current jsondb entry
            if "command" in entry and entry["command"]:
                entry["command"] = _format_command(entry["command"])

            # format 'file' attr of current jsondb entry
            if "file" in entry and entry["file"]:
                entry["file"] = _format_file(entry["file"])

    if jsondb_data:
        logging.warning(f"Overriding {jsondb_filepath} file with validated clang commands...")
        with open(jsondb_filepath, 'w', encoding='utf-8') as f:
            json.dump(jsondb_data, f, ensure_ascii=False, indent=4)


#===============================================================================
# Parse command line arguments and return options.
#===============================================================================
def _parse_args() -> dict:
    parser = argparse.ArgumentParser()

    parser.add_argument("jsondb", help="json compilation database file")
    parser.add_argument("-o", "--output", help="output directory", default=".")
    parser.add_argument("-j", "--jobs", help="parallel jobs", default="1")
    parser.add_argument("-n", "--name", help="name of analysis")
    parser.add_argument("-r", "--root", help="root directory")
    parser.add_argument("-i", "--ignore",
        help="Path to the Skipfile dictating which project files should be omitted from analysis")

    return parser.parse_args()


#===============================================================================
# Setup logging system with given options.
#===============================================================================
def _setup_log(options: dict) -> None:
    logging.basicConfig(level=logging.WARNING, format="[%(levelname)s] %(message)s", stream=sys.stderr)
    logging.addLevelName(logging.CRITICAL, "C")
    logging.addLevelName(logging.ERROR, "E")
    logging.addLevelName(logging.WARNING, "W")
    logging.addLevelName(logging.INFO, "I")
    logging.addLevelName(logging.DEBUG, "D")
    logging.getLogger().setLevel(logging.INFO)


#===============================================================================
#===============================================================================
def main() -> None:
    options = _parse_args()
    _setup_log(options)

    _export_cpath()
    _resolve_clang()

    alchemy_home = os.getenv("ALCHEMY_HOME", os.path.join(options.root, "alchemy"))
    alchemy_target_out = os.getenv("ALCHEMY_TARGET_OUT", os.path.join(options.root, "out"))

    analyze_options = " ".join(_ANALYZE_OPTIONS_LIST)
    analyze_disable = "".join([f" --disable {x}" for x in _DISABLE_LIST])
    analyze_ignore  = f" --ignore {options.ignore}" if options.ignore else ""

    if not os.path.isfile(options.jsondb):
        logging.info("Generating Alchemy compilation database in JSON format...")
        _exec_cmd(
            f"{alchemy_home}/scripts/genproject/genproject.py"
            f" jsondb"
            f" {alchemy_target_out}/alchemy-database.xml"
            f" prj"
            f" --merge"
            f" --name {options.name}"
            f" --recursive"
            f" --output {alchemy_target_out}")

    _validate_jsondb(options.jsondb)

    logging.info("Starting 'CodeChecker analyze' command...")
    _exec_cmd(
        f"CodeChecker analyze {options.jsondb}"
        f" --name {options.name}"
        f" {analyze_options}"
        f" {analyze_disable}"
        f" {analyze_ignore}"
        f" --jobs {options.jobs}"
        f" --output {options.output}")

    logging.info("Starting 'CodeChecker parse' command...")
    _exec_cmd(
        f"CodeChecker parse {options.output}"
        f" --trim-path-prefix {options.root}"
        f" --export html"
        f" --output {options.output}")


#===============================================================================
#===============================================================================
if __name__ == "__main__":
    main()
