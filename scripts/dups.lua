-- egrep "^[0-9]" afres/*|wc
-- for i in txts/*; do echo $i ; lua dups.lua "$i"; done
local T=0,D,V
for l in io.lines(...) do
    local ok = string.find(l,'%-%>') or string.find(l,'%<%-')
    if ok then
        local t,d,v = string.match(l, '(%d+)%s+(..)%s+(%d+)')
        t = tonumber(t)
        v = tonumber(v)
        ok = ok and T+750 > t
        ok = ok and D==d
        --ok = ok and V==v
        if ok then
            if V>=50 and v>=50 then
                print(t-T,V..D,v..d)
            end
            --assert(V >= v)
        end
        T,D,V = t,d,v
    end
end
