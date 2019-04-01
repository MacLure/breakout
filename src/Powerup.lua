Powerup = Class{}

function Powerup:init()
  self.x = 0
  self.y = 0
  self.width = 16
  self.height = 16
  self.dy = 90
  self.skin = 9
  self.color = 1
  self.inPlay = false
  self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 16)
  self.psystem:setParticleLifetime(0.5, 1)
  self.psystem:setLinearAcceleration(-5, 0, 15, 80)
  self.psystem:setAreaSpread('normal', 6, 6)
end

function Powerup:spawn(x, y)
  if math.random() > 0.9 then
    self.x = x - self.width / 2
    self.y = y
    self.skin = math.random() > 0.5 and 9 or 10
    self.color = self.skin == 10 and 5 or 1
    self.inPlay = true
  end
end

function Powerup:hit()
  self.inPlay = false
  self.psystem:setColors(
    paletteColors[self.color].r,
    paletteColors[self.color].g,
    paletteColors[self.color].b,
    55,
    paletteColors[self.color].r,
    paletteColors[self.color].g,
    paletteColors[self.color].b,
    0
  )
  self.psystem:emit(16)
end

function Powerup:collides(target)
  if self.x > target.x + target.width or target.x > self.x + self.width then
    return false
  end
  if self.y > target.y + target.height or target.y > self.y + self.height then
    return false
  end
  return true
end

function Powerup:update(dt)
  self.psystem:update(dt)

  if self.inPlay then
    self.y = self.y + self.dy * dt
    if self.y >= VIRTUAL_HEIGHT then
      self.inPlay = false
    end
  end
end

function Powerup:render()
  if self.inPlay then
    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.skin], self.x, self.y)
  end
  love.graphics.draw(self.psystem, self.x + self.width / 2, self.y + self.height / 2)
end