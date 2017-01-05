
function checkCollision(collider1, collider2)
  local x1, y1, w1, h1 = collider1:getBounds()  
  local x2, y2, w2, h2 = collider2:getBounds()
  
  if (x1 < x2 + w2 and
      x1 + w1 > x2 and
      y1 < y2 + h2 and
      y1 + h1 > y2)  then

    return true
  else
    return false
  end
end


--[[

if (rect1.x < rect2.x + rect2.width &&
   rect1.x + rect1.width > rect2.x &&
   rect1.y < rect2.y + rect2.height &&
   rect1.height + rect1.y > rect2.y) {
    // collision detected!
}

]]--