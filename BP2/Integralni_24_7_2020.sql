/*
Napomena:

A.
Prilikom  bodovanja rješenja prioritet ima rezultat koji upit treba da vrati (broj zapisa, vrijednosti agregatnih funkcija...).
U slučaju da rezultat upita nije tačan, a pogled, tabela... koji su rezultat tog upita se koriste u narednim zadacima, 
tada se rješenja narednih zadataka, bez obzira na tačnost koda, ne boduju punim brojem bodova, 
jer ni ta rješenja ne mogu vratiti tačan rezultat (broj zapisa, vrijednosti agregatnih funkcija...).

B.
Tokom pisanja koda obratiti posebnu pažnju na tekst zadatka i ono što se traži zadatkom. 
Prilikom pregleda rada pokreće se kod koji se nalazi u sql skripti i 
sve ono što nije urađeno prema zahtjevima zadatka ili je pogrešno urađeno predstavlja grešku. 
*/


------------------------------------------------
--1
/*
a) Kreirati bazu podataka pod vlastitim brojem indeksa.
*/

CREATE DATABASE Integralni_24_7_2020
USE Integralni_24_7_2020

--Prilikom kreiranja tabela voditi računa o međusobnom odnosu između tabela.
/*
b) Kreirati tabelu radnik koja će imati sljedeću strukturu:
	- radnikID, cjelobrojna varijabla, primarni ključ
	- drzavaID, 15 unicode karaktera
	- loginID, 256 unicode karaktera
	- god_rod, cjelobrojna varijabla
	- spol, 1 unicode karakter
*/
CREATE TABLE Radnik
(
	radnikID INT CONSTRAINT PK_RadnikID PRIMARY KEY,
	drzavaID NVARCHAR(15),
	loginID NVARCHAR(256),
	god_rod INT,
	spol NVARCHAR(1)
)

/*
c) Kreirati tabelu nabavka koja će imati sljedeću strukturu:
	- nabavkaID, cjelobrojna varijabla, primarni ključ
	- status, cjelobrojna varijabla
	- radnikID, cjelobrojna varijabla
	- br_racuna, 15 unicode karaktera
	- naziv_dobavljaca, 50 unicode karaktera
	- kred_rejting, cjelobrojna varijabla
*/
CREATE TABLE Nabavka
(
	nabavkaID INT CONSTRAINT PK_NabavkaID PRIMARY KEY,
	status INT,
	radnikID INT CONSTRAINT FK_RadnikID FOREIGN KEY REFERENCES Radnik(radnikID),
	br_racuna NVARCHAR(15),
	naziv_dobavljaca NVARCHAR(50),
	kred_rejting INT
)

/*
c) Kreirati tabelu prodaja koja će imati sljedeću strukturu:
	- prodajaID, cjelobrojna varijabla, primarni ključ, inkrementalno punjenje sa početnom vrijednošću 1, samo neparni brojevi
	- prodavacID, cjelobrojna varijabla
	- dtm_isporuke, datumsko-vremenska varijabla
	- vrij_poreza, novčana varijabla
	- ukup_vrij, novčana varijabla
	- online_narudzba, bit varijabla sa ograničenjem kojim se mogu unijeti samo cifre 0 ili 1
*/
CREATE TABLE Prodaja
(
	prodajaID INT CONSTRAINT PK_ProdajaID PRIMARY KEY IDENTITY(1,2),
	prodavacID INT CONSTRAINT FK_ProdavacID FOREIGN KEY REFERENCES Radnik(radnikID),
	dtm_isporuke DATETIME,
	vrij_poreza MONEY,
	ukup_crij MONEY,
	online_narudzba BIT CONSTRAINT CH_onl_nar CHECK(online_narudzba = 1 OR online_narudzba = 0)
)
--10 bodova



--------------------------------------------
--2. Import podataka
/*
a) Iz tabele Employee iz šeme HumanResources baze AdventureWorks2017 u tabelu radnik importovati podatke po sljedećem pravilu:
	- BusinessEntityID -> radnikID
	- NationalIDNumber -> drzavaID
	- LoginID -> loginID
	- godina iz kolone BirthDate -> god_rod
	- Gender -> spol
*/
-------------------------------------------------
INSERT INTO Radnik
SELECT BusinessEntityID, NationalIDNumber, LoginID, YEAR(BirthDate), Gender
FROM AdventureWorks2017.HumanResources.Employee 

/*
b) Iz tabela PurchaseOrderHeader i Vendor šeme Purchasing baze AdventureWorks2017 u tabelu nabavka importovati podatke po sljedećem pravilu:
	- PurchaseOrderID -> dobavljanjeID
	- Status -> status
	- EmployeeID -> radnikID
	- AccountNumber -> br_racuna
	- Name -> naziv_dobavljaca
	- CreditRating -> kred_rejting
*/
SELECT* FROM Radnik

