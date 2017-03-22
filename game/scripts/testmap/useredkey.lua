require("..engine.lclass")

require("..game.scripts.testmap.openenddoor")

local gameobject = nil

local used = false

scriptsetup = function( object )
  gameobject = object

  gameobject.onCollisionEnter = useredkeyCollisionEnter
end

useredkeyCollisionEnter = function ( caller, otherCollider )

  if ( used ) then
    return
  end

  if ( otherCollider:getOwner():getInstanceName() ~= "PLAYER" ) then
    return
  end

  if ( getGame():getInventory():consumeItem( "redkey" ) ) then
    getGame():getMessageBox():show( "Usou a Chave Vermelha" )
    getGame():getSaveGame():addEventKey( "redkeyopen", 1 )
    openEndDoor()
    used = true
  else
    getGame():getMessageBox():show( "Falta a Chave Vermelha" )
  end
end
