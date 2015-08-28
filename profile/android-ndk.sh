ANDROID_NDK_PATH=/opt/android-ndk-r10b
ANDROID_NDK_ROOT=$ANDROID_NDK_PATH
#PATH="$PATH:$ANDROID_NDK_ROOT"
ANDROID_SYSROOT=$ANDROID_NDK_ROOT/platforms/android-17/arch-arm/
JAVA_HOME=/usr/lib/jvm/java-openjdk

for DIR in $ANDROID_NDK_ROOT/toolchains/{arm,x86,mipsel}*-4.8/prebuilt/linux-`uname -i`/bin; do
  test -d "$DIR" || continue
	if ! echo ${PATH} | grep -q "$DIR"; then
		 PATH="$PATH:$DIR"
	fi
done

export ANDROID_NDK_ROOT ANDROID_NDK_PATH ANDROID_NDK_SYSROOT PATH
