require("..engine.lclass")

require("..engine.globalconf")

local Vec = require("..engine.math.vector")

class "Inventory"

function Inventory:Inventory()
  self.items = {}
end

function Inventory:reset()
  self.items = {}
end

function Inventory:addItem( itemname, itemammount )
  if not ( itemname ) then
    return
  end

  itemammount = itemammount or 1

  if ( self.items[itemname] ) then
    self.items[itemname].ammount = self.items[itemname].ammount + itemammount
  else
    self.items[itemname]         = {}
    self.items[itemname].name    = itemname
    self.items[itemname].ammount = tonumber( itemammount )
  end
end

function Inventory:hasItem( itemname, ammount )
  ammount = ammount or 1

  if ( self.items[itemname] ) then
    if ( self.items[itemname].ammount >= ammount ) then
      return true
    else
      return false
    end
  else
    return false
  end
end

function Inventory:consumeItem( itemname, ammount )
  ammount = ammount or 1

  if not ( self:hasItem( itemname, ammount ) ) then
    return false
  end

  self.items[itemname].ammount = self.items[itemname].ammount - tonumber( ammount )

  if ( self.items[itemname].ammount == 0 ) then
    self.items[itemname] = nil
  end

  return true
end
