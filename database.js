const sqlite3 = require('sqlite3').verbose();
const path = require('path');

class Database {
    constructor() {
        this.db = new sqlite3.Database(path.join(__dirname, 'characters.db'));
        this.initDatabase();
        this.initUserActivityTable();
        this.initRubyCoinTable();
        this.migrateRubyCoinLogsTable();
        this.initTempBanTable();
        this.initTempMuteTable();
        this.initHakiSpinsTable();
        this.initHakiHistoryTable();
        this.initTicketTable();
        this.initTicketLogsTable();
        this.initProfilesTable();
        this.initInviteTrackTable();
        this.initTrainingSystemTables();
        this.initCharacterGalleryTable();
        this.initPunishmentSystem();
        this.initEconomyTables();
        this.initKindnessSystem();
        this.initCustomProfileStyling();
    }

    migrateRubyCoinLogsTable() {
        console.log('🔄 Проверка и миграция таблицы rubycoin_logs...');
        
        this.db.get("SELECT name FROM sqlite_master WHERE type='table' AND name='rubycoin_logs'", (err, row) => {
            if (err) {
                console.error('❌ Ошибка проверки таблицы:', err);
                return;
            }

            if (!row) {
                console.log('✅ Создание новой таблицы rubycoin_logs');
                this.createNewRubyCoinLogsTable();
            } else {
                console.log('🔍 Проверка структуры существующей таблицы');
                this.db.all("PRAGMA table_info(rubycoin_logs)", (pragmaErr, columns) => {
                    if (pragmaErr) {
                        console.error('❌ Ошибка получения структуры:', pragmaErr);
                        return;
                    }

                    const columnNames = columns.map(col => col.name);
                    const hasUsername = columnNames.includes('username');
                    const hasMetadata = columnNames.includes('metadata');

                    if (!hasUsername || !hasMetadata) {
                        console.log('🔄 Требуется миграция таблицы');
                        this.performRubyCoinLogsMigration();
                    } else {
                        console.log('✅ Таблица rubycoin_logs актуальна');
                        this.createRubyCoinViews();
                    }
                });
            }
        });
    }

    createNewRubyCoinLogsTable() {
        const createTable = `
            CREATE TABLE IF NOT EXISTS rubycoin_logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT NOT NULL,
                username TEXT,
                user_discriminator TEXT,
                admin_id TEXT,
                admin_username TEXT,
                action_type TEXT NOT NULL CHECK(action_type IN (
                    'admin_add', 'admin_remove', 'earn', 'spend', 
                    'purchase', 'transfer_in', 'transfer_out', 'reward'
                )),
                amount REAL NOT NULL,
                balance_before REAL NOT NULL,
                balance_after REAL NOT NULL,
                category TEXT CHECK(category IN (
                    'admin_operation', 'shop_purchase', 'activity_reward',
                    'transfer', 'event_reward', 'system'
                )),
                item_name TEXT,
                description TEXT NOT NULL,
                guild_id TEXT,
                channel_id TEXT,
                message_id TEXT,
                metadata TEXT,
                created_at DATETIME DEFAULT (datetime('now', 'localtime'))
            )
        `;

        this.db.run(createTable, (err) => {
            if (err) {
                console.error('❌ Ошибка создания rubycoin_logs:', err);
            } else {
                console.log('✅ Таблица rubycoin_logs создана');
                this.createRubyCoinIndexes();
                this.createRubyCoinViews();
            }
        });
    }

