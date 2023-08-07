#! /bin/bash
#
## @file                update_w_from_parent.sh
## @author              Valentina Vispo
## @section LICENSE     Apache

echo -e 'Running parent update files script'
echo -e 'Creating .github/ folder\n'
mkdir -p .github/
echo -e 'Updating workflows...\n'
cp -r parentRepository/child.github/* .github/
echo -e '\nUpdate complete'
