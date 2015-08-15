#!/bin/sh

# prints a color table of 8bg * 8fg * 2 states (regular/bold)
echo
echo Table for 16-color terminal escape sequences.
echo
echo "Background | Foreground colors"
echo "---------------------------------------------------------------------"

if test "${ZSH_VERSION+set}" = set; then
  emulate sh
fi

if test "x`echo -e`" = x; then
  ECHO_E="echo -e"
else
  ECHO_E="echo"
fi

for bg in `seq 40 47`; do
	for bold in `seq 0 1`; do
		$ECHO_E "\033[0m"" ESC[${bg}m   | \c"
		for fg in `seq 30 37`; do
			if test "$bold" = 0; then
				$ECHO_E "\033[${bg}m\033[${fg}m [${fg}m  \c"
			else
				$ECHO_E "\033[${bg}m\033[1;${fg}m [1;${fg}m\c"
			fi
		done
		$ECHO_E "\033[0m"
	done
	echo "--------------------------------------------------------------------- "
done

echo
echo
