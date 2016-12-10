#!/bin/bash


sourceFile=$1
targetFile=$2

function generateHfile() {

    if [ -e $2 ];then
        rm $2
    fi
    touch $0


    fileString="// test"
    echo $fileString > $2

    cat $1 | while read line
    do
        echo $line|grep -e "\"[a-zA-Z_][a-zA-Z_0-9]*\" *= *\".*\";" > /dev/null
        if [ $? -eq 0 ];then 
            key=`echo $line | sed "s/ *=.*;//g"|sed "s/\"//g"`
            string="static NSString * const $key = @\"$key\";///< $line"
            echo "$string" >> $2
        fi
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

