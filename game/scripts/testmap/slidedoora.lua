local Vec = require("..engine.math.vector")

local opening    = 0
local targetx    = nil
local gameobject = nil
local absfun     = math.abs

scriptsetup = function( object )
  gameobject = object
  object.scriptupdate  = dooraUpdate
  targetx = object:getPosition().x - 60
end

dooraUpdate = function( caller, dt )
  if ( opening == 1 ) then
    local pos = gameobject:getPosition()
    local vel = Vec( -10, 0 ) * dt

    if ( absfun( targetx - pos.x ) > 0.1 ) then
      gameobject:changePosition( vel )
    else
      opening = 2
    end
  elseif ( opening == 0 ) then
    local prop = caller:getProperty()

    if ( prop == 1 ) then
      opening = 1
    end
  end
end
