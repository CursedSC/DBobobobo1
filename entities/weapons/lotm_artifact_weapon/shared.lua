-- LOTM Artifact Weapon
-- Артефакт-оружие с файтинг механикой
-- 3 разных атаки, блок, комбо

AddCSLuaFile()

SWEP.PrintName = "Артефакт"
SWEP.Author = "LOTM System"
SWEP.Category = "LOTM"

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
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = "models/props_junk/meathook001a.mdl"

SWEP.HoldType = "melee2"

-- =============================================
-- КОНФИГУРАЦИЯ АРТЕФАКТА
-- =============================================
SWEP.ArtifactConfig = {
    id = "default",
    name = "Артефакт",
    description = "Мистический артефакт",
    
    -- Базовые параметры
    damage = 25,
    range = 80,
    attackSpeed = 0.5,
    
    -- Файтинг система (true/false)
    enableCombos = true,         -- Включить комбо систему
    enableBlock = true,          -- Включить блок
    enableDodge = false,         -- Включить уклонение
    enableChargeAttack = false,  -- Включить заряженную атаку
    
    -- 3 разных атаки
    attacks = {
        {
            name = "Горизонтальный удар",
            damage = 25,
            animation = ACT_VM_HITCENTER,
            playerAnim = "sword_swing",
            sound = "weapons/knife/knife_slash1.wav",
            hitSound = "physics/flesh/flesh_impact_hard1.wav",
            range = 80,
            delay = 0.4,
            knockback = 100,
        },
        {
            name = "Вертикальный удар",
            damage = 35,
            animation = ACT_VM_HITCENTER,
            playerAnim = "sword_overhead",
            sound = "weapons/knife/knife_slash2.wav",
            hitSound = "physics/flesh/flesh_impact_hard2.wav",
            range = 75,
            delay = 0.5,
            knockback = 150,
            stunDuration = 0.5,
        },
        {
            name = "Выпад",
            damage = 45,
            animation = ACT_VM_HITCENTER,
            playerAnim = "sword_thrust",
            sound = "weapons/knife/knife_stab.wav",
            hitSound = "physics/flesh/flesh_impact_hard3.wav",
            range = 100,
            delay = 0.6,
            knockback = 200,
            bleed = true,
        },
    },
    
    -- Параметры блока
    block = {
        enabled = true,
        damageReduction = 0.7,   -- 70% снижение урона
        staminaCost = 10,
        perfectBlockWindow = 0.2, -- Окно идеального блока
        perfectBlockBonus = 1.0,  -- Полная блокировка
        animation = "guard",
        sound = "physics/metal/metal_solid_impact_hard1.wav",
    },
    
    -- Комбо система
    combo = {
        maxChain = 5,
        resetTime = 1.5,
        damageBonus = 0.1,  -- +10% урона за каждый комбо хит
        finisherAt = 5,     -- Финишер на 5м ударе
        finisherDamageMultiplier = 2.0,
    },
    
    -- Визуальные эффекты
    visuals = {
        swingTrail = true,
        trailColor = Color(211, 25, 202),
        hitParticle = "blood_impact_red_01",
        blockParticle = "impact_concrete",
    },
}

-- =============================================
-- ИНИЦИАЛИЗАЦИЯ
-- =============================================
function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    
    -- Состояние
    self.CurrentAttackIndex = 1
    self.ComboCount = 0
    self.LastAttackTime = 0
    self.IsBlocking = false
    self.BlockStartTime = 0
    self.NextAttackTime = 0
    self.StunEndTime = 0
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "Blocking")
    self:NetworkVar("Int", 0, "ComboCount")
    self:NetworkVar("Float", 0, "NextAttack")
    self:NetworkVar("Float", 1, "StunEnd")
end

