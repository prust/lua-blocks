-- following the graphic design of https://github.com/LLK/scratch-blocks/wiki (see also: https://wiki.scratch.mit.edu/wiki/Scratch_3.0#Gallery)
-- and the guides of https://developers.google.com/blockly/guides/overview

block_colors = {
  motion = '4c97ff',
  looks = '9966ff',
  sounds = 'cf63cf',
  control = 'ffab19',
  events = 'ffbf00',
  sensing = '5cb1d6',
  pen = '0fbd8c',
  operators = '59c069',
  data = 'ff8c1a',
  more = 'ff6680',
  text = '575e75'
}
font = love.graphics.newFont(18)

function hex(hex_str)
  _,_,r,g,b = hex_str:find('(%x%x)(%x%x)(%x%x)')
  return { tonumber(r, 16), tonumber(g, 16), tonumber(b, 16) }
end

function love.load()
  love.graphics.setFont(font)
end

-- in our example, we need to set some variables
-- see: https://code.tutsplus.com/tutorials/using-variables-and-data-in-scratch--cms-24230
function love.draw()
  local blocks = {
    renderBlock('motion', false, {'set fullscreen', numericInput('true')}),
    renderBlock('looks', false, {'new image', numericInput('skeleton.png')}),
    renderBlock('more', false, {'new grid, frame width:', numericInput(64), 'frame height:', numericInput(64)}),
    renderBlock('more', false, {'set frame rate:', numericInput(0.1)}),
    renderBlock('more', false, {'new animation, x:', numericInput('2-9'), 'y:', numericInput(1)}),
    renderBlock('sounds', true, {'load tiled map', numericInput('LavaPlace.lua')})
  }

  love.graphics.setBackgroundColor(hex('ffffff'))
  local y = 10
  for i, block in ipairs(blocks) do
    love.graphics.draw(block, 100, y)
    y = y + 60
  end
end

function numericInput(value)
  return {class = 'numeric', value = value}
end

function renderBlock(block_type, has_children, contents)
  local spacing = 10
  local radius = 20
  local min_first_width = 60

  -- get width of all content
  -- this is a DRY violation - TODO: extract
  local width = spacing
  for i, content in ipairs(contents) do
    if type(content) == 'string' then
      width = width + font:getWidth(content) + spacing
    elseif content.class == 'numeric' then
      width = width + radius + font:getWidth(content.value) + radius + spacing
    end

    if i == 1 and width < min_first_width then
      width = min_first_width
    end
  end

  local block = love.graphics.newCanvas(width, 70)
  love.graphics.setCanvas(block)

  local color = block_colors[block_type]
  love.graphics.setColor(hex(color))

  local inner_offset = 0
  if has_children then inner_offset = 20 end
  local vertices = {
    {0,0, 20,0, 30,10, 0,10},
    {50,10, 60,0, width,0, width,10},
    {0,10, width,10, width,60, 0,60},
    {20+inner_offset,60, 60+inner_offset,60, 50+inner_offset,70, 30+inner_offset,70}
  }

  -- the bottom has Y values of 40 and 50 instead of 60 and 70
  -- it also has the top 2 shapes offset by 20 instead of the bottom shape
  -- and the side rectangle, of course...
  
  -- if has_children then
  --   table.insert(vertices, {})
  -- end
  
  for i, vertices in ipairs(vertices) do
    love.graphics.polygon('fill', vertices)
  end

  local x = spacing -- start after left-margin
  for i, content in ipairs(contents) do
    if type(content) == 'string' then
      love.graphics.setColor(hex('ffffff'))
      love.graphics.print(content, x, 20)
      x = x + font:getWidth(content) + spacing
    elseif content.class == 'numeric' then
      local text_width = font:getWidth(content.value)
      love.graphics.setColor(hex('ffffff'))
      -- draw the same things twice, once in fill & once in line
      -- for decent anti-aliasing. see https://love2d.org/forums/viewtopic.php?t=82536
      -- and https://love2d.org/forums/viewtopic.php?t=1398
      love.graphics.rectangle('fill', x, 10, radius * 2 + text_width, radius * 2, radius, radius)
      love.graphics.rectangle('line', x, 10, radius * 2 + text_width, radius * 2, radius, radius)
      x = x + radius

      love.graphics.setColor(0, 0, 0)
      love.graphics.print(content.value, x, 20)
      x = x + text_width + radius + spacing
    end

    if i == 1 and x < min_first_width then
      x = min_first_width
    end
  end

  love.graphics.setColor(hex('ffffff'))
  love.graphics.setCanvas()

  return block
end