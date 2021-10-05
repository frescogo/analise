--lua5.3 parse.lua <file> /tmp

local VERSAO = 'v4.1'

local m = require 'lpeg'
local P, S, C, R, Ct, Cc = m.P, m.S, m.C, m.R, m.Ct, m.Cc

local INP, out = ...
--print(INP,out)
local pre,ts,pos = (((1-P'/')^0 * '/')^0 * C((1-m.R'09')^0) * C((m.R'09'+'_'+'-')^1) * C((1-P'.')^0) * '.txt'):match(INP)
local OUT = out .. '/' .. pre .. ts .. pos .. '.py'

-------------------------------------------------------------------------------

local SPC  = S'\t\n\r '
local X    = SPC ^ 0
local NUMS = R'09' ^ 1
local NSPC = ((1-SPC)^0)
local NL   = ((1-S'\r\n')^0)

local SEQ =
    P'SEQUÊNCIA ' *X* NUMS *X*
    P'='^1 *X*
    P'TEMPO' *X* 'DIR' *X* 'KMH' *X*
    P'-----' *X* '---' *X* '---' *X*
    Ct(Ct(C(NUMS) *X* C(NSPC) *X* C(NUMS) *X)^0)

local patt =
    P'Data:'          *X* C(NSPC) *X*
    P'Versão:'        *X* C(P'v'*NUMS*'.'*NUMS)*'.'*NUMS * NL *X*
    P'Descanso:'      *X* NL *X*
    P'Quedas:'        *X* C(NUMS) *X* (('('*C(NUMS)*P(1)*NUMS*')')+Cc(false)) *X*
    Ct(C((1-P':')^0) * ':' *X* C(NUMS) * ' pontos / ' * C(NUMS) * ' golpes / ' * (NUMS*'.'*NUMS) * ' km/h') * NL *X*
    Ct(C((1-P':')^0) * ':' *X* C(NUMS) * ' pontos / ' * C(NUMS) * ' golpes / ' * (NUMS*'.'*NUMS) * ' km/h') * NL *X*
    P'Parcial:'       *X* NL *X*
    P'Desequilibrio:' *X* NL *X*
    P'Quedas:'        *X* NL *X*
    P'FINAL:'         *X* C(NUMS) * ' pontos' *X*
    Ct(SEQ^0)         *X*
    P(0)

local data,versao,quedas,_quedas_,esq,dir,final,seqs = patt:match(assert(io.open(INP)):read'*a')
--print(data, versao, quedas, esq,dir, final, seqs)

--assert(VERSAO == versao)

--[[
print'---'
for i,seq in ipairs(seqs) do
    for j,v in ipairs(seq) do
        print(i,j, table.unpack(v))
    end
    print()
end
]]

esq = {
    nome   = esq[1],
    pontos = tonumber(esq[2]),
    golpes = tonumber(esq[3]),
    hits   = {},
    m150   = 0,
    m50    = 0,
    m25    = 0,
}

dir = {
    nome   = dir[1],
    pontos = tonumber(dir[2]),
    golpes = tonumber(dir[3]),
    hits   = {},
    m150   = 0,
    m50    = 0,
    m25    = 0,
}

-------------------------------------------------------------------------------

for _,seq in ipairs(seqs) do
    for i,hit in ipairs(seq) do
        local ts,xxx,vel = table.unpack(hit)
        vel = tonumber(vel)
        if i<#seq --[[and vel>=50]] then
            if xxx == '->' then 
                esq.hits[#esq.hits+1] = vel
            else
                dir.hits[#dir.hits+1] = vel
            end
        end
    end
end

table.sort(esq.hits, function (x,y) return x>y end)
table.sort(dir.hits, function (x,y) return x>y end)

for i=151, #esq.hits do
    esq.hits[i] = nil
end
for i=151, #dir.hits do
    dir.hits[i] = nil
end

for i=1, 150 do
    esq.m150 = esq.m150 + (esq.hits[i] or 0)
    dir.m150 = dir.m150 + (dir.hits[i] or 0)
end
esq.m150 = esq.m150 / 150
dir.m150 = dir.m150 / 150

for i=1, 50 do
    esq.m50 = esq.m50 + (esq.hits[i] or 0)
    dir.m50 = dir.m50 + (dir.hits[i] or 0)
end
esq.m50 = esq.m50 / 50
dir.m50 = dir.m50 / 50

for i=0, 25-1 do
    esq.m25 = esq.m25 + (esq.hits[150-i] or 0)
    dir.m25 = dir.m25 + (dir.hits[150-i] or 0)
end
esq.m25 = esq.m25 / 25
dir.m25 = dir.m25 / 25

do
    local x = _quedas_ or quedas
    assert((#seqs==x+1) or (#seqs==tonumber(x)))
end

function player (t)
    local ret = "{\n"
    ret = ret .. "\t\t'nome'   : '"..t.nome.."',\n"
    ret = ret .. "\t\t'golpes' : "..t.golpes..",\n"
    ret = ret .. "\t\t'pontos' : "..t.pontos..",\n"
    ret = ret .. "\t\t'm150'   : "..t.m150..",\n"
    ret = ret .. "\t\t'm50'    : "..t.m50..",\n"
    ret = ret .. "\t\t'm25'    : "..t.m25..",\n"
    ret = ret .. "\t\t'hits'   : ("..table.concat(t.hits,',').."),\n"
    ret = ret .. "\t\t'min'    : "..t.hits[#t.hits]..",\n"
    ret = ret .. "\t\t'max'    : "..t.hits[1]..",\n"
    ret = ret .. "\t}\n"
    return ret
end

local m300 = (esq.m150+dir.m150) / 2
local m100 = (esq.m50+dir.m50)   / 2
local m50  = (esq.m25+dir.m25)   / 2

local out = assert(io.open(OUT,'w'))
out:write("GAME = {\n")
out:write("\t'versao' : '"..VERSAO.."',\n")
out:write("\t'timestamp' : '"..ts.."',\n")
out:write("\t'final'     : "..tonumber(final)..",\n")
out:write("\t'm300'      : "..m300..",\n")
out:write("\t'm100'      : "..m100..",\n")
out:write("\t'm50'       : "..m50..",\n")
out:write("\t'golpes'    : "..(#esq.hits+#dir.hits)..",\n")
out:write("\t'quedas'    : "..quedas..",\n")
out:write("\t0           : "..player(esq)..",\n")
out:write("\t1           : "..player(dir)..",\n")
out:write("}\n")
out:close()

print(string.format('%-12s %-12s %5d  %5d   %02.2f   %02.2f   %02.2f', esq.nome, dir.nome, final, quedas, m300,m100,m50))