-- =============================================
-- ОСНОВНАЯ АТАКА (ЛКМ)
-- =============================================
function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    
    local config = self.ArtifactConfig
    local curTime = CurTime()
    
    -- Проверка стана
    if curTime < self:GetStunEnd() then return end
    
    -- Проверка блока
    if self:GetBlocking() then return end
    
    -- Проверка кулдауна
    if curTime < self:GetNextAttack() then return end
    
    -- Комбо система
    if config.enableCombos and config.combo then
        if curTime - self.LastAttackTime > config.combo.resetTime then
            self.ComboCount = 0
            self.CurrentAttackIndex = 1
        end
    end
    
    -- Выбор атаки
    local attacks = config.attacks
    if not attacks or #attacks == 0 then return end
    
    local attackData = attacks[self.CurrentAttackIndex]
    if not attackData then
        self.CurrentAttackIndex = 1
        attackData = attacks[1]
    end
    
    -- Урон с учётом комбо
    local damage = attackData.damage or config.damage or 25
    
    if config.enableCombos and config.combo then
        local comboBonus = 1 + (self.ComboCount * config.combo.damageBonus)
        
        -- Финишер
        if self.ComboCount >= config.combo.finisherAt - 1 then
            damage = damage * config.combo.finisherDamageMultiplier
        else
            damage = damage * comboBonus
        end
    end
    
    -- Выполняем атаку
    self:PerformAttack(attackData, damage)
    
    -- Обновляем состояние
    self:SetNextAttack(curTime + (attackData.delay or config.attackSpeed or 0.5))
    self:SetNextPrimaryFire(curTime + (attackData.delay or config.attackSpeed or 0.5))
    self.LastAttackTime = curTime
    
    -- Следующая атака в цепочке
    self.CurrentAttackIndex = self.CurrentAttackIndex + 1
    if self.CurrentAttackIndex > #attacks then
        self.CurrentAttackIndex = 1
    end
    
    -- Увеличиваем комбо
    self.ComboCount = self.ComboCount + 1
    self:SetComboCount(self.ComboCount)
    
    -- Сброс комбо при максимуме
    if config.combo and self.ComboCount >= config.combo.maxChain then
        self.ComboCount = 0
        self:SetComboCount(0)
    end
end

function SWEP:PerformAttack(attackData, damage)
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    
    -- Анимация
    if attackData.animation then
        self:SendWeaponAnim(attackData.animation)
    end
    
    -- Анимация игрока
    if attackData.playerAnim and SERVER then
        owner:SetAnimation(PLAYER_ATTACK1)
    end
    
    -- Звук свинга
    if attackData.sound then
        self:EmitSound(attackData.sound)
    end
    
    -- Трассировка
    local trace = {}
    trace.start = owner:GetShootPos()
    trace.endpos = trace.start + owner:GetAimVector() * (attackData.range or 80)
    trace.filter = owner
    trace.mask = MASK_SHOT_HULL
    
    local tr = util.TraceLine(trace)
    
    -- Попадание
    if tr.Hit and IsValid(tr.Entity) then
        if SERVER then
            local dmgInfo = DamageInfo()
            dmgInfo:SetDamage(damage)
            dmgInfo:SetAttacker(owner)
            dmgInfo:SetInflictor(self)
            dmgInfo:SetDamageType(DMG_SLASH)
            
            tr.Entity:TakeDamageInfo(dmgInfo)
            
            -- Откидывание
            if attackData.knockback and tr.Entity:IsPlayer() then
                local knockDir = (tr.Entity:GetPos() - owner:GetPos()):GetNormalized()
                tr.Entity:SetVelocity(knockDir * attackData.knockback)
            end
            
            -- Стан
            if attackData.stunDuration and tr.Entity:IsPlayer() then
                -- Можно добавить NWVar для стана
            end
            
            -- Кровотечение
            if attackData.bleed and dbt and dbt.setWound then
                dbt.setWound(tr.Entity, "Ранение", "Торс")
            end
        end
        
        -- Звук попадания
        if attackData.hitSound then
            self:EmitSound(attackData.hitSound)
        end
        
        -- Эффект
        if self.ArtifactConfig.visuals and self.ArtifactConfig.visuals.hitParticle then
            local effectData = EffectData()
            effectData:SetOrigin(tr.HitPos)
            effectData:SetNormal(tr.HitNormal)
            util.Effect("BloodImpact", effectData)
        end
    end
end

-- =============================================
-- БЛОК (ПКМ)
-- =============================================
function SWEP:SecondaryAttack()
    local config = self.ArtifactConfig
    if not config.enableBlock or not config.block or not config.block.enabled then return end
    
    -- Начинаем блок
    self:SetBlocking(true)
    self.BlockStartTime = CurTime()
    
    if config.block.sound then
        self:EmitSound(config.block.sound)
    end
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    
    local config = self.ArtifactConfig
    
    -- Обработка блока
    if self:GetBlocking() then
        -- Проверяем, держит ли игрок ПКМ
        if not owner:KeyDown(IN_ATTACK2) then
            self:SetBlocking(false)
        else
            -- Анимация блока
            if config.block and config.block.animation then
                -- Держим анимацию блока
            end
        end
    end
