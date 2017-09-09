Bg = Bg or {}

function Bg.init()
    Bg.img = love.graphics.newImage("img/bg.png")
end

function Bg.draw()
    love.graphics.setColor(255,255,255)
    love.graphics.draw(Bg.img)
end