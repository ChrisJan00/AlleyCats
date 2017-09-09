Bg = Bg or {}

function Bg.init()
    Bg.img = love.graphics.newImage("img/BG_placeholder.png")
end

function Bg.draw()
    love.graphics.setColor(255,255,255)
    love.graphics.draw(Bg.img)
end