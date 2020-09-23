/*
Napomena:
1. Prilikom bodovanja rješenja prioritet ima razultat koji treba upit da vrati (broj zapisa, vrijednosti agregatnih funkcija...).
U slučaju da rezultat upita nije tačan, a pogled, tabela... koji su rezultat tog upita se koriste u narednim zadacima, 
tada se rješenja narednih zadataka, bez obzira na tačnost koda, ne boduju punim brojem bodova, jer ni ta rješenja ne mogu vratiti tačan rezultat 
(broj zapisa, vrijednosti agregatnih funkcija...).
2. Tokom pisanja koda obratiti posebnu pažnju na tekst zadatka i ono što se traži zadatkom. 
Prilikom pregleda rada pokreće se kod koji se nalazi u sql skripti i sve ono što nije urađeno prema zahtjevima zadatka ili je pogrešno urađeno predstavlja grešku. 
Shodno navedenom na uvidu se ne prihvata prigovor da je neki dio koda posljedica previda ("nisam vidio", "slučajno sam to napisao"...) 
*/


/*
1.
a) Kreirati bazu pod vlastitim brojem indeksa.
*/
CREATE DATABASE Integralni_5_9_2019_A
USE Integralni_5_9_2019_A
GO
/* 
b) Kreiranje tabela.
Prilikom kreiranja tabela voditi računa o odnosima između tabela.
I. Kreirati tabelu narudzba sljedeće strukture:
	narudzbaID, cjelobrojna varijabla, primarni ključ
	dtm_narudzbe, datumska varijabla za unos samo datuma
	dtm_isporuke, datumska varijabla za unos samo datuma
	prevoz, novčana varijabla
	klijentID, 5 unicode karaktera
	klijent_naziv, 40 unicode karaktera
	prevoznik_naziv, 40 unicode karaktera
*/
CREATE TABLE Narudzba
(
	narudzbaID INT CONSTRAINT PK_NarudzbaID PRIMARY KEY,
	dtm_narudzbe DATE,
	dtm_isporuke DATE,
	prevoz MONEY,
	klijentID NVARCHAR(5),
	klijent_naziv NVARCHAR(40),
	prevoznik_naziv NVARCHAR(40)
)


/*
II. Kreirati tabelu proizvod sljedeće strukture:
	- proizvodID, cjelobrojna varijabla, primarni ključ
	- mj_jedinica, 20 unicode karaktera
	- jed_cijena, novčana varijabla
	- kateg_naziv, 15 unicode karaktera
	- dobavljac_naziv, 40 unicode karaktera
	- dobavljac_web, tekstualna varijabla
*/
CREATE TABLE Proizvod
(
	proizvodID INT CONSTRAINT PK_ProizvodID PRIMARY KEY,
	mj_jedinica NVARCHAR(20),
	jed_cijena MONEY,
	kateg_naziv NVARCHAR(15),
	dobavljac_naziv NVARCHAR(40),
	dobavljac_web TEXT
)

/*
III. Kreirati tabelu narudzba_proizvod sljedeće strukture:
	- narudzbaID, cjelobrojna varijabla, obavezan unos
	- proizvodID, cjelobrojna varijabla, obavezan unos
	- uk_cijena, novčana varijabla
*/
CREATE TABLE Narudzba_Proizvod
(
	narudzbaID INT CONSTRAINT FK_NarudzbaIDProizvod FOREIGN KEY REFERENCES Narudzba(narudzbaID) NOT NULL,
	proizvodID INT CONSTRAINT FK_ProizvodIDNarudzba FOREIGN KEY REFERENCES Proizvod(proizvodID) NOT NULL,
	uk_cijena MONEY,
	CONSTRAINT PK_narudzbaIDproizvodID PRIMARY KEY (narudzbaID, proizvodID)
)

-------------------------------------------------------------------
/*
2. Import podataka
a) Iz tabela Customers, Orders i Shipers baze Northwind importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- OrderDate -> dtm_narudzbe
	- ShippedDate -> dtm_isporuke
	- Freight -> prevoz
	- CustomerID -> klijentID
	- CompanyName -> klijent_naziv
	- CompanyName -> prevoznik_naziv
*/
INSERT INTO Narudzba
SELECT O.OrderID, O.OrderDate, O.ShippedDate, O.Freight, C.CustomerID, C.CompanyName, S.CompanyName
FROM NORTHWND.dbo.Orders AS O INNER JOIN NORTHWND.dbo.Customers AS C
ON C.CustomerID = O.CustomerID INNER JOIN NORTHWND.dbo.Shippers AS S
ON O.ShipVia = S.ShipperID


