----------------------------------------------------------------1.
/*
Koristeći isključivo SQL kod, kreirati bazu pod vlastitim brojem indeksa sa defaultnim postavkama.
*/

CREATE DATABASE Integralni_24_6_2019
USE Integralni_24_6_2019
GO

/*
Unutar svoje baze podataka kreirati tabele sa sljedećom struktorom:
--NARUDZBA
a) Narudzba
NarudzbaID, primarni ključ
Kupac, 40 UNICODE karaktera
PunaAdresa, 80 UNICODE karaktera
DatumNarudzbe, datumska varijabla, definirati kao datum
Prevoz, novčana varijabla
Uposlenik, 40 UNICODE karaktera
GradUposlenika, 30 UNICODE karaktera
DatumZaposlenja, datumska varijabla, definirati kao datum
BrGodStaza, cjelobrojna varijabla
*/
CREATE TABLE Narudzba
(
	NarudzbaID INT CONSTRAINT PK_NarudzbaID PRIMARY KEY,
	Kupac NVARCHAR(40),
	PunaAdresa NVARCHAR(80),
	DatumNarudzbe DATE,
	Prevoz MONEY,
	Uposlenik NVARCHAR(40),
	GradUposlenika NVARCHAR(30),
	DatumZaposlenja DATE,
	BrGodStaza INT
)



--PROIZVOD
/*
b) Proizvod
ProizvodID, cjelobrojna varijabla, primarni ključ
NazivProizvoda, 40 UNICODE karaktera
NazivDobavljaca, 40 UNICODE karaktera
StanjeNaSklad, cjelobrojna varijabla
NarucenaKol, cjelobrojna varijabla
*/
CREATE TABLE Proizvod
(
	ProizvodID INT CONSTRAINT PK_ProizvodID PRIMARY KEY,
	NazivProizvoda NVARCHAR(40),
	NazivDobavljaca NVARCHAR(40),
	StanjeNaSklad INT,
	NarucenaKol INT
)

--DETALJINARUDZBE
/*
c) DetaljiNarudzbe
NarudzbaID, cjelobrojna varijabla, obavezan unos
ProizvodID, cjelobrojna varijabla, obavezan unos
CijenaProizvoda, novčana varijabla
Kolicina, cjelobrojna varijabla, obavezan unos
Popust, varijabla za realne vrijednosti
Napomena: Na jednoj narudžbi se nalazi jedan ili više proizvoda.
*/
CREATE TABLE DetaljiNarudzbe
(
	NarudzbaID INT CONSTRAINT FK_NarudzbaIDDetalji FOREIGN KEY REFERENCES Narudzba(NarudzbaID) NOT NULL,
	ProizvodID INT CONSTRAINT FK_ProizvodIDDetalji FOREIGN KEY REFERENCES Proizvod(ProizvodID) NOT NULL,
	CijenaProizvoda MONEY,
	Kolicina INT NOT NULL,
	Popust REAL,
	CONSTRAINT FK_DetaljiNarudzbe PRIMARY KEY(NarudzbaID, ProizvodID)
)


----------------------------------------------------------------2.
--2a) narudzbe
/*
Koristeći bazu Northwind iz tabela Orders, Customers i Employees importovati podatke po sljedećem pravilu:
OrderID -> ProizvodID
ComapnyName -> Kupac
PunaAdresa - spojeno adresa, poštanski broj i grad, pri čemu će se između riječi staviti srednja crta sa razmakom prije i poslije nje
OrderDate -> DatumNarudzbe
Freight -> Prevoz
Uposlenik - spojeno prezime i ime sa razmakom između njih
City -> Grad iz kojeg je uposlenik
HireDate -> DatumZaposlenja
BrGodStaza - broj godina od datum zaposlenja
*/
INSERT INTO Narudzba
SELECT O.OrderID, C.CompanyName, C.Address+' - ' +C.PostalCode+' - ' +C.City, O.OrderDate, O.Freight, E.FirstName+' '+E.LastName, E.City, 
	   E.HireDate, DATEDIFF(YEAR,E.HireDate,GETDATE())
FROM NORTHWND.dbo.Orders AS O INNER JOIN NORTHWND.dbo.Customers AS C 
ON C.CustomerID = O.CustomerID INNER JOIN NORTHWND.dbo.Employees AS E
ON O.EmployeeID = E.EmployeeID


--proizvod
/*
Koristeći bazu Northwind iz tabela Products i Suppliers putem podupita importovati podatke po sljedećem pravilu:
ProductID -> ProizvodID
ProductName -> NazivProizvoda 
CompanyName -> NazivDobavljaca 
UnitsInStock -> StanjeNaSklad 
UnitsOnOrder -> NarucenaKol 
*/
INSERT INTO Proizvod
SELECT P.ProductID, P.ProductName,S.CompanyName,P.UnitsInStock, P.UnitsOnOrder
FROM NORTHWND.dbo.Products AS P INNER JOIN NORTHWND.dbo.Suppliers AS S
ON P.SupplierID = S.SupplierID

