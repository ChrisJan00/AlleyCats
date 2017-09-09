--require 'vector'

if Vector then
    -- bresenham if you are using vector.lua
    function getBresenV(pointFrom, pointTo)
        local dx,dy = (pointTo-pointFrom):unpack()
        if dx==0 and dy==0 then return { pointFrom:copy() } end
        local points = {}
        local adx,ady = math.abs(dx),math.abs(dy)
        if ady < adx then
            local tg = dy/dx
            local sdx = dx >= 0 and 1 or -1
            for i=0,adx do
                table.insert(points,
                    Vector(pointFrom.x + i*sdx,
                      math.round(pointFrom.y + i*tg*sdx) ) )
            end
        else
            local tg = dx/dy
            local sdy = dy >= 0 and 1 or -1
            for i=0,ady do
                table.insert(points,
                    Vector(math.round(pointFrom.x + i*tg*sdy),
                      pointFrom.y + i*sdy ) )
            end
        end

        return points
    end

    function getLineWalkerV(from, to)
        -- check completely vertical or horizontal lines
        local r_from, r_to = from:floor(), to:floor()
        if r_from.x == r_to.x or
            r_from.y == r_to.y
            then
            return getBresen(r_from, r_to)
        end

        local res = {}

        local diff = to - from
        local adiff = diff:abs()
        if adiff.x <= adiff.y then
            local frac = diff.x > 0 and (1 - (from.x%1)) or (from.x%1)
            local inc = diff:sign()
            local tg = diff.y/diff.x
            local v0 = from:copy()
            local steps = math.abs(r_to.x - r_from.x) + 1
            for iter=1, steps do
                local crossing_point = frac * inc.x * tg + v0.y
                if math.abs(crossing_point-from.y) > adiff.y then
                    crossing_point = to.y
                end

                fv0 = v0:floor()
                for ip = fv0.y,math.floor(crossing_point),inc.y do
                    table.insert(res, Vector(fv0.x, ip))
                end

                -- prepare for next iteration
                v0 = Vector(fv0.x + inc.x, crossing_point)
                frac = 1
            end
        else
            -- in order to avoid duplicated, error-prone code, I'll transpose, call, and transpose again
            res = getLineWalkerV(Vector(from.y, from.x), Vector(to.y, to.x))
            for _,p in ipairs(res) do
                local tmp = p.x
                p.x = p.y
                p.y = tmp
            end
        end

        return res
    end
end

-- bresenham without vector.lua
local function round(x) return math.floor(x+0.5) end
local function sign(x) return x>0 and 1 or -1 end
function getBresenP(xf, yf, xt, yt)
    local dx,dy = xt-xf,yt-yf
    if dx==0 and dy==0 then
        return {{ xf, yf }}
    end

    local points = {}
    local adx,ady = math.abs(dx),math.abs(dy)
    if ady < adx then
        local tg = dy/dx
        local sdx = dx >= 0 and 1 or -1
        for i=0,adx do
            points[i+1] =
                {xf + i*sdx,
                  round(yf + i*tg*sdx)}
        end
    else
        local tg = dx/dy
        local sdy = dy >= 0 and 1 or -1
        for i=0,ady do
            points[i+1] =
                { round(xf + i*tg*sdy),
                  yf + i*sdy }
        end
    end

    return points
end

function getLineWalkerP(xf, yf, xt, yt)
    -- check completely vertical or horizontal lines
    local r_xf, r_yf, r_xt, r_yt = math.floor(xf), math.floor(yf), math.floor(xt), math.floor(yt)
    if r_xf == xt or r_yf == yt then
        return getBresenP(r_xf, r_yf, r_xt, r_yt)
    end

    local res = {}
    local j = 1

    local dx,dy = xt-xf, yt-yf
    local adx,ady = math.abs(dx),math.abs(dy)
    if adx <= ady then
        local frac = dx > 0 and (1 - (xf%1)) or (xf%1)
        local add = sign(dx)
        local tg = dy/dx
        local x0,y0 = xf,yf
        local steps = math.abs(math.floor(xt) - math.floor(xf)) + 1
        local climb = sign(dy)
        for iter=1, steps do
            local crossing_point = frac * add * tg + y0
            if math.abs(crossing_point-yf) > ady then
                crossing_point = yt
            end

            local fx0 = math.floor(x0)
            for ip = math.floor(y0),math.floor(crossing_point),climb do
                res[j] = { fx0, ip }
                j = j + 1
            end

            -- prepare for next iteration
            x0 = fx0 + add
            y0 = crossing_point
            frac = math.abs(add)
        end
    else
        -- in order to avoid duplicated, error-prone code, I'll transpose, call, and transpose again
        res = getLineWalkerP(yf, xf, yt, xt)
        for j=1,#res do
            local tmp = res[j][1]
            res[j][1] = res[j][2]
            res[j][2] = tmp
        end
    end

    return res
end

if Vector then
    getBresen = getBresenV
    getLineWalker = getLineWalkerV
else
    getBresen = getBresenP
    getLineWalker = getLineWalkerP
end