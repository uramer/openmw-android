ARCH = $0

# Install dependencies
sudo apt-get install -y build-essential gcc-multilib python unzip pkg-config p7zip-full
cd /home/runner/
wget https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-Linux-x86_64.tar.gz
tar xvf cmake-$CMAKE_VERSION-Linux-x86_64.tar.gz
cd -

# build native libraries
export PATH=/home/runner/cmake-$CMAKE_VERSION-Linux-x86_64/bin/:$PATH
cd buildscripts
./build.sh --arch $ARCH
cd -

# build the APK
ARCH=$ARCH source buildscripts/include/version.sh
sed -i "s/abiFilters.*/abiFilters '$ABI'/" app/build.gradle
export ANDROID_NDK_HOME=$(pwd)/buildscripts/toolchain/ndk/
./gradlew assembleNightlyDebug

# create artifacts directory
mkdir artifacts

# compress symbols
cd buildscripts
./package-symbols.sh
mv symbols.7z ../artifacts/symbols-$(git rev-parse --short "$GITHUB_SHA")-$ARCH.7z
cd -

# collect outputs
mv app/build/outputs/apk/nightly/debug/omw_debug_*.apk artifacts/omw-debug-$(git rev-parse --short "$GITHUB_SHA")-$ARCH.apk
