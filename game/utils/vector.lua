-- vector_love: a small library for 2d vector math

-- zlib license
-- Copyright (c) 2014-2015 Christiaan Janssen

-- This software is provided 'as-is', without any express or implied
-- warranty. In no event will the authors be held liable for any damages
-- arising from the use of this software.

-- Permission is granted to anyone to use this software for any purpose,
-- including commercial applications, and to alter it and redistribute it
-- freely, subject to the following restrictions:

-- 1. The origin of this software must not be misrepresented; you must not
--    claim that you wrote the original software. If you use this software
--    in a product, an acknowledgement in the product documentation would be
--    appreciated but is not required.
-- 2. Altered source versions must be plainly marked as such, and must not be
--    misrepresented as being the original software.
-- 3. This notice may not be removed or altered from any source distribution.


function math.sign(a) return a>=0 and 1 or -1 end
-- if min > max, it will return min
function math.clamp(min, val, max) return math.max(min, math.min(val, max)) end
function math.round(a) return math.floor(a+0.5) end
-- avoid rounding errors
local quant = 1e-10
function math.setQuantStep(step) quant = step end
function math.quantize(a) return math.round(a/quant)*quant end

local Vector_proto = {
	copy = function(self) return Vector(self.x,self.y) end,
	norm = function(self)
		local m = self:mod()
		m = m == 0 and 1 or 1/m
		return m*self
	end,
	mod = function(self)
		return math.sqrt(self*self)
	end,
	angle = function(self)
       return math.atan2(self.y,self.x)
	end,
	isZero = function(self)
		return self.x == 0 and self.y == 0
	end,
	-- note: "iseq" instead of overridding the "__eq" operator because
	-- I still want to use vectors as hashes
	isEq = function(self, v2)
		return self.x==v2.x and self.y==v2.y
	end,
	abs = function(self)
		return Vector(math.abs(self.x),math.abs(self.y))
	end,
	sign = function(self)
		return Vector(math.sign(self.x),math.sign(self.y))
	end,
	floor = function(self)
		return Vector(math.floor(self.x),math.floor(self.y))
	end,
	round = function(self)
		return Vector(math.floor(self.x+0.5),math.floor(self.y+0.5))
	end,
	ceil = function(self)
		return Vector(math.ceil(self.x), math.ceil(self.y))
	end,
	rot = function(self, angle)
		local c,s = math.cos(angle), math.sin(angle)
		return Vector(self.x*c-self.y*s, self.x*s+self.y*c)
	end,
	angleBetween = function(fromvec, tovec)
		-- since division between vectors is not defined, we use the operator for "angle between vectors"
		local v1,v2 = fromvec:norm(),tovec:norm()
		local cosangle = math.acos(math.clamp(-1,v1*v2,1))
		local sinangle = math.asin(math.clamp(-1,v1*v2:ortho(),1))
		return cosangle*math.sign(sinangle)
	end,
	ortho = function(self)
		return Vector(self.y,-self.x)
	end,
	unpack = function(self)
		return self.x,self.y
	end,
	clamp = function(self,v1,v2)
		return Vector(math.clamp(v1.x, self.x, v2.x), math.clamp(v1.y, self.y, v2.y))
	end,
	quant = function(self)
		return Vector(math.quantize(self.x), math.quantize(self.y))
	end,
}

local Vector_mt = {
		__index = function(table, key) return Vector_proto[key] end,
		__add = function(lt,rt) return Vector(lt.x+rt.x,lt.y+rt.y) end,
		__sub = function(lt,rt) return Vector(lt.x-rt.x,lt.y-rt.y) end,
		__mul = function(lt,rt)
			if type(lt) == "number" then return Vector(lt*rt.x,lt*rt.y) end
			if type(rt) == "number" then return Vector(lt.x*rt,lt.y*rt) end
			return lt.x*rt.x + lt.y*rt.y
		end,
		__pow = function(lt,rt)
			-- note: there's no easy way to tell the difference between dot product and per-element product
			-- we will use pow for the second one
			return Vector(lt.x*rt.x, lt.y*rt.y)
		end,
		__div = function (lt, rt)
			if type(rt) == "number" then return Vector(lt.x/rt, lt.y/rt) end
			if type(lt) == "number" then return Vector(lt/rt.x, lt/rt.y) end
			-- defaults to per-element division
			return Vector(lt.x/rt.x, lt.y/rt.y)
		end,
		__unm = function(vec) return Vector(-vec.x,-vec.y) end,
		__mod = function(lt, rt)
			if type(rt) == "number" then return Vector(lt.x%rt, lt.y%rt) end
			return Vector(lt.x%rt.x, lt.y%rt.y)
		end,
	}


function Vector(x, y, data)
	local vec = { x = x or 0, y = y or 0 }
	if data and type(data) == "table" then
		for k,v in pairs(data) do vec[k] = v end
	end
	setmetatable(vec,Vector_mt)
	return vec
end

function VectorFromAngle(angle)
	return Vector(math.cos(angle),math.sin(angle))
end

function VectorFromPolar(mod, angle)
	return VectorFromAngle(angle)*mod
end