    performRubyCoinLogsMigration() {
        this.db.serialize(() => {
            console.log('📦 Начало миграции rubycoin_logs');

            this.db.run('BEGIN TRANSACTION');

            this.db.run('ALTER TABLE rubycoin_logs RENAME TO rubycoin_logs_old', (renameErr) => {
                if (renameErr) {
                    console.error('❌ Ошибка переименования:', renameErr);
                    this.db.run('ROLLBACK');
                    return;
                }

                const createNewTable = `
                    CREATE TABLE rubycoin_logs (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        user_id TEXT NOT NULL,
                        username TEXT,
                        user_discriminator TEXT,
                        admin_id TEXT,
                        admin_username TEXT,
                        action_type TEXT NOT NULL CHECK(action_type IN (
                            'admin_add', 'admin_remove', 'earn', 'spend', 
                            'purchase', 'transfer_in', 'transfer_out', 'reward'
                        )),
                        amount REAL NOT NULL,
                        balance_before REAL NOT NULL,
                        balance_after REAL NOT NULL,
                        category TEXT CHECK(category IN (
                            'admin_operation', 'shop_purchase', 'activity_reward',
                            'transfer', 'event_reward', 'system'
                        )),
                        item_name TEXT,
                        description TEXT NOT NULL,
                        guild_id TEXT,
                        channel_id TEXT,
                        message_id TEXT,
                        metadata TEXT,
                        created_at DATETIME DEFAULT (datetime('now', 'localtime'))
                    )
                `;

                this.db.run(createNewTable, (createErr) => {
                    if (createErr) {
                        console.error('❌ Ошибка создания новой таблицы:', createErr);
                        this.db.run('ROLLBACK');
                        return;
                    }

                    const copyData = `
                        INSERT INTO rubycoin_logs 
                        (id, user_id, admin_id, action_type, amount, balance_before, balance_after,
                         category, item_name, description, guild_id, channel_id, created_at)
                        SELECT 
                            id, user_id, admin_id, action_type, amount, balance_before, balance_after,
                            category, item_name, 
                            COALESCE(description, 'Операция ' || action_type),
                            guild_id, channel_id, created_at
                        FROM rubycoin_logs_old
                    `;

                    this.db.run(copyData, (copyErr) => {
                        if (copyErr) {
                            console.error('❌ Ошибка копирования данных:', copyErr);
                            this.db.run('ROLLBACK');
                            return;
                        }

                        this.db.run('DROP TABLE rubycoin_logs_old', (dropErr) => {
                            if (dropErr) {
                                console.error('❌ Ошибка удаления старой таблицы:', dropErr);
                                this.db.run('ROLLBACK');
                                return;
                            }

                            this.db.run('COMMIT', (commitErr) => {
                                if (commitErr) {
                                    console.error('❌ Ошибка коммита:', commitErr);
                                } else {
                                    console.log('✅ Миграция завершена успешно');
                                    this.createRubyCoinIndexes();
                                    this.createRubyCoinViews();
                                }
                            });
                        });
                    });
                });
            });
        });
    }

    createRubyCoinIndexes() {
        const indexes = [
            'CREATE INDEX IF NOT EXISTS idx_rubycoin_user ON rubycoin_logs(user_id)',
            'CREATE INDEX IF NOT EXISTS idx_rubycoin_username ON rubycoin_logs(username COLLATE NOCASE)',
            'CREATE INDEX IF NOT EXISTS idx_rubycoin_action ON rubycoin_logs(action_type)',
            'CREATE INDEX IF NOT EXISTS idx_rubycoin_created ON rubycoin_logs(created_at DESC)',
            'CREATE INDEX IF NOT EXISTS idx_rubycoin_category ON rubycoin_logs(category)',
            'CREATE INDEX IF NOT EXISTS idx_rubycoin_admin ON rubycoin_logs(admin_id)',
            'CREATE INDEX IF NOT EXISTS idx_rubycoin_combined ON rubycoin_logs(user_id, created_at DESC, action_type)',
            'CREATE INDEX IF NOT EXISTS idx_rubycoin_admin_combined ON rubycoin_logs(admin_id, created_at DESC)'
        ];

        indexes.forEach(indexQuery => {
            this.db.run(indexQuery, (err) => {
                if (err && !err.message.includes('already exists')) {
                    console.error('❌ Ошибка создания индекса:', err);
                }
            });
        });

        console.log('✅ Индексы rubycoin_logs созданы');
    }

