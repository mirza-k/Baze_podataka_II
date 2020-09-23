----------------------------
--1.
----------------------------
/*
Kreirati bazu pod vlastitim brojem indeksa
*/
CREATE DATABASE Integralni_23_6_2020
USE Integralni_23_6_2020


-----------------------------------------------------------------------
--Prilikom kreiranja tabela voditi računa o njihovom međusobnom odnosu.
-----------------------------------------------------------------------
/*
a) 
Kreirati tabelu dobavljac sljedeće strukture:
	- dobavljac_id - cjelobrojna vrijednost, primarni ključ
	- dobavljac_br_rac - 50 unicode karaktera
	- naziv_dobavljaca - 50 unicode karaktera
	- kred_rejting - cjelobrojna vrijednost
*/
CREATE TABLE Dobavljac
(
	dobavljac_id INT CONSTRAINT PK_Dobavljac PRIMARY KEY,
	dobavljac_br_rac NVARCHAR(50),
	naziv_dobavljaca NVARCHAR(50),
	kred_rejting INT
)

/*
b)
Kreirati tabelu narudzba sljedeće strukture:
	- narudzba_id - cjelobrojna vrijednost, primarni ključ
	- narudzba_detalj_id - cjelobrojna vrijednost, primarni ključ
	- dobavljac_id - cjelobrojna vrijednost
	- dtm_narudzbe - datumska vrijednost
	- naruc_kolicina - cjelobrojna vrijednost
	- cijena_proizvoda - novčana vrijednost
*/
CREATE TABLE Narudzba
(
	narudzba_id INT ,
	narudzba_detalji_id INT,
	dobavljac_id INT CONSTRAINT FK_Dobavljac FOREIGN KEY REFERENCES Dobavljac(dobavljac_id),
	dtm_narudzbe DATE,
	naruc_kolicina INT,
	cijena_proizvoda MONEY,
	CONSTRAINT PK_Narudzba_NarDetalji PRIMARY KEY(narudzba_id, narudzba_detalji_id)
)

/*
c)
Kreirati tabelu dobavljac_proizvod sljedeće strukture:
	- proizvod_id cjelobrojna vrijednost, primarni ključ
	- dobavljac_id cjelobrojna vrijednost, primarni ključ
	- proiz_naziv 50 unicode karaktera
	- serij_oznaka_proiz 50 unicode karaktera
	- razlika_min_max cjelobrojna vrijednost
	- razlika_max_narudzba cjelobrojna vrijednost
*/
--10 bodova
CREATE TABLE Dobavljac_Proizvod
(
	proizvod_id INT ,
	dobavljac_id INT CONSTRAINT FK_DobavljacPro FOREIGN KEY REFERENCES Dobavljac(dobavljac_id),
	proiz_naziv NVARCHAR(50),
	serij_oznaka_proiz NVARCHAR(50),
	razlika_min_max INT,
	razlika_max_narudzba INT
)



----------------------------
--2. Insert podataka
----------------------------
/*
a) 
U tabelu dobavljac izvršiti insert podataka iz tabele Purchasing.Vendor prema sljedećoj strukturi:
	BusinessEntityID -> dobavljac_id 
	AccountNumber -> dobavljac_br_rac 
	Name -> naziv_dobavljaca
	CreditRating -> kred_rejting
*/
INSERT INTO Dobavljac(dobavljac_id,dobavljac_br_rac, naziv_dobavljaca, kred_rejting)
SELECT BusinessEntityID, AccountNumber, Name, CreditRating
FROM AdventureWorks2017.Purchasing.Vendor

/*
b) 
U tabelu narudzba izvršiti insert podataka iz tabela Purchasing.PurchaseOrderHeader i Purchasing.PurchaseOrderDetail prema 
sljedećoj strukturi:
	PurchaseOrderID -> narudzba_id
	PurchaseOrderDetailID -> narudzba_detalj_id
	VendorID -> dobavljac_id 
	OrderDate -> dtm_narudzbe 
	OrderQty -> naruc_kolicina 
	UnitPrice -> cijena_proizvoda
*/
INSERT INTO Narudzba(narudzba_id, narudzba_detalji_id, dobavljac_id, dtm_narudzbe, naruc_kolicina, cijena_proizvoda)
SELECT POH.PurchaseOrderID, POD.PurchaseOrderDetailID, POH.VendorID, POH.OrderDate, POD.OrderQty, POD.UnitPrice
FROM AdventureWorks2017.Purchasing.PurchaseOrderHeader AS POH INNER JOIN AdventureWorks2017.Purchasing.PurchaseOrderDetail AS POD
ON POH.PurchaseOrderID = POD.PurchaseOrderID

