-- following the graphic design of https://github.com/LLK/scratch-blocks/wiki (see also: https://wiki.scratch.mit.edu/wiki/Scratch_3.0#Gallery)
-- and the guides of https://developers.google.com/blockly/guides/overview

-- require('mobdebug').start()

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

local LightningLayout = {}

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
  local styles = {
    block = { padding = 10, flow = 'horizontal' },
    parent_block = { padding = 10, flow = 'vertical' },
    numeric_input = { padding = 10 },
    text = { padding = 10 }
  }

  local parent_el = { flow = 'vertical', children = {
    { block_type = 'motion', class = 'block', children = { { class = 'text', text = 'set fullscreen' }, numericInput('true') } },
    { block_type = 'more', class = 'block', children = { { class = 'text', text = 'set frame rate:' }, numericInput(0.1) } },
    { block_type = 'sounds', class = 'parent_block', children = {
      { class = 'block', children = { { class = 'text', text = 'load tiled map' }, numericInput('LavaPlace.lua') } },
      { block_type = 'looks', class = 'block', children = { { class = 'text', text = 'new image' }, numericInput('skeleton.png') } },
      { block_type = 'more', class = 'block', children = { { class = 'text', text = 'new grid, frame width:' }, numericInput(64), { class = 'text', text = 'frame height:' }, numericInput(64) } }
    } },
    { block_type = 'more', class = 'block', children = { { class = 'text', text = 'new animation, x:' }, numericInput('2-9'), { text = 'y:' }, numericInput(1) } }
  } }

  applyStyles(parent_el, styles)

  width, height = love.graphics.getDimensions()
  LightningLayout:layout(parent_el, 0,0, width,height)

  love.graphics.setBackgroundColor(hex('ffffff'))

  renderBlock(parent_el)
end

function numericInput(value)
  return {class = 'numeric_input', text = value}
end

function renderBlock(block)
  local class = block.class
  local x = block._layout_x
  local y = block._layout_y
  local children = block.children
  local padding = block.padding or 0
  
  if (class == 'parent_block' or class == 'block') and block.block_type then
    local block_type = block.block_type
    local color = block_colors[block_type]
    love.graphics.setColor(hex(color))

    local inner_offset = 0
    if class == 'parent_block' then inner_offset = 20 end

    local width = block._layout_width
    local vertices = {
      {x,y, x+20,y, x+30,y+10, x,y+10},
      {x+50,y+10, x+60,y, x+width,y, x+width,y+10},
      {x,y+10, x+width,y+10, x+width,y+60, x,y+60},
      {x+20+inner_offset,y+60, x+60+inner_offset,y+60, x+50+inner_offset,y+70, x+30+inner_offset,y+70}
    }
    
    for i, vertices in ipairs(vertices) do
      love.graphics.polygon('fill', vertices)
    end
  elseif class == 'numeric_input' then
    local radius = 20
    local text_width = font:getWidth(block.text)
    love.graphics.setColor(hex('ffffff'))
    
    -- draw the same things twice, once in fill & once in line
    -- for decent anti-aliasing. see https://love2d.org/forums/viewtopic.php?t=82536
    -- and https://love2d.org/forums/viewtopic.php?t=1398
    love.graphics.rectangle('fill', x, y, radius * 2 + text_width, radius * 2, radius, radius)
    love.graphics.rectangle('line', x, y, radius * 2 + text_width, radius * 2, radius, radius)

    love.graphics.setColor(0, 0, 0)
    love.graphics.print(block.text, x + padding, y + padding)
  elseif class == 'text' then
    love.graphics.setColor(hex('ffffff'))
    love.graphics.print(block.text, x + padding, y + padding)
  end
  
  if children then
    for i, child in ipairs(children) do
      renderBlock(child)
    end
  end

  -- TODO: for parent blocks, we:
  -- need to render the side rectangle
  -- the bottom has Y values of 40 and 50 instead of 60 and 70 b/c it's not as tall
  -- the top 2 shapes are offset by 20 instead of the bottom shape
  -- if class == 'parent_block' then
  --   table.insert(vertices, {0+inner_offset,0, 20+inner_offset,0, 30+inner_offset,10, 0+inner_offset,10})
  --   table.insert(vertices, {50+inner_offset,10, 60+inner_offset,0, width+inner_offset,0, width+inner_offset,10})
  --   table.insert(vertices, {0,10, width,10, width,40, 0,40})
  --   table.insert(vertices, {20,40, 60,40, 50,50, 30,50})
  -- end
