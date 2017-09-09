Cats = Cats or {}

local function recalcHash()
    for _,cat in ipairs(Cats.list) do
        Cats.hash:add(BoxFromVectors(cat.pos, cat.pos + cat.size), cat)
    end
end

local function initSprites()
    Cats.bodySheet = prepareSpritesheet("img/sheet_cat_body_placeholder.png", 128, 128)
    Cats.headSheet = prepareSpritesheet("img/sheet_cat_head_placeholder.png", 128, 128)
    Cats.maskSheet = prepareSpritesheet("img/sheet_cat_headmasked_placeholder.png", 128, 128)
    Cats.eyeSheet = prepareSpritesheet("img/sheet_cat_eyes_placeholder.png", 128, 128)
    -- eyes
    -- poof reveal
    -- poof hide
    -- shadows
end

function Cats.init()
    Cats.list = {}
    Cats.hash = SpatialHash(128, 128)
    initSprites()

    -- initialize in non-colliding positions
    local positions = {}
    for xx = 0,screenSize.x/128 - 1 do
        for yy = 0,screenSize.y/128 - 1 do
            table.insert(positions, Vector(xx*128, yy*128))
        end
    end

    for i = 1,22 do
        Cats.add(table.remove(positions, math.random(#positions)))
    end
    recalcHash()
end

local function getPatience()
    return 0.1 + math.random() * 3
end

local function getWaitingTimer(cat)
    cat.move_timer = Timers.create(getPatience())
        :andThen(function()
            cat:startMove()
        end)
        :start()
end

local function getMovingTimer(cat)
    local d = getPatience() * 2
    local p1,p2,p3 = d*0.1, d*0.8, d*0.1
    local desiredSpeed = 100 + math.random(100)
    local ot = 0

    cat.dir = VectorFromAngle(math.random()*math.pi*2)
    cat.speed = 0
    cat.move_timer = Timers.create(p1)
    :withUpdate(function(t)
        local dt = t - ot
        ot = t
        cat.speed = cat.speed + desiredSpeed * dt / p1
        end)
    :thenWait(p2)
    :andThen(function() ot = 0 end)
    :thenWait(p3)
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
    local cat = {
        pos = pos:copy(),
        dir = VectorFromAngle(math.random()*math.pi*2),
        speed = 0,
        size = Vector(128,128),

        startWait = getWaitingTimer,
        startMove = getMovingTimer,

        head_anim = Cats.headSheet.getAnim(),
        body_anim = Cats.bodySheet.getAnim(),
        mask_anim = Cats.maskSheet.getAnim(),
        eye_anim = Cats.eyeSheet.getAnim(),
        -- shadow
        -- poof
        }

    cat.head_anim.row = math.random(#Cats.headSheet.sprites)
    cat.body_anim.row = math.random(#Cats.bodySheet.sprites)
    cat.mask_anim.row = cat.head_anim.row
    cat.eye_anim.row = cat.head_anim.row

    cat:startWait()

    table.insert(Cats.list, cat)
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

        -- slow down if in course to collision
        local stopDist = cat.size.x * 0.5
        local catCenter = cat.pos + cat.size * 0.5
        local catsInFront = Cats.hash:getHashForLine(
            BoxFromVectors(catCenter, catCenter + cat.dir * stopDist * 2))
        for other,_ in pairs(catsInFront) do
            if other ~= cat then
                local cosang = ((other.pos - cat.pos) * cat.dir)
                if cosang > 0 then
                    local dist = (other.pos - cat.pos):mod() + 1
                    cat.speed = math.min(cat.speed, math.max(0, cat.speed * (dist - stopDist) / stopDist))
                end
            end
        end

        -------------- anims
        cat.head_anim:update(dt)
        cat.body_anim:update(dt)
        cat.mask_anim:update(dt)
        cat.eye_anim:update(dt)

    end

    recalcHash()
end

function wipeSheets()
    Cats.bodySheet.batch:clear()
    Cats.headSheet.batch:clear()
    Cats.maskSheet.batch:clear()
    Cats.eyeSheet.batch:clear()
end

function drawSheets()
    love.graphics.setColor(255,255,255)
    love.graphics.draw(Cats.bodySheet.batch)
    love.graphics.draw(Cats.headSheet.batch)
    love.graphics.draw(Cats.maskSheet.batch)
    love.graphics.draw(Cats.eyeSheet.batch)
end

function Cats.draw()
    local spotCenter = Vector(love.mouse.getX(), love.mouse.getY())
    local lightRadius = 192
    local stencilFunc = function()
        love.graphics.circle("fill", spotCenter.x, spotCenter.y, lightRadius, lightRadius/2)
    end
    love.graphics.stencil(stencilFunc, "replace", 1)

    ------------------------------ OUTSIDE
    wipeSheets()
    for _,cat in ipairs(Cats.list) do
        -- Cats.bodySheet.batch:add(getquad(Cats.bodySheet, cat.body_anim), cat.pos.x, cat.pos.y)
        -- Cats.headSheet.batch:add(getquad(Cats.headSheet, cat.head_anim), cat.pos.x, cat.pos.y)
        -- Cats.maskSheet.batch:add(getquad(Cats.maskSheet, cat.mask_anim), cat.pos.x, cat.pos.y)
        Cats.eyeSheet.batch:add(getquad(Cats.eyeSheet, cat.eye_anim), cat.pos.x, cat.pos.y)
    end

    love.graphics.setStencilTest("less", 1)
    love.graphics.setColor(89, 89, 102)
    love.graphics.rectangle("fill", 0, 0, screenSize.x, screenSize.y)
    drawSheets()
    -- love.graphics.setColor(0,0,0,128)
    -- love.graphics.rectangle("fill", 0, 0, screenSize.x, screenSize.y)

    ------------------------------ INSIDE
    wipeSheets()
    for _,cat in ipairs(Cats.list) do
        Cats.bodySheet.batch:add(getquad(Cats.bodySheet, cat.body_anim), cat.pos.x, cat.pos.y)
        -- Cats.headSheet.batch:add(getquad(Cats.headSheet, cat.head_anim), cat.pos.x, cat.pos.y)
        Cats.maskSheet.batch:add(getquad(Cats.maskSheet, cat.mask_anim), cat.pos.x, cat.pos.y)
        -- Cats.eyeSheet.batch:add(getquad(Cats.eyeSheet, cat.eye_anim), cat.pos.x, cat.pos.y)
    end

    love.graphics.setStencilTest("greater", 0)
    drawSheets()


    -- reset stencil
    love.graphics.setStencilTest()

    -- love.graphics.setColor(255,0,0)
    -- love.graphics.print("test123", 20, 20)

end