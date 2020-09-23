Skip to content
Why GitHub? 
Team
  /*Napomena:
1. Prilikom  bodovanja rješenja prioritet ima razultat koji treba upit da vrati (broj zapisa, vrijednosti agregatnih funkcija...).
U slučaju da rezultat upita nije tačan, a pogled, tabela... koji su rezultat tog upita se koriste u narednim zadacima, 
tada se rješenja narednih zadataka, bez obzira na tačnost koda, ne boduju punim brojem bodova, jer ni ta rješenja ne mogu vratiti 
tačan rezultat (broj zapisa, vrijednosti agregatnih funkcija...).
2. Tokom pisanja koda obratiti posebnu pažnju na tekst zadatka i ono što se traži zadatkom. 
Prilikom pregleda rada pokreće se kod koji se nalazi u sql skripti i sve ono što nije urađeno prema zahtjevima zadatka ili 
je pogrešno urađeno predstavlja grešku. Shodno navedenom na uvidu se ne prihvata prigovor da je neki dio koda posljedica previda 
("nisam vidio", "slučajno sam to napisao"...) 
*/

/*
1.
a) Kreirati bazu pod vlastitim brojem indeksa.
*/
CREATE DATABASE Integralni_5_9_2019
USE Integralni_5_9_2019
GO

/* 
b) Kreiranje tabela.
Prilikom kreiranja tabela voditi računa o odnosima između tabela.
I. Kreirati tabelu produkt sljedeće strukture:
	- produktID, cjelobrojna varijabla, primarni ključ
	- jed_cijena, novčana varijabla
	- kateg_naziv, 15 unicode karaktera
	- mj_jedinica, 20 unicode karaktera
	- dobavljac_naziv, 40 unicode karaktera
	- dobavljac_post_br, 10 unicode karaktera
*/
CREATE TABLE Produkt
(
	produktID INT CONSTRAINT PK_ProduktID PRIMARY KEY,
	jed_cijena MONEY,
	kateg_naziv NVARCHAR(15),
	mj_jedinica NVARCHAR(20),
	dobavljac_naziv NVARCHAR(40),
	dobavljac_post_br NVARCHAR(10)
)


/*
II. Kreirati tabelu narudzba sljedeće strukture:
	- narudzbaID, cjelobrojna varijabla, primarni ključ
	- dtm_narudzbe, datumska varijabla za unos samo datuma
	- dtm_isporuke, datumska varijabla za unos samo datuma
	- grad_isporuke, 15 unicode karaktera
	- klijentID, 5 unicode karaktera
	- klijent_naziv, 40 unicode karaktera
	- prevoznik_naziv, 40 unicode karaktera
*/
CREATE TABLE Narudzba
(
	narudzbaID INT CONSTRAINT PK_NarudzbaID PRIMARY KEY,
	dtm_narudzbe DATE,
	dtm_isporuke DATE,
	grad_isporuke NVARCHAR(15),
	klijentID NVARCHAR(5),
	klijent_naziv NVARCHAR(40),
	prevoznik_naziv NVARCHAR(40)
)

/*
III. Kreirati tabelu narudzba_produkt sljedeće strukture:
	- narudzbaID, cjelobrojna varijabla, obavezan unos
	- produktID, cjelobrojna varijabla, obavezan unos
	- uk_cijena, novčana varijabla
*/
CREATE TABLE narudzba_produkt
(
	narudzbaID INT CONSTRAINT FK_NarudzbaID_Produkt FOREIGN KEY REFERENCES Narudzba(narudzbaID) NOT NULL,
	produktID INT CONSTRAINT FK_ProduktID_Narudzba FOREIGN KEY REFERENCES Produkt(produktID) NOT NULL,
	uk_cijena MONEY,
	CONSTRAINT PK_Narudzba_Produkt PRIMARY KEY(narudzbaID, produktID)
)

--10 bodova



