--[[

anchoring method for fixed position elements (mainly UI elements)

anchor must be :
     0 : CENTER
     1 : EAST
     2 : SOUTHEAST
     3 : SOUTH
     4 : SOUTHWEST
     5 : WEST
     6 : NORTHWEST
     7 : NORTH
     8 : NORTHEAST

way to remember: clockwise rotation starting from east (pi)

the offset for anchoring is relative to the alignment, so it behaves
differently in different anchoring . the general rule is that positive
offsets brings the element close to center, and negative
offsets push it further from center. in center alignments (north, south,
east, west), only one offset is used. the element position is added to the
anchored aligmnent position

--//TODO : testar "enums" com table
--//TODO : considerar posição/offset da camera no alinhamento

https://forums.coronalabs.com/topic/1792-does-lua-support-enums/

]]--

function getAnchoredPosition(anchor, positionX, positionY, offsetX, offsetY, elementWidth, elementHeight, elementScale)
  --//TODO keep screen dimensions reference?

  local screenWidth, screenHeight = love.graphics.getDimensions()

  elementWidth = elementWidth * elementScale
  elementHeight = elementHeight * elementScale

  local halfElementW = elementWidth / 2
  local halfElementH = elementHeight / 2

  local finalPositionX = 0
  local finalPositionY = 0

  if ( anchor == 0 ) then -- center

      finalPositionX = (screenWidth / 2) - halfElementW + offsetX + positionX
      finalPositionY = (sh / 2) - halfElementH + offsetY + positionY

    elseif ( anchor == 1 ) then -- east

      finalPositionX = screenWidth - elementWidth - offsetX + positionX
      finalPositionY = (screenHeight / 2) - halfElementH + positionY

    elseif ( anchor == 2 ) then -- southeast

      finalPositionX = screenWidth - elementWidth - offsetX + positionX
      finalPositionY = screenHeight - elementHeight - offsetY + positionY

    elseif ( anchor == 3 ) then -- south

      finalPositionX = (screenWidth / 2) - halfElementW + positionX
      finalPositionY = screenHeight - elementHeight - offsetY + positionY

    elseif ( anchor == 4 ) then -- southwest

      finalPositionX = offsetX + positionX
      finalPositionY = screenHeight - elementHeight - offsetY + positionY

    elseif ( anchor == 5 ) then -- west

      finalPositionX = offsetX + positionX
      finalPositionY = (screenHeight / 2) - halfElementH + positionY

    elseif ( anchor == 6 ) then -- northwest

      finalPositionX = offsetX + positionX
      finalPositionY = offsetY + self.position.y

    elseif ( anchor == 7 ) then -- north

      finalPositionX = (screenWidth / 2) - halfElementW + positionX
      finalPositionY = offsetY + positionY

    elseif ( anchor == 8 ) then -- northeast

      finalPositionX = screenWidth - elementWidth - offsetX + positionX
      finalPositionY = offsetY + positionY

  end

  return finalPositionX, finalPositionY
end
