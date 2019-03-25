LevelMaker = Class{}

function LevelMaker.createMap(level)
  local bricks = {}
  local numRows = math.random(1, 5)
  local numCols = math.random(7, 13)

  for y = 1, numRows do
    for x = 1, numCols do
      b = Brick(
        (x-1)                   -- recrement by 1 because tables are 1-indexed
        *32                     -- multiply by brick width 
        + 8                     -- padding
        + (13 - numCols) * 16,  -- left-side padding if fewer than 13 columns
        y * 16                  
      )
      table.insert(bricks, b)
    end
  end
  return bricks
end