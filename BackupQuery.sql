
-- 1. Yedekleme için varsayılan konum
USE master;
GO

-- Değişken tanımla
DECLARE @BackupPath NVARCHAR(255)
SET @BackupPath = 'C:\SQLBackups\' 

-- 2. Basit bir T-SQL yedekleme komutu 
BACKUP DATABASE [TestDB]
TO DISK = @BackupPath + 'TestDB_FullBackup.bak'
WITH FORMAT,
     INIT,
     NAME = 'Full Backup of TestDB',
     SKIP, NOREWIND, NOUNLOAD, STATS = 10;
GO

-- 3. SQL Server Agent Job oluşturma 


-- 4. Yedekleme başarı/başarısızlık kaydı için log tablosu oluşturma
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BackupLog]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[BackupLog] (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        BackupTime DATETIME DEFAULT GETDATE(),
        Status VARCHAR(50),
        Message VARCHAR(255)
    );
END
GO

-- 5. Yedekleme işlemini ve sonucu kaydeden bir stored procedure
IF OBJECT_ID('dbo.PerformBackup', 'P') IS NOT NULL
    DROP PROCEDURE dbo.PerformBackup;
GO

CREATE PROCEDURE dbo.PerformBackup
AS
BEGIN
    BEGIN TRY
        BACKUP DATABASE [TestDB]
        TO DISK = 'C:\SQLBackups\TestDB_Backup_' + CONVERT(VARCHAR, GETDATE(), 112) + '.bak'
        WITH INIT, STATS = 10;

        INSERT INTO BackupLog (Status, Message)
        VALUES ('Success', 'Backup completed successfully.');
    END TRY
    BEGIN CATCH
        INSERT INTO BackupLog (Status, Message)
        VALUES ('Fail', ERROR_MESSAGE());
    END CATCH
END;
GO

