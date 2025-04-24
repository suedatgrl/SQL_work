


CREATE DATABASE ENCRYPTION KEY;
GO

ALTER DATABASE AdventureWorks2016 SET ENCRYPTION ON;
GO

-- Windows Authentication kullanarak oturum açma
USE [master];
GO
CREATE LOGIN [domain\username] FROM WINDOWS;
GO

-- SQL Server Authentication için kullanıcı oluşturma
CREATE LOGIN sqluser WITH PASSWORD = 'password';
GO

-- Parametreli sorgu kullanımı
DECLARE @PersonID INT;
SET @PersonID = 10;

SELECT * FROM Person.Person WHERE CustomerID = @PersonID;
GO


-- master veritabanını kullanma
USE master;
GO

-- Audit log dosyasının geçerli bir yol ile oluşturulması
CREATE SERVER AUDIT Audit_User_Login
TO FILE (FILEPATH = 'C:\SQLServer\');  
GO

-- Audit'i başlatma
ALTER SERVER AUDIT Audit_User_Login
WITH (STATE = ON);
GO
