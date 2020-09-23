CREATE DATABASE Integralni_5_9_2016
USE Integralni_5_9_2016

--1)
CREATE TABLE Klijenti
(
	KlijentID INT CONSTRAINT PK_KlijentID PRIMARY KEY IDENTITY(1,1),
	Ime NVARCHAR(30) NOT NULL,
	Prezime NVARCHAR(30) NOT NULL,
	Telefon NVARCHAR(30) NOT NULL,
	Mail NVARCHAR(50) NOT NULL CONSTRAINT UQ_Mail UNIQUE,
	BrojRacuna NVARCHAR(15) NOT NULL,
	KorisnickoIme NVARCHAR(20) NOT NULL	,
	Lozinka NVARCHAR(20) NOT NULL
)

CREATE TABLE Transakcije
(
	TransakcijaID INT CONSTRAINT PK_TrasakcijaID PRIMARY KEY IDENTITY(1,1),
	Datum DATETIME NOT NULL,
	TipTransakcije NVARCHAR(30) NOT NULL,
	PosijlalacID INT CONSTRAINT FK_PosiljalacID FOREIGN KEY REFERENCES Klijenti(KlijentID) NOT NULL,
	PrimalacID INT CONSTRAINT FK_PrimalacID FOREIGN KEY REFERENCES Klijenti(KlijentID) NOT NULL,
	Svrha NVARCHAR(50) NOT NULL,
	Iznos DECIMAL NOT NULL
)

--2) 
INSERT INTO Klijenti(Ime,Prezime,Telefon,Mail,BrojRacuna,KorisnickoIme,Lozinka)
SELECT P.FirstName, P.LastName, PP.PhoneNumber, EA.EmailAddress, C.AccountNumber, P.FirstName+'.'+P.LastName, RIGHT(PAS.PasswordHash,8)
FROM AdventureWorks2017.Sales.Customer AS C INNER JOIN AdventureWorks2017.Person.Person AS P
ON P.BusinessEntityID = C.PersonID INNER JOIN AdventureWorks2017.Person.PersonPhone AS PP
ON PP.BusinessEntityID = P.BusinessEntityID INNER JOIN AdventureWorks2017.Person.EmailAddress AS EA
ON EA.BusinessEntityID = P.BusinessEntityID INNER JOIN AdventureWorks2017.Person.Password AS PAS
ON P.BusinessEntityID = PAS.BusinessEntityID

INSERT INTO Transakcije(Datum,TipTransakcije,PosijlalacID,PrimalacID,Svrha,Iznos)
VALUES (GETDATE(),'W',122,123,'///',2312),
	   (GETDATE(),'S',124,127,'///',2152),
	   (GETDATE(),'W',127,123,'///',63.1),
	   (GETDATE(),'S',133,130,'///',431.2),
	   (GETDATE(),'S',132,144,'///',6642),
	   (GETDATE(),'W',131,133,'///',67.12),
	   (GETDATE(),'W',137,123,'///',0.22),
	   (GETDATE(),'S',155,153,'///',1235),
	   (GETDATE(),'W',130,131,'///',223),
	   (GETDATE(),'S',144,154,'///',123)

--3) INDEKSI

--4) 
CREATE PROCEDURE Procedura_4
(
	@Ime NVARCHAR(30),
	@Prezime NVARCHAR(30),
	@Telefon NVARCHAR(20),
	@Mail NVARCHAR(50),
	@BrojRacuna NVARCHAR(15),
	@KorisnickoIme NVARCHAR(50),
	@Lozinka NVARCHAR(20)
)
AS 
BEGIN
INSERT INTO Klijenti(Ime, Prezime, Telefon, Mail, BrojRacuna, KorisnickoIme, Lozinka)
VALUES(@Ime,@Prezime,@Telefon,@Mail,@BrojRacuna,@KorisnickoIme,@Lozinka)
END

EXEC Procedura_4 'Mirza', 'Kozica', '062-323-641','mirza.kozica@edu.ba','92c9vx901y','mirza.k','132412scyx'

--5)
CREATE VIEW View_5
AS
SELECT T.Datum, T.TipTransakcije,PRIM.Ime+' '+PRIM.Prezime AS Primalac, PRIM.BrojRacuna AS [Primaoc racun],
	   POS.Ime+' ' + POS.Prezime AS Posiljalac, POS.BrojRacuna AS [Posiljaoc racun]
FROM Transakcije AS T INNER JOIN Klijenti AS PRIM
ON PRIM.KlijentID = T.PrimalacID INNER JOIN Klijenti AS POS
ON POS.KlijentID = T.PosijlalacID

SELECT* FROM View_5


--6)
CREATE PROCEDURE Procedure_6
(
	@BrojRacuna NVARCHAR(15)
)
AS
BEGIN
SELECT [Primaoc racun]
FROM View_5
WHERE [Primaoc racun] = @BrojRacuna
END

SELECT* FROM Transakcije


--7)
SELECT YEAR(Datum), SUM(Iznos) AS [Ukupan iznos]
FROM Transakcije
GROUP BY YEAR(Datum)

--8)
CREATE PROCEDURE Procedura_8
(
	@KlijentID INT
)
AS
BEGIN
DELETE FROM Transakcije
WHERE PosijlalacID = @KlijentID OR PrimalacID = @KlijentID;
DELETE FROM Klijenti 
WHERE KlijentID = @KlijentID;
END

EXEC Procedura_8 124

--9)
CREATE PROCEDURE Procedura_9
(
	@BrojRacuna NVARCHAR(15) NULL,
	@PrezimePosiljaoca NVARCHAR(20) NULL
)
AS
BEGIN
SELECT *
FROM View_5
WHERE [Posiljaoc racun] = @BrojRacuna OR SUBSTRING(Posiljalac,CHARINDEX(' ',Posiljalac,1)+1,40) = @PrezimePosiljaoca
UNION
SELECT*
FROM View_5
WHERE @BrojRacuna IS NULL AND @PrezimePosiljaoca IS NULL
END

SELECT* FROM View_5

EXEC Procedura_9 'AW00029485','Smith'