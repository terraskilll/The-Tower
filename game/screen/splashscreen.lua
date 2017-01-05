require ("lclass")

require("../input")
require("../screen/screen")
require("../gameobject/gameobject")
require("../gameobject/staticimage")

class "SplashScreen" ("Screen")

function SplashScreen:SplashScreen(theGame)
  self.game = theGame
end

function SplashScreen:onEnter()
  
end

function SplashScreen:onExit()
  
end

function SplashScreen:update(dt)
  
end

function SplashScreen:draw()
  self.game:getPlayer():draw()
end

function SplashScreen:onKeyPress(key, scancode, isrepeat)

end

function SplashScreen:onKeyRelease(key, scancode, isrepeat)
	
end