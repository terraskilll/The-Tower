require("..engine.lclass")

local utf8 = require("utf8")

class "TextInput"

function TextInput:TextInput(inputCaption, initialText)
  self.caption = inputCaption
  self.text    = initialText or ""

  self.finished = false
end

function TextInput:draw()

  love.graphics.setColor(0, 255, 100, 255)
  love.graphics.print(self.caption, 20, 20)
  love.graphics.setColor(glob.defaultColor)

  love.graphics.print(self.text, 20, 40)
end

function TextInput:update(dt)

end

function TextInput:getText()
  return self.text
end

function TextInput:input(t)
  self.text = self.text .. t
end

function TextInput:isFinished()
  return self.finished
end

function TextInput:keypressed( key )
  --https://love2d.org/wiki/love.textinput

  if key == "backspace" then
    local byteoffset = utf8.offset(self.text, -1)

    if byteoffset then
      self.text = string.sub(self.text, 1, byteoffset - 1)
      end
  end

  if key == "return" or key == "kpenter" then
    self.finished = true
  end

end
