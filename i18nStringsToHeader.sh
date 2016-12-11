#!/bin/bash


sourceFile=$1 # 源文件 .strings
targetFile=$2 # 目标头文件 target.h

function generateHfile() {

    echo "// test" > $2
    spaceTemp="kjlskjfoijwef"
    for name in `cat $1|grep "\"[a-zA-Z_ \-]*\" *= *\".*\";"|sed "s/ /$spaceTemp/g"`
    do 
        name=`echo $name|sed "s/$spaceTemp/ /g"|sed "s/ *= */=/g"`
        value=`echo $name|sed "s/ *=.*//g"|sed "s/\"//g"`
        key=`echo $value|sed "s/\-/_/g"|sed "s/ /_/g"`
        echo "$key = $value"
        echo "// $name" >> $2
        echo "static NSString * const i18n_$key = @\"$value\";" >> $2
    done
}

# 判断目标文件是否存在，不存在则创建
if [ ! -e "$targetFile" ];then
    touch $targetFile
fi

# 获取目标文件保存的md5
oldMd5String=`cat $targetFile|grep "md5:[a-zA-Z0-9]"|sed "s/.*md5://g"`
echo "oldMd5String: $oldMd5String"

# 获取现在头文件的md5
newMd5String=`md5 $sourceFile|sed "s/.*= //g"`
echo "newMd5String: $newMd5String"

# 判断 md5 是否一样
echo $oldMd5String | grep "$newMd5String"
if [ $? != 0 ];then
    echo not same
    # 不一样
    generateHfile $sourceFile $targetFile
    # 写入新md5
    echo "// md5:$newMd5String" >> $targetFile
else
    echo same
fi

