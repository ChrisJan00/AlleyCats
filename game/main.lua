require 'livecode'

function love.load()
    init()
end

function love.livereload()
    init()
end

function init()
    love.filesystem.load("vector.lua")()
    screenSize = Vector(1280, 720)

    if love.graphics.getWidth() ~= screenSize.x or love.graphics.getHeight() ~= screenSize.y then
        love.window.setMode(screenSize.x, screenSize.y)
    end
end

function love.draw()
end

function love.update(dt)
end
