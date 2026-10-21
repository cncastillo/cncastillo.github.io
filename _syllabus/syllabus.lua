local function header(header)
  if header.identifier == 'before-first-class' or header.identifier == 'schedule' then
    return {pandoc.RawBlock('typst', '#pagebreak()\n#set page(margin: (top: 0.75in, bottom: 0.65in, x: 0.65in), header-ascent: 8pt)\n#v(14pt, weak: false)'), header}
  elseif header.identifier == 'ai-policy' then
    return {pandoc.RawBlock('typst', '#set par(spacing: 14pt)'), header}
  end
end

local function raw_inline(inline)
  if inline.format == 'html' and inline.text:match('^<br') then
    return pandoc.LineBreak()
  elseif inline.format == 'html' and inline.text:match('^<img') then
    local name = inline.text:match('src="[^"]*/([^/"]+)%.svg"')
    return pandoc.RawInline('typst', '#icon("' .. name .. '")')
  end
end

local function para(para)
  local text = pandoc.utils.stringify(para)
  if text == '{: .schedule}' or text == '{: .grading}' or text == 'Scroll sideways to see all days.' then
    return {}
  elseif text == 'Required to pass: 45 points.' then
    return {pandoc.RawBlock('typst', '#align(center)['), para, pandoc.RawBlock('typst', ']\n#v(8pt, weak: false)')}
  elseif text:match('^Additional points:') then
    return {pandoc.RawBlock('typst', '#v(8pt, weak: false)'), para}
  end
end

local function format_table(tbl)
  local heading = #tbl.head.rows == 0 and '' or pandoc.utils.stringify(tbl.head.rows[1].cells[1].contents)
  tbl.classes:insert('typst:no-figure')
  tbl.attributes['typst:text:size'] = '9.5pt'
  tbl.attributes['typst:inset'] = '(x: 6pt, y: 4pt)'
  tbl.attributes['typst:stroke'] = '(x: none, y: 0.4pt + komagray)'
  if heading == '' then
    tbl.colspecs = {{pandoc.AlignLeft, 0.19}, {pandoc.AlignLeft, 0.81}}
    tbl.head.rows = {}
    tbl.attributes['typst:text:size'] = '10pt'
    tbl.attributes['typst:inset'] = '(x: 0pt, y: 3pt)'
    local last = #tbl.bodies[1].body - 1
    tbl.attributes['typst:stroke'] = '(x, y) => (top: if y == 0 {0.4pt + komagray} else {none}, bottom: if y == 2 or y == ' .. last .. ' {0.4pt + komagray} else {none})'
  elseif heading == 'Week' then
    tbl.colspecs = {
      {pandoc.AlignLeft, 0.16}, {pandoc.AlignLeft, 0.28},
      {pandoc.AlignLeft, 0.28}, {pandoc.AlignLeft, 0.28}
    }
    tbl.attributes['typst:inset'] = '(x: 5pt, y: 11pt)'
    tbl.attributes['typst:fill'] = '(x, y) => if y == 3 {komatint} else {none}'
    for _, row in ipairs(tbl.bodies[1].body) do
      if pandoc.utils.stringify(row.cells[1].contents) == 'Week 3' then
        row.cells[2].col_span = 3
        row.cells[2].alignment = pandoc.AlignCenter
        row.cells[3], row.cells[4] = nil, nil
      end
      for _, cell in ipairs(row.cells) do
        local sessions = {}
        for _, block in ipairs(cell.contents) do
          if block.t == 'Plain' or block.t == 'Para' then
            for _, inline in ipairs(block.content) do
              if inline.t == 'Span' and
                (inline.classes[1] == 'course-day-header' or inline.classes[1] == 'course-session') then
                if #sessions > 0 then
                  sessions[#sessions + 1] = pandoc.RawBlock('typst', '#v(6pt, weak: false)')
                end
                sessions[#sessions + 1] = pandoc.Para(inline.content)
              end
            end
          end
        end
        if #sessions > 0 then cell.contents = sessions end
      end
    end
  else
    tbl.colspecs = {
      {pandoc.AlignLeft, 0.46}, {pandoc.AlignRight, 0.20},
      {pandoc.AlignRight, 0.17}, {pandoc.AlignRight, 0.17}
    }
  end
  for _, row in ipairs(tbl.head.rows) do
    for _, cell in ipairs(row.cells) do
      for _, block in ipairs(cell.contents) do
        if block.t == 'Plain' or block.t == 'Para' then
          block.content = {pandoc.Strong(block.content)}
        end
      end
    end
  end
  return tbl
end

return {
  {Header = header, RawInline = raw_inline, Span = function(span)
     if span.classes[1] == 'recurring' then
       return pandoc.RawInline('typst', '#overline[' .. pandoc.utils.stringify(span) .. ']')
     elseif span.classes[1] == 'setup-legend' then
       span.content:insert(1, pandoc.RawInline('typst', '#h(1fr)'))
       return span.content
     end
   end, RawBlock = function(block)
    if block.format == 'html' then return {} end
   end, Div = function(div)
     if div.classes[1] == 'course-information' or div.classes[1] == 'pass-requirement' then
       return div.content
     end
   end,
   Para = para, Plain = para, Table = format_table}
}
