--1)
CREATE DATABASE Integralni_20_6_2017

USE Integralni_20_6_2017

--2)
CREATE TABLE Proizvodi
(
	ProizvodID INT CONSTRAINT PK_ProizvodID PRIMARY KEY IDENTITY (1,1),
	Sifra NVARCHAR(25) CONSTRAINT UQ_Sifra UNIQUE NOT NULL,
	Naziv NVARCHAR(50) NOT NULL,
	Kategorija NVARCHAR(50) NOT NULL,
	Cijena DECIMAL NOT NULL
)

CREATE TABLE Narudzbe
(
	NarudzbaID INT CONSTRAINT PK_NarudzbaID PRIMARY KEY IDENTITY (1,1),
	BrojNarudzbe NVARCHAR(25) CONSTRAINT UQ_BrojNarudzbe UNIQUE,
	Datum DATETIME NOT NULL,
	Ukupno DECIMAL NOT NULL
)

CREATE TABLE StavkeNarudzbe
(
	ProizvodID INT CONSTRAINT FK_ProizvodID FOREIGN KEY REFERENCES Proizvodi(ProizvodID),
	NarudzbaID INT CONSTRAINT FK_NarudzbeID FOREIGN KEY REFERENCES Narudzbe(NarudzbaID),
	Kolicina INT NOT NULL,
	Cijena DECIMAL NOT NULL,
	Popust DECIMAL NOT NULL,
	Iznos DECIMAL NOT NULL
)

--3)
SET IDENTITY_INSERT Proizvodi ON
INSERT INTO Proizvodi(ProizvodID,Sifra,Naziv,Kategorija,Cijena)
SELECT DISTINCT P.ProductID, P.ProductNumber, P.Name,PC.Name,P.ListPrice
FROM AdventureWorks2017.Production.Product AS P INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS PSC
ON P.ProductSubcategoryID = PSC.ProductSubcategoryID INNER JOIN AdventureWorks2017.Production.ProductCategory AS PC
ON PC.ProductCategoryID = PSC.ProductCategoryID INNER JOIN AdventureWorks2017.Sales.SalesOrderDetail AS SOD
ON SOD.ProductID = P.ProductID INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS SOH
ON SOH.SalesOrderID = SOD.SalesOrderID
WHERE YEAR( SOH.OrderDate) = '2014'
SET IDENTITY_INSERT Proizvodi OFF


SET IDENTITY_INSERT Narudzbe ON
INSERT INTO Narudzbe(NarudzbaID,BrojNarudzbe,Datum,Ukupno)
SELECT SOH.SalesOrderID, SOH.SalesOrderNumber, SOH.OrderDate, SOH.TotalDue 
FROM AdventureWorks2017.Sales.SalesOrderHeader AS SOH 
WHERE YEAR(SOH.OrderDate) = '2014'
SET IDENTITY_INSERT Narudzbe OFF


INSERT INTO StavkeNarudzbe
SELECT SOD.ProductID, SOD.SalesOrderID, SOD.OrderQty, SOD.UnitPrice, SOD.UnitPriceDiscount, SOD.LineTotal
FROM AdventureWorks2017.Sales.SalesOrderHeader AS SOH INNER JOIN AdventureWorks2017.Sales.SalesOrderDetail AS SOD
ON SOD.SalesOrderID = SOH.SalesOrderID
WHERE YEAR( SOH.OrderDate) = '2014'

--4)
CREATE TABLE Skladista
(
	SkladisteID INT CONSTRAINT PK_SkladisteID PRIMARY KEY IDENTITY(1,1),
	Naziv NVARCHAR(50) NOT NULL
)

CREATE TABLE ProizvodSkladiste
(
	ProizvodID INT CONSTRAINT FK_ProizvodIDSkladiste REFERENCES Proizvodi(ProizvodID),
	SkladisteID INT CONSTRAINT FK_SkladisteID REFERENCES Skladista(SkladisteID),
	Kolicina INT
)

--5)
INSERT INTO Skladista(Naziv)
VALUES ('Skladiste Kakanj'),
	   ('Skladiste Zenica'),
	   ('Skladiste Sarajevo')

INSERT INTO ProizvodSkladiste
SELECT P.ProizvodID,1,0
FROM Proizvodi AS P

INSERT INTO ProizvodSkladiste
SELECT P.ProizvodID,2,0
FROM Proizvodi AS P

INSERT INTO ProizvodSkladiste
SELECT P.ProizvodID,3,0
FROM Proizvodi AS P

--6)
CREATE PROCEDURE Procedura_6
(
	@SkladisteID INT,
	@ProizvodID INT,
	@Kolicina INT
)
AS
BEGIN
UPDATE ProizvodSkladiste
SET Kolicina = @Kolicina
WHERE SkladisteID = @SkladisteID AND ProizvodID = @ProizvodID
END

EXEC Procedura_6 1,707,5

--7) indeksi
CREATE NONCLUSTERED INDEX IX_Sifra_Proizvod 
ON Proizvodi (Sifra, Naziv)

SELECT Sifra, Naziv
FROM Proizvodi
WHERE Sifra LIKE '%[0-5]'

--8) triggeri
ALTER TRIGGER TR_Sprijecavanja_Brisanja
ON Proizvodi
INSTEAD OF DELETE
AS

BEGIN 
	PRINT 'Nije dozvoljeno brisanje'
--	ROLLBACK (moze a i ne mora)
END

DELETE FROM Proizvodi
WHERE ProizvodID = 713

SELECT* FROM Proizvodi
--9)
CREATE VIEW View_9
AS
SELECT P.Sifra, P.Naziv, P.Cijena, SUM(SN.Kolicina) AS [Ukupno prodano], SUM(SN.Cijena) AS Zarada
FROM Proizvodi AS P INNER JOIN StavkeNarudzbe AS SN
ON SN.ProizvodID = P.ProizvodID		
GROUP BY P.Sifra, P.Naziv, P.Cijena

SELECT* FROM View_9

--10)
CREATE PROCEDURE Procedura_10
(
	@SifraProizvoda NVARCHAR(30) = NULL
)
AS
BEGIN
SELECT*
FROM View_9
WHERE Sifra = @SifraProizvoda OR @SifraProizvoda IS NULL
END

EXEC Procedura_10 NULL

--11)
--Kreirati studenta i permisije.