/*
b) Iz tabela Categories, Product i Suppliers baze Northwind importovati podatke prema pravilu:
	- ProductID -> proizvodID
	- QuantityPerUnit -> mj_jedinica
	- UnitPrice -> jed_cijena
	- CategoryName -> kateg_naziv
	- CompanyName -> dobavljac_naziv
	- HomePage -> dobavljac_web
*/
INSERT INTO Proizvod
SELECT P.ProductID, P.QuantityPerUnit,P.UnitPrice, C.CategoryName, S.CompanyName, S.HomePage
FROM NORTHWND.dbo.Products AS P INNER JOIN NORTHWND.dbo.Categories AS C
ON C.CategoryID = P.CategoryID INNER JOIN NORTHWND.dbo.Suppliers AS S
ON P.SupplierID = S.SupplierID


/*
c) Iz tabele Order Details baze Northwind importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- ProductID -> proizvodID
	- uk_cijena <- proizvod jedinične cijene i količine
uz uslov da nije odobren popust na proizvod.
*/
INSERT INTO Narudzba_Proizvod(narudzbaID,proizvodID,uk_cijena)
SELECT OD.OrderID, OD.ProductID, OD.Quantity*OD.UnitPrice
FROM NORTHWND.dbo.[Order Details] AS OD
WHERE OD.Discount = 0

--10 bodova


-------------------------------------------------------------------
/*
3. 
Koristeći tabele proizvod i narudzba_proizvod kreirati pogled view_kolicina koji će imati strukturu:
	- proizvodID
	- kateg_naziv
	- jed_cijena
	- uk_cijena
	- kolicina - količnik ukupne i jedinične cijene
U pogledu trebaju biti samo oni zapisi kod kojih količina ima smisao (nije moguće da je na stanju 1,23 proizvoda).
Obavezno pregledati sadržaj pogleda.
*/
CREATE VIEW View_1
AS
SELECT P.proizvodID, P.kateg_naziv, P.jed_cijena, NP.uk_cijena, NP.uk_cijena/P.jed_cijena AS Kolicina
FROM Proizvod AS P INNER JOIN Narudzba_Proizvod AS NP
ON NP.proizvodID = P.proizvodID
WHERE FLOOR(NP.uk_cijena/P.jed_cijena) = NP.uk_cijena/P.jed_cijena

SELECT* FROM View_1

--7 bodova


-------------------------------------------------------------------
/*
4. 
Koristeći pogled kreiran u 3. zadatku kreirati proceduru tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara 
(možemo ostaviti bilo koji parametar bez unijete vrijednosti). Proceduru pokrenuti za sljedeće nazive kategorija:
1. Produce
2. Beverages
*/
CREATE PROCEDURE Procedura_1
(
	@ProizvodID INT = NULL,
	@NazivKategorije NVARCHAR(40) = NULL,
	@Jed_cijena MONEY =  NULL,
	@Uk_cijena MONEY = NULL,
	@Kolicina INT = NULL
)
AS
BEGIN
SELECT*
FROM View_1
WHERE proizvodID = @ProizvodID OR kateg_naziv = @NazivKategorije OR jed_cijena = @Jed_cijena OR uk_cijena = @Uk_cijena OR Kolicina = @Kolicina
END

EXEC Procedura_1 @NazivKategorije='Produce'
EXEC Procedura_1 @NazivKategorije='Beverages'

--8 bodova

------------------------------------------------
/*
5.
Koristeći pogled kreiran u 3. zadatku kreirati proceduru proc_br_kat_naziv koja će vršiti prebrojavanja po nazivu kategorije. 
Nakon kreiranja pokrenuti proceduru.
*/
CREATE PROCEDURE proc_br_kat_naziv
AS
BEGIN
SELECT kateg_naziv, COUNT(kateg_naziv) AS Izbrojano
FROM View_1
GROUP BY kateg_naziv
END

