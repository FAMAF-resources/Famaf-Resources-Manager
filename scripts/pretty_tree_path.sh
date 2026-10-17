#! /bin/bash

find . -type d -not -path '*/.*' -o -path . -type d | LC_ALL=C sort | sed -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'