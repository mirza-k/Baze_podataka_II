--1)
USE Integralni_4_9_2018

CREATE TABLE Autori
(
	AutorID NVARCHAR(11) CONSTRAINT PK_AutorID PRIMARY KEY,
	Prezime NVARCHAR(25) NOT NULL,
	Ime NVARCHAR(25) NOT NULL,
	Telefon NVARCHAR(20) DEFAULT(NULL),
	DatumKreiranjaZapisa DATETIME DEFAULT(GETDATE()),
	DatumModifikovanjaZapisa DATETIME DEFAULT(NULL)
)

CREATE TABLE Izdavaci
(	
	IzdavacID NVARCHAR(4) CONSTRAINT PK_IzdavacID PRIMARY KEY,
	Naziv NVARCHAR(100) NOT NULL CONSTRAINT UQ_Naziv UNIQUE,
	Biljeske NVARCHAR(1000) DEFAULT('Lorem ipsum'),
	DatumKreiranjaZapisa DATETIME DEFAULT(GETDATE()),
	DatumModifikovanjaZapisa DATETIME DEFAULT(NULL)
)
ALTER TRIGGER tr_Update_Izdavaci
ON Izdavaci AFTER UPDATE
AS
UPDATE Iz
SET DatumModifikovanjaZapisa =SYSDATETIME()
FROM Izdavaci AS Iz INNER JOIN inserted i
ON i.IzdavacID = Iz.IzdavacID
 
UPDATE Izdavaci
SET Biljeske = 'tntntnt'
WHERE IzdavacID=2131

CREATE NONCLUSTERED INDEX ix_Izdavaci
ON Izdavaci(Naziv) INCLUDE(Biljeske)

ALTER INDEX ix_Izdavaci ON Izdavaci
REBUILD

CREATE UNIQUE NONCLUSTERED INDEX ix_izd
ON Izdavaci(IzdavacID)
SELECT* FROM Izdavaci


INSERT INTO Izdavaci(IzdavacID,Naziv,Biljeske)
VALUES('2131','test','test')

CREATE TRIGGER tr_Izdavac_IODelete
ON Izdavaci INSTEAD OF DELETE
AS
PRINT 'Zabranjeno brisanje'

CREATE TABLE IzdavaciTrigg
(
	IzdavacID NVARCHAR(4),
	Naziv NVARCHAR(50),
	Komanda NVARCHAR(20),
	Korisnik NVARCHAR(20),
	DatumVrijeme DATETIME 
)

CREATE TYPE Mirza FROM NVARCHAR(50)
ALTER TABLE Izdavaci
ADD NoviTip Mirza

FROM Izdavaci

CREATE TRIGGER tr_Insert_Izdavac
ON Izdavaci AFTER INSERT
AS
INSERT INTO IzdavaciTrigg
SELECT i.IzdavacID,i.Naziv,'INSERT',SYSTEM_USER,GETDATE()
FROM inserted i

CREATE TRIGGER Preventiva
ON DATABASE FOR DROP_TABLE, DROP_VIEW
AS
PRINT 'Brisanje zabranjeno nad objektima'
ROLLBACK



SELECT* FROM IzdavaciTrigg

--2a)

CREATE TABLE Naslovi
(
	NaslovID NVARCHAR(6) CONSTRAINT PK_NaslovID PRIMARY KEY,
	IzdavacID NVARCHAR(4) CONSTRAINT FK_IzdavacID FOREIGN KEY REFERENCES Izdavaci(IzdavacID),
	Naslov NVARCHAR(100) NOT NULL,
	Cijena MONEY,
	DatumIzdavanjaNaslova DATETIME DEFAULT(GETDATE()),
	DatumKreiranjaZapisa DATETIME DEFAULT(GETDATE()),
	DatumModifikovanjaZapisa DATETIME DEFAULT(NULL)
)

CREATE TABLE NasloviAutori
(
	AutorID NVARCHAR (11) CONSTRAINT FK_AutorID_Nas_Aut FOREIGN KEY REFERENCES Autori(AutorID),
	NaslovID NVARCHAR(6) CONSTRAINT FK_NaslovID_Nas_Aut FOREIGN KEY REFERENCES Naslovi(NaslovID),
	DatumKreiranjaZapisa DATETIME DEFAULT(GETDATE()),
	DatumModifikovanjaZapisa DATETIME DEFAULT(NULL),
	PRIMARY KEY(AutorID, NaslovID)
)
--2b)
INSERT INTO Autori(AutorID,Prezime,Ime,Telefon)
SELECT au_id,au_fname,au_lname,phone 
FROM pubs.dbo.authors

INSERT INTO Izdavaci(IzdavacID,Naziv,Biljeske)
SELECT P.pub_id, P.pub_name, LEFT(CONVERT(NVARCHAR,PP.pr_info),100)
FROM pubs.dbo.publishers AS P INNER JOIN pubs.dbo.pub_info AS PP
ON PP.pub_id = P.pub_id
SELECT* FROM Izdavaci

