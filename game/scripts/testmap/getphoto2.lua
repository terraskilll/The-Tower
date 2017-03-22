require("..engine.lclass")

local gameobject = nil

scriptsetup = function( object )
  gameobject = object

  gameobject.onCollisionEnter = photo2CollisionEnter
end

photo2CollisionEnter = function ( caller, otherCollider )

  if ( otherCollider:getOwner():getInstanceName() ~= "PLAYER" ) then
    return
  end

  local name = caller:getInstanceName()

  local objectHit = getGame():queryObjectByName( name )

  if  ( objectHit ) then
    getGame():getInventory():addItem( "photo2", 1 )
    getGame():getMessageBox():show( "Achou um colecionável (Foto)" )
    getGame():destroy( objectHit )
    getGame():getSaveGame():addEventKey( "got" .. objectHit:getInstanceName(), 1 )

    --//TODO add snarky comment
  end

end