INSERT INTO Nabavka(nabavkaID,status,radnikID,br_racuna,naziv_dobavljaca,kred_rejting)
SELECT POH.PurchaseOrderID,POH.Status,POH.EmployeeID,V.AccountNumber,V.Name,V.CreditRating
FROM AdventureWorks2017.Purchasing.PurchaseOrderHeader AS POH INNER JOIN AdventureWorks2017.Purchasing.Vendor AS V
ON POH.VendorID = V.BusinessEntityID

/*
c) Iz tabele SalesOrderHeader šeme Sales baze AdventureWorks2017
u tabelu prodaja importovati podatke po sljedećem pravilu:
	- SalesPersonID -> prodavacID
	- ShipDate -> dtm_isporuke
	- TaxAmt -> vrij_poreza
	- TotalDue -> ukup_vrij
	- OnlineOrderFlag -> online_narudzba
*/
--10 bodova
INSERT INTO Prodaja(prodavacID,dtm_isporuke,vrij_poreza,ukup_crij,online_narudzba)
SELECT	SalesPersonID,ShipDate,TaxAmt,TotalDue,OnlineOrderFlag
FROM AdventureWorks2017.Sales.SalesOrderHeader


------------------------------------------
--3.
/*
a) U tabeli radnik dodati kolonu st_kat (starosna kategorija), tipa 3 karaktera.
*/
ALTER TABLE Radnik
ADD st_kat NVARCHAR(3)

/*
b) Prethodno kreiranu kolonu popuniti po principu:
	starosna kategorija		uslov
	I						osobe do 30 godina starosti (uključuje se i 30)
	II						osobe od 31 do 49 godina starosti
	III						osobe preko 50 godina starosti
*/
UPDATE Radnik
SET st_kat = 'III'
WHERE YEAR(GETDATE())-god_rod >= 50

SELECT * FROM Radnik

/*
c) Neka osoba sa navršenih 65 godina starosti odlazi u penziju.
Prebrojati koliko radnika ima 10 ili manje godina do penzije.
Rezultat upita isključivo treba biti poruka 
'Broj radnika koji imaju 10 ili manje godina do penzije je ' nakon čega slijedi prebrojani broj.
Neće se priznati rješenje koje kao rezultat upita vraća više kolona.
*/
SELECT 'Broj radnika koji imaju 10 ili manje godina do penzije je ' + CONVERT(NVARCHAR,COUNT(*))
FROM Radnik
WHERE 65 - (YEAR(GETDATE())-god_rod) <= 10


--15 bodova

------------------------------------------
--4.
/*
a) U tabeli prodaja kreirati kolonu stopa_poreza (10 unicode karaktera)
*/
ALTER TABLE Prodaja
ADD stopa_poreza NVARCHAR(10)

/*
b) Prethodno kreiranu kolonu popuniti kao količnik vrij_poreza i ukup_vrij,
Stopu poreza izraziti kao cijeli broj sa oznakom %, pri čemu je potrebno 
da između brojčane vrijednosti i znaka % bude prazno mjesto. (npr. 14.00 %)
*/
UPDATE Prodaja
SET stopa_poreza = CONVERT(NVARCHAR,FLOOR((vrij_poreza/ukup_crij) * 100))+' %'

--10 bodova



-----------------------------------------
--5.
/*
a)
Koristeći tabelu nabavka kreirati pogled view_slova sljedeće strukture:
	- slova
	- prebrojano, prebrojani broj pojavljivanja slovnih dijelova podatka u koloni br_racuna. 
*/
CREATE VIEW view_slova
AS
SELECT LEFT(br_racuna, CHARINDEX('0',br_racuna,1)-1) AS Slova, COUNT(LEFT(br_racuna, CHARINDEX('0',br_racuna,1)-1)) AS Prebrojano
FROM Nabavka
GROUP BY LEFT(br_racuna, CHARINDEX('0',br_racuna,1)-1)

SELECT* FROM view_slova

/*b)
Koristeći pogled view_slova odrediti razliku vrijednosti između prebrojanih i srednje vrijednosti kolone.
Rezultat treba da sadrži kolone slova, prebrojano i razliku.
Sortirati u rastućem redolsijedu prema razlici.
*/
SELECT Slova, Prebrojano, Prebrojano-(SELECT AVG(Prebrojano) FROM view_slova) AS Razlika
FROM view_slova
ORDER BY Razlika ASC
--10 bodova

-----------------------------------------
--6.
/*
a) Koristeći tabelu prodaja kreirati pogled view_stopa sljedeće strukture:
	- prodajaID
	- stopa_poreza
	- stopa_num, u kojoj će bit numerička vrijednost stope poreza */
CREATE VIEW view_stopa
AS
SELECT prodajaID, stopa_poreza, CONVERT(FLOAT,LEFT(stopa_poreza,CHARINDEX(' ',stopa_poreza,1)-1)) AS stopa_num
FROM Prodaja