    createRubyCoinViews() {
        const userStatsView = `
            CREATE VIEW IF NOT EXISTS v_rubycoin_user_stats AS
            SELECT 
                user_id,
                MAX(username) as latest_username,
                COUNT(*) as total_transactions,
                SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END) as total_earned,
                SUM(CASE WHEN amount < 0 THEN ABS(amount) ELSE 0 END) as total_spent,
                MAX(balance_after) as current_balance,
                MAX(created_at) as last_transaction,
                MIN(created_at) as first_transaction
            FROM rubycoin_logs
            GROUP BY user_id
        `;

        const categoryStatsView = `
            CREATE VIEW IF NOT EXISTS v_rubycoin_category_stats AS
            SELECT 
                user_id,
                MAX(username) as username,
                category,
                COUNT(*) as transaction_count,
                SUM(ABS(amount)) as total_amount,
                AVG(ABS(amount)) as avg_amount
            FROM rubycoin_logs
            WHERE category IS NOT NULL
            GROUP BY user_id, category
        `;

        const adminActivityView = `
            CREATE VIEW IF NOT EXISTS v_admin_rubycoin_activity AS
            SELECT 
                admin_id,
                MAX(admin_username) as admin_username,
                COUNT(*) as total_operations,
                SUM(CASE WHEN amount > 0 THEN 1 ELSE 0 END) as additions,
                SUM(CASE WHEN amount < 0 THEN 1 ELSE 0 END) as removals,
                SUM(amount) as net_change,
                MAX(created_at) as last_operation
            FROM rubycoin_logs
            WHERE admin_id IS NOT NULL
            GROUP BY admin_id
        `;

        [userStatsView, categoryStatsView, adminActivityView].forEach(viewQuery => {
            this.db.run(viewQuery, (err) => {
                if (err && !err.message.includes('already exists')) {
                    console.error('❌ Ошибка создания представления:', err);
                }
            });
        });

        console.log('✅ Представления rubycoin созданы');
    }

    initDatabase() {
        const createTableQuery = `
            CREATE TABLE IF NOT EXISTS characters (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT NOT NULL,
                name TEXT NOT NULL,
                race TEXT,
                age INTEGER,
                nickname TEXT,
                organization TEXT,
                position TEXT,
                mention TEXT,
                strength INTEGER DEFAULT 0,
                agility INTEGER DEFAULT 0,
                reaction INTEGER DEFAULT 0,
                accuracy INTEGER DEFAULT 0,
                endurance INTEGER DEFAULT 0,
                durability INTEGER DEFAULT 0,
                magic INTEGER DEFAULT 0,
                devilfruit TEXT,
                patronage TEXT,
                core TEXT,
                hakivor TEXT,
                hakinab TEXT,
                hakiconq TEXT,
                elements TEXT,
                martialarts TEXT,
                budget INTEGER DEFAULT 0,
                additional TEXT,
                avatar_url TEXT,
                embed_color TEXT DEFAULT '#9932cc',
                icon_url TEXT DEFAULT NULL,
                slot INTEGER DEFAULT 1,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        `;
        this.db.run(createTableQuery, (err) => {
            if (err) console.error('Ошибка создания таблицы персонажей:', err);
        });
    }

    initUserActivityTable() {
        const createActivityTableQuery = `
            CREATE TABLE IF NOT EXISTS user_activity (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT NOT NULL,
                guild_id TEXT NOT NULL,
                messages_count INTEGER DEFAULT 0,
                voice_time INTEGER DEFAULT 0,
                week_start DATE NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(user_id, guild_id, week_start)
            )
        `;
        this.db.run(createActivityTableQuery, (err) => {
            if (err) console.error('Ошибка создания таблицы активности:', err);
        });
    }

    initRubyCoinTable() {
        const createRubyCoinTableQuery = `
            CREATE TABLE IF NOT EXISTS user_rubycoins (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT NOT NULL UNIQUE,
                rubycoins REAL DEFAULT 0.0,
                total_earned REAL DEFAULT 0.0,
                total_spent REAL DEFAULT 0.0,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        `;
        this.db.run(createRubyCoinTableQuery, (err) => {
            if (err) console.error('Ошибка создания таблицы RubyCoin:', err);
        });
    }

