/*
1. Kroz SQL kod, napraviti bazu podataka koja nosi ime vašeg broja dosijea. U postupku kreiranja u
obzir uzeti samo DEFAULT postavke.
*/
CREATE DATABASE Integralni_16_7_2016
USE Integralni_16_7_2016
GO

/*
Unutar svoje baze podataka kreirati tabelu sa sljedećom strukturom:
a) Proizvodi:
I. ProizvodID, automatski generatpr vrijednosti i primarni ključ
II. Sifra, polje za unos 10 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
III. Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
IV. Cijena, polje za unos decimalnog broja (obavezan unos)
*/
CREATE TABLE Proizvodi
(
	ProizvodID INT CONSTRAINT PK_ProizvodID PRIMARY KEY IDENTITY(1,1),
	Sifra NVARCHAR(10) UNIQUE NOT NULL,
	Naziv NVARCHAR(50) NOT NULL,
	Cijena DECIMAL NOT NULL
)
ALTER TABLE Proizvodi
ADD Test INT CONSTRAINT CH_Test CHECK(Test>10)

INSERT INTO Proizvodi
VALUES('test2','test',22,11)
/*
b) Skladista
I. SkladisteID, automatski generator vrijednosti i primarni ključ
II. Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
III. Oznaka, polje za unos 10 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
IV. Lokacija, polje za unos 50 UNICODE karaktera (obavezan unos)
*/
CREATE TABLE Skladista
(
	SkladisteID INT CONSTRAINT PK_SkladisteID PRIMARY KEY IDENTITY(1,1),
	Naziv NVARCHAR(50) NOT NULL,
	Oznaka NVARCHAR(10) NOT NULL UNIQUE,
	Lokacija NVARCHAR(50) NOT NULL
)

/*
c) SkladisteProizvodi
I) Stanje, polje za unos decimalnih brojeva (obavezan unos)
Napomena: Na jednom skladištu može biti uskladišteno više proizvoda, dok isti proizvod može biti
uskladišten na više različitih skladišta. Onemogućiti da se isti proizvod na skladištu može pojaviti više
puta
*/
CREATE TABLE SkladisteProizvodi
(
	SkladisteID INT CONSTRAINT FK_SkladisteID_Proizvod FOREIGN KEY REFERENCES Skladista(SkladisteID),
	ProizvodID INT CONSTRAINT FK_ProizvodID_Skladiste FOREIGN KEY REFERENCES Proizvodi(ProizvodID),
	Stanje DECIMAL NOT NULL,
	CONSTRAINT PK_Skl_Pro PRIMARY KEY(SkladisteID,ProizvodID)
)

/*
2. Popunjavanje tabela podacima
a) Putem INSERT komande u tabelu Skladista dodati minimalno 3 skladišta.
b) Koristeći bazu podataka AdventureWorks2014, preko INSERT i SELECT komande importovati
10 najprodavanijih bicikala (kategorija proizvoda 'Bikes' i to sljedeće kolone:
I. Broj proizvoda (ProductNumber) - > Sifra,
II. Naziv bicikla (Name) -> Naziv,
III. Cijena po komadu (ListPrice) -> Cijena,
c) Putem INSERT i SELECT komandi u tabelu SkladisteProizvodi za sva dodana skladista
importovati sve proizvode tako da stanje bude 100
*/
--a)
INSERT INTO Skladista(Naziv,Oznaka,Lokacija)
VALUES ('Skladiste 1', 'SAK-100-1','Grad 1'),
		('Skladiste 2','SAK-100-2','Grad 2'),
		('Skladiste 3','SAK-100-3','Grad 3')
--b)
INSERT INTO Proizvodi(Sifra,Naziv,Cijena)
SELECT X.ProductNumber,X.Name,X.ListPrice
FROM (SELECT TOP 10  P.ProductNumber,P.Name,P.ListPrice  
	FROM AdventureWorks2017.Production.Product AS P INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS PSC 
	ON PSC.ProductSubcategoryID = P.ProductSubcategoryID INNER JOIN AdventureWorks2017.Production.ProductCategory AS PC
	ON PC.ProductCategoryID = PSC.ProductCategoryID INNER JOIN AdventureWorks2017.Sales.SalesOrderDetail AS SOD
	ON SOD.ProductID = P.ProductID
	WHERE PC.Name = 'Bikes'
	GROUP BY P.ProductNumber,P.Name,P.ListPrice
	ORDER BY SUM(SOD.OrderQty) DESC
	) AS X


--c)
INSERT INTO SkladisteProizvodi(ProizvodID,SkladisteID,Stanje)
SELECT  ProizvodID,1,100 FROM Proizvodi

INSERT INTO SkladisteProizvodi(ProizvodID,SkladisteID,Stanje)
SELECT  ProizvodID,2,100 FROM Proizvodi

INSERT INTO SkladisteProizvodi(ProizvodID,SkladisteID,Stanje)
SELECT  ProizvodID,3,100 FROM Proizvodi

/*3.
Kreirati uskladištenu proceduru koja će vršiti povečanje stanja skladišta za određeni proizvod na
odabranom skladištu. Provjeriti ispravnost procedure.
*/
CREATE PROCEDURE uvecaj_stanje
(
	@ProizvodID INT,
	@Skladiste INT,
	@Povecanje INT
)
AS
BEGIN
UPDATE SkladisteProizvodi
SET Stanje += @Povecanje
WHERE ProizvodID = @ProizvodID AND SkladisteID = @Skladiste
END
GO