INSERT INTO Naslovi(NaslovID,IzdavacID,Naslov,Cijena,DatumIzdavanjaNaslova)
SELECT title_id,pub_id,title,price,pubdate
FROM pubs.dbo.titles
SELECT* FROM Naslovi

INSERT INTO NasloviAutori(AutorID,NaslovID)
SELECT au_id, title_id 
FROM pubs.dbo.titleauthor
SELECT* FROM NasloviAutori

--2c)
CREATE TABLE Gradovi
(
	GradID INT IDENTITY(5,5) CONSTRAINT PK_GradID PRIMARY KEY,
	Naziv NVARCHAR(100) NOT NULL CONSTRAINT UQ_NazivGrada UNIQUE,
	DatumKreiranjaZapisa DATE NOT NULL DEFAULT(GETDATE()),
	DatumModifikovanjaZapisa DATE DEFAULT(NULL)
)

INSERT INTO Gradovi(Naziv)
SELECT distinct city
FROM pubs.dbo.authors

ALTER TABLE Autori
ADD Grad INT CONSTRAINT FK_GradAutori FOREIGN KEY REFERENCES Gradovi(GradID)

--2d) 
CREATE PROCEDURE DodajGradAutoru_1
AS
BEGIN
UPDATE TOP(10) Autori
SET Grad = 65
END

CREATE PROCEDURE DodajGradAutoru_2
AS
BEGIN
UPDATE Autori
SET Grad = 10
WHERE Grad IS NULL
END

EXEC DodajGradAutoru_2

--3)
CREATE VIEW pogled_1
AS
SELECT A.Ime+' '+A.Prezime AS [Ime prezime], A.Grad, N.Naslov, N.Cijena, I.Naziv , I.Biljeske 
FROM Autori AS A INNER JOIN NasloviAutori AS NA
ON NA.AutorID = A.AutorID INNER JOIN Naslovi AS N
ON N.NaslovID = NA.NaslovID INNER JOIN Izdavaci AS I
ON I.IzdavacID = N.IzdavacID
WHERE N.Cijena IS NOT NULL AND N.Cijena > 10 AND I.Naziv LIKE '%&%' AND A.Grad = 65

SELECT* FROM pogled_1

--4)
ALTER TABLE Autori
ADD Email NVARCHAR(100) DEFAULT(NULL)

--5)
CREATE PROCEDURE DodajEmail_1
AS 
BEGIN
UPDATE Autori
SET Email = Ime+'.'+Prezime+'@fit.ba'
WHERE Grad = 65
END

CREATE PROCEDURE DodajEmail_2
AS
BEGIN
UPDATE Autori
SET Email = Prezime+'.'+Ime+'@fit.ba'
WHERE Grad = 10
END

EXEC DodajEmail_2

--6)
CREATE TABLE #Lokalna
(
	Title NVARCHAR(50),
	LastName NVARCHAR(50),
	FirstName NVARCHAR(50),
	EmailAdress NVARCHAR(50),
	PhoneNumber NVARCHAR(50),
	CardNumber NVARCHAR(50),
	UserName AS FirstName + '.' + LastName,
	Password AS LEFT(REPLACE(NEWID(),'-','7'),16)
)

INSERT INTO #Lokalna(Title,LastName,FirstName,EmailAdress,PhoneNumber,CardNumber)
SELECT ISNULL(P.Title,'N/A'), P.LastName, P.FirstName, EA.EmailAddress,'xxx-xxx-xxx', CC.CardNumber	
FROM AdventureWorks2017.Person.Person AS P INNER JOIN AdventureWorks2017.Person.EmailAddress AS EA
ON EA.BusinessEntityID = P.BusinessEntityID LEFT OUTER JOIN AdventureWorks2017.Sales.PersonCreditCard AS PCC
ON PCC.BusinessEntityID = P.BusinessEntityID LEFT OUTER JOIN AdventureWorks2017.Sales.CreditCard AS CC
ON CC.CreditCardID = PCC.CreditCardID
ORDER BY 2,3 

--7) indeksi
CREATE NONCLUSTERED INDEX IX_UserName_Lokalna
ON #Lokalna(UserName)
INCLUDE(LastName, FirstName)

SELECT UserName, LastName, FirstName
FROM #Lokalna
WHERE UserName LIKE '%s'

--8)
CREATE PROCEDURE BrisanjeKreditnihLokalna
AS
BEGIN
DELETE FROM #Lokalna
WHERE CardNumber IS NULL
END

EXECUTE BrisanjeKreditnihLokalna

--9) backup


CREATE PROCEDURE Brisanje
AS
BEGIN
DELETE FROM #Lokalna
WHERE CardNumber IS NULL
END

--10a) 