--RJ: 78

--detaljinarudzbe
/*
Koristeći bazu Northwind iz tabele Order Details importovati podatke po sljedećem pravilu:
OrderID -> NarudzbaID
ProductID -> ProizvodID
CijenaProizvoda - manja zaokružena vrijednost kolone UnitPrice, npr. UnitPrice = 3,60 CijenaProizvoda = 3,00
*/
INSERT INTO DetaljiNarudzbe
SELECT OD.OrderID, OD.ProductID, FLOOR(OD.UnitPrice), OD.Quantity, OD.Discount
FROM NORTHWND.dbo.[Order Details] AS OD


----------------------------------------------------------------3.
--3a
/*
U tabelu Narudzba dodati kolonu SifraUposlenika kao 20 UNICODE karaktera. Postaviti uslov da podatak mora biti dužine tačno 15 karaktera.
*/
ALTER TABLE Narudzba
ADD SifraUposlenika NVARCHAR(20) CONSTRAINT CK_Sifra CHECK(Len(SifraUposlenika) = 15)


--3b
/*
Kolonu SifraUposlenika popuniti na način da se obrne string koji se dobije spajanjem grada uposlenika i prvih 10 karaktera datuma zaposlenja pri 
čemu se između grada i 10 karaktera nalazi jedno prazno mjesto. Provjeriti da li je izvršena izmjena.
*/
UPDATE Narudzba
SET SifraUposlenika = LEFT(REVERSE(GradUposlenika+' '+RIGHT(DatumZaposlenja,10)),15) 
WHERE SifraUposlenika IS NULL

SELECT *
FROM Narudzba

--3c
/*
U tabeli Narudzba u koloni SifraUposlenika izvršiti zamjenu svih zapisa kojima grad uposlenika završava slovom "d" tako da se umjesto toga ubaci 
slučajno generisani string dužine 20 karaktera. Provjeriti da li je izvršena zamjena.
*/
UPDATE Narudzba
SET SifraUposlenika = LEFT(NEWID(),15)
WHERE GradUposlenika LIKE '%d'



----------------------------------------------------------------4.
/*
Koristeći svoju bazu iz tabela Narudzba i DetaljiNarudzbe kreirati pogled koji će imati sljedeću strukturu: Uposlenik, SifraUposlenika, 
ukupan broj proizvoda izveden iz NazivProizvoda, uz uslove da je dužina sifre uposlenika 20 karaktera, te da je ukupan broj proizvoda veći od 2. 
Provjeriti sadržaj pogleda, pri čemu se treba izvršiti sortiranje po ukupnom broju proizvoda u opadajućem redoslijedu.*/
CREATE VIEW Pogled_1
AS 
SELECT N.Uposlenik, N.SifraUposlenika, COUNT(P.NazivProizvoda) AS [Ukupan broj proizvoda]
FROM Narudzba AS N INNER JOIN DetaljiNarudzbe AS DN
ON N.NarudzbaID = DN.NarudzbaID INNER JOIN Proizvod AS P
ON P.ProizvodID = DN.ProizvodID
--WHERE LEN(N.SifraUposlenika) = 20
GROUP BY N.Uposlenik, N.SifraUposlenika
HAVING COUNT(P.NazivProizvoda) > 2

SELECT* 
FROM Pogled_1
ORDER BY [Ukupan broj proizvoda] DESC

----------------------------------------------------------------5. 
/*
Koristeći vlastitu bazu kreirati proceduru nad tabelom Narudzbe kojom će se dužina podatka u koloni SifraUposlenika 
smanjiti sa 20 na 4 slučajno generisana karaktera. Pokrenuti proceduru. */
CREATE PROCEDURE Procedura_1
AS
BEGIN
UPDATE Narudzba
SET SifraUposlenika = LEFT(NEWID(),4)
WHERE LEN(SifraUposlenika) = 15
END

ALTER TABLE Narudzba
DROP CONSTRAINT CK_Sifra

