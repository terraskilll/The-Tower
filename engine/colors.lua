
colors = {
  WHITE = { 255, 255, 255, 255 },
  GRAY  = { 128, 128, 128, 255 },
  BLACK = { 0, 0, 0, 255 },
  RED   = { 255, 0, 0, 255 },
  GREEN = { 0, 255, 0, 255 },
  BLUE  = { 0, 0, 255, 255 },

  getTransparent = function ( color, alpha )
    return { color[1], color[2], color[3], alpha }
  end
}
