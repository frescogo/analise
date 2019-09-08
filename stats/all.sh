#!/bin/sh

# ./all.sh ../Jogos/20190405/ > ranking.md
# :%!sort -r -k3

echo "\`\`\`"
echo "ESQ          DIR            PTS    QDS    KMH"
echo "---------------------------------------------"
for i in $1/*.txt; do
    #echo $i
    base=`basename $i .txt`
    lua5.3  parse.lua $i /tmp
    python3 histogram.py "/tmp/$base.py" $1
done
echo "\`\`\`"
