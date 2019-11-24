# Stats & Rank

Software para Ánalise do FrescoGO!

## Stats

```
$ cd stats/
$ ./all.sh ../jogos/<arena>/<data>/ > stats.md      # :%!sort -n -r -k3
```

## Ranks

```
$ cd ranks/
$ ./all.sh ../jogos/<arena>/<data>/ > ranks.lua
```

```
$ cd ranks/
$ vi rank.lua   # insere um `dofile` para cada `ranks.lua`
$ lua rank.lua
```