----------------------------------------------------------------------------------------------------------------------------
/*
2. Import podataka
a) Iz tabela Categories, Product i Suppliers baze Northwind u tabelu produkt importovati podatke prema pravilu:
	- ProductID -> produktID
	- QuantityPerUnit -> mj_jedinica
	- UnitPrice -> jed_cijena
	- CategoryName -> kateg_naziv
	- CompanyName -> dobavljac_naziv
	- PostalCode -> dobavljac_post_br
*/
INSERT INTO Produkt(produktID,mj_jedinica,jed_cijena,kateg_naziv,dobavljac_naziv,dobavljac_post_br)
SELECT P.ProductID, P.QuantityPerUnit, P.UnitPrice, C.CategoryName, S.CompanyName, S.PostalCode
FROM NORTHWND.dbo.Products AS P INNER JOIN NORTHWND.dbo.Categories AS C
ON P.CategoryID = C.CategoryID INNER JOIN NORTHWND.dbo.Suppliers AS S
ON S.SupplierID = P.SupplierID


/*
a) Iz tabela Customers, Orders i Shipers baze Northwind u tabelu narudzba importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- OrderDate -> dtm_narudzbe
	- ShippedDate -> dtm_isporuke
	- ShipCity -> grad_isporuke
	- CustomerID -> klijentID
	- CompanyName -> klijent_naziv
	- CompanyName -> prevoznik_naziv
*/
INSERT INTO Narudzba(narudzbaID,dtm_narudzbe,dtm_isporuke,grad_isporuke,klijentID,klijent_naziv,prevoznik_naziv)
SELECT O.OrderID, O.OrderDate, O.ShippedDate,O.ShipCity, C.CustomerID, C.CompanyName, S.CompanyName
FROM NORTHWND.dbo.Orders AS O INNER JOIN NORTHWND.dbo.Customers AS C
ON O.CustomerID = C.CustomerID INNER JOIN NORTHWND.dbo.Shippers AS S
ON S.ShipperID = O.ShipVia

/*
c) Iz tabele Order Details baze Northwind u tabelu narudzba_produkt importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- ProductID -> produktID
	- uk_cijena <- produkt jedinične cijene i količine
uz uslov da je odobren popust 5% na produkt.
*/
INSERT INTO narudzba_produkt(narudzbaID,produktID,uk_cijena)
SELECT OrderID,ProductID,UnitPrice*Quantity
FROM NORTHWND.dbo.[Order Details] 
WHERE Discount = 0.05
--10 bodova

----------------------------------------------------------------------------------------------------------------------------
/*
3. 
a) Koristeći tabele narudzba i narudzba_produkt kreirati pogled view_uk_cijena koji će imati strukturu:
	- narudzbaID
	- klijentID
	- uk_cijena_cijeli_dio
	- uk_cijena_feninzi - prikazati kao cijeli broj  
Obavezno pregledati sadržaj pogleda.
b) Koristeći pogled view_uk_cijena kreirati tabelu nova_uk_cijena uz uslov da se preuzmu samo oni zapisi u kojima su feninzi veći od 49. 
U tabeli trebaju biti sve kolone iz pogleda, te nakon njih kolona uk_cijena_nova u kojoj će ukupna cijena biti zaokružena na veću vrijednost. 
Npr. uk_cijena = 10, feninzi = 90 -> uk_cijena_nova = 11
*/
CREATE VIEW view_uk_cijena
AS
SELECT N.narudzbaID, N.klijent_naziv, FLOOR(NP.uk_cijena) AS CijeliDio,SUBSTRING(CONVERT(NVARCHAR,NP.uk_cijena),CHARINDEX('.',NP.uk_cijena)+1,20) AS Feninzi
FROM Narudzba AS N INNER JOIN narudzba_produkt AS NP
ON N.narudzbaID = NP.narudzbaID

SELECT* FROM view_uk_cijena

SELECT narudzbaID, klijent_naziv,CijeliDio, Feninzi, CijeliDio+1 AS [uk_cijena_nova] INTO nova_uk_cijena 
FROM view_uk_cijena
WHERE Feninzi > 49

SELECT* FROM nova_uk_cijena



