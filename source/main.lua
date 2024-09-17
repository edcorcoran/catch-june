import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local pd<const> = playdate
local gfx<const> = pd.graphics

introFlag = 1
math.randomseed(playdate.getSecondsSinceEpoch())

local playerSprite = nil
local juneSprite = nil

local wait_length<const> = 500

local moveOptions = {'up','down', 'left', 'right'}
local lastJuneMovement = moveOptions[math.random(4)]

function gameIntro()
    local font<const> = gfx.getFont()
    
    local phrase_1<const> = "June escaped!"
    local w<const> = font:getTextWidth(phrase_1)
    local h<const> = font:getHeight()
    local x<const> = (400 - w) / 2
    local y<const> = (240 - h) / 2
    gfx.drawText(phrase_1, x, y)
    playdate.wait(wait_length)
    gfx.clear()
  
    local phrase_2<const> = "Now you must ..."
    local w<const> = font:getTextWidth(phrase_2)
    local h<const> = font:getHeight()
    local x<const> = (400 - w) / 2
    local y<const> = (240 - h) / 2
    gfx.drawText(phrase_2, x, y)
    playdate.wait(wait_length)
    gfx.clear()

    local phrase_3<const> = "CATCH JUNE"
    local w<const> = font:getTextWidth(phrase_3)
    local h<const> = font:getHeight()
    local x<const> = (400 - w) / 2
    local y<const> = (240 - h) / 2
    gfx.drawText(phrase_3, x, y)
    playdate.wait(wait_length)
    gfx.clear()
end

function setupGame()
    local playerImage = gfx.image.new("images/GuyBodyL2")
    assert( playerImage )

    playerSprite = gfx.sprite.new( playerImage )
    playerSprite:moveTo( 200, 120 )
    playerSprite:add()
    playerSprite:setCollideRect( 0, 0, playerSprite:getSize() )

    local JuneImage = gfx.image.new("images/Monster")
    assert( JuneImage )

    juneSprite = gfx.sprite.new( JuneImage )
    local randx = math.random(0,400)
    local randy = math.random(0,240)
    juneSprite:moveTo( randx, randy )
    juneSprite:add()
    juneSprite:setCollideRect( 0, 0, juneSprite:getSize() )

      local backgroundImage = gfx.image.new( "images/background" )
    assert( backgroundImage )

    gfx.sprite.setBackgroundDrawingCallback(
        function( x, y, width, height )
            backgroundImage:draw( 0, 0 )
        end
    )

end

function gameWon()
    playerSprite:remove()
    juneSprite:remove()
    gfx.clear()
    local font<const> = gfx.getFont()
    local phrase_1<const> = "You Caught June!"
    local w<const> = font:getTextWidth(phrase_1)
    local h<const> = font:getHeight()
    local x<const> = (400 - w) / 2
    local y<const> = (240 - h) / 2
    gfx.drawText(phrase_1, x, y)
    playdate.wait(1000)
    gfx.clear()
end

function moveJune()
    -- Markov chain movement.
    -- 50% chance you stay in the same direction 
    -- 16.66% chance (50/3) you move one of the other directions. 

    local statetab = {
        up = {'down', 'left', 'right', 'up', 'up', 'up'}
        , down = {'left', 'right', 'up', 'down', 'down', 'down'}
        , left = {'right', 'up', 'down', 'left', 'left', 'left'}
        , right = {'left', 'up', 'down', 'right', 'right', 'right'}
    }

    local list = statetab[lastJuneMovement]
      -- choose a random item from list
    local nextmove = list[math.random(6)]

    if nextmove == 'up' then 
        if juneSprite.y > 0 then juneSprite:moveBy(0,-4) end
    end
    if nextmove == 'right' then 
        if juneSprite.y < 400 then juneSprite:moveBy(4,0) end
    end
    if nextmove == 'down' then 
        if juneSprite.y < 240 then juneSprite:moveBy(0,4) end
    end
    if nextmove == 'left' then juneSprite:moveBy(-4,0)
        if juneSprite.x > 0 then juneSprite:moveBy( -4, 0 ) end
    end


end

function pd.update()

    if introFlag == 1 then
        gameIntro()
        introFlag = 0
        setupGame()
    end


    if playerSprite:alphaCollision(juneSprite) then
        gameWon()
        setupGame()
    end
    -- Player movement
    if pd.buttonIsPressed( pd.kButtonUp ) then
        if playerSprite.y > 0 then playerSprite:moveBy( 0, -2 ) end
    end
    if pd.buttonIsPressed( pd.kButtonRight ) then
        if playerSprite.x < 400 then playerSprite:moveBy( 2, 0 ) end
    end
    if pd.buttonIsPressed( pd.kButtonDown ) then
        if playerSprite.y < 240 then playerSprite:moveBy( 0, 2 ) end
    end
    if pd.buttonIsPressed( pd.kButtonLeft ) then
        if playerSprite.x > 0 then playerSprite:moveBy( -2, 0 ) end
    end

    -- Move June
    moveJune()

    -- local direction = math.random(4)
    -- if direction == 1 then 
    --     if juneSprite.y > 0 then juneSprite:moveBy(0,-4) end
    -- end
    -- if direction == 2 then 
    --     if juneSprite.y < 400 then juneSprite:moveBy(4,0) end
    -- end
    -- if direction == 3 then 
    --     if juneSprite.y < 240 then juneSprite:moveBy(0,4) end
    -- end
    -- if direction == 4 then juneSprite:moveBy(-4,0)
    --     if juneSprite.x > 0 then juneSprite:moveBy( -4, 0 ) end
    -- end

    gfx.sprite.update()
    pd.timer.updateTimers()
end
