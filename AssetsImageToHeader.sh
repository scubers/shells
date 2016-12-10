#!/bin/bash



sourceDir=$1
targetFile=$2


function generationImageHForDir() {
    for name in `ls $1`
    do
        #release_close.imageset
        echo $name|grep -e "[a-zA-Z_0-9\-]*\.imageset" > /dev/null
        if [ $? -eq 0 ];then
            varname=`echo $name | sed "s/\.imageset//g"|sed "s/\-/_/g"`
            echo "static NSString * const image_name_$varname = @\"${varname}\";" >> $2
        else
            if [ -d "${1}/${name}" ];then
                generationImageHForDir ${1}/${name} $2
            fi
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

# 获取文件夹所有文件的md5
newMd5String=`find $sourceDir -type f|md5`
echo "newMd5String: $newMd5String" 

# 判断 md5 是否一样
echo $oldMd5String | grep "$newMd5String"
if [ $? != 0 ];then
    echo not same
    # 不一样
    # 生成头文件
    generationImageHForDir $sourceDir $targetFile
    # 写入新md5 替换旧文件
    echo "// md5:$newMd5String" >> $targetFile
else
    echo same
fi
