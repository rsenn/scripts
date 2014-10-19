: ${prefix=/usr}

make program_prefix=mapip- prefix="$prefix" install
#make program_prefix=mapip2- prefix="$prefix" install
make program_prefix= prefix="$prefix/mapip" install
#make program_prefix= prefix="$prefix/mapip2" install
