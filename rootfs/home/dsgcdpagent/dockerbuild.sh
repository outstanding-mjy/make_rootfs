#!/bin/sh
#docker run --rm -v /home/dsgcdp:/home/dsgcdp:z toolset7 /home/dsgcdp/jsoncpp/build.sh
cd /home/dsgcdp
make -f Makefile.linux clean
make -f Makefile.linux
make -f Makefile.linux rpm
