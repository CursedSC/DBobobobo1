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

    initDatabase() {}
    initUserActivityTable() {}
    initRubyCoinTable() {}
    initTempBanTable() {}
    initTempMuteTable() {}
    initHakiSpinsTable() {}
    initHakiHistoryTable() {}
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
}

module.exports = Database;