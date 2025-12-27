-- LOTM Artifact Base Weapon
-- Базовый SWEP для всех артефактов
-- Использует LOTM.Weapons.Registry для конфига

AddCSLuaFile()

SWEP.PrintName = "Артефакт"
SWEP.Author = "LOTM System"
SWEP.Category = "LOTM Artifacts"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
SWEP.HoldType = "melee2"

-- ID артефакта (устанавливается при выдаче)
SWEP.ArtifactId = "mystic_blade"

-- =============================================
-- ИНИЦИАЛИЗАЦИЯ
-- =============================================
function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    self:LoadArtifactConfig()
    
    -- Состояние
    self.AttackCount = 0
    self.LastAttackTime = 0
    self.IsBlocking = false
    self.BlockStartTime = 0
    self.OnCooldown = false
    self.CooldownEndTime = 0
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "Blocking")
    self:NetworkVar("Bool", 1, "OnCooldown")
    self:NetworkVar("Int", 0, "AttackCount")
    self:NetworkVar("Float", 0, "CooldownEnd")
    self:NetworkVar("Float", 1, "NextAttack")
    self:NetworkVar("String", 0, "ArtifactID")
end

function SWEP:LoadArtifactConfig()
    local id = self:GetArtifactID()
    if id == "" then id = self.ArtifactId end
    
    if LOTM and LOTM.Weapons and LOTM.Weapons.Get then
        self.Config = LOTM.Weapons.Get(id) or LOTM.Weapons.DefaultConfig
    else
        self.Config = {
            name = "Артефакт",
            damage = 25,
            range = 80,
            attacksBeforeCooldown = 3,
            attackCooldown = 2.0,
            attackDelay = 0.6,
            canBlock = true,
            canDash = true,
            attacks = {
                {name = "Атака 1", damage = 1.0, knockback = 100},
                {name = "Атака 2", damage = 1.2, knockback = 150},
                {name = "Атака 3", damage = 1.5, knockback = 200, finisher = true},
            },
        }
    end
    
    -- Применяем конфиг
    if self.Config then
        self.PrintName = self.Config.name
        self.WorldModel = self.Config.model or self.WorldModel
        self:SetHoldType(self.Config.holdType or "melee2")
    end
end

-- =============================================
-- ОСНОВНАЯ АТАКА (ЛКМ) - 3 атаки, потом КД
-- =============================================
function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    
    local config = self.Config
    if not config then return end
    
    local curTime = CurTime()
    
    -- Проверка КД после 3 атак
    if self:GetOnCooldown() then
        if curTime < self:GetCooldownEnd() then
            return
        else
            self:SetOnCooldown(false)
            self:SetAttackCount(0)
        end
    end
    
    -- Проверка блока
    if self:GetBlocking() then return end
    
    -- Проверка задержки между атаками
    if curTime < self:GetNextAttack() then return end
    
    -- Текущий индекс атаки
    local attackIndex = self:GetAttackCount() + 1
    local attacks = config.attacks or {}
    
    if attackIndex > #attacks then
        attackIndex = 1
    end
    
    local attackData = attacks[attackIndex]
    if not attackData then return end
    
    -- Выполняем атаку
    self:PerformAttack(attackData, attackIndex)
    
    -- Обновляем счётчик
    self:SetAttackCount(attackIndex)
    self:SetNextAttack(curTime + (config.attackDelay or 0.6))
    self:SetNextPrimaryFire(curTime + (config.attackDelay or 0.6))
    self.LastAttackTime = curTime
    
    -- Проверка на КД после 3 атак
    if attackIndex >= (config.attacksBeforeCooldown or 3) then
        self:SetOnCooldown(true)
        self:SetCooldownEnd(curTime + (config.attackCooldown or 2.0))
        self:SetAttackCount(0)
        
        if CLIENT then
            surface.PlaySound("buttons/button10.wav")
        end
    end
end

