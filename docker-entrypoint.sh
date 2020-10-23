#!/bin/bash
# Basically runs jmeter, assuming the PATH is set to point to JMeter bin DIR (see Dockerfile)
#
# This script expects the standard JMeter command parameters.
#
set -e
freeMem=`awk '/MemFree/ { print int($2/1024) }' /proc/meminfo`
s=$(($freeMem/10*8))
x=$(($freeMem/10*8))
n=$(($freeMem/10*2))
export JVM_ARGS="-XX:+AggressiveOpts -Xmn${n}m -Xms${s}m -Xmx${x}m"
#export JVM_ARGS="-XX:ParallelGCThreads=8 -XX:-UseG1GC -XX:+UseConcMarkSweepGC -XX:+AggressiveOpts -XX:+UseLargePages -Xmn${n}m -Xms${s}m -Xmx${x}m"

echo "JAVA_JDK_VERSION: ${JAVA_JDK_VERSION}"
echo "START Running Jmeter on format : ${TZ} : `date`"

# Keep entrypoint simple: we must pass the standard JMeter arguments
jmeter $@

echo "END Running Jmeter on `date`"
