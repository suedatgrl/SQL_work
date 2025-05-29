-- 1. Full Backup (Tam Yedekleme)
BACKUP DATABASE [AdventureWorks2022]
TO DISK = 'C:\Backups\AdventureWorks2022_full.bak'
WITH FORMAT, MEDIANAME = 'DbBackup', NAME = 'Full Backup of AdventureWorks2022';
GO

-- 2. Differential Backup (Fark Yedekleme)
BACKUP DATABASE [AdventureWorks2022]
TO DISK = 'C:\Backups\AdventureWorks2022_diff.bak'
WITH DIFFERENTIAL, MEDIANAME = 'DbBackup', NAME = 'Differential Backup of AdventureWorks2022';
GO

-- 3. Transaction Log Backup (Transaction Log Yedekleme)
BACKUP LOG [AdventureWorks2022]
TO DISK = 'C:\Backups\AdventureWorks2022_log.bak'
WITH MEDIANAME = 'DbLogBackup', NAME = 'Transaction Log Backup of AdventureWorks2022';
GO

-- 4. Yedekleme Durumunu Kontrol Etme
RESTORE FILELISTONLY
FROM DISK = 'C:\Backups\AdventureWorks2022_full.bak';
GO

-- 5. Veritabanını Yedekten Geri Yükleme (Restore)
-- Full Backup
RESTORE DATABASE [AdventureWorks2022]
FROM DISK = 'C:\Backups\AdventureWorks2022_full.bak'
WITH REPLACE;
GO

-- Differential Backup
RESTORE DATABASE [AdventureWorks2022]
FROM DISK = 'C:\Backups\AdventureWorks2022_full.bak'
WITH NORECOVERY;
GO

RESTORE DATABASE [AdventureWorks2022]
FROM DISK = 'C:\Backups\AdventureWorks2022_diff.bak'
WITH RECOVERY;
GO

-- Transaction Log Backup
RESTORE LOG [AdventureWorks2022]
FROM DISK = 'C:\Backups\AdventureWorks2022_log.bak'
WITH RECOVERY;
GO

-- 6. Veritabanını Belirli Bir Zaman Noktasına Geri Yükleme (Point-in-Time Restore)
RESTORE DATABASE [AdventureWorks2022]
FROM DISK = 'C:\Backups\AdventureWorks2022_full.bak'
WITH NORECOVERY;
GO

RESTORE LOG [AdventureWorks2022]
FROM DISK = 'C:\Backups\AdventureWorks2022_log.bak'
WITH STOPAT = '2025-04-20 13:30:00', RECOVERY;
GO

-- 7. Yedekleme Durumu
SELECT database_id, name, state_desc, recovery_model_desc
FROM sys.databases
WHERE name = '[AdventureWorks2022]';
GO