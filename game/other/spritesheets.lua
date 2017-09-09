function prepareSpritesheet(name, spritew, spriteh)
    local img = love.graphics.newImage(name)

    local ret = {
        batch = love.graphics.newSpriteBatch(img, 1000),
        sprites = {}
    }

    -- left to right, bottom to top
    local xcount = math.floor(img:getWidth() / spritew)
    local ycount = math.floor(img:getHeight() / spriteh)

    for iy = 1, ycount do
        table.insert(ret.sprites, {})
        local yy = (ycount-iy) * spriteh
        for ix = 1, xcount do
            local xx = (ix-1) * spritew
            table.insert(ret.sprites[iy], love.graphics.newQuad(xx, yy, spritew, spriteh, img:getWidth(), img:getHeight()))
        end
    end

    local framerate = 12
    ret.getAnim = function()
        return {
            frame = math.random(xcount),
            row = 1,
            frameCount = xcount,
            rowCount = ycount,
            frameTimer = math.random()*(1/framerate),
            frameDelay = 1/framerate,
            update = updateAnim,
            sync = syncAnim,
            reset = function(anim)
                anim.frame = 1
                anim.frameTimer = 0
            end,
            looping = true,
            totalTime = function(anim)
                return anim.frameCount * anim.frameDelay
            end,
        }
    end

    return ret
end

function updateAnim(anim, dt)
    anim.frameTimer = anim.frameTimer + dt
    while anim.frameTimer > anim.frameDelay do
        anim.frameTimer = anim.frameTimer - anim.frameDelay
        if anim.looping then
            anim.frame = (anim.frame % anim.frameCount) + 1
        else
            anim.frame = math.min(anim.frame + 1, anim.frameCount)
        end
    end
end

function syncAnim(animDest, animRef)
    animDest.frame = animRef.frame
    animDest.frameTimer = animRef.frameTimer
    animDest.row = math.min(animRef.row, animDest.rowCount)
end

function getquad(sheet, anim)
    return sheet.sprites[anim.row][anim.frame]
end
