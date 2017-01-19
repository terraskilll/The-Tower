--[[--


Manages the command input in the game (keyboard, mouse, joystick)


Receive the commands and sends them to the registered listeners

TODO
	tratar nils nos listeners (if listener)
	nao repassar eventos para os demais listeners caso sejam processados pelo listener anterior (no chaining)
--]]--

local Vec = require("../engine/math/vector")

local absfun = math.abs
local sqrt   = math.sqrt

local joyid = nil

local normalizee = function(v1, v2)
	local mag = sqrt(v1 * v1 + v2 * v2)

	if mag > 0 then
    v1, v2 = v1/mag, v2/mag
  end

  return v1, v2
end

Input = {
	overallListener = nil,
	currentScreenListener = nil,
  camera = nil,
  joystick = nil,
  joyOffset = 0.5,
  axisX = 0, --//TODO change to vetor?
  axisY = 0
}

function Input:update(dt)

  --//TODO general refactor

	Input.axisX = 0
	Input.axisY = 0

  if (self.joystick ~= nil) then
    Input.axisX = self.joystick:getAxis(1)
    Input.axisY = self.joystick:getAxis(2)

    if ( absfun(Input.axisX) > Input.joyOffset ) then
      if (Input.axisX < 0) then
        Input.axisX = -1
      else
        Input.axisX = 1
      end
		else
			Input.axisX = 0
    end

    if ( absfun(Input.axisY) > Input.joyOffset ) then
      if (Input.axisY < 0) then
        Input.axisY = -1
      else
        Input.axisY = 1
      end
		else
			Input.axisY = 0
    end

  end

	if (love.keyboard.isDown("down")) then
		Input.axisY = 1
	elseif (love.keyboard.isDown("up")) then
		Input.axisY = -1
	end

	if (love.keyboard.isDown("right")) then
		Input.axisX = 1
	elseif (love.keyboard.isDown("left")) then
		Input.axisX = -1
	end

	--normalize the axis values
	--//TODO revise when using vector
	Input.axisX , Input.axisY = normalizee(Input.axisX, Input.axisY)
end

-- [[ TECLADO ]] --

function Input:keyPressed(key, scancode, isrepeat)
	if not Input.overallListener:onKeyPress(key, scancode, isrepeat) then
		Input.currentScreenListener:onKeyPress(key, scancode, isrepeat)
	end
end

function Input:keyReleased(key, scancode, isrepeat)
	if not Input.overallListener:onKeyRelease(key, scancode, isrepeat) then
		Input.currentScreenListener:onKeyRelease(key, scancode, isrepeat)
	end
end

function Input:isKeyDown(key)
	return love.keyboard.isDown(key)
end

function Input:textInput( t )
	if ( Input.currentScreenListener.textInput ) then
		Input.currentScreenListener:textInput( t )
	end
end

-- [[ MOUSE ]] --

function Input:mousePressed(x, y, button, istouch)
	mx, my = Input.camera:mousePosition() -- correct position by scale
end

function Input:mouseReleased(x, y, button, istouch)
	mx, my = Input.camera:mousePosition() -- correct position by scale
end

function Input.mouseMoved(x, y, dx, dy, istouch)
	mx, my = Input.camera:mousePosition() -- correct position by scale
end

function Input.wheelMoved(x, y)
	Input:checkJoysticksConnected()
end

-- [[ JOYSTICK / GAMEPAD ]] --

function Input:joystickAdded(joystick)
	local joysticks = love.joystick.getJoysticks()
  Input.joystick = joysticks[1]

	Input.joyid = joysticks[1]:getID()

	print("Joystick ID : " .. Input.joyid)
end

function Input:joystickRemoved(joystick)
	-- TODO ?
end

function Input:joystickPressed(joystick, button)
	if joystick:getID() == Input.joyid then

		if (Input.currentScreenListener.joystickPressed ~= nil) then
      Input.currentScreenListener:joystickPressed(joystick, button)
    end

  end
end

function Input:joystickReleased(joystick, button)
  if joystick:getID() == Input.joyid then

    if (Input.currentScreenListener.joystickReleased ~= nil) then
      Input.currentScreenListener:joystickReleased(joystick, button)
    end

  end
end

function Input:getAxis()
  return Input.axisX, Input.axisY
end
