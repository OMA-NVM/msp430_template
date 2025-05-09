#!/bin/sh

here=$(realpath .)

export DYLD_LIBRARY_PATH="${here}/mspdebug-master/libs"
${here}/mspdebug-master/mspdebug "$@"
