USE AdventureWorks2022;
GO

CREATE TABLE dbo.NewFeatureTable (
    FeatureID INT IDENTITY(3,1) PRIMARY KEY,
    FeatureName NVARCHAR(20) NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

ALTER TABLE Person.Person
ADD MiddleName NVARCHAR(50) NULL;
GO
------------------------
USE AdventureWorks2016;
GO

CREATE TABLE dbo.SchemaChangesLog (
    ChangeID INT IDENTITY(1,1) PRIMARY KEY,
    EventType NVARCHAR(100),
    ObjectName NVARCHAR(256),
    TSQLCommand NVARCHAR(MAX),
    ChangeDate DATETIME DEFAULT GETDATE()
);
GO

CREATE TRIGGER trg_SchemaChangeLogger
ON DATABASE
FOR DDL_DATABASE_LEVEL_EVENTS
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EventType NVARCHAR(100) = EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)');
    DECLARE @ObjectName NVARCHAR(256) = EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(256)');
    DECLARE @TSQLCommand NVARCHAR(MAX) = EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)');

    INSERT INTO dbo.SchemaChangesLog (EventType, ObjectName, TSQLCommand)
    VALUES (@EventType, @ObjectName, @TSQLCommand);
END;
GO
---------------------------
RESTORE DATABASE AdventureWorks2022
FROM DISK = 'C:\Backup\AdventureWorks2022_PreUpgrade.bak'
WITH REPLACE;