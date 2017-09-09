Intro = Intro or {}

function Intro.init()
    Intro.flashRadius = screenSize.x
    Intro.startRadius = screenSize.x
    Intro.endRadius = 192
    Cats.allMasked = false

    Intro.Timers = Timers.newInstance()

    local preFlashDuration = 3
    local flashDuration = 2
    Intro.Timers.create(preFlashDuration)
        :thenWait(flashDuration)
        :prepare(function()
            -- Cats.allMasked = false
            Cats.launchMasks()
        end)
        :withUpdate(function(t)
            Intro.flashRadius = (Intro.endRadius - Intro.startRadius) * t / flashDuration + Intro.startRadius
        end)
        :andThen(function()
            -- Cats.allMasked = true
        end)
        :start()
end

function Intro.update(dt)
    Intro.Timers.update(dt)
end