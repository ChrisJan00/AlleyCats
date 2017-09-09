
-- require 'vector'
-- require 'box'
-- require 'bresen'

-- IMPORTANT
-- these methods do NOT return a list, but a hashmap where all the values are "true"
-- you will have to iterate through the keys to get the data

local function getCoords(self, pos)
    --return Vector(math.floor(1+pos.x/self.cellW), math.floor(1+pos.y/self.cellH))
    return (Vector(1,1) + pos/self.cellSize):floor()
end

local function getCoordsFloat(self, pos)
    return (Vector(1,1) + pos/self.cellSize)
end

local function addSingle(self, ipos, elem)
    if not self.map[ipos.x] then
        self.map[ipos.x] = {}
    end
    if not self.map[ipos.x][ipos.y] then
        self.map[ipos.x][ipos.y] = {}
    end
    self.map[ipos.x][ipos.y][elem] = true
end

local function getHash(self, ipos)
    if self.map[ipos.x] and self.map[ipos.x][ipos.y] then return self.map[ipos.x][ipos.y] end
    return {}
end

local _keyable_dict = {
    keys = function(dict)
        local res = {}
        local i = 1
        for k,_ in pairs(dict) do
            res[i] = k
            i = i+1
        end
        return res
    end,
    -- values = function(dict)
    --     local res = {}
    --     local i = 1
    --     for _,v in pairs(dict) do
    --         res[i] = v
    --         i = i+1
    --     end
    --     return res
    -- end,
    map = function(dict, func)
        for k,_ in pairs(dict) do
            func(k)
        end
    end,
    -- map_v = function(dict, func)
    --     for _,v in pairs(dict) do
    --         func(v)
    --     end
    -- end,
}

local function KeyableDict(newTable)
    local mt = { __index = function(table, key) return _keyable_dict[key] end }
    newTable = newTable or {}
    setmetatable(newTable,mt)
    return newTable
end

------------------------------------------------------------------------------------------------------------------------------

local _spatialHash = {}
function _spatialHash.init(self, cellSize)
    self.cellSize = cellSize
    self.map = {}
end

function _spatialHash.clean(self)
    self.map = {}
end

function _spatialHash.add(self, box, elem)
    local from = getCoords(self, box:topLeft())
    local to = getCoords(self, box:bottomRight())
    for xi = from.x,to.x do
        for yi = from.y,to.y do
            addSingle(self, Vector(xi,yi), elem)
        end
    end
end


function _spatialHash.getHashForPoint(self, point)
    local ipoint = getCoords(self, point)
    return KeyableDict(getHash(self, ipoint))
end

function _spatialHash.getHashForLine(self, segment)
    local res = KeyableDict()
    local from = getCoordsFloat(self, segment:topLeft())
    local to = getCoordsFloat(self, segment:bottomRight())
    local points = getLineWalkerV(from, to)
    for _, cell in ipairs(points) do
        local elems = getHash(self, cell)
        for e,_ in pairs(elems) do
            res[e] = true
        end
    end

    return res
end

function _spatialHash.getHashForLineBresen(self, segment)
    local res = KeyableDict()
    local from = getCoords(self, segment:topLeft())
    local to = getCoords(self, segment:bottomRight())
    local points = getBresenV(from, to)
    for _, cell in ipairs(points) do
        local elems = getHash(self, cell)
        for e,_ in pairs(elems) do
            res[e] = true
        end
    end

    return res
end

function _spatialHash.getHashForBox(self, box)
	local b = box:sortedCoords()
    local from = getCoords(self, b:topLeft())
    local to = getCoords(self, b:bottomRight())
    local res = KeyableDict()
    for xi = from.x, to.x do
        for yi = from.y, to.y do
            local elems = getHash(self, Vector(xi, yi))
            for e,_ in pairs(elems) do
                res[e] = true
            end
        end
    end

    return res
end

----------------
function SpatialHash(x, y)
    local mt = { __index = function(table, key) return _spatialHash[key] end }
    local newTable = {}
    setmetatable(newTable,mt)

    -- 1 param: expecting vector
    -- 2 params: expecting x and y
    -- 0 params: default 32x24
    local v = x
    if y then v = Vector(x, y) end
    if not x then v = Vector(32,24) end

    newTable:init(v)
    return newTable
end