SELECT* FROM view_stopa
/*b)
Koristeći pogled view_stopa, a na osnovu razlike između vrijednosti u koloni stopa_num i 
srednje vrijednosti stopa poreza za svaki proizvodID navesti poruku 'manji', odnosno, 'veći'. 
*/
ALTER TABLE Prodaja
ADD Poruka NVARCHAR(20)

SELECT prodajaID, 'veci' as Poruka
FROM view_stopa
WHERE stopa_num - (SELECT AVG(stopa_num) FROM view_stopa) > 0
UNION
SELECT prodajaID, 'manji' as Poruka
FROM view_stopa
WHERE stopa_num - (SELECT AVG(stopa_num) FROM view_stopa) < 0


--12 bodova

------------------------------------------
--7.
/*
Koristeći pogled view_stopa_poreza kreirati proceduru proc_stopa_poreza
tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara 
(možemo ostaviti bilo koji parametar bez unijete vrijednosti),
pri čemu će se prebrojati broja zapisa po stopi poreza uz uslova 
da se dohvate samo oni zapisi u kojima je stopa poreza veća od 10 %.
Proceduru pokrenuti za sljedeće vrijednosti:
	- stopa poreza = 12, 15 i 21 
*/
--10 bodova
CREATE PROCEDURE proc_stopa_poreza
(
	@prodajaID INT = NULL,
	@stopa_poreza NVARCHAR(10) = NULL,
	@stopa_num FLOAT = NULL
)
AS
BEGIN
SELECT stopa_poreza, COUNT(stopa_poreza)
FROM view_stopa
GROUP BY stopa_poreza
WHERE (stopa_num > 10) AND (prodajaID=@prodajaID OR stopa_poreza = @stopa_poreza OR stopa_num=@stopa_num)
END

EXEC proc_stopa_poreza @stopa_poreza = '12.00 %'
EXEC proc_stopa_poreza @stopa_poreza = '15.00 %'
EXEC proc_stopa_poreza @stopa_poreza = '21.00 %'


---------------------------------------------------------------------------------------------------
--8.
/*
Kreirati proceduru proc_prodaja kojom će se izvršiti 
promjena vrijednosti u koloni online_narudzba tabele prodaja. 
Promjena će se vršiti tako što će se 0 zamijeniti sa NO, a 1 sa YES. 
Pokrenuti proceduru kako bi se izvršile promjene, a nakon toga onemogućiti 
da se u koloni unosi bilo kakva druga vrijednost osim NO ili YES.
*/
--13 bodova

CREATE PROCEDURE proc_prodaja
AS
BEGIN
ALTER TABLE Prodaja
DROP CONSTRAINT CH_onl_nar

ALTER TABLE Prodaja
ALTER COLUMN online_narudzba NVARCHAR(10)

UPDATE Prodaja
SET online_narudzba = 'YES'
WHERE online_narudzba = '1'

UPDATE Prodaja
SET online_narudzba = 'NO'
WHERE online_narudzba = '0'

END

EXEC proc_prodaja

------------------------------------------
--9.
/*
a) 
Nad kolonom god_rod tabele radnik kreirati ograničenje kojim će
se onemogućiti unos bilo koje godine iz budućnosti kao godina rođenja.
Testirati funkcionalnost kreiranog ograničenja navođenjem 
koda za insert podataka kojim će se kao godina rođenja
pokušati unijeti bilo koja godina iz budućnosti.
*/
SELECT*
FROM Radnik
INSERT INTO Radnik(radnikID, drzavaID ,loginID,god_rod,spol,st_kat)
VALUES(231312,321312,'dasdasda',2222,'M','III')

ALTER TABLE Radnik
ADD CONSTRAINT god_rod CHECK(god_rod < YEAR(GETDATE()))


/*
b) Nad kolonom drzavaID tabele radnik kreirati ograničenje kojim će se ograničiti dužina podatka na 7 znakova. 
Ako je prethodno potrebno, izvršiti prilagodbu kolone, pri čemu nije dozvoljeno prilagođavati podatke čiji 
dužina iznosi 7 ili manje znakova.
Testirati funkcionalnost kreiranog ograničenja navođenjem koda za insert podataka 
kojim će se u drzavaID pokušati unijeti podataka duži od 7 znakova bilo koja godina iz budućnosti.
*/
--10 bodova
SELECT* FROM Radnik

UPDATE Radnik
SET drzavaID = LEFT(drzavaID,7)
WHERE LEN(drzavaID) > 7

ALTER TABLE Radnik
ADD CONSTRAINT CH_drzavaID CHECK(LEN(drzavaID)<=7)


-----------------------------------------------
--10.
/*
Kreirati backup baze na default lokaciju, obrisati bazu, a zatim izvršiti restore baze. 
Uslov prihvatanja koda je da se može izvršiti.
*/
--2 boda

