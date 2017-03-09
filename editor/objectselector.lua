
require("..engine.lclass")
require("..engine.io.io")
require("..engine.ui/uigroup")
require("..engine.ui/button/button")

require("../editor/textinput")

class "ObjectSelector"

function ObjectSelector:ObjectSelector( )
  self.objects = {}

  self.listStart = 1
  self.listEnd   = 1

  self.menu = UIGroup()
  local addButton = Button( 0, 0, "+", ib_uibutton2, 0.4 )
  addButton:setAnchor( 4, 2, 2 )

  local delButton = Button( 0, 0, "-", ib_uibutton2, 0.4 )
  delButton:setAnchor( 4, 100, 2 )
  --exitButton.onButtonClick = self.exitButtonClick

  self.menu:addButton( addButton )
  self.menu:addButton( delButton )
end

function ObjectSelector:addObject( objectName, objectData )
  table.insert( self.objects, { name = objectName, data = objectData } )
end

function ObjectSelector:select( index )
  return self.objects[index]
end

function ObjectSelector:draw()
  love.graphics.setColor( 255, 255, 255, 30 )

  love.graphics.rectangle( "fill", 0, 0, 200, 720 )

  love.graphics.setColor( glob.defaultColor )

  self.menu:draw()

  if ( #self.objects == 0 ) then
    return
  end

  for i = self.listStart, self.listEnd do
    love.graphics.print( self.objects[i].name, 3, ( (i - self.listStart + 1) * 16) + 56 )
  end

end

function ObjectSelector:isMouseOver( x, y )

end

function ObjectSelector:mousePressed( x, y, button, scaleX, scaleY, sender )

end

function ObjectSelector:mouseMoved( x, y, dx, dy )

  self.menu:mouseMoved( x, y, dx, dy, 1, 1, self )

end

function ObjectSelector:fillList( sourceList )

end
