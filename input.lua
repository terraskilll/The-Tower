--[[--

Gerencia a entrada de comandos no jogo (teclado, mouse, joystick)

Recebe os diversos comandos e repassa aos devidos listeners registrados

TODO
	tratar nils nos listeners (if listener)
	nao repassar eventos para os demais listeners caso sejam processados pelo listener anterior (no chaining)
--]]--

--require("lclass")

--class "Input"

local joyid = nil

Input = {
	overallListener = nil,
	currentScreenListener = nil,
  camera = nil,
  joystick = nil,
  joyOffset = 0.5,
  axisY = 0,
  axisY = 0
}

function Input:update(dt)

  --//TODO general refactor 

  if (self.joystick ~= nil) then
    self.axisX = self.joystick:getAxis(1)
    self.axisY = self.joystick:getAxis(2)

    if (math.abs(self.axisX) < self.joyOffset) then
      self.axisX = 0
    else
      if (self.axisX < 0) then
        self.axisX = -1
      else
        self.axisX = 1
      end
    end

    if (math.abs(self.axisY) < self.joyOffset) then
      self.axisY = 0
    else
      if (self.axisY < 0) then
        self.axisY = -1
      else
        self.axisY = 1
      end
    end
  end

  --//TODO add keyboard control support

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

-- [[ MOUSE ]] --

function Input:mousePressed(x, y, button, istouch)
	mx, my = self.camera:mousePosition() -- correct position by scale
end

function Input:mouseReleased(x, y, button, istouch)
	mx, my = self.camera:mousePosition() -- correct position by scale
end

function Input.mouseMoved(x, y, dx, dy, istouch)
	mx, my = self.camera:mousePosition() -- correct position by scale
end

function Input.wheelMoved(x, y)
	Input:checkJoysticksConnected()
end

-- [[ JOYSTICK / GAMEPAD ]] --

function Input:joystickAdded(joystick)
	local joysticks = love.joystick.getJoysticks()
  self.joystick = joysticks[1]
 
	self.joyid = joysticks[1]:getID()

	print("Joystick ID : " .. self.joyid)
end

function Input:joystickRemoved(joystick)
	-- TODO ? 
end

function Input:joystickPressed(joystick, button)
	if joystick:getID() == self.joyid then

		if (Input.currentScreenListener.joystickPressed ~= nil) then
      Input.currentScreenListener:joystickPressed(joystick, button)
    end
	
  end
end

function Input:joystickReleased(joystick, button)
  if joystick:getID() == self.joyid then
    
    if (Input.currentScreenListener.joystickReleased ~= nil) then
      Input.currentScreenListener:joystickReleased(joystick, button)
    end
  
  end
end

function Input:getAxis()
  return self.axisX, self.axisY
end