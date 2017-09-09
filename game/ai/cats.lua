Cats = Cats or {}

function Cats.init()
    Cats.list = {}
    Cats.hash = SpatialHash(128, 128)
    for i = 0,5 do
        local p = Vector(math.random()*0.5 + 0.25, math.random()*0.5 + 0.25)
        Cats.add(p ^ screenSize)
    end
end

function Cats.add(pos)
    local newCat = {
        pos = pos:copy(),
        dir = VectorFromAngle(math.random()*math.pi*2),
        speed = 100,
        size = Vector(128,128)
        }

    table.insert(Cats.list, newCat)
    -- Cats.hash:add(BoxFromVectors(pos, pos + newCat.size), newCat)
end

-- local function updateHash()
--     for _,cat in ipairs(Cats.list) do
--         Cats.hash:add(BoxFromVectors(cat.pos, cat.pos + cat.size), cat)
--     end
-- end

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

    -- updateHash()
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