-------------------------------------------------------------------------------
-- a temporary (??) gigantic file for loaded resources
-------------------------------------------------------------------------------

function loadImage(path)
  return love.graphics.newImage(path)
end

i_bluearrows = love.graphics.newImage("res/bluearrows.png")
i_orangearrows = love.graphics.newImage("res/orangearrows.png")

--i_cowboy = love.graphics.newImage("res/cowboy.png")

i_character = love.graphics.newImage("res/character1.png")

i_char = love.graphics.newImage("res/char.png")

i_box = love.graphics.newImage("res/box.png")

-------------------------------------------------------------------------------
-- others stuff
-------------------------------------------------------------------------------

i_deffloor = loadImage("res/floor/floor1.png")

i__spid = loadImage("res/_spid.png") --//TODO temporary

i__tree = loadImage("res/_tree.png") --//TODO temporary

i__mov = loadImage("res/_mov.png") --//TODO temporary

i__lit = loadImage("res/__lit.png")  --//TODO temporary
