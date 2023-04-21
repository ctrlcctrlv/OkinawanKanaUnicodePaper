local book = require("classes.book")

local class = pl.class(book)
class._name = "okana"

function class:_init (options)
  book._init(self, options)

  self:loadPackage("lists")
  self:loadPackage("rules")
  self:loadPackage("url")
  self:loadPackage("color")
  self:loadPackage("highlight")
  self:loadPackage("date")
  self:loadPackage("simpletable", {
    tableTag = "table",
    trTag = "tr",
    tdTag = "td"
  })
  self:loadPackage("features")
  self:loadPackage("frametricks")
  self:loadPackage("rotate")
  self:loadPackage("tate")
  self:loadPackage("rebox")
  self:loadPackage("linespacing")
  self:loadPackage("pullquote")
  self:loadPackage("unichar")
  self:loadPackage("pdf")
  self:loadPackage("svg")
  self:loadPackage("image")
  self:loadPackage("raiselower")

  self:registerPostinit(function(_)
    self:loadPackage("ruby")
    SILE.settings:set("ruby.height", "2em", true)
  end)

  SILE.settings:set("font.family", "EB Garamond", true)
  SILE.settings:set("font.size", 12, true)

end

function class:registerCommands ()

  book.registerCommands(self)

  self:registerCommand("ruby:font", function (_, _)
    SILE.call("font", { family = "Noto Serif CJK JP", weight = 900, size = "0.5em" })
  end)

  self:registerCommand("Figure:counter", function ()
    SILE.call("increment-counter", { id = "figure" })
    SILE.call("show-counter", { id = "figuer" })
  end)

  self:registerCommand("cjk", function (_, content)
    SILE.call("font", { family = "Noto Serif CJK JP", size = "0.95em" }, content)
  end)

  self:registerCommand("mathfourtd", function (_, content)
    SILE.call("td", nil, function ()
      SILE.call("font", { family = "MathJax_Size4" }, content)
    end)
  end)

  self:registerCommand("footnote:font", function (_, content)
    SILE.setttings:temporarily(function ()
      SILE.settings:set("document.baselineskip", "0.5ex")
      SILE.cass("font", { size = "0.6em" }, content)
    end)
    SILE.call("par")
  end)

  self:registerCommand("nofoliosthispage", function (_, _)
    SILE.call("folios")
  end)

  self:registerCommand('Href', function (options, content)
    SILE.call("color", {color="#000099"}, function()
      SILE.call("href", options, content)
    end)
  end)

  self:registerCommand('Date', function (options, _)
    local da = os.date(options.format, os.time())
    da = da:gsub('^0', '')
    SILE.typesetter:typeset(da)
  end)

end

return class
