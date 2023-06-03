#!/usr/bin/env python3

import argparse
import glob
import os
import re
import subprocess
import sys

DEFAULT_PLATFORM = "gcc_64"

SDKROOT_PATTERNS = [
    "/opt/Qt*",
    "/opt/QT*",
    "/opt/qt*",
    "/Applications/Qt*",
    os.path.expanduser("~/Qt*"),
]

# Extracted from distutils.version that is deprecated and planned for removal
class LooseVersion:
    RE_COMPONENT = re.compile(r'(\d+ | [a-z]+ | \.)', re.VERBOSE)
    def __init__(self, vstring):
        self.vstring = vstring
        components = [x for x in self.RE_COMPONENT.split(vstring)
                if x and x != '.']
        for i, obj in enumerate(components):
            try:
                components[i] = int(obj)
            except ValueError:
                pass
        self.version = components

    def __eq__(self, other):
        c = self._cmp(other)
        return c if c is NotImplemented else c == 0

    def __lt__(self, other):
        c = self._cmp(other)
        return c if c is NotImplemented else c < 0

    def __le__(self, other):
        c = self._cmp(other)
        return c if c is NotImplemented else c <= 0

    def __gt__(self, other):
        c = self._cmp(other)
        return c if c is NotImplemented else c > 0

    def __ge__(self, other):
        c = self._cmp(other)
        return c if c is NotImplemented else c >= 0

    def _cmp (self, other):
        if isinstance(other, str):
            other = LooseVersion(other)
        elif not isinstance(other, LooseVersion):
            return NotImplemented

        if self.version == other.version:
            return 0
        if self.version < other.version:
            return -1
        if self.version > other.version:
            return 1

def find_qmake_in_sdk(sdk):
    qmake = os.path.join(sdk, "bin", "qmake")
    return qmake if os.path.exists(qmake) else ""


def find_qmake_in_sdk_root(sdkroot, options):
    # Get matching versions in reverse order to find highest one matching
    # the criteria
    matches = []
    for version in options.version.split(","):
        matches.extend([os.path.basename(x)
                for x in glob.glob(os.path.join(sdkroot, version + "*"))])
    matches.sort(key=LooseVersion, reverse=True)

    for match in matches:
        sdk = os.path.join(sdkroot, match, options.platform)
        qmake = find_qmake_in_sdk(sdk)
        if qmake: return qmake


def find_qmake_in_path():
    # Get smake binary in PATH
    try:
        qmake = subprocess.check_output(
                "which qmake",
                shell=True, universal_newlines=True).strip()
    except subprocess.SubprocessError:
        return ""
    return qmake


def check_qmake_version(qmake, version):
    # Get its actual version
    try:
        actual_version = subprocess.check_output(
                "%s -query QT_VERSION" % qmake,
                shell=True, universal_newlines=True).strip()
    except subprocess.SubprocessError:
        return False
    # Verify that it is compatible
    return any([LooseVersion(actual_version) >= LooseVersion(v)
            for v in version.split(",")])


def find_qmake(options):
    # Look in given SDK
    if options.sdk:
        qmake = find_qmake_in_sdk(options.sdk)
        if qmake: return qmake

    # Search in other default locations
    if options.version:
        # Look in given SDKROOT
        if options.sdkroot:
            qmake = find_qmake_in_sdk_root(options.sdkroot, options)
            if qmake: return qmake

        for pattern in SDKROOT_PATTERNS:
            for sdkroot in glob.glob(pattern):
                qmake = find_qmake_in_sdk_root(sdkroot, options)
                if qmake: return qmake

    # Finally, find qmake in PATH
    if not options.no_path:
        qmake = find_qmake_in_path()
        if qmake: return qmake

    return

def main():
    parser = argparse.ArgumentParser()

    parser.add_argument("--version",
        default="",
        help="Qt version to use")

    parser.add_argument("--platform",
        default="gcc_64",
        help="Qt platform to use")

    parser.add_argument("--sdk",
        default="",
        help="Qt sdk to use")

    parser.add_argument("--sdkroot",
        default="",
        help="Qt sdk root to use")

    parser.add_argument("--no-path",
        action="store_true",
        default=False,
        help="Do not look in PATH")

    options = parser.parse_args()

    qmake = find_qmake(options)
    if qmake and (not options.version or
            check_qmake_version(qmake, options.version)):
        print(qmake)
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
