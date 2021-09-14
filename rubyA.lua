local pdf = require("justenoughlibtexpdf")
--local stretch = require("packages/stretch")
-- Japaneese language support defines units which are useful here
SILE.languageSupport.loadLanguage("ja")

SILE.registerCommand("rubyA:font", function (_, _)
  SILE.call("font", { filename="fonts/FKOkinawanMP.ttf", size = "0.6em", weight = 800 })
end)

SILE.settings.declare({
    parameter = "rubyA.height",
    type = "string",
    default = "2zw",
    help = "Vertical offset between the rubyA and the main text"
  })

SILE.settings.declare({
    parameter = "rubyA.latinspacer",
    type = "glue",
    default = SILE.nodefactory.glue("0.25em"),
    help = "Glue added between consecutive Latin rubyA"
  })

local isLatin = function (char)
  return (char > 0x20 and char <= 0x24F) or (char >= 0x300 and char <= 0x36F)
    or (char >= 0x1DC0 and char <= 0x1EFF) or (char >= 0x2C60 and char <= 0x2c7F)
end

local checkIfSpacerNeeded = function (reading)
  -- First, did we have a rubyA node at all?
  if not SILE.scratch.lastRubyABox then return end
  -- Does the current reading start with a latin?
  if not isLatin(SU.codepoint(SU.firstChar(reading))) then return end
  -- Did we have some nodes recently?
  local top = #SILE.typesetter.state.nodes
  if top < 2 then return end
  -- Have we had other stuff since the last rubyA node?
  if SILE.typesetter.state.nodes[top] ~= SILE.scratch.lastRubyABox
     and SILE.typesetter.state.nodes[top-1] ~= SILE.scratch.lastRubyABox then
    return
  end
  -- Does the previous reading end with a latin?
  if not isLatin(SU.codepoint(SU.lastChar(SILE.scratch.lastRubyAText))) then return end
  -- OK, we need a spacer!
  SILE.typesetter:pushGlue(SILE.settings.get("rubyA.latinspacer"))
end

SILE.registerCommand("rubyA", function (options, content)
  local reading = SU.required(options, "reading", "\\rubyA")
  SILE.typesetter:setpar("")

  checkIfSpacerNeeded(reading)

  -- measure rubyA
  rubyAbox_c = function ()
    SILE.settings.temporarily(function ()
      SILE.call("noindent")
      SILE.call("rubyA:font")
      SILE.typesetter:typeset(reading)
    end)
  end
  SILE.call("hbox", {}, rubyAbox_c)
  local rubyAbox = SILE.typesetter.state.nodes[#SILE.typesetter.state.nodes]
  SU.debug("rubyA", "OO", rubyAbox.outputYourself)

  local rubyA_lc = rubyAbox:lineContribution()

  -- measure the content
  SILE.call("hbox", {}, content)
  local cbox = SILE.typesetter.state.nodes[#SILE.typesetter.state.nodes]
  local content_lc = cbox:lineContribution()
  SU.debug("rubyA", "base box is " .. cbox)
  SU.debug("rubyA", "reading is  " .. rubyAbox)
  -- define rubyAbox output rules
  rubyAbox_outputYourself = function(ratio) return function (self, typesetter, line)
    local ox = typesetter.frame.state.cursorX
    local oy = typesetter.frame.state.cursorY
    typesetter.frame:advanceWritingDirection(rubyAbox.width)
    typesetter.frame:advancePageDirection(-SILE.measurement(SILE.settings.get("rubyA.height")))
    SILE.outputter:setCursor(typesetter.frame.state.cursorX, typesetter.frame.state.cursorY)
    SU.debug("rubyA", self.value[1])
    local sx = ratio
    local sy = 1.0
    pdf:gsave()
    local horigin = (typesetter.frame.state.cursorX):tonumber()
    local vorigin = (typesetter.frame.state.cursorY):tonumber()
    pdf.setmatrix(1, 0, 0, 1, horigin, vorigin)
    pdf.setmatrix(sx, 0, 0, sy, 0, 0)
    pdf.setmatrix(1, 0, 0, 1, -horigin, -vorigin)
    for i = 1, #(self.value) do
      local node = self.value[i]
      node:outputYourself(typesetter, line)
    end
    pdf:grestore()
    typesetter.frame.state.cursorX = ox
    typesetter.frame.state.cursorY = oy
  end end
  if content_lc > rubyA_lc then
    SU.debug("rubyA", "Base is longer, offsetting rubyA to fit")
    -- This is actually the offset against the base
    rubyAbox.width = SILE.length(cbox:lineContribution() - rubyAbox:lineContribution())/2
    local ratio = 1.0
    rubyAbox.outputYourself = rubyAbox_outputYourself(ratio)
  else
    local diff = rubyA_lc - content_lc
    SU.debug("rubyA", "RubyA is longer, inserting " .. to_insert .. " either side of base")
    -- SU.debug("frames", "CBOX LC", cbox:lineContribution(), rubyAbox:lineContribution())
    local ratio = content_lc:absolute():tonumber() / rubyA_lc:absolute():tonumber()
    rubyAbox.outputYourself = rubyAbox_outputYourself(ratio)
    --SILE.call("hbox", {}, rubyAbox_c)
    --cbox.width = rubyAbox:lineContribution()
    rubyAbox.height = 0
    rubyAbox.width = 0
  end
  SILE.scratch.lastRubyABox = rubyAbox
  SILE.scratch.lastRubyAText = reading
end)

return {
  documentation = [[
\begin{document}
Japanese texts often contain pronunciation hints (called \em{furigana}) for
difficult kanji or foreign words. These hints are traditionally placed either
above (in horizontal typesetting) or beside (in vertical typesetting) the word
that they explain. The typesetting term for these glosses is \em{rubyA}.

The \code{rubyA} package provides the \code{\\rubyA[reading=...]\{...\}} command
which sets a piece of rubyA above or beside the base text. For example:

\set[parameter=rubyA.height, value=12pt]
\language[main=ja]{}

\define[command=rubyA:font]{\font[family=Noto Sans CJK JP,size=6pt]}
\begin{verbatim}
\line
\\rubyA[reading=\font[family=Noto Sans CJK JP]{れいわ}]\{\font[family=Noto Sans CJK JP]{令和}\}
\line
\end{verbatim}

Produces:
\medskip
\font[family=Noto Sans CJK JP]{
  \rubyA[reading=れいわ]{令和}
}

\language[main=en]

\end{document}
]]
}
