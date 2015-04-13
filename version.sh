#!/bin/bash
#
# determine-version -- report a useful version for releases
#
# Copyright 2008, Aron Griffis <agriffis@n01se.net>
# Copyright 2008, Oracle
# Released under the GNU GPLv2
 
v="v3.17"

lib_major=0
lib_minor=1
lib_patchlevel=1

which git &> /dev/null
if [ $? == 0 -a -d .git ]; then
    if head=`git rev-parse --verify HEAD 2>/dev/null`; then
        if tag=`git describe --tags 2>/dev/null`; then
            v="$tag"
        fi

        # Are there uncommitted changes?
        git update-index --refresh --unmerged > /dev/null
        if git diff-index --name-only HEAD | grep -v "^scripts/package" \
            | read dummy; then
            v="$v"-dirty
        fi
    fi
fi

echo "/* NOTE: this file is autogenerated by version.sh, do not edit */" > .build-version.h
echo "#ifndef __BUILD_VERSION" >> .build-version.h
echo >> .build-version.h
echo "#define __BUILD_VERSION" >> .build-version.h
echo >> .build-version.h
echo "#define BTRFS_LIB_MAJOR $lib_major" >> .build-version.h
echo "#define BTRFS_LIB_MINOR $lib_minor" >> .build-version.h
echo "#define BTRFS_LIB_PATCHLEVEL $lib_patchlevel" >> .build-version.h
echo >> .build-version.h
echo "#define BTRFS_LIB_VERSION ( BTRFS_LIB_MAJOR * 10000 + \\" >> .build-version.h
echo "                            BTRFS_LIB_MINOR * 100 + \\" >> .build-version.h
echo "                            BTRFS_LIB_PATCHLEVEL )" >> .build-version.h
echo >> .build-version.h
echo "#define BTRFS_BUILD_VERSION \"Btrfs $v\"" >> .build-version.h
echo "#endif" >> .build-version.h

diff -q version.h .build-version.h >& /dev/null

if [ $? == 0 ]; then
    rm .build-version.h
    exit 0
fi

mv .build-version.h version.h
