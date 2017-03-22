require("..engine.lclass")

local gameobject = nil

scriptsetup = function( object )
  gameobject = object

  gameobject.onCollisionEnter = bluekeyCollisionEnter
end

bluekeyCollisionEnter = function ( caller, otherCollider )

  if ( otherCollider:getOwner():getInstanceName() ~= "PLAYER" ) then
    return
  end

  local name = caller:getInstanceName()

  local objectHit = getGame():queryObjectByName( name )

  if  ( objectHit ) then
    getGame():getInventory():addItem( "bluekey", 1 )
    getGame():getMessageBox():show( "Pegou a Chave Azul" )
    getGame():destroy( objectHit )
    getGame():getSaveGame():addEventKey( "got" .. objectHit:getInstanceName(), 1 )
  end

end
