USE AdventureWorks2022;
GO

SELECT BusinessEntityID, FirstName, LastName, EmailPromotion
FROM Person.Person
WHERE EmailPromotion NOT IN (0,1);
GO

UPDATE Person.Person
SET EmailPromotion = 0
WHERE EmailPromotion NOT IN (0,1);
GO

UPDATE Person.Person
SET FirstName = UPPER(FirstName),
    LastName = UPPER(LastName);
GO

SELECT EmailPromotion, COUNT(*) AS Count
FROM Person.Person
GROUP BY EmailPromotion;
GO