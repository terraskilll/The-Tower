--[[--

Manages the command input in the game (keyboard, mouse, joystick)

Receive the commands and sends them to the registered listeners

TODO
	tratar nils nos listeners (if listener)
	nao repassar eventos para os demais listeners caso sejam processados pelo listener anterior (no chaining)
--]]--

local Vec = require("..engine.math.vector")

local absfun = math.abs
local sqrt   = math.sqrt

local joyid = nil

Input = {
	overallListener       = nil,
	currentScreenListener = nil,
	inputByKeyboard       = true,
  camera                = nil,
  joystick              = nil,
  joyOffset             = 0.5,
	axis                  = Vec(0,0)
}

function Input:update( dt )

  --//TODO general refactor

	Input.axis.x = 0
	Input.axis.y = 0

  if (self.joystick ~= nil) then
    Input.axis.x = self.joystick:getAxis(1)
    Input.axis.y = self.joystick:getAxis(2)

    if ( absfun(Input.axis.x) > Input.joyOffset ) then

			Input.inputByKeyboard = false

			if (Input.axis.x < 0) then
        Input.axis.x = -1
      else
        Input.axis.x = 1
      end

		else
			Input.axis.x = 0
    end

    if ( absfun(Input.axis.y) > Input.joyOffset ) then

			Input.inputByKeyboard = false

			if (Input.axis.y < 0) then
        Input.axis.y = -1
      else
        Input.axis.y = 1
      end

		else
			Input.axis.y = 0
    end

  end

	if (Input:isKeyDown("down")) then
		Input.axis.y = 1
	elseif (Input:isKeyDown("up")) then
		Input.axis.y = -1
	end

	if (Input:isKeyDown("right")) then
		Input.axis.x = 1
	elseif (Input:isKeyDown("left")) then
		Input.axis.x = -1
	end

	--normalize the axis values
	Input.axis:normalize()

end

-- [[ TECLADO ]] --

function Input:keyPressed( key, scancode, isrepeat )

	Input.inputByKeyboard = true

	if not Input.overallListener:onKeyPress( key, scancode, isrepeat ) then

		if ( Input.currentScreenListener.onKeyPress ) then
			Input.currentScreenListener:onKeyPress( key, scancode, isrepeat )
		end

	end

end

function Input:keyReleased( key, scancode, isrepeat )
	if not Input.overallListener:onKeyRelease( key, scancode, isrepeat ) then

		if ( Input.currentScreenListener.onKeyRelease ) then
			Input.currentScreenListener:onKeyRelease( key, scancode, isrepeat )
		end

	end
end

function Input:isKeyDown(key)

	local isDown = love.keyboard.isDown( key )

	if (isDown) then
		Input.inputByKeyboard = true
	end

	return love.keyboard.isDown( key )

end

function Input:textInput( t )

	if ( Input.currentScreenListener.textInput ) then
		Input.currentScreenListener:textInput( t )
	end

end

-- [[ MOUSE ]] --

function Input:mousePressed( x, y, button, istouch )

	--mx, my = Input.camera:mousePosition() --correct position by scale

	local scaleX, scaleY = Input.camera:getScale()

	if not Input.overallListener:onMousePress( x, y, button, scaleX, scaleY, istouch ) then

		if ( Input.currentScreenListener.onMouseMove ) then
			Input.currentScreenListener:onMousePress( x, y, button, scaleX, scaleY, istouch )
		end

	end

end

function Input:mouseReleased( x, y, button, istouch )
	mx, my = Input.camera:mousePosition() -- correct position by scale

	local scaleX, scaleY = Input.camera:getScale()

	if not Input.overallListener:onMouseRelease( x, y, button, scaleX, scaleY, istouch ) then

		if ( Input.currentScreenListener.onMouseMove ) then
			Input.currentScreenListener:onMouseRelease( x, y, button, scaleX, scaleY, istouch )
		end

	end

end

function Input:mouseMoved( x, y, dx, dy )

	local scaleX, scaleY = Input.camera:getScale()

	if not Input.overallListener:onMouseMove( x, y, dx, dy ) then

		if ( Input.currentScreenListener.onMouseMove ) then
			Input.currentScreenListener:onMouseMove( x, y, dx, dy, scaleX, scaleY )
		end

	end

end

function Input:wheelMoved( xm, ym )
	if not Input.overallListener:onMouseWheelMoved( xm, ym ) then

		if ( Input.currentScreenListener.onMouseWheelMoved ) then
			Input.currentScreenListener:onMouseWheelMoved( xm, ym )
		end

	end
end

function Input:mousePosition()
	--//TODO check for camera?
	return love.mouse.getPosition()
end

-- [[ JOYSTICK / GAMEPAD ]] --

function Input:joystickAdded( joystick )
	local joysticks = love.joystick.getJoysticks()
  Input.joystick  = joysticks[1]

	Input.joyid = joysticks[1]:getID()

	--print("Joystick ID : " .. Input.joyid)
end

function Input:joystickRemoved( joystick )
	-- TODO ?
end

function Input:joystickPressed( joystick, button )
	if joystick:getID() == Input.joyid then

		Input.inputByKeyboard = false

		if (Input.currentScreenListener.joystickPressed ~= nil) then
      Input.currentScreenListener:joystickPressed(joystick, button)
    end

  end

end

function Input:joystickReleased( joystick, button )
  if joystick:getID() == Input.joyid then

    if ( Input.currentScreenListener.joystickReleased ) then
      Input.currentScreenListener:joystickReleased( joystick, button )
    end

  end
end

function Input:getAxis()
  return Vec( Input.axis.x, Input.axis.y )
end

function Input:isInputByKeyboard()
	return Input.inputByKeyboard
end
