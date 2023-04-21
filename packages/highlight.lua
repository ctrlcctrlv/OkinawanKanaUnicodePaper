local base = require("packages.base")

local package = pl.class(base)
package._name = "lists"

function package:_init ()
  base._init(self)
  self:loadPackage("color")
end

function package:registerCommands ()

  self:registerCommand("highlight", function (options, content)
    local box = SILE.call("hbox", {}, content)
    local color = options.color or "white"
    color = SILE.colorparser(color)
    local oy = box.outputYourself
    box.outputYourself = function(self, typesetter, line)
      local x = SILE.typesetter.frame.state.cursorX
      local y = SILE.typesetter.frame.state.cursorY
      local margin = 0
      if options.margin then
        margin = SU.cast("length", options.margin):absolute()
        y = y - margin
      end
      typesetter.frame:advanceWritingDirection(margin)
      SILE.outputter:pushColor(color)
      SILE.outputter:drawRule(x, y-self.height, self:scaledWidth(line)+(margin*2), self.height+(margin*2))
      SILE.outputter:popColor()
      oy(self, typesetter, line)
      typesetter.frame:advanceWritingDirection(margin)
    end
  end)

end

return package
