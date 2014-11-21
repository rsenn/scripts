#!/bin/sh

COMPILER=${1:-cc}

echo | "$COMPILER" -dM -E -  | sort 