end

function applyStyles(block, styles)
  if block.class and styles[block.class] then
    local props = styles[block.class]
    for key, value in pairs(props) do
      block[key] = value
    end
  end
  
  if block.children then
    for i, child in ipairs(block.children) do
      applyStyles(child, styles)
    end
  end
end

function LightningLayout:layout(el, parent_x, parent_y, parent_width, parent_height)
  local padding = el.padding or 0
  local border_width = el.borderWidth or 0

  -- calc supplied values based on parent's height/width
  local top, left, bottom, right, width, height
  if el.top ~= nil then top = val(el.top, parent_height) end
  if el.bottom ~= nil then bottom = val(el.bottom, parent_height) end
  if el.left ~= nil then left = val(el.left, parent_width) end
  if el.right ~= nil then right = val(el.right, parent_height) end
  if el.width ~= nil then width = val(el.width, parent_width) end
  if el.height ~= nil then height = val(el.height, parent_height) end

  -- derive width/height if possible (what about deriving left/right/top/bottom?)
  if width == nil and left ~= nil and right ~= nil then
    width = parent_width - left - right
  end
  if height == nil and top ~= nil and bottom ~= nil then
    height = parent_height - top - bottom
  end

  -- if necessary, derive width/height from children
  if width == nil or height == nil then
    -- can't derive width/height for absolutely positioned elements (no flow) that aren't text elements
    if el.flow == nil and not el.text then
      if width == nil then width = 0 end
      if height == nil then height = 0 end
    else
      local content_w = 0
      local content_h = 0
      if el.text then
        content_w = font:getWidth(el.text)
        content_h = font:getHeight()
      else
        local is_vert = el.flow == 'vertical'

        for i, child in ipairs(el.children) do
          local w, h = self:layout(child) -- should this include margins? Seems like it should, but that can be a % of the parent's width/height
          if is_vert then
            content_h = content_h + h
            if w > content_w then content_w = w end -- set content_w to the max width
          else
            content_w = content_w + w
            if h > content_h then content_h = h end -- set content_h to the max height
          end
        end
      end

      if width == nil then
        width = content_w + padding * 2 + border_width * 2
      end
      if height == nil then
        height = content_h + padding * 2 + border_width * 2
      end
    end
  end

  el._layout_width = width
  el._layout_height = height

  -- short-circuit if we weren't supplied the parent width/height; this is a preliminary pass
  if parent_width == nil and parent_height == nil then
    return width, height
  end

  -- derive x based on right & width; y based on bottom & height
  if left ~= nil then
    el._layout_x = parent_x + left
  else
    if right ~= nil then
      el._layout_x = parent_x + parent_width - right - width
    else
      el._layout_x = parent_x -- + math.floor((parent_width - width) / 2)
    end
  end

  if top ~= nil then
    el._layout_y = parent_y + top
  else
    if bottom ~= nil then
      el._layout_y = parent_y + parent_height - bottom - height
    else
      el._layout_y = parent_y -- + math.floor((parent_height - height) / 2)
    end
  end

  print(el.block_type or el.text, '(' .. el._layout_x .. ',' .. el._layout_y .. ')', width .. 'x' .. height)

  -- 2nd pass, now that we have derived x/y/width/height
  if el.children then
    local padding = el.padding or 0
    local border_width = el.borderWidth or 0
    local offset = padding + border_width
    local x = el._layout_x + offset
    local y = el._layout_y + offset
    for i, child in ipairs(el.children) do
      local w, h = self:layout(child, x, y, el._layout_width, el._layout_height)
      if el.flow == 'horizontal' then
        x = x + w
      elseif el.flow == 'vertical' then
        y = y + h
      end
    end
  end

  return width, height
end

function val(value, parent_value)
  if type(value) == 'string' and value:sub(-1) == '%' then
    if parent_value ~= nil then
      return math.floor(tonumber(value:sub(1, -1)) / 100 * parent_value)
    else
      print('Error: value supplied in %, but parent height or width not available')
      return 0
    end
  else
    return value
  end
end
