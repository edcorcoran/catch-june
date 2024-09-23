import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local pd<const> = playdate
local gfx<const> = pd.graphics
local snd<const> = pd.sound
local wait_length<const> = 500

introFlag = 1
math.randomseed(playdate.getSecondsSinceEpoch())

local playerSprite = nil
local juneSprite = nil

local moveOptions = {'up','down', 'left', 'right'}
local lastJuneMovement = moveOptions[math.random(4)]
local barkCounter = 0


-- sprite images
local playerImageWalkingUp = gfx.image.new("images/GuyBodyL2")
local playerImageWalkingDown = gfx.image.new("images/GuyBodyR2")
local playerImageWalkingRight = gfx.image.new("images/GuyBodyL1")
local playerImageWalkingLeft = gfx.image.new("images/GuyBodyR1")
assert( playerImageWalkingUp )
assert( playerImageWalkingDown )
assert( playerImageWalkingRight )
assert( playerImageWalkingLeft )

local JuneImage = gfx.image.new("images/dog")
assert( JuneImage )

-- sound & music sources 
local backgroundMusic = snd.fileplayer.new("sounds/music")
assert ( backgroundMusic )

local dogbark = snd.sampleplayer.new("sounds/bark")
assert (dogbark)

function gameIntro()
    -- start music
    -- backgroundMusic:play(0)
    
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
    
    playerSprite = gfx.sprite.new( playerImageWalkingUp )
    playerSprite:moveTo( 200, 120 )
    playerSprite:add()
    playerSprite:setCollideRect( 0, 0, playerSprite:getSize() )

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
    math.randomseed(playdate.getSecondsSinceEpoch())
    -- Markov chain movement.
    -- 12 options; 3/12 = 1/4 = 25% chance of changing 
    local statetab = {
        up = {'down', 'left', 'right', 'up', 'up', 'up', 'up', 'up', 'up', 'up', 'up', 'up'}
        , down = {'left', 'right', 'up', 'down', 'down', 'down', 'down', 'down', 'down', 'down', 'down', 'down'}
        , left = {'right', 'up', 'down', 'left', 'left', 'left', 'left', 'left', 'left', 'left', 'left', 'left'}
        , right = {'left', 'up', 'down', 'right', 'right', 'right', 'right', 'right', 'right', 'right', 'right', 'right'}
    }

    -- choose a random item from list
    local list = statetab[lastJuneMovement]
    local nextmove = list[math.random(#list)]

    -- if June hits the boundaries of the screen, switch direction
    if juneSprite.x < 0 then nextmove = 'right' end -- too far left
    if juneSprite.y < 0 then nextmove = 'down' end -- too far up 
    if juneSprite.x > 400 then nextmove = 'left' end -- too far right
    if juneSprite.y > 240 then nextmove = 'up' end -- too far down 

    -- bark every 10 times June changes direction 
    -- print(barkCounter)
    if nextmove ~= lastJuneMovement then
        barkCounter = barkCounter + 1
        if math.fmod(barkCounter,10) == 0 then dogbark:play() end
    end

    if nextmove == 'up' then 
        juneSprite:moveBy(0,-4)
    end
    if nextmove == 'right' then 
        juneSprite:moveBy(4,0)
    end
    if nextmove == 'down' then 
        juneSprite:moveBy(0,4)
    end
    if nextmove == 'left' then 
        juneSprite:moveBy(-4,0)
    end

    lastJuneMovement = nextmove

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
    local scaling_factor<const> = 1.5

    if pd.buttonIsPressed( pd.kButtonUp ) then
        if playerSprite.y > 0 then playerSprite:moveBy( 0, -2 ) end
        playerSprite:setImage(playerImageWalkingUp, 0, 1)
        playerSprite:setCollideRect( 0, 0, playerSprite:getSize() )
    end
    if pd.buttonIsPressed( pd.kButtonRight ) then
        if playerSprite.x < 400 then playerSprite:moveBy( 2, 0 ) end
        playerSprite:setImage(playerImageWalkingRight, 0 , scaling_factor)
        playerSprite:setCollideRect( 0, 0, playerSprite:getSize() )
    end
    if pd.buttonIsPressed( pd.kButtonDown ) then
        if playerSprite.y < 240 then playerSprite:moveBy( 0, 2 ) end
        playerSprite:setImage(playerImageWalkingDown, 0, 1)
        playerSprite:setCollideRect( 0, 0, playerSprite:getSize() )
    end
    if pd.buttonIsPressed( pd.kButtonLeft ) then
        if playerSprite.x > 0 then playerSprite:moveBy( -2, 0 ) end
        playerSprite:setImage(playerImageWalkingLeft, 0 , scaling_factor)
        playerSprite:setCollideRect( 0, 0, playerSprite:getSize() )
    end

    -- Move June
    moveJune()

    gfx.sprite.update()
    pd.timer.updateTimers()
end