EXEC Procedura_1
----------------------------------------------------------------6.
/*
Koristeći vlastitu bazu podataka kreirati pogled koji će imati sljedeću strukturu: NazivProizvoda, 
Ukupno - ukupnu sumu prodaje proizvoda uz uzimanje u obzir i popusta. 
Suma mora biti zakružena na dvije decimale. U pogled uvrstiti one proizvode koji su naručeni, uz uslov da je suma veća od 10000. 
Provjeriti sadržaj pogleda pri čemu ispis treba sortirati u opadajućem redoslijedu po vrijednosti sume.
*/
CREATE VIEW Pogled_2
AS
SELECT P.NazivProizvoda, ROUND(SUM((DN.CijenaProizvoda-(DN.CijenaProizvoda*DN.Popust)) * DN.Kolicina ),2) AS [Ukupna suma prodaje]
FROM Proizvod AS P INNER JOIN DetaljiNarudzbe AS DN
ON DN.ProizvodID = P.ProizvodID
GROUP BY P.NazivProizvoda, DN.Popust
HAVING SUM((DN.CijenaProizvoda-(DN.CijenaProizvoda*DN.Popust)) * DN.Kolicina ) > 10000

SELECT* FROM Pogled_2
ORDER BY 2 DESC

----------------------------------------------------------------7.
--7a
/*
Koristeći vlastitu bazu podataka kreirati pogled koji će imati sljedeću strukturu: Kupac, NazivProizvoda, 
suma po cijeni proizvoda pri čemu će se u pogled smjestiti samo oni zapisi kod kojih je cijena proizvoda veća od srednje vrijednosti 
cijene proizvoda. Provjeriti sadržaj pogleda pri čemu izlaz treba sortirati u rastućem redoslijedu izračunatoj sumi.
*/
CREATE VIEW Pogled_3
AS
SELECT N.Kupac, P.NazivProizvoda, SUM(DN.CijenaProizvoda) AS "Suma proizvoda" 
FROM Narudzba AS N INNER JOIN DetaljiNarudzbe AS DN 
ON DN.NarudzbaID = N.NarudzbaID INNER JOIN Proizvod AS P
ON P.ProizvodID = DN.ProizvodID
WHERE DN.CijenaProizvoda > (SELECT AVG(DetaljiNarudzbe.CijenaProizvoda) FROM DetaljiNarudzbe)
GROUP BY N.Kupac, P.NazivProizvoda

SELECT* FROM Pogled_3

/*
Koristeći vlastitu bazu podataka kreirati proceduru kojom će se, koristeći prethodno kreirani pogled, definirati parametri: kupac,
NazivProizvoda i SumaPoCijeni. Proceduru kreirati tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara
(možemo ostaviti bilo koji parametar bez unijete vrijednosti), uz uslov da vrijednost sume bude veća od srednje vrijednosti suma koje
su smještene u pogled. Sortirati po sumi cijene. Procedura se treba izvršiti ako se unese vrijednost za bilo koji parametar.
Nakon kreiranja pokrenuti proceduru za sljedeće vrijednosti parametara:
1. SumaPoCijeni = 123
2. Kupac = Hanari Carnes
3. NazivProizvoda = Côte de Blaye
*/

CREATE PROCEDURE Procedura_2
(
	@Kupac NVARCHAR(50) = NULL,
	@NazivProizvoda NVARCHAR(50) = NULL,
	@Suma INT = NULL
)
AS
BEGIN
SELECT *
FROM Pogled_3
WHERE [Suma proizvoda] > (SELECT AVG([Suma proizvoda]) FROM Pogled_3) AND (@Suma = [Suma proizvoda] OR @NazivProizvoda = NazivProizvoda OR @Kupac = Kupac)
ORDER BY [Suma proizvoda]
END

----------------------------------------------------------------8.
/*
a) Kreirati indeks nad tabelom Proizvod. Potrebno je indeksirati NazivDobavljaca. Uključiti i kolone StanjeNaSklad i NarucenaKol. 
Napisati proizvoljni upit nad tabelom Proizvod koji u potpunosti koristi prednosti kreiranog indeksa.*/
CREATE NONCLUSTERED INDEX IX_NazivDobavljaca_Proizvod
ON Proizvod(NazivDobavljaca)
INCLUDE (StanjeNaSklad, NarucenaKol)

SELECT*
FROM Proizvod
WHERE NazivDobavljaca = 'Gai pâturage' AND StanjeNaSklad > 10 AND NarucenaKol < 10

/*b) Uraditi disable indeksa iz prethodnog koraka.*/
ALTER INDEX IX_NazivDobavljaca_Proizvod
ON Proizvod
DISABLE

--enable svih indexa
ALTER INDEX ALL
ON Proizvodi
REBUILD

----------------------------------------------------------------9.
/*Napraviti backup baze podataka na default lokaciju servera.*/



----------------------------------------------------------------10.
/*Kreirati proceduru kojom će se u jednom pokretanju izvršiti brisanje svih pogleda i procedura koji su kreirani u Vašoj bazi.*/
CREATE PROCEDURE Brisanje_Proc_View
AS
BEGIN
DROP PROCEDURE dbo.Procedura_1, dbo.Procedura_2;
DROP VIEW dbo.Pogled_1, dbo.Pogled_2,dbo.Pogled_3;
END

EXECUTE Brisanje_Proc_View