    initTempBanTable() {
        const createTempBanTableQuery = `
            CREATE TABLE IF NOT EXISTS temp_bans (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT NOT NULL,
                guild_id TEXT NOT NULL,
                ban_end_time DATETIME NOT NULL,
                reason TEXT NOT NULL,
                moderator_id TEXT NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(user_id, guild_id)
            )
        `;
        this.db.run(createTempBanTableQuery, (err) => {
            if (err) console.error('Ошибка создания таблицы темп-банов:', err);
        });
    }

    initTempMuteTable() {
        const createTempMuteTableQuery = `
            CREATE TABLE IF NOT EXISTS temp_mutes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT NOT NULL,
                guild_id TEXT NOT NULL,
                mute_end_time DATETIME NOT NULL,
                reason TEXT NOT NULL,
                moderator_id TEXT NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(user_id, guild_id)
            )
        `;
        this.db.run(createTempMuteTableQuery, (err) => {
            if (err) console.error('Ошибка создания таблицы темп-мутов:', err);
        });
    }

    initHakiSpinsTable() {
        const createHakiSpinsTableQuery = `
            CREATE TABLE IF NOT EXISTS user_haki_spins (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT NOT NULL UNIQUE,
                haki_spins INTEGER DEFAULT 0,
                total_earned INTEGER DEFAULT 0,
                total_used INTEGER DEFAULT 0,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        `;
        this.db.run(createHakiSpinsTableQuery, (err) => {
            if (err) console.error('Ошибка создания таблицы круток хаки:', err);
        });
    }

    initHakiHistoryTable() {
        const createHakiHistoryTableQuery = `
            CREATE TABLE IF NOT EXISTS haki_spin_history (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT NOT NULL,
                haki_result TEXT NOT NULL,
                spin_count INTEGER NOT NULL,
                total_spins INTEGER NOT NULL,
                session_id TEXT NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        `;
        this.db.run(createHakiHistoryTableQuery, (err) => {
            if (err) console.error('Ошибка создания таблицы истории хаки:', err);
        });
    }

    initTicketTable() {}
    initTicketLogsTable() {}
    initProfilesTable() {}
    initInviteTrackTable() {}
    initTrainingSystemTables() {}
    initCharacterGalleryTable() {}
    initPunishmentSystem() {}
    initEconomyTables() {}
    initKindnessSystem() {}
    initCustomProfileStyling() {}

    getUserRubyCoins(userId) {
        return new Promise((resolve, reject) => {
            const query = 'SELECT rubycoins FROM user_rubycoins WHERE user_id = ?';
            this.db.get(query, [userId], (err, row) => {
                if (err) reject(err);
                else resolve(row ? row.rubycoins : 0);
            });
        });
    }

    addRubyCoins(userId, amount) {
        return new Promise((resolve, reject) => {
            const query = `
                INSERT INTO user_rubycoins (user_id, rubycoins, total_earned)
                VALUES (?, ?, ?)
                ON CONFLICT(user_id)
                DO UPDATE SET
                    rubycoins = rubycoins + ?,
                    total_earned = CASE WHEN ? > 0 THEN total_earned + ? ELSE total_earned END,
                    total_spent = CASE WHEN ? < 0 THEN total_spent + ABS(?) ELSE total_spent END,
                    updated_at = CURRENT_TIMESTAMP
            `;
            this.db.run(query, [
                userId, amount, Math.max(0, amount),
                amount,
                amount, amount,
                amount, amount
            ], function(err) {
                if (err) reject(err);
                else resolve(this.changes);
            });
        });
    }

    getCharacterByUserId(userId) {
        return new Promise((resolve, reject) => {
            const query = 'SELECT * FROM characters WHERE user_id = ?';
            this.db.get(query, [userId], (err, row) => {
                if (err) reject(err);
                else resolve(row);
            });
        });
    }

    getAllCharactersByUserId(userId) {
        return new Promise((resolve, reject) => {
            const query = 'SELECT * FROM characters WHERE user_id = ? ORDER BY slot ASC, created_at DESC';
            this.db.all(query, [userId], (err, rows) => {
                if (err) reject(err);
                else resolve(rows || []);
            });
        });
    }

