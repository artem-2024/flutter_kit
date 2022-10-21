#!/bin/bash
# eg：sh buildIpa.sh production 1.3.2 19

# 蒲公英API_KEY
MY_PGY_API_K="863fb222e8522ecc2420f1b454c3e337"

######################################## 使用说明 ##################################################

# 1. 给脚本可执行权限：`chmod +x buildIpa.sh`
# 2. buildIpaTestExportOptions.plist 文件放在项目根目录下


# 保存开始时间
start=`date +%s`

# 项目路径
PROJECT_DIR=$(pwd)
# ipa存放目录
ipaDIR="my_ipa"

flutter pub get
echo "\033[1;32m开始构建xcarchive...\033[0m\n\c"
flutter build ipa --dart-define=lmsEnvName=$1 --build-name=$2 --build-number=$3
cd build/ios/archive/

# 暂不处理生产环境
if [ $1 == "production" ]; then
    echo "\033[1;32m生产环境请手动发布...\033[0m\n\c"
    open .
    exit
fi

# 拷贝构建文件
XC_FILE_PATH="copyForUpload.xcarchive"
rm -rf $XC_FILE_PATH
cp -R *.xcarchive $XC_FILE_PATH
# 创建新的文件夹存放ipa
rm -rf $ipaDIR
mkdir $ipaDIR

echo "\033[1;32m开始导出ipa...\033[0m\n\c"
# 导出 ipa包
xcodebuild -exportArchive -archivePath "$XC_FILE_PATH" -configuration "Adhoc" -exportPath "$ipaDIR" -allowProvisioningUpdates -exportOptionsPlist "$PROJECT_DIR/buildIpaTestExportOptions.plist"

cd $ipaDIR
FILE_PATH="copyForUpload.ipa"
# 拷贝文件，防止中文名上传失败
cp -R *.ipa $FILE_PATH

echo "\033[1;32m开始上传到蒲公英...\033[0m\n\c"
# 上传包到蒲公英
curl --progress-bar -F "file=@$FILE_PATH" -F "_api_key=$MY_PGY_API_K" https://www.pgyer.com/apiv2/app/upload | tee /dev/null

printf "\n"
# 计算总耗时并打印
end=`date +%s`
SEC=$[ end - start ]
(( SEC < 60 )) && echo "\033[1;32m总耗时: $SEC 秒\033[0m\c"
(( SEC >= 60 && SEC < 3600 )) && echo "\033[1;32m总耗时: $(( SEC / 60 )) 分 $(( SEC % 60 )) 秒\033[0m\c"
(( SEC > 3600 )) && echo "\033[1;32m总耗时: $(( SEC / 3600 )) 小时 $(( (SEC % 3600) / 60 )) 分 $(( (SEC % 3600) % 60 )) 秒\033[0m\c"