function SWEP:PerformAttack(attackData, attackIndex)
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    
    local config = self.Config
    local baseDamage = config.damage or 25
    local damage = baseDamage * (attackData.damage or 1.0)
    
    -- Анимация игрока
    if attackData.playerAnim then
        owner:SetAnimation(PLAYER_ATTACK1)
    end
    
    -- Звук свинга
    if attackData.sound then
        self:EmitSound(attackData.sound)
    else
        self:EmitSound("weapons/knife/knife_slash1.wav")
    end
    
    -- Трейс
    local trace = {}
    trace.start = owner:GetShootPos()
    trace.endpos = trace.start + owner:GetAimVector() * (config.range or 80)
    trace.filter = owner
    trace.mask = MASK_SHOT_HULL
    
    local tr = util.TraceLine(trace)
    
    -- Hull trace для лучшего попадания
    if not tr.Hit then
        trace.mins = Vector(-10, -10, -10)
        trace.maxs = Vector(10, 10, 10)
        tr = util.TraceHull(trace)
    end
    
    -- Попадание
    if tr.Hit and IsValid(tr.Entity) then
        if SERVER then
            local dmgInfo = DamageInfo()
            dmgInfo:SetDamage(damage)
            dmgInfo:SetAttacker(owner)
            dmgInfo:SetInflictor(self)
            dmgInfo:SetDamageType(attackData.magicDamage and DMG_ENERGYBEAM or DMG_SLASH)
            
            tr.Entity:TakeDamageInfo(dmgInfo)
            
            -- Откидывание
            if attackData.knockback and tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
                local knockDir = (tr.Entity:GetPos() - owner:GetPos()):GetNormalized()
                knockDir.z = 0.2
                
                if tr.Entity:IsPlayer() then
                    tr.Entity:SetVelocity(knockDir * attackData.knockback)
                elseif tr.Entity:IsNPC() then
                    local phys = tr.Entity:GetPhysicsObject()
                    if IsValid(phys) then
                        phys:ApplyForceCenter(knockDir * attackData.knockback * 10)
                    end
                end
            end
            
            -- Лайфстил
            if attackData.lifesteal then
                owner:SetHealth(math.min(owner:Health() + attackData.lifesteal, owner:GetMaxHealth()))
            end
            
            -- Кровотечение
            if attackData.bleed and dbt and dbt.setWound then
                dbt.setWound(tr.Entity, "Ранение", "Торс")
            end
            
            -- Лечение
            if attackData.heal then
                owner:SetHealth(math.min(owner:Health() + attackData.heal, owner:GetMaxHealth()))
            end
            
            -- Стан
            if attackData.stun and tr.Entity:IsPlayer() then
                tr.Entity:Freeze(true)
                timer.Simple(attackData.stun, function()
                    if IsValid(tr.Entity) then
                        tr.Entity:Freeze(false)
                    end
                end)
            end
            
            -- Невидимость
            if attackData.invisible then
                owner:SetColor(Color(255, 255, 255, 50))
                owner:SetRenderMode(RENDERMODE_TRANSALPHA)
                timer.Simple(attackData.invisible, function()
                    if IsValid(owner) then
                        owner:SetColor(Color(255, 255, 255, 255))
                        owner:SetRenderMode(RENDERMODE_NORMAL)
                    end
                end)
            end
        end
        
        -- Звук попадания
        if attackData.hitSound then
            self:EmitSound(attackData.hitSound)
        else
            self:EmitSound("physics/flesh/flesh_impact_hard1.wav")
        end
        
        -- Эффект
        local effectData = EffectData()
        effectData:SetOrigin(tr.HitPos)
        effectData:SetNormal(tr.HitNormal)
        if tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
            util.Effect("BloodImpact", effectData)
        else
            util.Effect("Impact", effectData)
        end
    end
end

-- =============================================
-- БЛОК (ПКМ)
-- =============================================
function SWEP:SecondaryAttack()
    local config = self.Config
    if not config or not config.canBlock then return end
    
    self:SetBlocking(true)
    self.BlockStartTime = CurTime()
    
    self:EmitSound("physics/metal/metal_solid_impact_soft1.wav")
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    
    -- Обработка блока
    if self:GetBlocking() then
        if not owner:KeyDown(IN_ATTACK2) then
            self:SetBlocking(false)
        end
    end
    
    -- Сброс счётчика атак если прошло много времени
    if CurTime() - self.LastAttackTime > 3 and not self:GetOnCooldown() then
        self:SetAttackCount(0)
    end
end

