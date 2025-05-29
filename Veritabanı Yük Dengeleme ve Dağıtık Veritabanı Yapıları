RESTORE DATABASE AdventureWorks2019
FROM DISK = 'C:\temp\AdventureWorks2019.bak'
WITH 
    MOVE 'AdventureWorks2017' TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\AdventureWorks2019.mdf',
    MOVE 'AdventureWorks2017_Log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\AdventureWorks2019.ldf',
    REPLACE


-- Yük dengeleme testleri için ek veritabanları oluşturun
CREATE DATABASE TestDB_Primary;
CREATE DATABASE TestDB_Secondary;
CREATE DATABASE TestDB_Replica;

-- Test tabloları oluşturun
USE TestDB_Primary;
CREATE TABLE Customers (
    ID int IDENTITY(1,1) PRIMARY KEY,
    Name nvarchar(100),
    Email nvarchar(100),
    CreatedDate datetime DEFAULT GETDATE()
);

-- Örnek veri ekleyin
INSERT INTO Customers (Name, Email) VALUES 
('Ahmet Yılmaz', 'ahmet@email.com'),
('Mehmet Kaya', 'mehmet@email.com'),
('Ayşe Demir', 'ayse@email.com');



-- Replication için gerekli ayarları yapın
USE AdventureWorks2019;
EXEC sp_replicationdboption 
    @dbname = 'AdventureWorks2019',
    @optname = 'publish',
    @value = 'true';



    --Availability Group Oluşturma
    -- Önce veritabanını Full Recovery moduna alın
ALTER DATABASE TestDB_Primary SET RECOVERY FULL;

-- Full backup alın
BACKUP DATABASE TestDB_Primary 
TO DISK = 'C:\temp\TestDB_Primary.bak';

-- Log backup alın
BACKUP LOG TestDB_Primary 
TO DISK = 'C:\temp\TestDB_Primary.trn';


-- Availability Group Listener oluşturun
ALTER AVAILABILITY GROUP AG_TestDB
ADD LISTENER 'AG_TestDB_Listener' (
    WITH IP ((N'127.0.0.1', N'255.255.255.0')),
    PORT = 1433
);


--Mirroring db hazırlık
-- Principal veritabanını Full Recovery moduna alın
ALTER DATABASE TestDB_Secondary SET RECOVERY FULL;

-- Full backup alın
BACKUP DATABASE TestDB_Secondary 
TO DISK = 'C:\temp\TestDB_Secondary.bak';

-- Log backup alın
BACKUP LOG TestDB_Secondary 
TO DISK = 'C:\temp\TestDB_Secondary.trn';

-- Mirror veritabanı oluşturun (NORECOVERY ile)
RESTORE DATABASE TestDB_Secondary_Mirror
FROM DISK = 'C:\temp\TestDB_Secondary.bak'
WITH NORECOVERY,
MOVE 'TestDB_Secondary' TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\TestDB_Secondary_Mirror.mdf',
MOVE 'TestDB_Secondary_Log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\TestDB_Secondary_Mirror.ldf';

-- Log restore
RESTORE LOG TestDB_Secondary_Mirror
FROM DISK = 'C:\temp\TestDB_Secondary.trn'
WITH NORECOVERY;


--kurulum
-- Mirror veritabanında partner ayarlayın
ALTER DATABASE TestDB_Secondary_Mirror
SET PARTNER = 'TCP://localhost:5022';

-- Principal veritabanında partner ayarlayın
ALTER DATABASE TestDB_Secondary
SET PARTNER = 'TCP://localhost:5023';


-- Mirroring durumunu görüntüleyin
SELECT 
    db.name,
    m.mirroring_role_desc,
    m.mirroring_state_desc,
    m.mirroring_safety_level_desc
FROM sys.database_amirroring m
JOIN sys.databases db ON m.database_id = db.database_id
WHERE m.mirroring_guid IS NOT NULL;



--failover
-- Availability Group'ta manual failover
ALTER AVAILABILITY GROUP AG_TestDB FAILOVER;

-- Failover durumunu kontrol
SELECT 
    ag.name AS AvailabilityGroup,
    r.replica_server_name,
    r.role_desc,
    rs.is_local,
    rs.role
FROM sys.availability_groups ag
JOIN sys.availability_replicas r ON ag.group_id = r.group_id
JOIN sys.dm_hadr_availability_replica_states rs ON r.replica_id = rs.replica_id;

-- Test için connection string
-- Always On için: Server=AG_TestDB_Listener;Database=TestDB_Primary;
-- Mirroring için: Server=localhost;Database=TestDB_Secondary;Failover Partner=localhost;

-- Failover testi
-- 1. Primary'ye veri insert 
USE TestDB_Primary;
INSERT INTO Customers (Name, Email) VALUES ('Test User', 'test@email.com');

-- 2. Failover
ALTER AVAILABILITY GROUP AG_TestDB FAILOVER;

-- 3. Yeni primary'de veriyi kontrol 
SELECT * FROM Customers ORDER BY ID DESC;

-- Publisher'da veri ekleyin
USE AdventureWorks2019;
INSERT INTO Person.Person (PersonType, FirstName, LastName)
VALUES ('EM', 'Test', 'User');

-- Subscriber'da kontrol edin
USE AdventureWorks_Replica;
SELECT TOP 5 * FROM Person.Person ORDER BY ModifiedDate DESC;
