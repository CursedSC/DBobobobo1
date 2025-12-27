# LOTM Potion System

## Описание
Система зелий из Lord of the Mysteries для Garry's Mod. Полностью автономная, с учётом игроков через базу данных SQLite.

## Структура

### Core Files
- **sh_potions_core.lua** - Ядро системы, базовые функции и структуры данных
- **sh_potions_data.lua** - База данных зелий и способностей
- **sh_loader.lua** - Автозагрузчик модулей

### Server Files
- **sv_energy.lua** - Система энергии с регенерацией
- **sv_potions.lua** - Серверная логика употребления зелий, учёт игроков, сохранение в БД

### Client Files  
- **cl_potions.lua** - Клиентский HUD, управление способностями

## Использование

### Для администраторов

#### Выдать зелье игроку:
```lua
lotm_give_potion <potion_uid>
```

Примеры:
- `lotm_give_potion seer_s9` - Выдать зелье Seer (Sequence 9)
- `lotm_give_potion clown_s8` - Выдать зелье Clown (Sequence 8)
- `lotm_give_potion hunter_s9` - Выдать зелье Hunter (Sequence 9)

#### Сбросить текущее зелье:
```lua
lotm_reset_potion
```

### Для игроков

#### Активация способностей:
- **Клавиша 1** - Способность в слоте 1
- **Клавиша 2** - Способность в слоте 2  
- **Клавиша 3** - Способность в слоте 3
- **Клавиша 4** - Способность в слоте 4

#### HUD отображает:
- Шкалу энергии (0-100)
- Название текущего зелья и его Sequence
- Прогресс переваривания (0-100%)
- Слоты способностей (1-4)

## Энергия

### Параметры:
- **Максимум**: 100 единиц
- **Базовая регенерация**: +2 ед/сек
- **В бою**: +0.5 ед/сек
- **Вне боя**: +4 ед/сек
- **Таймаут боя**: 5 секунд

### Боевой режим активируется при:
- Получении урона
- Нанесении урона

## Добавление новых зелий

### Шаблон в `sh_potions_data.lua`:

```lua
local my_potion_abilities = {
    LOTM.CreateAbility({
        ID = "unique_ability_id",
        Name = "Ability Name",
        Description = "Описание способности",
        Type = LOTM.ABILITY_TYPES.ACTIVE, -- или PASSIVE
        EnergyCost = 20,
        Cooldown = 15,
        Slot = 1, -- 0 для пассивных, 1-4 для активных
        OnActivate = function(ply)
            -- Код активации способности
        end,
        OnPassive = function(ply)
            -- Код пассивного эффекта
        end
    })
}

LOTM.RegisterPotion(LOTM.CreatePotion({
    UID = "my_potion_s9",
    Name = "My Potion",
    Sequence = 9,
    Description = "Описание зелья",
    Abilities = my_potion_abilities,
    DigestionRate = 0.05,
    MadnessRisk = 0.15
}))
```

## Текущие зелья

### Seer Pathway
- **seer_s9** (Sequence 9) - Divination, Danger Premonition
- **clown_s8** (Sequence 8) - Flame Control, Paper Figurine, Enhanced Agility

### Monster Pathway  
- **hunter_s9** (Sequence 9) - Enhanced Tracking, Precise Shot

### Spectator Pathway
- **spectator_s9** (Sequence 9) - Mind Reading, Psychological Insight

## База данных

### Таблица: `lotm_players`
- **steamid** (TEXT PRIMARY KEY) - SteamID64 игрока
- **data** (TEXT) - JSON с данными игрока

### Структура данных игрока:
```lua
{
    CurrentPotion = "potion_uid" or nil,
    DigestionProgress = 0.0 - 1.0,
    AbilityCooldowns = {
        ["ability_id"] = timestamp
    },
    ActedPrinciples = {} -- для будущего использования
}
```

## Переваривание зелий

- Автоматическое: каждые 30 секунд прогресс увеличивается на DigestionRate зелья
- При достижении 100% игрок может принять следующее зелье  
- Уведомление при полном переваривании

## Технические детали

### Network Strings:
- `LOTM_SyncPlayerData` - Синхронизация данных клиент-сервер
- `LOTM_ConsumePotion` - Употребление зелья
- `LOTM_ActivateAbility` - Активация способности
- `LOTM_Notification` - Уведомления игроку

### NWVars:
- `LOTM_Energy` (Float) - Текущая энергия
- `LOTM_LastCombat` (Float) - Время последнего боя
- `LOTM_Ability_1-4` (String) - ID способностей в слотах

## Будущие улучшения

- [ ] UI меню для просмотра всех зелий
- [ ] Система Acting (отыгрыш принципов для ускорения переваривания)
- [ ] Система Madness (безумие при неправильном использовании)
- [ ] Визуальные эффекты для способностей
- [ ] Звуковые эффекты
- [ ] Больше путей и зелий
- [ ] Система Beyonder characteristics (характеристик)