end

-- =============================================
-- УРОН ПРИ БЛОКЕ
-- =============================================
hook.Add("EntityTakeDamage", "LOTM.ArtifactWeapon.BlockDamage", function(target, dmgInfo)
    if not IsValid(target) or not target:IsPlayer() then return end
    
    local weapon = target:GetActiveWeapon()
    if not IsValid(weapon) or weapon:GetClass() ~= "lotm_artifact_weapon" then return end
    if not weapon:GetBlocking() then return end
    
    local config = weapon.ArtifactConfig
    if not config.block then return end
    
    local curTime = CurTime()
    local blockStart = weapon.BlockStartTime or 0
    local timeSinceBlock = curTime - blockStart
    
    local reduction = config.block.damageReduction or 0.5
    
    -- Идеальный блок
    if timeSinceBlock <= (config.block.perfectBlockWindow or 0.2) then
        reduction = config.block.perfectBlockBonus or 1.0
        
        -- Эффект идеального блока
        if SERVER then
            target:EmitSound("physics/metal/metal_solid_impact_hard2.wav")
            
            local effectData = EffectData()
            effectData:SetOrigin(target:GetPos() + Vector(0, 0, 40))
            util.Effect("cball_explode", effectData)
        end
    end
    
    -- Применяем снижение урона
    local newDamage = dmgInfo:GetDamage() * (1 - reduction)
    dmgInfo:SetDamage(newDamage)
    
    -- Звук блока
    if SERVER then
        weapon:EmitSound(config.block.sound or "physics/metal/metal_solid_impact_hard1.wav")
    end
end)

-- =============================================
-- HUD
-- =============================================
function SWEP:DrawHUD()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    
    local config = self.ArtifactConfig
    local scrw, scrh = ScrW(), ScrH()
    
    local colorOutLine = Color(211, 25, 202)
    
    -- Комбо счётчик
    if config.enableCombos and self:GetComboCount() > 0 then
        local comboY = scrh * 0.3
        local combo = self:GetComboCount()
        
        -- Фон
        draw.RoundedBox(4, scrw / 2 - 40, comboY, 80, 50, Color(0, 0, 0, 150))
        
        -- Текст комбо
        draw.SimpleText("COMBO", "DermaDefault", scrw / 2, comboY + 10, colorOutLine, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("x" .. combo, "Comfortaa Bold X30", scrw / 2, comboY + 35, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Бонус урона
        if config.combo then
            local bonusPercent = math.floor(combo * config.combo.damageBonus * 100)
            draw.SimpleText("+" .. bonusPercent .. "%", "DermaDefault", scrw / 2, comboY + 55, Color(100, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    -- Индикатор блока
    if self:GetBlocking() then
        draw.SimpleText("🛡 БЛОК", "Comfortaa Bold X25", scrw / 2, scrh * 0.7, Color(100, 150, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Текущая атака в цепочке
    if config.attacks and #config.attacks > 1 then
        local attackIndex = self.CurrentAttackIndex or 1
        local attackName = config.attacks[attackIndex] and config.attacks[attackIndex].name or "Атака"
        
        draw.SimpleText(attackName, "DermaDefault", scrw / 2, scrh - 100, colorOutLine, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Индикаторы атак
        local indicatorY = scrh - 75
        local totalWidth = #config.attacks * 20
        local startX = scrw / 2 - totalWidth / 2
        
        for i = 1, #config.attacks do
            local x = startX + (i - 1) * 20
            local color = i == attackIndex and colorOutLine or Color(100, 100, 100)
            draw.RoundedBox(4, x, indicatorY, 15, 15, color)
        end
    end
end

-- =============================================
-- ХОЛОТАЙП
-- =============================================
function SWEP:Deploy()
    self:SetHoldType(self.HoldType)
    return true
end

function SWEP:Holster()
    self:SetBlocking(false)
    self.ComboCount = 0
    self:SetComboCount(0)
    return true
end

print("[LOTM] Artifact Weapon SWEP loaded")




