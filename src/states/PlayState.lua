PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
  self.paddle = params.paddle
  -- self.ball = params.ball
  self.health = params.health
  self.bricks = params.bricks
  self.powerup = Powerup()
  self.haskey = false
  self.balls = {params.ball}
  self.ballsCount = 1
  self.highScores = params.highScores
  self.score = params.score
  self.recoverPoints = 5000
  self.level = params.level
  -- self.ball.dx = math.random(-200, 200)
  -- self.ball.dy = math.random(-50, -60)
  self.balls[1].dx = math.random(-200, 200)
  self.balls[1].dy = math.random(-50, -60)

  self.pause = false
end

function PlayState:update(dt) 
  if self.paused then
    if love.keyboard.wasPressed('space') then
      self.paused = false
      gSounds['pause']:play()
    else
      return
    end
  elseif love.keyboard.wasPressed('space') then
    self.paused = true
    self.paused = true
    gSounds['pause']:play()
    return
  end

  self.paddle:update(dt)
  -- self.ball:update(dt)

  -- if self.ball:collides(self.paddle) then
  --   self.ball.y = self.paddle.y - 8
  --   self.ball.dy = -self.ball.dy
  --   if self.ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
  --     self.ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.ball.x))
  --   elseif self.ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
  --     self.ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.ball.x))
  --   end

  --   gSounds['paddle-hit']:play()
  self.powerup:update(dt)
  for k, ball in pairs(self.balls) do
    ball:update(dt)
  end

  -- for k, brick in pairs(self.bricks) do
  --   if brick.inPlay and self.ball:collides(brick) then
  --     self.score = self.score + (brick.tier * 200 + brick.color * 25)
  --     brick:hit()

  if self.powerup.inPlay and self.powerup:collides(self.paddle) then
    if self.hasKey then
      self.powerup.locked = false
    end
    
    self.powerup:hit()
    self.score = self.score + self.powerup.skin * 5

    if self.powerup.skin == 10 then
      self.hasKey = true
    else
      for i = 1, 2 do
        local ball = Ball(math.random(7))
        ball.x = self.balls[1].x
        ball.y = self.balls[1].y
        ball.dx = self.balls[1].dx + math.random(-16, 16)
        ball.dy = self.balls[1].dy + math.random(-16, 16)
        table.insert(self.balls, ball)
        self.ballsCount = self.ballsCount + 1
      end
    end
  end

  for key, ball in pairs(self.balls) do
    if ball:collides(self.paddle) then
      ball.y = self.paddle.y - 8
      ball.dy = -ball.dy

      -- if self.ball.x + 2 < brick.x and self.ball.dx > 0 then
      --   self.ball.dx = -self.ball.dx
      --   self.ball.x = brick.x - 8
      -- elseif self.ball.x + 6 > brick.x + brick.width and self.ball.dx < 0 then

      if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
        ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))

      elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
        ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
      end
      gSounds['paddle-hit']:play()
    end      

    for k, brick in pairs(self.bricks) do
      if brick.inPlay and ball:collides(brick) then
        if brick.locked and self.hasKey then
          brick.locked = false
          self.hasKey = false
          self.score = self.score + 2500
        elseif not brick.locked then
          self.score = self.score + (brick.tier * 200 + brick.color * 25)
        end
        brick:hit() 

        if self.score > self.recoverPoints then
          self.health = math.min(3, self.health + 1)
          self.paddle:grow()
          self.recoverPoints = math.min(100000, self.recoverPoints * 2)
        end

        if self:checkVictory() then
          gSounds['victory']:play()
          gStateMachine:change('victory', {
            level = self.level,
            paddle = self.paddle,
            health = self.health,
            score = self.score,
            highScores = self.highScores,
            ball = ball,
            recoverPoints = self.recoverPoints
          })
        elseif not self.powerup.inPlay then
          self.powerup:spawn(brick.x + brick.width / 2, brick.y)
        end

        if ball.x + 2 < brick.x and ball.dx > 0 then
          
          ball.dx = -ball.dx
          ball.x = brick.x - 8

      --   self.ball.dx = -self.ball.dx
      --   self.ball.x = brick.x + 32
      -- elseif self.ball.y < brick.y then

        elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
          ball.dx = - ball.dx
          ball.x = brick.x + 32


      --   self.ball.dy = -self.ball.dy
      --   self.ball.y = brick.y - 8
      -- else

        elseif ball.y < brick.y then
          ball.dy = -ball.dy
          ball.y = brick.y - 8


      --   self.ball.dy = -self.ball.dy
      --   self.ball.y = brick.y + 16
      -- end
      -- self.ball.dy = self.ball.dy * 1.02

        else
          ball.dy = -ball.dy
          ball.y = brick.y + 16
        end

        break
      end
    end
  --   end
  -- end

  -- if self.ball.y >= VIRTUAL_HEIGHT then
  --   self.health = self.health - 1
  --   gSounds['hurt']:play()
  --   if self.health == 0 then
  --     gStateMachine:change('game-over', {
  --       score = self.score,
  --       highScores = self.highScores
  --     })
  --   else
  --     gStateMachine:change('serve', {
  --       paddle = self.paddle,
  --       bricks = self.bricks,
  --       health = self.health,
  --       score = self.score,
  --       highScores = self.highScores,
  --       level = self.level
  --     })

    if ball.y >= VIRTUAL_HEIGHT then
      if self.ballsCount > 1 then
        table.remove(self.balls, key)
        self.ballsCount = self.ballsCount - 1
      else
        self.hasKey = false
        self.health = self.health - 1
        self.paddle:shrink()
        gSounds['hurt']:play()

        if self.health == 0 then
          gStateMachine:change('game-over', {
            score = self.score,
            highScores = self.highScores
          })
        else
          gStateMachine:change('serve', {
            paddle = self.paddle,
            bricks = self.bricks,
            health = self.health,
            score = self.score,
            highScores = self.highScores,
            level = self.level,
            recoverPoints = self.recoverPoints
          })
        end
      end
    end
  end

  for k, brick in pairs(self.bricks) do
    brick:update(dt)
  end

  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  end
end



function PlayState:render()

  for k, brick in pairs(self.bricks) do
    brick:render()
  end

  for k, brick in pairs(self.bricks) do
    brick:renderParticles()
  end
  
  self.paddle:render()
  -- self.ball:render()
  self.powerup:render()

  for k, ball in pairs(self.balls) do
    ball:render()
  end

  renderScore(self.score)
  renderHealth(self.health)

  if self.paused then
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('PAUSED', 0, VIRTUAL_HEIGHT / 2 -16, VIRTUAL_WIDTH, 'center')
  end
end

function PlayState:checkVictory()
  for k, brick in pairs(self.bricks) do
    if brick.inPlay then
      return false
    end
  end
  return true
end
