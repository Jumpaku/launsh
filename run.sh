#!/bin/sh

set -eux

env
pwd
ls
echo 'A process is being performed' > result.txt
echo '...'
cat pubspec.yaml
echo 'done'