/*
c) 
U tabelu dobavljac_proizvod izvršiti insert podataka iz tabela Purchasing.ProductVendor i Production.Product prema sljedećoj strukturi:
	ProductID -> proizvod_id 
	BusinessEntityID -> dobavljac_id 
	Name -> proiz_naziv 
	ProductNumber -> serij_oznaka_proiz
	MaxOrderQty - MinOrderQty -> razlika_min_max 
	MaxOrderQty - OnOrderQty -> razlika_max_narudzba
uz uslov da se povuku samo oni zapisi u kojima ProductSubcategoryID nije NULL vrijednost.
*/
INSERT INTO Dobavljac_Proizvod(proizvod_id, dobavljac_id, proiz_naziv, serij_oznaka_proiz, razlika_min_max, razlika_max_narudzba)
SELECT P.ProductID, PV.BusinessEntityID, P.Name, P.ProductNumber, PV.MaxOrderQty-PV.MinOrderQty, PV.MaxOrderQty - PV.OnOrderQty
FROM AdventureWorks2017.Purchasing.ProductVendor AS PV INNER JOIN AdventureWorks2017.Production.Product AS P
ON PV.ProductID = P.ProductID
WHERE P.ProductSubcategoryID IS NOT NULL


--10 bodova

----------------------------
--3.
----------------------------
/*
Koristeći sve tri tabele iz vlastite baze kreirati pogled view_dob_god sljedeće strukture:
	- dobavljac_id
	- proizvod_id
	- naruc_kolicina
	- cijena_proizvoda
	- ukupno, kao proizvod naručene količine i cijene proizvoda
Uslov je da se dohvate samo oni zapisi u kojima je narudžba obavljena 2013. ili 2014. godine i da se broj računa dobavljača završava cifrom 1.
*/
CREATE VIEW view_dob_god
AS
SELECT D.dobavljac_id, DP.proizvod_id, N.naruc_kolicina, N.cijena_proizvoda, N.naruc_kolicina*N.cijena_proizvoda AS Ukupno
FROM Dobavljac AS D INNER JOIN Dobavljac_Proizvod AS DP
ON DP.dobavljac_id = D.dobavljac_id INNER JOIN Narudzba AS N
ON N.dobavljac_id = D.dobavljac_id
WHERE (YEAR(N.dtm_narudzbe) = 2013 OR YEAR(N.dtm_narudzbe) = 2014) AND D.dobavljac_br_rac LIKE '%1'

--10 bodova

----------------------------
--4.
----------------------------
/*
Koristeći pogled view_dob_god kreirati proceduru proc_dob_god koja će sadržavati parametar naruc_kolicina i imati sljedeću strukturu:
	- dobavljac_id
	- proizvod_id
	- suma_ukupno, sumirana vrijednost kolone ukupno po dobavljac_id i proizvod_id
Uslov je da se dohvataju samo oni zapisi u kojima je naručena količina trocifreni broj.
Nakon kreiranja pokrenuti proceduru za vrijednost naručene količine 300.
*/
CREATE PROCEDURE proc_dob_god
(
	@naruc_kolicina INT
)
AS 
BEGIN
SELECT dobavljac_id, proizvod_id, SUM(Ukupno)
FROM view_dob_god
WHERE naruc_kolicina = @naruc_kolicina
GROUP BY dobavljac_id, proizvod_id
END

EXEC proc_dob_god @naruc_kolicina = 300
--10 bodova


----------------------------
--5.
----------------------------
/*
a)
Tabelu dobavljac_proizvod kopirati u tabelu dobavljac_proizvod_nova.
b) 
Iz tabele dobavljac_proizvod_nova izbrisati kolonu razlika_min_max.
c)
U tabeli dobavljac_proizvod_nova kreirati novu kolonu razlika. Kolonu popuniti razlikom vrijednosti kolone razlika_max_narudzba i srednje vrijednosti ove kolone, uz uslov da ako se u zapisu nalazi NULL vrijednost u kolonu razlika smjestiti 0.
*/
--15 bodova
--a)
SELECT*
INTO dobavljac_proizvod_nova
FROM Dobavljac_Proizvod

--b)
ALTER TABLE dobavljac_proizvod_nova
DROP COLUMN razlika_min_max

--c)
ALTER TABLE dobavljac_proizvod_nova
ADD Razlika INT

UPDATE dobavljac_proizvod_nova
SET Razlika = ISNULL(razlika_max_narudzba - (SELECT AVG(razlika_max_narudzba) FROM dobavljac_proizvod_nova),0)

SELECT* FROM dobavljac_proizvod_nova

