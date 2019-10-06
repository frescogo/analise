#!/bin/sh

# $ ./all.sh ../jogos/Bolivar/20190908/ > ../jogos/Bolivar/20190908/ranking.lua

for i in $1/*.txt; do
    #echo $i
    base=`basename $i .txt`
    lua5.3 parse.lua $i
done