----------------------------------------------------------------------------------------------------------------------------
/*
4. 
Koristeći tabelu uk_cijena_nova kreiranu u 3. zadatku kreirati proceduru tako da je prilikom izvršavanja moguće unijeti bilo
koji broj parametara 
(možemo ostaviti bilo koji parametar bez unijete vrijednosti). Proceduru pokrenuti za sljedeće vrijednosti varijabli:
1. narudzbaID - 10730
2. klijentID  - ERNSH
*/

CREATE PROCEDURE Procedura_3
(
	@narudzbaID INT = NULL,
	@klijent_naziv NVARCHAR(50) = NULL,
	@CijeliDio MONEY = NULL,
	@Feninzi INT = NULL,
	@uk_cijena_nova MONEY = NULL
)
AS
BEGIN
SELECT* 
FROM nova_uk_cijena
WHERE narudzbaID = @narudzbaID OR klijent_naziv = @klijent_naziv OR CijeliDio = @CijeliDio OR Feninzi = @Feninzi OR 
	  uk_cijena_nova = @uk_cijena_nova
END

EXEC Procedura_3 10730
--10 bodova



----------------------------------------------------------------------------------------------------------------------------
/*
5.
Koristeći tabelu produkt kreirati proceduru proc_post_br koja će prebrojati zapise u kojima poštanski broj dobavljača počinje cifrom. 
Potrebno je dati prikaz poštanskog broja i ukupnog broja zapisa po poštanskom broju. Nakon kreiranja pokrenuti proceduru.
*/

--5 bodova

CREATE PROCEDURE proc_post_br
AS
BEGIN
SELECT dobavljac_post_br, COUNT(dobavljac_post_br) AS Izbrojano
FROM Produkt
WHERE dobavljac_post_br LIKE '[0-9]%'
GROUP BY dobavljac_post_br
END
-------------------------------------------------------------------
/*
6.
a) Iz tabele narudzba kreirati pogled view_prebrojano sljedeće strukture:
	- klijent_naziv
	- prebrojano - ukupan broj narudžbi po nazivu klijent
Obavezno napisati naredbu za pregled sadržaja pogleda.
b) Napisati naredbu kojom će se prikazati maksimalna vrijednost kolone prebrojano.
c) Iz pogleda kreiranog pod a) dati pregled zapisa u kojem će osim kolona iz pogleda prikazati razlika maksimalne vrijednosti i kolone prebrojano 
uz uslov da se ne prikazuje zapis u kojem se nalazi maksimlana vrijednost.
*/

--a)
CREATE VIEW view_prebrojano
AS
SELECT klijent_naziv, COUNT(narudzbaID) AS [broj narudzbi po klijentu]
FROM Narudzba
GROUP BY klijent_naziv

SELECT* FROM view_prebrojano

--b)
SELECT MAX([broj narudzbi po klijentu])
FROM view_prebrojano

--c)
SELECT klijent_naziv, [broj narudzbi po klijentu], (SELECT MAX([broj narudzbi po klijentu]) FROM view_prebrojano)-[broj narudzbi po klijentu] AS Razlika
FROM view_prebrojano
WHERE [broj narudzbi po klijentu] < 31

--12 bodova


-------------------------------------------------------------------
/*
7.
a) U tabeli produkt dodati kolonu lozinka, 20 unicode karaktera 
b) Kreirati proceduru kojom će se izvršiti punjenje kolone lozinka na sljedeći način:
	- ako je u dobavljac_post_br podatak sačinjen samo od cifara, lozinka se kreira obrtanjem niza znakova koji se dobiju spajanjem zadnja četiri 
	znaka kolone mj_jedinica i kolone dobavljac_post_br
	- ako podatak u dobavljac_post_br podatak sadrži jedno ili više slova na bilo kojem mjestu, 
	lozinka se kreira obrtanjem slučajno generisanog niza znakova
Nakon kreiranja pokrenuti proceduru.
Obavezno provjeriti sadržaj tabele narudžba.
*/
--a)
ALTER TABLE Produkt
ADD lozinka NVARCHAR(20)

