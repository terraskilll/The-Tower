require("../engine/lclass")

local Vec = require("../engine/math/vector")

class "CollisionManager"

function CollisionManager:CollisionManager()
  self.collidersCount = 0
  self.colliders = {}
end

function CollisionManager:addCollider( objectWithCollider )
  if ( objectWithCollider == nil ) then
    return  -- not a collider
  end

  table.insert( self.colliders, objectWithCollider )
  self.collidersCount = #self.colliders
end

function CollisionManager:checkCollisions()

  for i=1, self.collidersCount do
    for j=1, self.collidersCount do

      if (i ~= j) then

        local coll = collision.check( self.colliders[i], self.colliders[j] )

        if ( coll ) then
          self.colliders[i]:collisionEnter( self.colliders[j] )
          self.colliders[j]:collisionEnter( self.colliders[i] )
        end

      end

    end
  end

end

function CollisionManager:checkCollisionForMovement( currentPosition, movementVector, objectCollider )
  local movedPosition = Vec( currentPosition.x + movementVector.x,  currentPosition.y + movementVector.y)

  local futureCollider = objectCollider:clone()
  futureCollider:setOwner( objectCollider:getOwner() )
  futureCollider:changePosition( movementVector.x , movementVector.y )

  local collided = false

  local collIndex = 1

  local checkedAll = self.collidersCount == 0 -- if no colliders, no check

  while not checkedAll do

    if ( futureCollider:getOwner() ~= self.colliders[collIndex]:getOwner() ) then

      collided = collision.check( futureCollider, self.colliders[collIndex] )

      if ( collided ) then
        --//notifies collision to objects
        self.colliders[collIndex]:collisionEnter( objectCollider )
        objectCollider:collisionEnter( self.colliders[collIndex] )

        if ( self.colliders[collIndex]:isSolid() ) then
          movementVector:set( 0, 0 ) --//TODO change to check the collision and keep moving?
        end

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

    checkedAll = collIndex > self.collidersCount
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
