require("..engine.lclass")

local gameobject = nil

local used = false

scriptsetup = function( object )
  gameobject = object

  gameobject.onCollisionEnter = usebluekeyCollisionEnter
end

usebluekeyCollisionEnter = function ( caller, otherCollider )

  if ( used ) then
    return
  end

  if ( otherCollider:getOwner():getInstanceName() ~= "PLAYER" ) then
    return
  end

  if ( getGame():getInventory():consumeItem( "bluekey" ) ) then
    getGame():getMessageBox():show( "Usou a Chave Azul" )
    used = true
  else
    getGame():getMessageBox():show( "Falta a Chave Azul" )
  end
end
