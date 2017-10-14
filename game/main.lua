function love.load()
    love.filesystem.load("utils/vector.lua")()
    love.filesystem.load("utils/box.lua")()
    love.filesystem.load("utils/bresen.lua")()
    love.filesystem.load("utils/spatialhash.lua")()
    love.filesystem.load("utils/timers.lua")()
    love.filesystem.load("ai/cats.lua")()
    love.filesystem.load("other/background.lua")()
    love.filesystem.load("other/intro.lua")()
    love.filesystem.load("other/spritesheets.lua")()
    screenSize = Vector(1280, 720)

    if love.graphics.getWidth() ~= screenSize.x or love.graphics.getHeight() ~= screenSize.y then
        love.window.setMode(screenSize.x, screenSize.y)
    end

    love.window.setTitle("Alley Cats")

    Cats.init()
    Bg.init()
    Intro.init()

    reset()
end

function reset()
    Cats.reset()
    Bg.reset()
    Intro.reset()
end

function love.draw()
    Bg.draw()
    Cats.draw()
    Intro.draw()
end

function love.update(dt)
    Intro.update(dt)
    Cats.update(dt)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.push("quit")
        return
    end
end

function love.mousepressed(x,y)
    Cats.manageMouseClick()
end