/*4.
 Kreiranje indeksa u bazi podataka nad tabelama
a) Non-clustered indeks nad tabelom Proizvodi. Potrebno je indeksirati Sifru i Naziv. Također,
potrebno je uključiti kolonu Cijena
b) Napisati proizvoljni upit nad tabelom Proizvodi koji u potpunosti iskorištava indeks iz
prethodnog koraka
c) Uradite disable indeksa iz koraka a)
*/
--a)
CREATE NONCLUSTERED INDEX IX_Sifra_Naziv_Proizvodi
ON Proizvodi(Sifra,Naziv)
INCLUDE (Cijena)

--b)
SELECT Naziv, Sifra, Cijena
FROM Proizvodi
WHERE Naziv LIKE '%2' AND Sifra LIKE '%2' AND Cijena > 1000

--c)
ALTER INDEX IX_Sifra_Naziv_Proizvodi ON Proizvodi
DISABLE

/*
5. Kreirati view sa sljedećom definicijom. Objekat treba da prikazuje sifru, naziv i cijenu proizvoda,
oznaku, naziv i lokaciju skladišta, te stanje na skladištu.
*/
CREATE VIEW Pregled_1
AS
SELECT P.Sifra, P.Naziv, P.Cijena, S.Oznaka, S.Naziv AS "Naziv skladista" , S.Lokacija, SP.Stanje
FROM Proizvodi AS P INNER JOIN SkladisteProizvodi AS SP 
ON SP.ProizvodID = P.ProizvodID INNER JOIN Skladista AS S
ON S.SkladisteID = SP.SkladisteID

SELECT* FROM Pregled_1

/*6.
 Kreirati uskladištenu proceduru koja će na osnovu unesene šifre proizvoda prikazati ukupno stanje
zaliha na svim skladištima. U rezultatu prikazati sifru, naziv i cijenu proizvoda te ukupno stanje zaliha.
U proceduri koristiti prethodno kreirani view. Provjeriti ispravnost kreirane procedure.
*/
ALTER PROCEDURE stanje_na_skladistima
(
	@Sifra NVARCHAR(50)
)
AS
BEGIN 
SELECT Sifra, Naziv, Cijena, SUM(Stanje)
FROM Pregled_1
WHERE Sifra = @Sifra
GROUP BY Sifra, Naziv, Cijena
END

/*7.
. Kreirati uskladištenu proceduru koja će vršiti upis novih proizvoda, te kao stanje zaliha za uneseni
proizvod postaviti na 0 za sva skladišta. Provjeriti ispravnost kreirane procedure.
*/
ALTER PROCEDURE upis_proizvoda 
(
	@Sifra NVARCHAR(50),
	@Naziv NVARCHAR(50),
	@Cijena INT
)
AS
BEGIN
INSERT INTO Proizvodi(Sifra,Naziv,Cijena)
VALUES (@Sifra,@Naziv,@Cijena);

INSERT INTO SkladisteProizvodi(ProizvodID,SkladisteID,Stanje)
SELECT (SELECT DISTINCT ProizvodID FROM Proizvodi WHERE Sifra = @Sifra),SkladisteID,0
FROM Skladista 
END

/*8.
 Kreirati uskladištenu proceduru koja će za unesenu šifru proizvoda vršiti brisanje proizvoda
uključuju�i stanje na svim skladištima. Provjeriti ispravnost procedure.
*/
CREATE PROCEDURE brisanje_proizvoda
(
	@Sifra NVARCHAR(50)
)
AS 
BEGIN
DELETE FROM SkladisteProizvodi
WHERE ProizvodID = (SELECT ProizvodID FROM Proizvodi WHERE Sifra = @Sifra);

DELETE FROM Proizvodi
WHERE Sifra = @Sifra
END

EXEC brisanje_proizvoda 'TEST'

/*9.
 Kreirati uskladištenu proceduru koja će za unesenu šifru proizvoda, oznaku skladišta ili lokaciju
skladišta vršiti pretragu prethodno kreiranim view-om (zadatak 5). Procedura obavezno treba da
vraća rezultate bez obrzira da li su vrijednosti parametara postavljene. Testirati ispravnost procedure
u sljedećim situacijama:
a) Nije postavljena vrijednost niti jednom parametru (vraća sve zapise)
b) Postavljena je vrijednost parametra šifra proizvoda, a ostala dva parametra nisu
c) Postavljene su vrijednosti parametra šifra proizvoda i oznaka skladišta, a lokacija
nije
d) Postavljene su vrijednosti parametara šifre proizvoda i lokacije, a oznaka skladišta
nije
e) Postavljene su vrijednosti sva tri parametra
*/

CREATE PROCEDURE procc
(
	@sifra NVARCHAR(50)=NULL,
	@oznaka NVARCHAR(50)=NULL,
	@lokacija NVARCHAR(50)=NULL
)
AS
BEGIN
SELECT*
FROM Pregled_1
WHERE (Sifra=@sifra OR @sifra IS NULL) AND (Oznaka=@oznaka OR @oznaka IS NULL) AND (Lokacija = @lokacija OR @lokacija IS NULL)
END

EXEC procc NULL,NULL,'Grad 2'

--CREATE PROCEDURE glavna_proc
--(
--	@Sifra NVARCHAR(50) = NULL,
--	@Lokacija NVARCHAR(50) = NULL,
--	@Oznaka NVARCHAR(50) = NULL
--)
--AS
--BEGIN
--SELECT Sifra,Naziv,Oznaka
--FROM Pregled_1
--WHERE (Sifra = @Sifra OR @Sifra IS NULL) AND (Oznaka = @Oznaka OR @Oznaka IS NULL)  AND(Lokacija = @Lokacija OR @Lokacija IS NULL)
--END

EXEC glavna_proc

/*10. Napraviti full i diferencijalni backup baze podataka na default lokaciju servera:*/
