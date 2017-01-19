
local absfun = math.abs

collision = {

  check = function (collider1, collider2)
    if ( collider1:getKind() == "box" and collider2:getKind() == "box" ) then

      return collision.checkBoxToBox( collider1, collider2 )

    elseif ( collider1:getKind() == "circle" and collider2:getKind() == "circle" ) then

      return collision.checkCircleToCircle( collider1, collider2 )

    elseif ( collider1:getKind() == "box" and collider2:getKind() == "circle" ) then

      return collision.checkBoxToCircle( collider1, collider2 )

    else

      return collision.checkBoxToCircle( collider2, collider1 )

    end

  end,

  checkBoxToBox = function ( collider1, collider2 )

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
  end,

  checkCircleToCircle = function ( collider1, collider2 )
    local x1, y1 = collider1:getCenter()
    local r1 = collider1:getRadius()

    local x2, y2 = collider2:getCenter()
    local r2 = collider2:getRadius()

    local distance = (x1 - x2)^2 + (y1 - y2)^2
    return distance <= (r1 + r2)^2
  end,

  checkBoxToCircle = function ( boxcollider, circlecollider )
    local boxx, boxy, boxw, boxh = boxcollider:getBounds()

    local circlex, circley = circlecollider:getCenter()
    local circler = circlecollider:getRadius()

    local distX = absfun(circlex - boxx - boxw / 2);
    local distY = absfun(circley - boxy - boxh / 2);

    if (distX > (boxw / 2 + circler)) then return false end

    if (distY > (boxh / 2 + circler)) then return false end

    if (distX <= (boxw / 2)) then return true; end

    if (distY <= (boxh / 2)) then return true; end

    local dx = distX - boxw / 2;
    local dy = distY - boxh / 2;

    return (dx * dx + dy * dy <= (circler * circler));
  end
}
