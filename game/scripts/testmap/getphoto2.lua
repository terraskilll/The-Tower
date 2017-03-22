require("..engine.lclass")

scriptsetup = function( object )
  object.onCollisionEnter = photo2CollisionEnter

  local resname, restype, respath = getGame():getResourceManager():getResourceByName( "naoserve_a" )
  local audio = getGame():getResourceManager():loadAudio( respath )
  getGame():getAudioManager():addSound( "naoserve_a", audio, 0.4 )
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
    getGame():getAudioManager():playSound( "naoserve_a" )
  end

end
