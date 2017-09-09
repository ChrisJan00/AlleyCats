local Segment_proto = {
    copy = function(self) return Segment(self.x0,self.y0,self.x1,self.y1) end,
    displace = function(segment, vector) return Segment(segment.x0 + vector.x, segment.y0 + vector.y, segment.x1 + vector.x, segment.y1 + vector.y) end,
    -- intersects = function(segment1, segment2) return segment1.x1 >= segment2.x0 and segment1.x0 <= segment2.x1 and segment1.y0 <= segment2.y1 and segment1.y1 >= segment2.y0 end,
    from = function(segment) return Vector(segment.x0, segment.y0) end,
    to = function(segment) return Vector(segment.x1, segment.y1) end,
    center = function(segment) return Vector((segment.x0+segment.x1)*0.5, (segment.y0+segment.y1)*0.5) end,
    length = function(segment) return (segment:to() - segment:from()):mod() end,
    dirvec = function(segment) return (segment:to() - segment:from()):norm() end,

    floor = function(self)
        return Segment(math.floor(self.x0),math.floor(self.y0),math.floor(self.x1),math.floor(self.y1))
    end,
    unpack = function(self)
        return self.x0,self.y0,self.x1,self.y1
    end,

    containsPoint = function(seg, point)
        local ro_x = seg.x1-seg.x0
        local beta_x = (point.x-seg.x0)/ro_x
        if beta_x < 0 or beta_x>1 then return false end
        local ro_y = seg.y1-seg.y0
        local beta_y = (point.y-seg.y0)/ro_y
        return beta_x == beta_y
    end,

    intersects = function(sb, sa)
        local ro_x,ro_y = sb.x1-sb.x0, sb.y1-sb.y0
        local phi_x,phi_y = sa.x1-sa.x0, sa.y1-sa.y0
        local denom = ro_y*phi_x - ro_x*phi_y
        if denom == 0 then
            if ro_y == 0 and ro_x == 0 then
                return sa:containsPoint(sb:from())
            else
                return sb:containsPoint(sa:from())
            end
        end
        local alpha = (ro_y*sb.x0 - ro_x*sb.y0 + ro_x*sa.y0 - ro_y*sa.x0) / denom
        if alpha < 0 or alpha > 1 then return false end
        if ro_x ~= 0 then
            local beta = (sa.x0 - sb.x0 + phi_x * alpha) / ro_x
            return beta >= 0 and beta <= 1
        else
            local beta = (sa.y0 - sb.y0 + phi_y * alpha) / ro_y
            return beta >= 0 and beta <= 1
        end
    end,
    intersection = function(sb, sa)
        -- repeating code is generally bad, but performance?
        local ro_x,ro_y = sb.x1-sb.x0, sb.y1-sb.y0
        local phi_x,phi_y = sa.x1-sa.x0, sa.y1-sa.y0
        local denom = ro_y*phi_x - ro_x*phi_y
        if denom == 0 then
            if ro_y == 0 and ro_x == 0 then
                if sa:containsPoint(sb:from()) then return sb:from() else return nil end
            else
                if sb:containsPoint(sa:from()) then return sa:from() else return nil end
            end
        end
        local alpha = (ro_y*sb.x0 - ro_x*sb.y0 + ro_x*sa.y0 - ro_y*sa.x0) / denom
        if alpha < 0 or alpha > 1 then return nil end
        if ro_x ~= 0 then
            local beta = (sa.x0 - sb.x0 + phi_x * alpha) / ro_x
            if beta < 0 or beta > 1 then return nil end
        else
            local beta = (sa.y0 - sb.y0 + phi_y * alpha) / ro_y
            if beta < 0 or beta > 1 then return nil end
        end

        return Vector(sa.x0 + alpha * phi_x, sa.y0 + alpha * phi_y)
    end,
    intersectsBox = function(segment, box)
        if box:containsPoint(segment:from()) or box:containsPoint(segment:to()) then return true end
        if not box:intersects(Box(segment:unpack())) then return false end
        return segment:intersects(Segment(box.x0,box.y0, box.x1,box.y0)) or
            segment:intersects(Segment(box.x0,box.y1, box.x1,box.y1)) or
            segment:intersects(Segment(box.x0,box.y0, box.x0,box.y1)) or
            segment:intersects(Segment(box.x1,box.y0, box.x1,box.y1))
    end,
}

local Segment_mt = {
        __index = function(table, key) return Segment_proto[key] end,
        __add = function(lt,rt) return lt:displace(rt) end,
        __sub = function(lt,rt) return lt:displace(-rt) end,
    }


function Segment(x0, y0, x1, y1, data)
    local segment = { x0 = x0 or 0, y0 = y0 or 0, x1 = x1 or 0, y1 = y1 or 0 }
    if data and type(data) == "table" then
        for k,v in pairs(data) do segment[k] = v end
    end
    setmetatable(segment,Segment_mt)
    return segment
end

function SegmentFromBox(box)
    return Segment(box.x0, box.y0, box.x1, box.y1)
end

function SegmentFromVectors(from, to)
    return Segment(from.x, from.y, to.x, to.y)
end

function SegmentRelative(from, dir)
    return Segment(from.x, from.y, from.x+dir.x, from.y+dir.y)
end
