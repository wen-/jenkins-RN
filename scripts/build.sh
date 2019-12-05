#!/bin/sh
# build.sh

echo "> $0 $*";

# 获取参数
build_yarn=1;
build_ios=0;
build_android=0;
desc=""

while [ $# -gt 0 ]
do
    case "$1" in
        -ios|--ios)  build_ios=1;;
        -android|--android)  build_android=1;;
        --no-yarn)  build_yarn=0;;
        --desc)  desc="$2"; shift;;
        -env|--env)  env="$2"; shift;;
    esac
    shift
done

project=$PWD
currTime=$(date '+%Y%m%d-%H%M%S')

# yarn 安装依赖
if [[ 1 == "$build_yarn" ]]; then
    yarn install
fi

# 新建文件夹
if [ ! -d "$project/build/" ]; then
	mkdir $project/build/
fi

if [ ! -d "$project/build/apk" ]; then
	mkdir $project/build/apk/
fi

if [ ! -d "$project/build/ipa/" ]; then
	mkdir $project/build/ipa/
fi

# ---------- android -----------
if [[ 1 == "$build_android" ]]||[[ 0 == "$build_ios" && 0 == "$build_android" ]]; then

cd android
./gradlew clean

./gradlew assembleRelease

apkname="app-release.apk"
newapkname="app-release-jenkins.apk"

cd $project/build/apk/ && mkdir $currTime

cp $project/android/app/build/outputs/apk/release/$apkname $project/build/apk/$currTime/$newapkname

if [ ! -f "$project/build/apk/$currTime/$newapkname" ]; then
    echo ">> Failed to package Android app"
    osascript -e 'display notification "android编译打包出错" with title "android打包出错"'
	exit 1;
fi

if [ "$?" == "0" ]; then
    echo ">> $project/build/apk/$currTime/$newapkname bulided!"
    echo ">> apk打包完成!"
    osascript -e 'display notification "Android打包成功" with title "Android打包完成"'
fi

fi
