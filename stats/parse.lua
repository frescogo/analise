--lua5.3 parse.lua <file> /tmp

local VERSAO = '2.0'

local m = require 'lpeg'
local P, S, C, R, Ct, Cc = m.P, m.S, m.C, m.R, m.Ct, m.Cc

local INP, out = ...
--local ts = (((1-P'/')^0 * '/')^0 * 'serial_' * C((1-P'.')^1) * '.txt'):match(INP)
local pre,ts,pos = (((1-P'/')^0 * '/')^0 * C((1-m.R'09')^0) * C((m.R'09'+'_')^1) * C((1-P'.')^0) * '.txt'):match(INP)
local OUT = out .. '/' .. pre .. ts .. pos .. '.py'

-------------------------------------------------------------------------------

local SPC  = S'\t\n\r '
local X    = SPC ^ 0
local NUMS = R'09' ^ 1
local PTS  = NUMS * P'.' * NUMS

local SEQ = Ct(
    P'-- Sequencia ' * X * NUMS * X * P'-'^1 * P'\r\n'      *
    (P'    ****' * Cc(true) + P'            ****' * Cc(false))  * X *
    Ct( (P'!'^-1 *X* NUMS *X* P'!'^-1 *X*
        P'(' *X* C(NUMS) *X* P'km/h)' * X)^0 )  * X *
    (P'!'^-1 *X* NUMS *X* P'!'^-1)^-1                       * X *
    P(0))

local patt =
    P'relatorio'^-1                         * X *
    P'-'^1                                  * X *
    C((1-P' /')^0)                          * X *   -- Joao
    P'/'                                    * X *
    C((1-S'\r\n')^0)                        * X *   -- Maria
    P'-'^0                                  * X *
    P'TOTAL .............. ' * C(PTS) * ' pts'   * X *   -- 3701 pts
    P'Tempo Restante ..... ' * C(NUMS) * ':' * C(NUMS) * X * -- 180650 (-0s)
    P'Quedas ............. ' * C(NUMS)      * X *   -- 6 quedas
    P'Golpes ............. ' * C(NUMS)      * X *   -- 286 golpes
    P'Média .............. ' * C(NUMS) * ' km/h'  * X *   -- 45 kmh
    P'Juiz ............... ' * C((1-S'\r\n')^0)   * X *   -- Arnaldo
    (1-PTS)^1 * C(PTS) * ' pts' * (1-S'\r\n')^0   * X *   -- Joao: 5500
    P'rev  [' * Ct((X * C(NUMS))^1) *X* ']' * X * -- [ ... ]
    P'nrm  [' * Ct((X * C(NUMS))^1) *X* ']' * X *  -- [ ... ]
    (1-PTS)^1 * C(PTS) * ' pts' * (1-S'\r\n')^0   * X *   -- Joao: 5500
    P'rev  [' * Ct((X * C(NUMS))^1) *X* ']' * X * -- [ ... ]
    P'nrm  [' * Ct((X * C(NUMS))^1) *X* ']' * X * -- [ ... ]
    P'-'^0                                  * X *
    C('(v' * C(NUMS) * '/' *
                  C(NUMS) * 'cm/'    *
                  C(NUMS) * 's/maxs(' *
                  C(NUMS) * ',' * C(NUMS) * ')/equ' *
                  C(NUMS) * '/cont' *
                  C(NUMS) * '/fim'  *
                  C(NUMS) * ')')        * X *
    P'-'^1                              * X *
    Ct(SEQ^1)                           * X *
    P'-'^1                              * X *
    P'Atleta' *X*'|'*X* 'Vol' *X* 'Nrm' *X* 'Rev' *X*'|'*X* 'Total' * X *
    (1-P'|')^0 *X*'|'*X* C(PTS) *X* C(PTS) *X* C(PTS) *X*'|'*X* C(PTS) * ' pts' * X *
    (1-P'|')^0 *X*'|'*X* C(PTS) *X* C(PTS) *X* C(PTS) *X*'|'*X* C(PTS) * ' pts' * X *
    P'-'^1                                  * X *
    P'Media ........... ' *X* C(PTS) * ' pts' *X*
    P'Equilibrio ...... ' *X* C(PTS) *X* '(-)' *X*
    P'Quedas (' * C(NUMS) * P') ..... ' *X* C(NUMS)*P'%' *X* '(-)' *X*
    P'TOTAL ........... ' *X* C(PTS) * ' pts' *X*
