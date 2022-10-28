#!/bin/bash

check_version ()
{
    printf "$1\n$2\n" | sort --reverse --version-sort --check=silent && printf "1"
}

lookup_11_or_higher ()
{
    # Find oldest clang-format available, but matching minimum requirement
    OLD_IFS=$IFS
    IFS=":"

    find ${PATH} -name 'clang-format-*' 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)*)?$' | sort -V | uniq | while read v ; do
        if [ "$(check_version $v 11)" = "1" ] ; then
            echo "clang-format-$v"
            break
        fi
    done

    IFS=$OLD_IFS
}

lookup_default ()
{
    basename "$(which clang-format)"
}

CLANG_FORMAT=$(lookup_11_or_higher)

if test "x$CLANG_FORMAT" = "x"; then
    CLANG_FORMAT=$(lookup_default)
fi

echo $CLANG_FORMAT