-- =============================================
-- УРОН ПРИ БЛОКЕ
-- =============================================
hook.Add("EntityTakeDamage", "LOTM.ArtifactBase.BlockDamage", function(target, dmgInfo)
    if not IsValid(target) or not target:IsPlayer() then return end
    
    local weapon = target:GetActiveWeapon()
    if not IsValid(weapon) then return end
    if weapon:GetClass() ~= "lotm_artifact_base" then return end
    if not weapon:GetBlocking() then return end
    
    local config = weapon.Config
    if not config then return end
    
    local curTime = CurTime()
    local blockStart = weapon.BlockStartTime or 0
    local timeSinceBlock = curTime - blockStart
    
    local reduction = config.blockDamageReduction or 0.6
    
    -- Идеальный блок
    if timeSinceBlock <= (config.perfectBlockWindow or 0.2) then
        reduction = 1.0  -- Полная блокировка
        
        if SERVER then
            target:EmitSound("physics/metal/metal_solid_impact_hard2.wav")
            
            -- Контратака
            local attacker = dmgInfo:GetAttacker()
            if IsValid(attacker) and (attacker:IsPlayer() or attacker:IsNPC()) then
                local knockDir = (attacker:GetPos() - target:GetPos()):GetNormalized()
                if attacker:IsPlayer() then
                    attacker:SetVelocity(knockDir * 300)
                end
            end
        end
    else
        if SERVER then
            weapon:EmitSound("physics/metal/metal_solid_impact_hard1.wav")
        end
    end
    
    local newDamage = dmgInfo:GetDamage() * (1 - reduction)
    dmgInfo:SetDamage(newDamage)
end)

-- =============================================
-- HUD
-- =============================================
function SWEP:DrawHUD()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    
    local config = self.Config
    local scrw, scrh = ScrW(), ScrH()
    
    local colorOutLine = Color(211, 25, 202)
    local colorBG = Color(0, 0, 0, 180)
    
    -- Панель атак (внизу по центру)
    local panelW, panelH = 200, 60
    local panelX = scrw / 2 - panelW / 2
    local panelY = scrh - 120
    
    draw.RoundedBox(4, panelX, panelY, panelW, panelH, colorBG)
    
    -- Название оружия
    draw.SimpleText(config and config.name or "Артефакт", "DermaDefaultBold", 
        panelX + panelW / 2, panelY + 8, colorOutLine, TEXT_ALIGN_CENTER)
    
    -- Индикаторы атак
    local attacks = config and config.attacks or {}
    local attackCount = self:GetAttackCount()
    local maxAttacks = config and config.attacksBeforeCooldown or 3
    
    local indicatorW = 50
    local startX = panelX + (panelW - indicatorW * maxAttacks) / 2
    
    for i = 1, maxAttacks do
        local x = startX + (i - 1) * indicatorW
        local y = panelY + 25
        
        local color = Color(60, 60, 70)
        if i <= attackCount then
            color = colorOutLine
        end
        
        draw.RoundedBox(2, x + 5, y, indicatorW - 10, 20, color)
        draw.SimpleText(tostring(i), "DermaDefault", x + indicatorW / 2, y + 10, 
            Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Кулдаун
    if self:GetOnCooldown() then
        local remaining = self:GetCooldownEnd() - CurTime()
        if remaining > 0 then
            draw.RoundedBox(4, panelX, panelY - 25, panelW, 20, Color(100, 50, 50, 200))
            draw.SimpleText("КД: " .. string.format("%.1f", remaining) .. "с", "DermaDefaultBold",
                panelX + panelW / 2, panelY - 15, Color(255, 100, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    -- Индикатор блока
    if self:GetBlocking() then
        draw.SimpleText("🛡 БЛОК", "Comfortaa Bold X25", scrw / 2, scrh * 0.65, 
            Color(100, 150, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

-- =============================================
-- ДЕПЛОЙ / ХОЛСТЕР
-- =============================================
function SWEP:Deploy()
    self:LoadArtifactConfig()
    self:SetHoldType(self.Config and self.Config.holdType or "melee2")
    return true
end

function SWEP:Holster()
    self:SetBlocking(false)
    return true
end

-- Установка артефакта
function SWEP:SetArtifact(artifactId)
    self:SetArtifactID(artifactId)
    self.ArtifactId = artifactId
    self:LoadArtifactConfig()
end

print("[LOTM] Artifact Base SWEP loaded")