EXEC proc_br_kat_naziv
-------------------------------------------------------------------
/*
6.
a) Iz tabele narudzba_proizvod kreirati pogled view_suma sljedeće strukture:
	- narudzbaID
	- suma - sume ukupne cijene po ID narudžbe
Obavezno napisati naredbu za pregled sadržaja pogleda.
b) Napisati naredbu kojom će se prikazati srednja vrijednost sume zaokružena na dvije decimale.
c) Iz pogleda kreiranog pod a) dati pregled zapisa čija je suma veća od prosječne sume. Osim kolona iz pogleda, 
potrebno je prikazati razliku sume i srednje vrijednosti. 
Razliku zaokružiti na dvije decimale.
*/
CREATE VIEW view_suma
AS
SELECT NP.proizvodID, SUM(NP.uk_cijena) AS [Suma ukupne cijene]
FROM Narudzba_Proizvod AS NP
GROUP BY NP.proizvodID

SELECT ROUND(AVG([Suma ukupne cijene]),2)
FROM view_suma

SELECT proizvodID, [Suma ukupne cijene], [Suma ukupne cijene]- (SELECT AVG([Suma ukupne cijene]) FROM view_suma) AS Razlika
FROM view_suma
WHERE [Suma ukupne cijene] > (SELECT AVG([Suma ukupne cijene]) FROM view_suma)
--15 bodova


-------------------------------------------------------------------
/*
7.
a) U tabeli narudzba dodati kolonu evid_br, 30 unicode karaktera 
b) Kreirati proceduru kojom će se izvršiti punjenje kolone evid_br na sljedeći način:
	- ako u datumu isporuke nije unijeta vrijednost, evid_br se dobija generisanjem slučajnog niza znakova
	- ako je u datumu isporuke unijeta vrijednost, evid_br se dobija spajanjem datum narudžbe i datuma isprouke uz umetanje donje crte između datuma
Nakon kreiranja pokrenuti proceduru.
Obavezno provjeriti sadržaj tabele narudžba.
*/
ALTER TABLE Narudzba
ADD evid_br NVARCHAR(30)

CREATE PROCEDURE Procedura_2
AS
BEGIN
UPDATE Narudzba
SET evid_br = LEFT(NEWID(),30)
WHERE dtm_isporuke IS NULL

UPDATE Narudzba
SET evid_br = CONVERT(NVARCHAR(15),dtm_isporuke)+'_'+CONVERT(NVARCHAR(15),dtm_narudzbe)
WHERE dtm_isporuke IS NOT NULL
END

DROP PROCEDURE Procedura_2

EXEC Procedura_2

SELECT* FROM Narudzba
--15 bodova


-------------------------------------------------------------------
/*
8. Kreirati proceduru kojom će se dobiti pregled sljedećih kolona:
	- narudzbaID,
	- klijent_naziv,
	- proizvodID,
	- kateg_naziv,
	- dobavljac_naziv
Uslov je da se dohvate samo oni zapisi u kojima naziv kategorije sadrži samo 1 riječ.
Pokrenuti proceduru.
*/
CREATE PROCEDURE Procedura_3
AS
BEGIN
SELECT N.narudzbaID, N.klijent_naziv,P.proizvodID, P.kateg_naziv, P.dobavljac_naziv
FROM Narudzba AS N INNER JOIN Narudzba_Proizvod AS NP
ON NP.narudzbaID = N.narudzbaID INNER JOIN Proizvod as P
ON P.proizvodID = NP.proizvodID
WHERE CHARINDEX(' ', P.kateg_naziv,1) = 0 AND CHARINDEX('/', P.kateg_naziv,1) = 0
END

EXEC Procedura_3
--10 bodova


-------------------------------------------------------------------
/*
9.
U tabeli proizvod izvršiti update kolone dobavljac_web tako da se iz kolone dobavljac_naziv uzme prva riječ, 
a zatim se formira web adresa u formi www.prva_rijec.com. 
Update izvršiti pomoću dva upita, vodeći računa o broju riječi u nazivu. 
*/
UPDATE Proizvod
SET dobavljac_web = 'www.'+ SUBSTRING( dobavljac_naziv, 1,CHARINDEX(' ',dobavljac_naziv,1))+'.com'
SELECT SUBSTRING( dobavljac_naziv, 1,CHARINDEX(' ',dobavljac_naziv,1))
FROM Proizvod

-------------------------------------------------------------------
/*
10.
a) Kreirati backup baze na default lokaciju.
b) Kreirati proceduru kojom će se u jednom izvršavanju obrisati svi pogledi i procedure u bazi. Pokrenuti proceduru.
*/
