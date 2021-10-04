#!/bin/sh

# ./all.sh ../jogos/Bolivar/20190405/ > ranking.md
# :%!sort -n -r -k3

echo "\`\`\`"
mkdir -p "$1/stats/"
echo "ESQ          DIR            PTS    QDS"
echo "--------------------------------------"
for i in $1/*.txt; do
    #echo $i
    base=`basename "$i" .txt`
    lua5.3  parse.lua "$i" /tmp
    python3 histogram.py "/tmp/$base.py" "$1/stats/"
done
echo "\`\`\`"
