#!/bin/bash
# -*- coding: utf-8 -*-

DIRNAME=`dirname $0`
LIBPATH=`dirname $DIRNAME`/lib
IRBRC=${DIRNAME}/.irbrc

env IRBRC=$IRBRC irb -I $LIBPATH
