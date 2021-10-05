# FrescoGO - Análises

## Stats

Gera os histogramas de todos os jogos a partir dos relatórios gravados em um diretório.

1. Vá para o diretório `stats/`.
2. Execute o script `all.sh` passando o diretório com os relatórios em `.txt`.
3. As imagens serão gravadas em um sub-diretório `stats/`.

```
$ cd stats/
$ ./all.sh torneios/feferj-ribeira-out-21/
$ ls torneios/feferj-ribeira-out-21/stats/
```

### Dups

Identifica golpes duplicados a partir dos relatórios gravados em um diretório.

1. Vá para o diretório `scripts/`.
2. Execute o comando para varrer todos os arquivos.
3. O resultado será exibido na tela.

```
$ cd scripts/
$ for i in ../stats/torneios/feferj-ribeira-out-21/*.txt; do lua dups.lua "$i"; done
```
