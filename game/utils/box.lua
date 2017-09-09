-- require 'vector'

local Box_proto = {
    copy = function(self) return Box(self.x0,self.y0,self.x1,self.y1) end,
    displace = function(box, vector) return Box(box.x0 + vector.x, box.y0 + vector.y, box.x1 + vector.x, box.y1 + vector.y) end,
    intersects = function(box1, box2)
        if not box1:isSorted() then box1=box1:sortedCoords() end
        if not box2:isSorted() then box2=box2:sortedCoords() end
        return box1.x1 >= box2.x0 and box1.x0 <= box2.x1 and box1.y0 <= box2.y1 and box1.y1 >= box2.y0
    end,
    containsPoint = function(box, vector)
        if not box:isSorted() then box=box:sortedCoords() end
        return vector.x >= box.x0 and vector.x <= box.x1 and vector.y >= box.y0 and vector.y <= box.y1
    end,
    topLeft = function(box)
        if box:isSorted() then return Vector(box.x0, box.y0) end
        return Vector(math.min(box.x0, box.x1), math.min(box.y0, box.y1))
    end,
    bottomRight = function(box)
        if box:isSorted() then return Vector(box.x1, box.y1) end
        return Vector(math.max(box.x0, box.x1), math.max(box.y0, box.y1))
    end,
    center = function(box) return Vector((box.x0+box.x1)*0.5, (box.y0+box.y1)*0.5) end,
    isSorted = function(box) return box.x1 >= box.x0 and box.y1 >= box.y0 end,
    sortedCoords = function(box) return Box(math.min(box.x0, box.x1), math.min(box.y0, box.y1), math.max(box.x0, box.x1), math.max(box.y0, box.y1)) end,
    size = function(box) return (box:bottomRight() - box:topLeft()):abs() end,
    rect = function(box)
        if not box:isSorted() then box = box:sortedCoords() end
        return Box(box.x0, box.y0, box.x1-box.x0, box.y1-box.y0)
    end,

    floor = function(self)
        return Box(math.floor(self.x0),math.floor(self.y0),math.floor(self.x1),math.floor(self.y1))
    end,
    unpack = function(self)
        return self.x0,self.y0,self.x1,self.y1
    end,
}

local Box_mt = {
        __index = function(table, key) return Box_proto[key] end,
        __add = function(lt,rt) return lt:displace(rt) end,
        __sub = function(lt,rt) return lt:displace(-rt) end,
    }


function Box(x0, y0, x1, y1, data)
    local box = { x0 = x0 or 0, y0 = y0 or 0, x1 = x1 or 0, y1 = y1 or 0 }
    if data and type(data) == "table" then
        for k,v in pairs(data) do box[k] = v end
    end
    setmetatable(box,Box_mt)
    return box
end

-- either a rect as a table with entries x,y,w,h or the entries themselves
function BoxFromRect(x,y,w,h)
    if type(x)=="table" then
        return Box(x.x,x.y,x.x+x.w,x.y+x.h)
    end
    return Box(x,y,x+w,y+h)
end

function BoxFromVectors(topleft, bottomright)
    return Box(topleft.x, topleft.y, bottomright.x, bottomright.y)
end

function CenteredBox(center, dimensions)
    return Box(center.x - dimensions.x*0.5, center.y - dimensions.y*0.5, center.x + dimensions.x*0.5, center.y + dimensions.y*0.5)
end
