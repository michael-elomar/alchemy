#!/usr/bin/env python3

import argparse
import logging
import os
import subprocess
import sys

from re import match


_ANALYZE_OPTIONS_LIST =[
    # Delete analysis reports stored in the output directory.
    "--clean",

    # Perform Cross Translation Unit (CTU) analysis, both 'collect' and 'analyze' phases.
    "--ctu",

    # If Cross-TU analysis is enabled and fails for some reason, try to re analyze the same
    # translation unit without Cross-TU enabled.
    "--ctu-reanalyze-on-failure",

    # Filter out reports from files that were skipped from the analysis.
    "--drop-reports-from-skipped-files",

    # There are some implicit include paths which are only used by GCC (include-fixed).
    # This flag determines whether these should be kept among the implicit include paths.
    "--keep-gcc-include-fixed"
]

_DISABLE_LIST = []

_EXCLUDE_SUBDIRS_LIST = [".git", "docs", "host", "linux-sdk"]

_PRJ_PATH = os.path.join(os.getcwd(), "prj")

_SDK_USR_INCLUDE_PATH = os.path.join(os.getcwd(), "sdk", "usr", "include")


def _exec_cmd(cmd: str) -> None:
    """
    Execute command in current directory and ignore errors
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


def _export_cpath() -> None:
    cpath = os.environ["CPATH"].split(":") if os.getenv("CPATH") else []
    cwd = os.getcwd()

    cpath.append(_SDK_USR_INCLUDE_PATH)

    for subpath in [_PRJ_PATH, _SDK_USR_INCLUDE_PATH]:
        for root, dirs, files in os.walk(subpath, topdown=True):
            dirs[:] = [d for d in dirs if d not in _EXCLUDE_SUBDIRS_LIST]
            filtered_files = list(filter(lambda v: match('^.*(\.h|\.hpp)$', v), files))
            if not filtered_files:
                continue
            if subpath == _PRJ_PATH:
                cpath.append(root)
            elif subpath == _SDK_USR_INCLUDE_PATH \
                    and os.getenv("JKS_SAST_RUN_NAME_PREFIX") in os.path.basename(root) \
                    and os.path.basename(os.path.dirname(root)) == "gen":
                cpath.append(os.path.dirname(root))

    os.environ["CPATH"] = ":".join(cpath)


def main() -> None:
    parser = argparse.ArgumentParser()

    parser.add_argument("jsondb", help="compile_commands.json file")
    parser.add_argument("-o", "--output", help="output directory", default=".")
    parser.add_argument("-j", "--jobs", help="parallel jobs", default="1")
    parser.add_argument("-n", "--name", help="name of analysis")
    parser.add_argument("-r", "--root", help="root directory")
    parser.add_argument("-i",
        "--ignore",
        help="Path to the Skipfile dictating which project files should be omitted from analysis")

    options = parser.parse_args()

    logging.basicConfig(
        level=logging.WARNING,
        format="[%(levelname)s] %(message)s",
        stream=sys.stderr)
    logging.addLevelName(logging.CRITICAL, "C")
    logging.addLevelName(logging.ERROR, "E")
    logging.addLevelName(logging.WARNING, "W")
    logging.addLevelName(logging.INFO, "I")
    logging.addLevelName(logging.DEBUG, "D")
    logging.getLogger().setLevel(logging.INFO)

    analyze_options = " ".join(_ANALYZE_OPTIONS_LIST)
    analyze_disable = "".join([f" --disable {x}" for x in _DISABLE_LIST])
    analyze_ignore  = f" --ignore {options.ignore}" if options.ignore else ""

    _export_cpath()

    _exec_cmd(
        f"CodeChecker analyze {options.jsondb}"
        f" --name {options.name}"
        f" {analyze_options}"
        f" {analyze_disable}"
        f" {analyze_ignore}"
        f" --jobs {options.jobs}"
        f" --output {options.output}")

    _exec_cmd(
        f"CodeChecker parse {options.output}"
        f" --trim-path-prefix {options.root}"
        f" --export html"
        f" --output {options.output}")


if __name__ == "__main__":
    main()
