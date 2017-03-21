require("..engine.lclass")

local Vec = require("..engine.math.vector")

class "CollisionManager"

function CollisionManager:CollisionManager()
  self.layers = {}
end

function CollisionManager:addLayer( layerIndex, layerName, collisionEnabled )
  local layer = {
    name      = layerName,
    enabled   = collisionEnabled,
    colliders = {},
    collcount = 0
  }

  self.layers[layerIndex] = layer
end

function CollisionManager:enableLayer( layerIndex, trueToEnable )
  self.layers[layerIndex].enabled = trueToEnable
end

function CollisionManager:addCollider( objectCollider, layer )
  if ( ( objectCollider == nil ) or ( layer == nil ) ) then
    return  -- not a collider, or layer is incorrect
  end

  table.insert( self.layers[layer].colliders, objectCollider )
  self.layers[layer].collcount = self.layers[layer].collcount + 1
end

function CollisionManager:removeCollider( objectCollider, layer )

  if ( objectCollider == nil ) then
    return
  end

  local index = 0

  for i = 1, #self.layers[layer].colliders do
    if ( self.layers[layer].colliders[i]:getOwner():getInstanceName() == objectCollider:getOwner():getInstanceName() ) then
      index = i
    end
  end

  if ( index > 0 ) then
    table.remove( self.layers[layer].colliders, index )
    self.layers[layer].collcount = self.layers[layer].collcount - 1
  end

end

function CollisionManager:clear()
  self.layers = {}
end

function CollisionManager:checkCollisionForLayer( layer )
  if ( not layer.enabled ) then
    return
  end

  for i = 1, layer.collcount do
    for j = 1, layer.collcount do

      if (i ~= j) then

        local coll = collision.check( layer.colliders[i], layer.colliders[j] )

        if ( coll ) then
          layer.colliders[i]:collisionEnter( layer.colliders[j] )
          layer.colliders[j]:collisionEnter( layer.colliders[i] )
        end

      end

    end --for j
  end  -- for i

end

function CollisionManager:checkCollisions()

  --// TODO more efficient collision check

  for i = 1, #self.layers do
    self:checkCollisionForLayer( self.layers[i] )
  end
end

function CollisionManager:checkCollisionForMovement( currentPosition, movementVector, objectCollider, objectLayer )
  local movedPosition = Vec( currentPosition.x + movementVector.x,  currentPosition.y + movementVector.y)

  local futureCollider = objectCollider:clone()
  futureCollider:setOwner( objectCollider:getOwner() )
  futureCollider:changePosition( movementVector.x , movementVector.y )

  local collided = false

  local collIndex = 1

  local checkedAll = self.layers[objectLayer].collcount == 0 -- if no colliders, no check

  while not checkedAll do

    if ( futureCollider:getOwner() ~= self.layers[objectLayer].colliders[collIndex]:getOwner() ) then

      collided = collision.check( futureCollider, self.layers[objectLayer].colliders[collIndex] )

      if ( collided ) then
        --//notifies collision to objects
        if ( self.layers[objectLayer].colliders[collIndex]:isSolid() ) then
          movementVector:set( 0, 0 ) --//TODO change to check the collision and keep moving?
        end

        objectCollider:collisionEnter( self.layers[objectLayer].colliders[collIndex] )
        self.layers[objectLayer].colliders[collIndex]:collisionEnter( objectCollider )

        --[[ --TODO FIX: code below is not working properly, so we set vector to 0 for now
        movementVector = self:orientedCollisionCheck( objectCollider, self.staticColliders[collIndex], movementVector )

        if ( movementVector.x == 0 and movementVector.y == 0 ) then
          checkedAll = true -- cant move, so exit loop
        end
      else
        collIndex = collIndex + 1
        checkedAll = collIndex >= self.staticCollidersCount
      end

      ]]

      end

    end

    collIndex = collIndex + 1

    checkedAll = collIndex > self.layers[objectLayer].collcount
  end

  return movementVector
end

function CollisionManager:orientedCollisionCheck( coll1, coll2, movementVector )
  -- checks whether a collided object can keep moving on in one direction
  -- at least, if the movement is diagonal (x not equal 0, y not equal 0)

  local collx = coll1:clone()
  local colly = coll1:clone()

  collx:changePosition(movementVector.x, 0)
  colly:changePosition(0, movementVector.y)

  local collidedX = collision.check( collx, coll2 )
  local collidedY = collision.check( colly, coll2 )

  if (collidedX and collidedY) then

    return Vec(0,0) -- collided both, cant move

  elseif (collidedX) then

    return Vec(0,movementVector.y) -- can keep going on Y

  else

    return Vec(movementVector.x, 0) -- can keep going on X

  end

end
