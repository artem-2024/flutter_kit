#!/bin/bash
# eg：sh buildApk.sh production

# 蒲公英API_KEY
MY_PGY_API_K="863fb222e8522ecc2420f1b454c3e337"

# 保存开始时间
start=`date +%s`

flutter pub get
echo -e "\033[1;32m开始构建apk...\033[0m\n\c"
flutter build apk --dart-define=lmsEnvName=$1
cd build/app/outputs/apk/release/

# 暂不处理生产环境
if [ $1 == "production" ]; then
    echo -e "\033[1;32m生产环境请手动发布\033[0m\n\c"
    # 打开当前文件夹 windows
    start .
    # 打开当前文件夹 mac
    open .
    exit
fi

FILE_PATH="copyForUpload.apk"
rm -rf $FILE_PATH
# 拷贝文件，防止中文名上传失败
cp -R *.apk $FILE_PATH

echo -e "\033[1;32m开始上传到蒲公英...\033[0m\n\c"

# 上传包到蒲公英
curl --progress-bar -F "file=@$FILE_PATH" -F "_api_key=$MY_PGY_API_K" https://www.pgyer.com/apiv2/app/upload | tee /dev/null

printf "\n"
# 计算总耗时并打印
end=`date +%s`
SEC=$[ end - start ]
(( SEC < 60 )) && echo -e "\033[1;32m总耗时: $SEC 秒\033[0m\c"
(( SEC >= 60 && SEC < 3600 )) && echo -e "\033[1;32m总耗时: $(( SEC / 60 )) 分 $(( SEC % 60 )) 秒\033[0m\c"
(( SEC > 3600 )) && echo -e "\033[1;32m总耗时: $(( SEC / 3600 )) 小时 $(( (SEC % 3600) / 60 )) 分 $(( (SEC % 3600) % 60 )) 秒\033[0m\c"
