#!/usr/bin/env python3

import argparse
import logging
import os
import subprocess
import sys

_IGNORE_LIST = [
    "clang-diagnostic-unused-parameter",
    "clang-diagnostic-double-promotion",
    "clang-diagnostic-reserved-identifier",
    "clang-diagnostic-reserved-macro-identifier",
    "cert-err33-c",
]


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


def main() -> None:
    parser = argparse.ArgumentParser()

    parser.add_argument("jsondb", help="compile_commands.json file")
    parser.add_argument("-o", "--output", help="output directory", default=".")
    parser.add_argument("-j", "--jobs", help="parallel jobs", default="1")
    parser.add_argument("-n", "--name", help="name of analysis")
    parser.add_argument("-r", "--root", help="root directory")

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

    _exec_cmd(
        f"CodeChecker analyze {options.jsondb}"
        f" --clean"
        f" --name {options.name}"
        + "".join([f" --disable {x}" for x in _IGNORE_LIST]) +
        f" --jobs {options.jobs}"
        f" --output {options.output}")

    _exec_cmd(
        f"CodeChecker parse {options.output}"
        f" --trim-path-prefix {options.root}"
        f" --export html"
        f" --output {options.output}")


if __name__ == "__main__":
    main()
