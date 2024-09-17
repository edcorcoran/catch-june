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
    -- Set up the player sprite.
    local playerImage = gfx.image.new("images/GuyBodyL2")
    assert( playerImage ) -- make sure the image was where we thought

    playerSprite = gfx.sprite.new( playerImage )
    playerSprite:moveTo( 200, 120 ) -- this is where the center of the sprite is placed; (200,120) is the center of the Playdate screen
    playerSprite:add() -- This is critical!
    playerSprite:setCollideRect( 0, 0, playerSprite:getSize() )

    local JuneImage = gfx.image.new("images/Monster")
    assert( JuneImage ) -- make sure the image was where we thought

    juneSprite = gfx.sprite.new( JuneImage )
    local randx = math.random(0,400)
    local randy = math.random(0,240)
    juneSprite:moveTo( randx, randy )
    juneSprite:add() -- This is critical!
    juneSprite:setCollideRect( 0, 0, juneSprite:getSize() )

    -- We want an environment displayed behind our sprite.
    -- There are generally two ways to do this:
    -- 1) Use setBackgroundDrawingCallback() to draw a background image. (This is what we're doing below.)
    -- 2) Use a tilemap, assign it to a sprite with sprite:setTilemap(tilemap),
    --       and call :setZIndex() with some low number so the background stays behind
    --       your other sprites.

    local backgroundImage = gfx.image.new( "images/background" )
    assert( backgroundImage )

    gfx.sprite.setBackgroundDrawingCallback(
        function( x, y, width, height )
            -- x,y,width,height is the updated area in sprite-local coordinates
            -- The clip rect is already set to this area, so we don't need to set it ourselves
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

    -- -- Poll the d-pad and move our player accordingly.
    -- -- (There are multiple ways to read the d-pad; this is the simplest.)
    -- -- Note that it is possible for more than one of these directions
    -- -- to be pressed at once, if the user is pressing diagonally.

    if pd.buttonIsPressed( pd.kButtonUp ) then
        playerSprite:moveBy( 0, -2 )
    end
    if pd.buttonIsPressed( pd.kButtonRight ) then
        playerSprite:moveBy( 2, 0 )
    end
    if pd.buttonIsPressed( pd.kButtonDown ) then
        playerSprite:moveBy( 0, 2 )
    end
    if pd.buttonIsPressed( pd.kButtonLeft ) then
        playerSprite:moveBy( -2, 0 )
    end

    -- Move June
    local direction = math.random(4)
    if direction == 1 then juneSprite:moveBy(0,-4) end
    if direction == 2 then juneSprite:moveBy(4,0) end
    if direction == 3 then juneSprite:moveBy(0,4) end
    if direction == 4 then juneSprite:moveBy(-4,0) end

    -- Call the functions below in playdate.update() to draw sprites and keep
    -- timers updated. (We aren't using timers in this example, but in most
    -- average-complexity games, you will.)

    gfx.sprite.update()
    pd.timer.updateTimers()
end
