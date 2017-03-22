require("..engine.lclass")

local gameobject = nil

scriptsetup = function( object )
  gameobject = object

  gameobject.onCollisionEnter = book2CollisionEnter
end

book2CollisionEnter = function ( caller, otherCollider )

  if ( otherCollider:getOwner():getInstanceName() ~= "PLAYER" ) then
    return
  end

  local name = caller:getInstanceName()

  local objectHit = getGame():queryObjectByName( name )

  if  ( objectHit ) then
    getGame():getInventory():addItem( "book2", 1 )
    getGame():getMessageBox():show( "Pegou um livro: \"Toda Mafalda\"" )
    getGame():destroy( objectHit )
    getGame():getSaveGame():addEventKey( "got" .. objectHit:getInstanceName(), 1 )

    --//TODO add snarky comment

  end

end
