Cats = Cats or {}

local function recalcHash()
    for _,cat in ipairs(Cats.list) do
        Cats.hash:add(BoxFromVectors(cat.pos, cat.pos + cat.size), cat)
    end
end

function Cats.init()
    Cats.list = {}
    Cats.hash = SpatialHash(128, 128)

    -- initialize in non-colliding positions
    local positions = {}
    for xx = 0,screenSize.x/128 - 1 do
        for yy = 0,screenSize.y/128 - 1 do
            table.insert(positions, Vector(xx*128, yy*128))
        end
    end

    for i = 1,5 do
        Cats.add(table.remove(positions, math.random(#positions)))
    end
    recalcHash()
end

local function getPatience()
    return 0.1 + math.random() * 3
end

local function getWaitingAnim(cat)
    cat.anim = Timers.create(getPatience())
        :andThen(function()
            cat:startMove()
        end)
        :start()
end

local function getMovingAnim(cat)
    local d = getPatience() * 2
    local p1,p2,p3 = d*0.1, d*0.8, d*0.1
    local desiredSpeed = 100 + math.random(100)
    local ot = 0

    cat.dir = VectorFromAngle(math.random()*math.pi*2)
    cat.speed = 0
    cat.anim = Timers.create(p1)
    :withUpdate(function(t)
        local dt = t - ot
        ot = t
        cat.speed = cat.speed + desiredSpeed * dt / p1
        end)
    :thenWait(p2)
    :thenWait(p3)
    :andThen(function() ot = 0 end)
    :withUpdate(function(t)
        local dt = t - ot
        ot = t
        cat.speed = math.max(cat.speed - desiredSpeed * dt / p3, 0)
        end)
    :andThen(function()
        cat.speed = 0
        cat:startWait()
        end)
    :start()
end



function Cats.add(pos)
    local newCat = {
        pos = pos:copy(),
        dir = VectorFromAngle(math.random()*math.pi*2),
        speed = 0,
        size = Vector(128,128),
        startWait = getWaitingAnim,
        startMove = getMovingAnim
        }

    newCat:startWait()

    table.insert(Cats.list, newCat)
end


local function oldupdate(dt)
    for _,cat in ipairs(Cats.list) do
        -- movement
        local newpos = cat.pos + dt * cat.dir * cat.speed

        -- stupid bounce
        if newpos.x < 0 then
            cat.dir.x = -cat.dir.x
            newpos.x = cat.pos.x
        end
        if newpos.x > screenSize.x - cat.size.x then
            cat.dir.x = -cat.dir.x
            newpos.x = cat.pos.x
        end
        if newpos.y < 0 then
            cat.dir.y = -cat.dir.y
            newpos.y = cat.pos.y
        end
        if newpos.y > screenSize.y - cat.size.y then
            cat.dir.y = -cat.dir.y
            newpos.y = cat.pos.y
        end

        cat.pos = newpos

    end

    -- updateHash()
end

function Cats.update(dt)
    for _,cat in ipairs(Cats.list) do
        -- movement
        local newpos = cat.pos + dt * cat.dir * cat.speed

        -- stupid bounce
        if newpos.x < 0 then
            cat.dir.x = -cat.dir.x
            newpos.x = cat.pos.x
        end
        if newpos.x > screenSize.x - cat.size.x then
            cat.dir.x = -cat.dir.x
            newpos.x = cat.pos.x
        end
        if newpos.y < 0 then
            cat.dir.y = -cat.dir.y
            newpos.y = cat.pos.y
        end
        if newpos.y > screenSize.y - cat.size.y then
            cat.dir.y = -cat.dir.y
            newpos.y = cat.pos.y
        end

        cat.pos = newpos

    end

    recalcHash()
end


function Cats.draw()

    -- test background
    love.graphics.setColor(0,0,255)
    love.graphics.rectangle("fill", 0, 0, screenSize.x, screenSize.y)


    local spotCenter = Vector(love.mouse.getX(), love.mouse.getY())
    local lightRadius = 192
    local stencilFunc = function()
        love.graphics.circle("fill", spotCenter.x, spotCenter.y, lightRadius, lightRadius/2)
    end
    love.graphics.stencil(stencilFunc, "replace", 1)

    for _,cat in ipairs(Cats.list) do
        -- draw outside lightspot
        love.graphics.setStencilTest("less", 1)

        love.graphics.setColor(255,255,0)
        love.graphics.rectangle("fill", cat.pos.x, cat.pos.y, cat.size.x, cat.size.y)

        -- draw inside lightspot
        love.graphics.setStencilTest("greater", 0)

        love.graphics.setColor(255,0,0)
        love.graphics.rectangle("fill", cat.pos.x, cat.pos.y, cat.size.x, cat.size.y)
    end

    -- darker overlay
    love.graphics.setStencilTest("less", 1)
    love.graphics.setColor(0,0,0,128)
    love.graphics.rectangle("fill", 0, 0, screenSize.x, screenSize.y)

    -- reset stencil
    love.graphics.setStencilTest()

    -- love.graphics.setColor(255,0,0)
    -- love.graphics.print("test123", 20, 20)

end