--[[
]]
    P(0)

-------------------------------------------------------------------------------

local esquerda, direita, total, _,_, quedas, golpes, ritmo, _,
      p0, esqs0,dirs0, p1, esqs1,dirs1,
      conf, version, dist, tempo, max,reves, equ, cont, fim,
      seqs,
      _vol0, _nrm0, _rev0, _tot0,
      _vol1, _nrm1, _rev1, _tot1,
      _media, _equilibrio, _, _quedas, _final = patt:match(assert(io.open(INP)):read'*a')

print(string.format('%-12s %-12s %2.2f  %5d  %5d', esquerda, direita, _final, quedas, ritmo))
--[[
print(INP)
print(esquerda, direita, total, ritmo, dir1, version, dist, maxs,max, reves, equ, cont, seqs)
for i,seq in ipairs(seqs) do
    print(i,seq)
end
error'ok'
]]

-------------------------------------------------------------------------------

--assert(total==_final and p0==_tot0 and p1==_tot1)

local nomes  = { esquerda, direita }
local pontos = { {_tot0,_vol0,_nrm0,_rev0}, {_tot1,_vol1,_nrm1,_rev1} }
--local ritmos = { {0,esq0,dir0}, {0,esq1,dir1} }
local reves  = { esqs0, esqs1 }
local normal = { dirs0, dirs1 }
local hits = { {}, {} }
    for _,seq in ipairs(seqs) do
        local isesq, vels = table.unpack(seq)
        for i,vel in ipairs(vels) do
            local idx do
                if isesq then
                    if i%2 == 1 then
                        idx = 1
                    else
                        idx = 2
                    end
                else
                    if i%2 == 1 then
                        idx = 2
                    else
                        idx = 1
                    end
                end
            end
            --ritmos[idx][1] = ritmos[idx][1] + vel*vel
            hits[idx][#hits[idx]+1] = vel
        end
    end
    --ritmos[1][1] = math.floor(math.sqrt(ritmos[1][1]/#hits[1]))
    --ritmos[2][1] = math.floor(math.sqrt(ritmos[2][1]/#hits[2]))
assert(tonumber(golpes) == (#hits[1]+#hits[2]))

assert((#seqs==quedas+1) or (#seqs==tonumber(quedas)))

function player (i)
    local ret = "{\n"
    ret = ret .. "\t\t'nome'   : '"..nomes[i].."',\n"
    ret = ret .. "\t\t'golpes' : "..#hits[i]..",\n"
    ret = ret .. "\t\t'pontos' : ("..table.concat(pontos[i],',').."),\n"
    --ret = ret .. "\t\t'ritmo'  : ("..table.concat(ritmos[i],',').."),\n"
    ret = ret .. "\t\t'reves'  : ("..table.concat(reves[i],',').."),\n"
    ret = ret .. "\t\t'normal' : ("..table.concat(normal[i],',').."),\n"
    ret = ret .. "\t\t'hits'   : ("..table.concat(hits[i],',').."),\n"
    ret = ret .. "\t}\n"
    return ret
end

local out = assert(io.open(OUT,'w'))
out:write("GAME = {\n")
out:write("\t'versao' : '"..VERSAO.."',\n")
out:write("\t'timestamp' : '"..ts.."',\n")
out:write("\t'config'    : '"..conf.."',\n")
--out:write("\t'maximas'   : "..maxs..",\n")
out:write("\t'pontos'    : (".._final..",".._media..",".._equilibrio..","..tonumber(_quedas).."),\n")
out:write("\t'ritmo'     : "..ritmo..",\n")
out:write("\t'golpes'    : "..golpes..",\n")
out:write("\t'quedas'    : "..quedas..",\n")
out:write("\t0           : "..player(1)..",\n")
out:write("\t1           : "..player(2)..",\n")
out:write("}\n")
out:close()
