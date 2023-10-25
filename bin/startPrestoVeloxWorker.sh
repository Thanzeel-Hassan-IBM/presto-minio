#!/bin/sh

# On Mac make sure DYLD_LIBRARY_PATH points to /usr/local/lib
# Mac M1s have had issues with finding the libantlr because this path is not searched.
UNAME=`uname`
if [[ ${UNAME} =~ "Darwin" && ! ${DYLD_LIBRARY_PATH} =~ "/usr/local/lib" ]]; then
  export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/usr/local/lib
fi

# Check PRESTO_TOP
if [ -z "${PRESTO_TOP}" ]; then
    echo "Set PRESTO_TOP environment variable."
    exit 1
fi

if [ -z "${PRESTO_HOME}" ]; then
    echo "Set PRESTO_HOME environment variable. Where should presto go?"
    exit 1
fi

# Check if discovery url was set in config.properties to be used by the worker
PORT_SET=`grep replace_port $PRESTO_HOME/velox-etc/config.properties`
if [ ! -z "${PORT_SET}" ]; then
    echo "Find the (second) discovery port after running startHiveQueryRunner.sh"
    echo "Example output:"
    echo "  2023-03-12T16:46:37.361-0600	INFO	main	com.facebook.presto.tests.DistributedQueryRunner	Discovery URL http://127.0.0.1:40691"
    exit 1
fi

if [ -f "$PRESTO_TOP/presto-native-execution/presto_cpp/main/presto_server" ]; then
    $PRESTO_TOP/presto-native-execution/presto_cpp/main/presto_server --logtostderr=1 --v=1 --etc_dir=${PRESTO_HOME}/velox-etc
elif [ -f "$PRESTO_TOP/presto-native-execution/_build/debug/presto_cpp/main/presto_server" ]; then
    $PRESTO_TOP/presto-native-execution/_build/debug/presto_cpp/main/presto_server --logtostderr=1 --v=1 --etc_dir=${PRESTO_HOME}/velox-etc
elif [ -f "$PRESTO_TOP/presto-native-execution/_build/release/presto_cpp/main/presto_server" ]; then
    $PRESTO_TOP/presto-native-execution/_build/release/presto_cpp/main/presto_server --logtostderr=1 --v=1 --etc_dir=${PRESTO_HOME}/velox-etc
else
    echo "Error: presto_server executable not found."
fi
