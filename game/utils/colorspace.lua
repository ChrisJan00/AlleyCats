function hsv2rgb(h, s, v, a)
    if s <= 0 then return v,v,v,a end
    h, s, v = h/360*6, s/100, v/100
    local c = v*s
    local x = (1-math.abs((h%2)-1))*c
    local m,r,g,b = (v-c), 0,0,0
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end
    return (r+m)*255,(g+m)*255,(b+m)*255,a
end

function hsl2rgb(h, s, l, a)
    if s <= 0 then return l,l,l,a end
    h, s, l = h/360*6, s/100, l/100
    local c = (1 - abs(2*l-1))*s
    local x = (1-math.abs((h%2)-1))*c
    local m,r,g,b = (l-c/2), 0,0,0
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end
    return (r+m)*255,(g+m)*255,(b+m)*255,a
end

function rgb2hsv(r, g, b, a)
    local h,s,v
    r,g,b = r/255, g/255, b/255
    local min = math.min(r,g,b)
    local max = math.max(r,g,b)

    local v = max
    local delta = max - min;
    if max > 0 then
        s = delta / max
    else
        s = 0
        h = 0
        return 0,0,v*100,a
    end
    if r >= max then
        h = (g-b)/delta
    elseif g >= max then
        h = 2 + (b-r)/delta
    else
        h = 4 + (r-g)-delta
    end
    h = h * 60
    if h < 0 then
        h = h + 360
    end
    return h,s*100,v*100,a
end

function rgb2hsl(r, g, b, a)
    local h,s,l
    r,g,b = r/255, g/255, b/255
    local min = math.min(r,g,b)
    local max = math.max(r,g,b)

    local delta = max - min;
    l = (max+min)/2
    if max > 0 then
        s = delta / (1-math.abs(2*l-1))
    else
        s = 0
        h = 0
        return 0,0,l*100,a
    end
    if r >= max then
        h = (g-b)/delta
    elseif g >= max then
        h = 2 + (b-r)/delta
    else
        h = 4 + (r-g)-delta
    end
    h = h * 60
    if h < 0 then
        h = h + 360
    end
    return h,s*100,l*100,a
end