--b)
CREATE PROCEDURE dodaj_lozinku
AS
BEGIN
UPDATE Produkt
SET lozinka = REVERSE(RIGHT(mj_jedinica,4)+ RIGHT(dobavljac_post_br,4))
WHERE dobavljac_post_br NOT LIKE '[A-Z]%' AND dobavljac_post_br NOT LIKE '%[A-Z]%' AND dobavljac_post_br NOT LIKE '%[A-Z]'

UPDATE Produkt
SET lozinka = LEFT(REVERSE(NEWID()),20)
WHERE dobavljac_post_br LIKE '[A-Z]%' OR dobavljac_post_br LIKE '%[A-Z]%' OR dobavljac_post_br LIKE '%[A-Z]'
END

SELECT* FROM Produkt
EXEC dodaj_lozinku


--10 bodova


-------------------------------------------------------------------
/*
8. 
a) Kreirati pogled kojim sljedeće strukture:
	- produktID,
	- dobavljac_naziv,
	- grad_isporuke
	- period_do_isporuke koji predstavlja vremenski period od datuma narudžbe do datuma isporuke
Uslov je da se dohvate samo oni zapisi u kojima je narudzba realizirana u okviru 4 sedmice.
Obavezno pregledati sadržaj pogleda.
b) Koristeći pogled view_isporuka kreirati tabelu isporuka u koju će biti smještene sve kolone iz pogleda. 
*/
--a)
CREATE VIEW View_8
AS
SELECT P.produktID, P.dobavljac_naziv, N.grad_isporuke,DATEDIFF(WEEK,N.dtm_narudzbe,N.dtm_isporuke) AS preiod_do_isporuke
FROM Produkt AS P INNER JOIN narudzba_produkt AS NP
ON NP.produktID = P.produktID INNER JOIN Narudzba AS N
ON NP.narudzbaID = N.narudzbaID
WHERE DATEDIFF(WEEK,N.dtm_narudzbe,N.dtm_isporuke) <=4

SELECT* FROM View_8

--b)
SELECT* INTO Isporuka
FROM View_8

SELECT* FROM Isporuka
-------------------------------------------------------------------
/*
9.
a) U tabeli isporuka dodati kolonu red_br_sedmice, 10 unicode karaktera.
b) U tabeli isporuka izvršiti update kolone red_br_sedmice ( prva, druga, treca, cetvrta) u zavisnosti
od vrijednosti u koloni period_do_isporuke. 
Pokrenuti proceduru
c) Kreirati pregled kojim će se prebrojati broj zapisa po rednom broju sedmice. 
Pregled treba da sadrži redni broj sedmice i ukupan broj zapisa po rednom broju.
*/
--a)
ALTER TABLE Isporuka
ADD red_br_sedmice NVARCHAR(10)


--b)
CREATE PROCEDURE isporuka_update
AS
BEGIN

UPDATE Isporuka
SET red_br_sedmice = 'prva'
WHERE preiod_do_isporuke = 1

UPDATE Isporuka
SET red_br_sedmice = 'druga'
WHERE preiod_do_isporuke = 2

UPDATE Isporuka
SET red_br_sedmice = 'treca'
WHERE preiod_do_isporuke = 3

UPDATE Isporuka
SET red_br_sedmice = 'cetvrta'
WHERE preiod_do_isporuke = 4

END

EXEC isporuka_update
SELECT* FROM Isporuka

--c)
CREATE VIEW isporuka_view
AS
SELECT red_br_sedmice,COUNT(red_br_sedmice) AS Ukupno
FROM Isporuka
GROUP BY red_br_sedmice

SELECT* FROM isporuka_view

--15 bodova

-------------------------------------------------------------------
/*
10.
a) Kreirati backup baze na default lokaciju.
b) Kreirati proceduru kojom će se u jednom izvršavanju obrisati svi pogledi i procedure u bazi. Pokrenuti proceduru.
*/

--5 BODOVA

