Cats = Cats or {}

local function recalcHash()
    for _,cat in ipairs(Cats.list) do
        Cats.hash:add(BoxFromVectors(cat.pos, cat.pos + cat.size), cat)
    end
end

local function initSprites()
    Cats.bodySheet = prepareSpritesheet("img/sheet_cat_body.png", 128, 128)
    Cats.headSheet = prepareSpritesheet("img/sheet_cat_heads.png", 128, 128)
    Cats.maskSheet = prepareSpritesheet("img/sheet_cat_headmasked.png", 128, 128)
    Cats.eyeSheet = prepareSpritesheet("img/sheet_cat_eyes.png", 128, 128)
    Cats.shadowSheet = prepareSpritesheet("img/sheet_cat_shadow.png", 128, 128)
    Cats.poofRevealSheet = prepareSpritesheet("img/sheet_poof_reveal.png", 256, 256)
    Cats.poofHideSheet = prepareSpritesheet("img/sheet_poof_hide.png", 256, 256)
end

local function repool()
    Cats.pool = {}
    for i=1,#Cats.headSheet.sprites do
        if i ~= Cats.selectedMask then
            table.insert(Cats.pool, i)
        end
    end
end

function Cats.init()
    Cats.count = 18

    Cats.Timers = Timers.newInstance()
    Cats.list = {}
    Cats.hash = SpatialHash(128, 128)
    initSprites()
    Cats.selectedMask = math.random(#Cats.maskSheet.sprites)

    Cats.allMasked = true

    -- initialize in non-colliding positions
    local positions = {}
    for xx = 0,screenSize.x/128 - 1 do
        for yy = 0,screenSize.y/128 - 1 do
            table.insert(positions, Vector(xx*128 + 64, yy*128 + 64))
        end
    end

    repool()
    for i = 1,Cats.count do
        Cats.add(table.remove(positions, math.random(#positions)))
    end

    local selected_cat = Cats.list[1]
    selected_cat:setHead(Cats.selectedMask)
    selected_cat.the_one = true
    Cats.selectedBody = selected_cat.body_anim.row

    recalcHash()
end

local function getPatience()
    return 0.1 + math.random() * 3
end

local function getWaitingTimer(cat)
    cat.move_timer = Cats.Timers.create(getPatience())
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
    cat.move_timer = Cats.Timers.create(p1)
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
        looking_dir = math.random(2) == 1 and 1 or -1,

        startWait = getWaitingTimer,
        startMove = getMovingTimer,

        head_anim = Cats.headSheet.getAnim(),
        body_anim = Cats.bodySheet.getAnim(),
        mask_anim = Cats.maskSheet.getAnim(),
        eye_anim = Cats.eyeSheet.getAnim(),
        shadow_anim = Cats.shadowSheet.getAnim(),

        setHead = function(mycat, selection)
            mycat.head_anim.row = selection
            mycat.mask_anim:sync(mycat.head_anim)
            mycat.eye_anim:sync(mycat.head_anim)
            end
        }

    -- local head_selection = 0
    -- repeat
    --     head_selection = math.random(#Cats.headSheet.sprites)
    -- until head_selection ~= Cats.selectedMask

    local head_selection = 1
    if not Cats.pool or #Cats.pool == 0 then
        repool()
    end
    head_selection = table.remove(Cats.pool, math.random(#Cats.pool))

    cat:setHead(head_selection)
    cat.body_anim.row = math.random(#Cats.bodySheet.sprites)
    cat.shadow_anim:sync(cat.body_anim)

    cat:startWait()

    table.insert(Cats.list, cat)
end


function Cats.update(dt)
    Cats.Timers.update(dt)

    for _,cat in ipairs(Cats.list) do
        -- movement
        local newpos = cat.pos + dt * cat.dir * cat.speed

        -- stupid bounce
        if newpos.x < cat.size.x * 0.5 then
            cat.dir.x = -cat.dir.x
            newpos.x = cat.pos.x
        end
        if newpos.x > screenSize.x - cat.size.x * 0.5  then
            cat.dir.x = -cat.dir.x
            newpos.x = cat.pos.x
        end
        if newpos.y < cat.size.y * 0.5 then
            cat.dir.y = -cat.dir.y
            newpos.y = cat.pos.y
        end
        if newpos.y > screenSize.y - cat.size.y * 0.5 then
            cat.dir.y = -cat.dir.y
            newpos.y = cat.pos.y
        end

        cat.pos = newpos

        -- slow down if in course to collision
        local stopDist = cat.size.x * 0.5
        local catsInFront = Cats.hash:getHashForLine(
            BoxFromVectors(cat.pos, cat.pos + cat.dir * stopDist * 2))
        for other,_ in pairs(catsInFront) do
            if other ~= cat then
                local cosang = ((other.pos - cat.pos) * cat.dir)
                if cosang > 0 then
                    local dist = (other.pos - cat.pos):mod() + 1
                    cat.speed = math.min(cat.speed, math.max(0, cat.speed * (dist - stopDist) / stopDist))
                end
            end
        end

        -- look dir
        cat.looking_dir = cat.dir.x < 0 and 1 or -1

        -------------- anims
        cat.head_anim:update(dt)
        cat.mask_anim:update(dt)
        cat.eye_anim:update(dt)

        if cat.speed > 0 then
            cat.shadow_anim:update(dt)
            cat.body_anim:update(dt)
        end

        if cat.poof_reveal_anim then
            cat.poof_reveal_anim:update(dt)
        end

        if cat.poof_hide_anim then
            cat.poof_hide_anim:update(dt)
        end
    end

    recalcHash()
end

function Cats.manageMouseClick()
    if Intro.fixedPointer then
        return
    end

    local spotCenter = Vector(love.mouse.getX(), love.mouse.getY())

    local firstclickcat = false
    for cat,_ in pairs(Cats.hash:getHashForPoint(spotCenter)) do
        local dist = (spotCenter - cat.pos):mod()
        if dist < 64 and not cat.clicked then
            firstclickcat = cat
            break
        end
    end

    if not firstclickcat then
        return
    end

    local cat = firstclickcat
    cat.poof_reveal_anim = Cats.poofRevealSheet.getAnim()
    cat.poof_reveal_anim:reset()
    cat.poof_reveal_anim.looping = false
    cat.clicked = true

    local T = cat.poof_reveal_anim:totalTime()
    Cats.Timers.create(T * 0.3)
        :andThen(function()
            cat.unmasked = true
        end)
        :thenWait(T * 0.7)
        :andThen(function()
            cat.poof_reveal_anim = nil
            if cat.the_one then
                Intro.triggerEndAnim()
            end
        end)
        :start()

end

function Cats.launchMasks()
    Cats.allMasked = false
    for _,cat in ipairs(Cats.list) do
        cat.poof_hide_anim = Cats.poofHideSheet.getAnim()
        cat.poof_hide_anim:reset()
        cat.poof_hide_anim.looping = false

        local T = cat.poof_hide_anim:totalTime()
        Cats.Timers.create(T)
            :andThen(function()
                cat.poof_hide_anim = nil
                end)
            :start()
    end

    Cats.Timers.create(Cats.poofHideSheet.getAnim():totalTime() * 0.3)
        :andThen(function()
            Cats.allMasked = true
        end)
        :start()
end

function wipeSheets()
    Cats.bodySheet.batch:clear()
    Cats.headSheet.batch:clear()
    Cats.maskSheet.batch:clear()
    Cats.eyeSheet.batch:clear()
    Cats.shadowSheet.batch:clear()
    Cats.poofRevealSheet.batch:clear()
    Cats.poofHideSheet.batch:clear()
end

function drawSheets()
    love.graphics.setColor(255,255,255)
    love.graphics.draw(Cats.shadowSheet.batch)
    love.graphics.draw(Cats.bodySheet.batch)
    love.graphics.draw(Cats.headSheet.batch)
    love.graphics.draw(Cats.maskSheet.batch)
    love.graphics.draw(Cats.eyeSheet.batch)
    love.graphics.draw(Cats.poofRevealSheet.batch)
    love.graphics.draw(Cats.poofHideSheet.batch)
end



function Cats.draw()
    local spotCenter = Intro.fixedPointer or Vector(love.mouse.getX(), love.mouse.getY())
    local stencilFunc = function()
        love.graphics.circle("fill", spotCenter.x, spotCenter.y, Intro.flashRadius, Intro.flashRadius/2)
    end
    love.graphics.stencil(stencilFunc, "replace", 1)

    local hs = 64

    local hoveredCats = {}
    for cat,_ in pairs(Cats.hash:getHashForPoint(spotCenter)) do
        local dist = (spotCenter - cat.pos):mod()
        if dist < 64 then
            hoveredCats[cat] = true
        end
    end

    local function aq(sheet, anim, cat)
        local sc = hoveredCats[cat] == true and 1.2 or 1
        sheet.batch:add(getquad(sheet, anim), cat.pos.x, cat.pos.y, 0, sc * cat.looking_dir, sc, cat.size.x*0.5, cat.size.y*0.5)
    end

        local function aq2(sheet, anim, cat)
        sheet.batch:add(getquad(sheet, anim), cat.pos.x, cat.pos.y, 0, cat.looking_dir, 1, cat.size.x, cat.size.y)
    end

    ------------------------------ OUTSIDE
    wipeSheets()
    for _,cat in ipairs(Cats.list) do
        aq(Cats.eyeSheet, cat.eye_anim, cat)
    end

    love.graphics.setStencilTest("less", 1)
    love.graphics.setColor(78, 48, 30)
    love.graphics.rectangle("fill", 0, 0, screenSize.x, screenSize.y)
    drawSheets()


    ------------------------------ INSIDE
    wipeSheets()
    for _,cat in ipairs(Cats.list) do
        aq(Cats.shadowSheet, cat.shadow_anim, cat)
        aq(Cats.bodySheet, cat.body_anim, cat)
        if not Cats.allMasked or cat.unmasked then
            aq(Cats.headSheet, cat.head_anim, cat)
            aq(Cats.eyeSheet, cat.eye_anim, cat)
        else
            aq(Cats.maskSheet, cat.mask_anim, cat)
        end

        if cat.poof_reveal_anim then
            aq2(Cats.poofRevealSheet, cat.poof_reveal_anim, cat)
        end
        if cat.poof_hide_anim then
            aq2(Cats.poofHideSheet, cat.poof_hide_anim, cat)
        end
    end

    love.graphics.setStencilTest("greater", 0)
    drawSheets()


    -- reset stencil
    love.graphics.setStencilTest()

    -- love.graphics.setColor(255,0,0)
    -- love.graphics.print("test123", 20, 20)

end