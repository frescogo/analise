--lua5.3 parse.lua <file>

local m = require 'lpeg'
local P, S, C, R, Ct, Cc = m.P, m.S, m.C, m.R, m.Ct, m.Cc

local INP = ...
local timestamp = (((1-P'/')^0 * '/')^0 * 'serial_' * C((1-P'.')^1) * '.txt'):match(INP)

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

local k1, k2, total, _,_, quedas, golpes, ritmo, juiz,
      p0, esqs0,dirs0, p1, esqs1,dirs1,
      conf, version, dist, tempo, max,reves, equ, cont, fim,
      seqs,
      _vol0, _nrm0, _rev0, _tot0,
      _vol1, _nrm1, _rev1, _tot1,
      _media, _equilibrio, _, _quedas, _final = patt:match(assert(io.open(INP)):read'*a')

--print(timestamp, k1,k2, arena, juiz, total, version)

assert(dist    == '750')
assert(tempo   == '150')
assert(equ     == '1')
assert(version == '200')

--local version = v1..'.'..v2..'.'..v3
local arena = 'Bolivar'

print([[
MATCH {
    timestamp = ']]..timestamp..[[',
    players   = { ']]..k1..[[', ']]..k2..[[' },
    arena     = ']]..arena..[[',
    referee   = ']]..juiz..[[',
    score     = ]]..math.floor(total*100)..[[,
    version   = ']]..version..[[',
}
]])
