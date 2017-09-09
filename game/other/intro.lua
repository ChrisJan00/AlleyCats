Intro = Intro or {}

function Intro.init()
    Intro.flashRadius = screenSize.x
    Intro.startRadius = screenSize.x
    Intro.endRadius = 192
    Cats.allMasked = false

    Intro.Timers = Timers.newInstance()
    Intro.revealActive = false

    local preFlashDuration = 3
    local flashDuration = 2
    local revealDuration = 1
    Intro.Timers.create(preFlashDuration)
        :thenWait(flashDuration)
        :prepare(function()
            -- Cats.allMasked = false
            Cats.launchMasks()
        end)
        :withUpdate(function(t)
            Intro.flashRadius = (Intro.endRadius - Intro.startRadius) * t / flashDuration + Intro.startRadius
        end)
        :thenWait(revealDuration)
        :andThen(function()
            -- Cats.allMasked = true
            Intro.revealActive = true
        end)
        :start()


    Intro.revealBg = love.graphics.newImage("img/bg_find_overlay.png")
    Intro.canvas = love.graphics.newCanvas(screenSize.x, screenSize.y)
end

function Intro.update(dt)
    Intro.Timers.update(dt)
end

function Intro.triggerEndAnim()
    local flashDuration = 4
    Intro.revealActive = false
    Cats.Timers:pauseAll()

    for _,cat in ipairs(Cats.list) do
        cat.speed = 0
    end

    Intro.Timers.create(flashDuration)
        :withUpdate(function(t)
            Intro.flashRadius = (Intro.startRadius - Intro.endRadius) * t / flashDuration + Intro.endRadius
            end)
        :andThen(function()
            init()
        end)
        :start()
end

function Intro.draw()
    if Intro.revealActive then
        local pointer = Vector(love.mouse.getX(), love.mouse.getY())

        love.graphics.setCanvas(Intro.canvas)
            love.graphics.setColor(255,255,255)
            love.graphics.draw(Intro.revealBg)

            love.graphics.draw(Cats.shadowSheet.batch:getTexture(), Cats.shadowSheet.sprites[1][1], 64, 34)
            love.graphics.draw(Cats.bodySheet.batch:getTexture(), Cats.bodySheet.sprites[Cats.selectedBody][1], 64, 34)
            love.graphics.draw(Cats.headSheet.batch:getTexture(), Cats.headSheet.sprites[Cats.selectedMask][1], 64, 34)
            love.graphics.draw(Cats.eyeSheet.batch:getTexture(), Cats.eyeSheet.sprites[Cats.selectedMask][1], 64, 34)
        love.graphics.setCanvas()

        if pointer.x > 360 or pointer.y > 240 then
            love.graphics.setColor(255,255,255)
        else
            love.graphics.setColor(255,255,255, 128)
        end
        love.graphics.draw(Intro.canvas)

    end
end