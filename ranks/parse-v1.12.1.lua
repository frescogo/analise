--lua5.3 parse.lua <file>

local m = require 'lpeg'
local P, S, C, R, Ct, Cc = m.P, m.S, m.C, m.R, m.Ct, m.Cc

local INP = ...
local timestamp = (((1-P'/')^0 * '/')^0 * 'serial_' * C((1-P'.')^1) * '.txt'):match(INP)

-------------------------------------------------------------------------------

local SPC  = S'\t\n\r '
local X    = SPC ^ 0
local NUMS = R'09' ^ 1

local SEQ = Ct(
    P'-- Sequencia ' * X * NUMS * X * P'-'^1 * P'\r\n'      *
    (P'    ****' * Cc(true) + P'            ****' * Cc(false))  * X *
    Ct( (P'!'^-1 *X* NUMS *X* P'!'^-1 *X*
        P'(' *X* C(NUMS) *X* P'/' *X* NUMS * P')' * X)^0 )  * X *
    (P'!'^-1 *X* NUMS *X* P'!'^-1)^-1                       * X *
    P'-----   -----' * X * NUMS * X * NUMS                  * X *
    P(0))

local patt =
    P'relatorio'^-1                         * X *
    P'-'^1                                  * X *
    C((1-P' /')^0)                          * X *   -- Joao
    P'/'                                    * X *
    C((1-S'\r\n')^0)                        * X *   -- Maria
    P'-'^0                                  * X *
    P'TOTAL ........ ' * C(NUMS) * ' pts'   * X *   -- 3701 pts
    P'Tempo ........ ' * C(NUMS) * 'ms (faltam ' * NUMS * 's)'   * X *   -- 180650 (-0s)
    P'Quedas ....... ' * C(NUMS)            * X *   -- 6 quedas
    P'Golpes ....... ' * C(NUMS)            * X *   -- 286 golpes
    P'Ritmo ........ ' * C(NUMS) *'/'* C(NUMS) * ' kmh' * X *   -- 45/45 kmh
    P'Juiz ......... ' * C((1-S'\r\n')^0)   * X *   -- Arnaldo
    (1-NUMS)^1 * C(NUMS) * ' pts'           * X *   -- Joao: 5500
    P'rev  [' * Ct((X * C(NUMS))^1) *X* '] => ' * C(NUMS) * ' kmh' * X *   -- [ ... ]
    P'nrm  [' * Ct((X * C(NUMS))^1) *X* '] => ' * C(NUMS) * ' kmh' * X *   -- [ ... ]
    (1-NUMS)^1 * C(NUMS) * ' pts'           * X *   -- Maria: 4427
    P'rev  [' * Ct((X * C(NUMS))^1) *X* '] => ' * C(NUMS) * ' kmh' * X *   -- [ ... ]
    P'nrm  [' * Ct((X * C(NUMS))^1) *X* '] => ' * C(NUMS) * ' kmh' * X *   -- [ ... ]
    P'-'^0                                  * X *
    C('(v' * C(NUMS) * '/' *
                  C(NUMS) * 'cm/'    *
                  C(NUMS) * 's/max(' *
                  C(NUMS) * ',' * C(NUMS) * ',' * C(NUMS) * ')/equ' *
                  C(NUMS) * '/cont' *
                  C(NUMS) * '/fim'  *
                  C(NUMS) * ')')        * X *
    P'-'^1                              * X *
    Ct(SEQ^1)                           * X *
    P'-'^1                              * X *
    P'Atleta' *X* 'Vol' *X* 'Maxs' *X* 'Total' * X *
    (1-NUMS)^0 * C(NUMS) *X* '+' *X* C(NUMS) *X* '=' *X* C(NUMS) * ' pts' * X *
    (1-NUMS)^0 * C(NUMS) *X* '+' *X* C(NUMS) *X* '=' *X* C(NUMS) * ' pts' * X *
    P'-'^1                                  * X *
    P'Media ........ ' *X* C(NUMS) * ' pts' *X*
    P'Equilibrio ... ' *X* C(NUMS) *X* '(-)' *X*
    P'Quedas ....... ' *X* C(NUMS) *X* '(-)' *X*
    P'TOTAL ........ ' *X* C(NUMS) * ' pts' *X*
--[[
]]
    P(0)

local k1, k2, total, _, quedas, golpes, ritmo1, ritmo2, juiz,
      p0, esqs0,esq0,dirs0,dir0, p1, esqs1,esq1,dirs1,dir1,
      conf, version, dist, tempo, maxs,max,reves, equ, cont, fim,
      seqs,
      _vol0, _maxs0, _tot0,
      _vol1, _maxs1, _tot1,
      _media, _equilibrio, _quedas, _final = patt:match(assert(io.open(INP)):read'*a')

--print(timestamp, k1,k2, arena, juiz, total, version)

assert(dist    == '750')
assert(tempo   == '150')
assert(maxs    == '1')
assert(equ     == '1')
assert(version == '1121')

--local version = v1..'.'..v2..'.'..v3
local arena = 'Bolivar'

print([[
MATCH {
    timestamp = ']]..timestamp..[[',
    players   = { ']]..k1..[[', ']]..k2..[[' },
    arena     = ']]..arena..[[',
    referee   = ']]..juiz..[[',
    score     = ]]..total..[[,
    version   = ']]..version..[[',
}
]])
