
require("..engine.globalconf")
require("..engine.input")
require("..engine.utl.funcs")

require("..game.thetower")

local game

function getGame()
	return game
end

function love.load()
	game = TheTower()
end

function love.draw()
	game:draw()
end

function love.update( dt )
	game:update( dt )
end

function love.keypressed( key, scancode, isrepeat )
	glob.devMode.check( key )

  Input:keyPressed( key, scancode, isrepeat )
end

function love.keyreleased( key, scancode, isrepeat )
	Input:keyReleased( key, scancode, isrepeat )
end

function love.mousepressed( x, y, button, istouch )
	Input:mousePressed( x, y, button, istouch )
end

function love.mousereleased( x, y, button, istouch )
	Input:mouseReleased( x, y, button, istouch )
end

function love.mousemoved( x, y, dx, dy )
	Input:mouseMoved( x, y, dx, dy )
end

function love.wheelmoved( x, y )
	Input:wheelMoved( x, y )
end

function love.joystickadded( joystick )
	Input:joystickAdded( joystick )
end

function love.joystickremoved( joystick )
	Input:joystickRemoved( joystick )
end

function love.joystickpressed( joystick, button )
	Input:joystickPressed( joystick, button )
end

function love.joystickreleased( joystick, button )
	Input:joystickReleased( joystick, button )
end

function love.textinput( t )
  Input:textInput( t ) --//TODO refactor?
end