    getCharacterById(characterId) {
        return new Promise((resolve, reject) => {
            const query = 'SELECT * FROM characters WHERE id = ?';
            this.db.get(query, [characterId], (err, row) => {
                if (err) reject(err);
                else resolve(row);
            });
        });
    }

    createCharacter(characterData) {
        return new Promise((resolve, reject) => {
            const query = `
                INSERT INTO characters (
                    user_id, name, race, age, nickname, organization, position, mention,
                    strength, agility, reaction, accuracy, endurance, durability, magic,
                    devilfruit, patronage, core, hakivor, hakinab,
                    hakiconq, elements, martialarts, budget, additional, avatar_url, embed_color, slot
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            `;
            this.db.run(query, [
                characterData.user_id, characterData.name, characterData.race,
                characterData.age, characterData.nickname, characterData.organization,
                characterData.position, characterData.mention, characterData.strength,
                characterData.agility, characterData.reaction, characterData.accuracy,
                characterData.endurance, characterData.durability, characterData.magic,
                characterData.devilfruit, characterData.patronage, characterData.core,
                characterData.hakivor, characterData.hakinab,
                characterData.hakiconq, characterData.elements,
                characterData.martialarts, characterData.budget, characterData.additional,
                characterData.avatar_url || null, characterData.embed_color || '#9932cc',
                characterData.slot || 1
            ], function(err) {
                if (err) reject(err);
                else resolve(this.lastID);
            });
        });
    }

    updateCharacterStats(characterId, stats) {
        return new Promise((resolve, reject) => {
            const query = `
                UPDATE characters SET
                    strength = ?, agility = ?, reaction = ?, accuracy = ?,
                    endurance = ?, durability = ?, magic = ?, devilfruit = ?,
                    patronage = ?, core = ?, hakivor = ?, hakinab = ?,
                    hakiconq = ?, elements = ?, martialarts = ?, budget = ?,
                    organization = ?, position = ?, additional = ?
                WHERE id = ?
            `;
            this.db.run(query, [
                stats.strength, stats.agility, stats.reaction, stats.accuracy,
                stats.endurance, stats.durability, stats.magic, stats.devilfruit,
                stats.patronage, stats.core, stats.hakivor, stats.hakinab,
                stats.hakiconq, stats.elements, stats.martialarts, stats.budget,
                stats.organization, stats.position, stats.additional, characterId
            ], function(err) {
                if (err) reject(err);
                else resolve(this.changes);
            });
        });
    }

    deleteCharacter(characterId) {
        return new Promise((resolve, reject) => {
            const query = 'DELETE FROM characters WHERE id = ?';
            this.db.run(query, [characterId], function(err) {
                if (err) reject(err);
                else resolve(this.changes);
            });
        });
    }

    addMessageActivity(userId, guildId) {
        return new Promise((resolve, reject) => {
            const weekStart = this.getWeekStart();
            const query = `
                INSERT INTO user_activity (user_id, guild_id, messages_count, week_start)
                VALUES (?, ?, 1, ?)
                ON CONFLICT(user_id, guild_id, week_start)
                DO UPDATE SET
                    messages_count = messages_count + 1,
                    updated_at = CURRENT_TIMESTAMP
            `;
            this.db.run(query, [userId, guildId, weekStart], function(err) {
                if (err) reject(err);
                else resolve(this.changes);
            });
        });
    }

    getWeekStart() {
        const now = new Date();
        const dayOfWeek = now.getDay();
        const diff = now.getDate() - dayOfWeek + (dayOfWeek === 0 ? -6 : 1);
        const monday = new Date(now.setDate(diff));
        monday.setHours(0, 0, 0, 0);
        return monday.toISOString().split('T')[0];
    }

    getUserWeekActivity(userId, guildId) {
        return new Promise((resolve, reject) => {
            const weekStart = this.getWeekStart();
            const query = `
                SELECT messages_count, voice_time
                FROM user_activity
                WHERE user_id = ? AND guild_id = ? AND week_start = ?
            `;
            this.db.get(query, [userId, guildId, weekStart], (err, row) => {
                if (err) reject(err);
                else resolve(row || { messages_count: 0, voice_time: 0 });
            });
        });
    }
}

module.exports = Database;