----------------------------
--6.
----------------------------
/*
Prebrojati koliko u tabeli dobavljac_proizvod ima različitih serijskih oznaka proizvoda koje završavaju bilo kojim slovom engleskog alfabeta, 
a koliko ima onih koji ne završavaju bilo kojim slovom engleskog alfabeta. Upit treba da vrati poruke:
	'Različitih serijskih oznaka proizvoda koje završavaju slovom engleskog alfabeta ima:' iza čega slijedi broj zapisa 
	i
	'Različitih serijskih oznaka proizvoda koje NE završavaju slovom engleskog alfabeta ima:' iza čega slijedi broj zapisa
*/
SELECT 'Razlicitih serijskih oznaka proizvoda koje zavrsavaju slovom engleskog alfabeta ima ' +  CONVERT(NVARCHAR,COUNT(serij_oznaka_proiz))
FROM Dobavljac_Proizvod
WHERE serij_oznaka_proiz LIKE '%[A-Z]'

SELECT 'Razlicitih serijskih oznaka proizvoda koje NE zavrsavaju slovom engleskog alfabeta ima ' +  CONVERT(NVARCHAR,COUNT(serij_oznaka_proiz))
FROM Dobavljac_Proizvod
WHERE serij_oznaka_proiz NOT LIKE '%[A-Z]'
--10 bodova


----------------------------
--7.
----------------------------
/*
a)
Dati informaciju o dužinama podatka u koloni serij_oznaka_proiz tabele dobavljac_proizvod. 
b)
Dati informaciju o broju različitih dužina podataka u koloni serij_oznaka_proiz tabele dobavljac_proizvod. 
Poruka treba biti u obliku: 'Kolona serij_oznaka_proiz ima ___ različite dužinr podataka.' Na mjestu donje crte se nalazi izračunati brojčani podatak.
*/
--a)
SELECT serij_oznaka_proiz, LEN(serij_oznaka_proiz) AS Duzina
FROM Dobavljac_Proizvod

--b)
CREATE VIEW Pomocni
AS
SELECT* 
FROM(SELECT LEN(serij_oznaka_proiz) AS Duzina, COUNT(LEN(serij_oznaka_proiz)) AS Broj 
     FROM Dobavljac_Proizvod  
	 GROUP BY LEN(serij_oznaka_proiz)) AS T

SELECT* FROM Pomocni

SELECT 'Kolona serij_oznaka_proiz ima ' + CONVERT(NVARCHAR,COUNT(*))+ ' razlicite duzine podataka.'
FROM Pomocni


--10 bodova


----------------------------
--8.
----------------------------
/*
Prebrojati kod kolikog broja dobavljača je broj računa kreiran korištenjem više od jedne riječi iz naziva dobavljača. 
Jednom riječi se podrazumijeva skup slova koji nije prekinut blank (space) znakom. 
*/
--10 bodova

SELECT COUNT(*) AS Prebrojano
FROM Dobavljac
WHERE LEN(LEFT(dobavljac_br_rac,CHARINDEX('0',dobavljac_br_rac,1)-1)) > LEN(SUBSTRING(naziv_dobavljaca,1,CHARINDEX(' ',naziv_dobavljaca,1)))
	  AND LEN(SUBSTRING(naziv_dobavljaca,1,CHARINDEX(' ',naziv_dobavljaca,1)))>0
----------------------------
--9.
----------------------------
/*
Koristeći pogled view_dob_god kreirati proceduru proc_djeljivi koja će sadržavati parametar prebrojano i kojom će se prebrojati broj
pojavljivanja vrijednosti u koloni naruc_kolicina koje su djeljive sa 100. Sortirati po koloni prebrojano. Nakon kreiranja pokrenuti 
proceduru za sljedeću vrijednost parametra prebrojano = 10
*/
--13 bodova
CREATE PROCEDURE proc_djeljivi
(
	@prebrojano INT
)
AS
BEGIN
SELECT naruc_kolicina, COUNT(*) AS Prebrojano
FROM view_dob_god
WHERE naruc_kolicina % 100 = 0 
GROUP BY naruc_kolicina
HAVING COUNT(*) = @prebrojano
END

EXEC proc_djeljivi @prebrojano = 10

----------------------------
--10.
----------------------------
/*
a) Kreirati backup baze na default lokaciju.
b) Napisati kod kojim će biti moguće obrisati bazu.
c) Izvršiti restore baze.
Uslov prihvatanja kodova je da se mogu pokrenuti.
*/
BACKUP DATABASE Integralni_23_6_2020
TO DISK = 'Integralni_23_6_2020.bak'	
GO

USE master
DROP DATABASE Integralni_23_6_2020

RESTORE DATABASE Integralni_23_6_2020 
FROM DISK = 'Integralni_23_6_2020.bak'

--2 boda
