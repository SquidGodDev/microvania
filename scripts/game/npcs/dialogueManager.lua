local pd <const> = playdate
local gfx <const> = playdate.graphics

class('DialogueManager').extends(gfx.sprite)

function DialogueManager:init(dialogue, player, npc)
    self.player = player
    player.talkingToNpc = true
    self.dialogue = {}
    local lineCount = 1
    for s in dialogue:gmatch("[^\r\n]+") do
        if self.playerTalking == nil then
            if s == "n" then
                self.playerTalking = false
            else
                self.playerTalking = true
            end
        end
        if lineCount % 2 == 0 then
            table.insert(self.dialogue, s)
        end
        lineCount += 1
    end

    self.playerX, self.playerY = player.x, player.y - 64
    self.npcX, self.npxY = npc.x + 16, npc.y - 32
    self.curLine = 1
    self.maxLine = #self.dialogue

    self.curSpeechBubble = nil
    self:createSpeechBubble()

    self:add()
end

function DialogueManager:update()
    if pd.buttonJustPressed(pd.kButtonA) then
        local speechBubbleActive = self.curSpeechBubble:advance()
        if not speechBubbleActive then
            self.curLine += 1
            self.playerTalking = not self.playerTalking
            if self.curLine > self.maxLine then
                self:remove()
                pd.timer.performAfterDelay(300, function()
                    self.player.talkingToNpc = false
                end)
            else
                self:createSpeechBubble()
            end
        end
    end
end

function DialogueManager:createSpeechBubble()
    local bubbleX, bubbleY = self.playerX, self.playerY
    if not self.playerTalking then
        bubbleX, bubbleY = self.npcX, self.npxY
    end
    self.curSpeechBubble = SpeechBubble(self.dialogue[self.curLine], bubbleX, bubbleY)
end