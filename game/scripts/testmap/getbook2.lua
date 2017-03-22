require("..engine.lclass")

scriptsetup = function( object )
  object.onCollisionEnter = book2CollisionEnter

  local resname, restype, respath = getGame():getResourceManager():getResourceByName( "vale_a" )
  local audio = getGame():getResourceManager():loadAudio( respath )
  getGame():getAudioManager():addSound( "vale_a", audio, 0.4 )
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
    getGame():getAudioManager():playSound( "vale_a" )
  end

end
