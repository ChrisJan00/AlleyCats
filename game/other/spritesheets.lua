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

    ret.getAnim = function()
        return {
            frame = 1,
            row = 1,
            frameCount = xcount,
            frameTimer = 0,
            frameDelay = 1/24,
            update = updateAnim
        }
    end

    return ret
end

function updateAnim(anim, dt)
    anim.frameTimer = anim.frameTimer + dt
    while anim.frameTimer > anim.frameDelay do
        anim.frameTimer = anim.frameTimer - anim.frameDelay
        anim.frame = (anim.frame % anim.frameCount) + 1
    end
end

function getquad(sheet, anim)
    return sheet.sprites[anim.row][anim.frame]
end
