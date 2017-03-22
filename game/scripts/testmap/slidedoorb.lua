local Vec = require("..engine.math.vector")

local opening = 0

local targetx   = nil

local gameobject = nil

local absfun = math.abs

scriptsetup = function( object )
  gameobject = object

  object.scriptupdate  = doorbUpdate

  targetx = object:getPosition().x + 60
end

doorbUpdate = function( caller, dt )
  if ( opening == 1 ) then
    local pos = gameobject:getPosition()
    local vel = Vec( 10, 0 ) * dt

    if ( absfun( pos.x - targetx ) > 0.1 ) then
      gameobject:changePosition( vel )
    else
      opening = 2
    end
  elseif ( opening == 0 ) then
    local prop = caller:getProperty()

    if ( prop == 1 ) then
      opening = 1
      --//TODO open sound?
    end
  end
end
