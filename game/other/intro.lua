Intro = Intro or {}

function Intro.init()
    Intro.flashRadius = screenSize.x
    Intro.startRadius = screenSize.x
    Intro.endRadius = 192
    Cats.allMasked = false

    Intro.Timers = Timers.newInstance()

    local flashDuration = 3
    Intro.Timers.create(flashDuration)
        :withUpdate(function(t)
            Intro.flashRadius = (Intro.endRadius - Intro.startRadius) * t / flashDuration + Intro.startRadius
        end):start()
end

function Intro.update(dt)
    Intro.Timers.update(dt)
end