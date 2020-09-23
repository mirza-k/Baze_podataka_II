----------------------------
--1.
----------------------------
/*
Kreirati bazu pod vlastitim brojem indeksa
*/
CREATE DATABASE Integralni_Ze
USE Integralni_Ze
GO
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
	dobavljac_id INT CONSTRAINT PK_DobavljacID PRIMARY KEY,
	dobavljac_br_rac NVARCHAR(50),
	naziv_dobavljaca NVARCHAR(50),
	kred_rejting INT
)

/*
b)
Kreirati tabelu narudzba sljedeće strukture:
	- narudzba_detalj_id - cjelobrojna vrijednost, primarni ključ
	- narudzba_id - cjelobrojna vrijednost
	- dobavljac_id - cjelobrojna vrijednost
	- dtm_narudzbe - datumska vrijednost
	- naruc_kolicina - cjelobrojna vrijednost
	- cijena_proizvoda - novčana vrijednost
*/
create table narudzba
(
	narudzba_detalj_id int constraint PK_narudzba primary key,
	narudzba_id int,
	dobavljac_id int CONSTRAINT FK_Dobavljac FOREIGN KEY REFERENCES Dobavljac(dobavljac_id),
	dtm_narudzbe datetime,
	naruc_kolicina int,
	cijena_proizvoda int
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
CREATE TABLE dobavljac_proizvod
(
	proizvod_id int,
	dobavljac_id int CONSTRAINT FK_Dobavljacc FOREIGN KEY REFERENCES Dobavljac(dobavljac_id),
	proiz_naziv nvarchar(50),
	serij_oznaka_proiz nvarchar(50),
	razlika_min_max int,
	razlika_max_narudzba int,
	constraint PK_dobavljac_proizvod primary key(proizvod_id, dobavljac_id)
)

--10 bodova


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
INSERT INTO Dobavljac(dobavljac_id,dobavljac_br_rac,naziv_dobavljaca,kred_rejting)
SELECT BusinessEntityID, AccountNumber, Name, CreditRating
FROM AdventureWorks2017.Purchasing.Vendor

/*
from Adventure
b) 
U tabelu narudzba izvršiti insert podataka iz tabela Purchasing.PurchaseOrderHeader i Purchasing.PurchaseOrderDetail prema sljedećoj strukturi:
	PurchaseOrderID -> narudzba_id
	PurchaseOrderDetailID -> narudzba_detalj_id
	VendorID -> dobavljac_id 
	OrderDate -> dtm_narudzbe 
	OrderQty -> naruc_kolicina 
	UnitPrice -> cijena_proizvoda
*/
INSERT INTO narudzba(narudzba_id,narudzba_detalj_id,dobavljac_id,dtm_narudzbe,naruc_kolicina,cijena_proizvoda)
SELECT POH.PurchaseOrderID, POD.PurchaseOrderDetailID, POH.VendorID, POH.OrderDate,POD.OrderQty,POD.UnitPrice
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
uz uslov da se dohvate samo oni zapisi u kojima se podatak u koloni rowguid tabele Production.Product završava cifrom.
*/
INSERT INTO dobavljac_proizvod(proizvod_id, dobavljac_id, proiz_naziv, serij_oznaka_proiz, razlika_min_max, razlika_max_narudzba)
SELECT  P.ProductID, PV.BusinessEntityID, P.Name, P.ProductNumber, PV.MaxOrderQty-PV.MinOrderQty, PV.MaxOrderQty-PV.OnOrderQty
FROM AdventureWorks2017.Purchasing.ProductVendor AS PV INNER JOIN AdventureWorks2017.Production.Product AS P
ON P.ProductID = PV.ProductID
WHERE P.rowguid LIKE '%[0-9]'

--10 bodova

----------------------------
--3.
----------------------------
/*
Koristeći sve tri tabele iz vlastite baze kreirati pogled view_dob_proiz sljedeće strukture:
	- dobavljac_id
	- proizvod_id
	- naruc_kolicina
	- cijena_proizvoda
	- razlika, kao razlika kolona razlika_min_max i razlika_max_narudzba 
Uslov je da se dohvate samo oni zapisi u kojima je razlika pozitivan broj ili da kreditni rejting 1.
*/
--10 bodova
CREATE VIEW view_dob_proiz
AS
SELECT D.dobavljac_id, DP.proizvod_id, N.naruc_kolicina, N.cijena_proizvoda, DP.razlika_min_max-DP.razlika_max_narudzba AS razlika 
FROM Dobavljac AS D INNER JOIN dobavljac_proizvod AS DP
ON DP.dobavljac_id = D.dobavljac_id INNER JOIN narudzba AS N
ON N.dobavljac_id = D.dobavljac_id
WHERE DP.razlika_min_max-DP.razlika_max_narudzba > 0 OR D.kred_rejting = 1

----------------------------
--4.
----------------------------
/*
Koristeći pogled view_dob_proiz kreirati proceduru proc_dob_proiz koja će sadržavati 
parametar razlika i imati sljedeću strukturu:
	- dobavljac_id
	- suma_razlika, sumirana vrijednost kolone razlika po dobavljac_id i proizvod_id
Uslov je da se dohvataju samo oni zapisi u kojima je razlika jednocifren ili dvocifren broj.
Nakon kreiranja pokrenuti proceduru za vrijednost razlike 2.
*/
--10 bodova
CREATE PROCEDURE proc_dob_proiz
(
	@Razlika INT
)
AS
BEGIN
SELECT dobavljac_id, proizvod_id, SUM(razlika) AS Suma
FROM view_dob_proiz
WHERE razlika=@Razlika AND ((razlika >=0 AND razlika <=9) OR (razlika > 9 AND razlika < 100))
GROUP BY dobavljac_id, proizvod_id
END

EXEC proc_dob_proiz @Razlika=2

----------------------------
--5.
----------------------------
/*
a)
Pogled view_dob_proiz kopirati u tabelu tabela_dob_proiz uz uslov da se ne dohvataju zapisi u kojima je razlika NULL vrijednost
--11051
*/
SELECT*
INTO tabela_dob_proiz
FROM view_dob_proiz
WHERE razlika IS NOT NULL

/*b) 
U tabeli tabela_dob_proiz kreirati izračunatu kolonu ukupno kao proizvod naručene količine i cijene proizvoda.
*/
ALTER TABLE tabela_dob_proiz
ADD Ukupno AS naruc_kolicina * cijena_proizvoda

/*c)
U tabeli tabela_dob_proiz kreirati novu kolonu razlika_ukupno. Kolonu popuniti razlikom vrijednosti kolone ukupno i srednje vrijednosti ove kolone. 
Negativne vrijednosti u koloni razlika_ukupno zamijeniti 0.
*/
--15 bodova
ALTER TABLE tabela_dob_proiz
ADD razlika_ukupno REAL

UPDATE tabela_dob_proiz
SET razlika_ukupno = 0
WHERE razlika_ukupno < 0

UPDATE tabela_dob_proiz
SET razlika_ukupno = Ukupno - (SELECT AVG(Ukupno) FROM tabela_dob_proiz)


----------------------------
--6.
----------------------------
/*
Prebrojati koliko u tabeli dobavljac_proizvod ima različitih serijskih oznaka proizvoda kojima se poslije prve srednje crte nalazi bilo koje slovo engleskog alfabeta, 
a koliko ima onih kojima se poslije prve srednje crte nalazi cifra. Upit treba da vrati dvije poruke (tekst i podaci se ne prikazuju u zasebnim kolonama):
	'Različitih serijskih oznaka proizvoda koje završavaju slovom engleskog alfabeta ima: ' iza čega slijedi podatak o ukupno prebrojanom  broju zapisa 
	i
	'Različitih serijskih oznaka proizvoda kojima se poslije prve srednje crte nalazi cifra ima:' iza čega slijedi podatak o ukupno prebrojanom  broju zapisa 
*/
--10
----------------------------
SELECT   'Različitih serijskih oznaka proizvoda koje završavaju slovom engleskog alfabeta ima: ' + CONVERT(NVARCHAR,COUNT(DISTINCT serij_oznaka_proiz))
FROM dobavljac_proizvod
WHERE serij_oznaka_proiz LIKE '%-[A-Z]%'

SELECT   'Različitih serijskih oznaka proizvoda kojima se poslije prve srednje crte nalazi cifra ima:'  + CONVERT(NVARCHAR,COUNT(DISTINCT serij_oznaka_proiz))
FROM dobavljac_proizvod
WHERE serij_oznaka_proiz LIKE '%-[0-9]%'


--7.
----------------------------
/*
a)
Koristeći tabelu dobavljac kreirati pogled view_duzina koji će sadržavati slovni dio podataka 
u koloni dobavljac_br_rac, te broj znakova slovnog dijela podatka.*/
CREATE VIEW view_duzina 
AS
SELECT SUBSTRING(dobavljac_br_rac,1,CHARINDEX('0',dobavljac_br_rac,1)-1) AS Znakovi, LEN(SUBSTRING(dobavljac_br_rac,1,CHARINDEX('0',dobavljac_br_rac,1)-1)) AS [Broj znakova]
FROM Dobavljac

/*
b)
Koristeći pogled view_duzina odrediti u koliko zapisa broj prebrojanih znakova je veći ili jednak, 
a koliko manji od srednje vrijednosti prebrojanih brojeva znakova. 
Rezultat upita trebaju biti dva reda sa odgovarajućim porukama.
*/
SELECT 'Broj zapisa koji su veci ili jednaki: ' + CONVERT(NVARCHAR,COUNT(*))
FROM view_duzina
WHERE [Broj znakova] >= (SELECT AVG([Broj znakova]) FROM view_duzina)

UNION

SELECT 'Broj zapisa koji su manji: ' + CONVERT(NVARCHAR,COUNT(*))
FROM view_duzina
WHERE [Broj znakova] < (SELECT AVG([Broj znakova]) FROM view_duzina)


--10 bodova
----------------------------
--8.
----------------------------
/*
Prebrojati kod kolikog broja dobavljača je broj računa kreiran korištenjem više od jedne riječi iz naziva dobavljača. 
Jednom riječi se podrazumijeva skup slova koji nije prekinut blank (space) znakom. 
*/


--10 bodova

----------------------------
--9.
----------------------------
/*
a) U tabeli dobavljac_proizvod id proizvoda promijeniti tako što će se sve trocifrene vrijednosti svesti na vrijednost stotina (npr. 524 => 500). 
Nakon toga izvršiti izmjenu vrijednosti u koloni proizvod_id po sljedećem pravilu:
- Prije postojeće vrijednosti dodati "pr-", 
- Nakon postojeće vrijednosti dodati srednju crtu i četverocifreni brojčani dio iz kolone serij_oznaka_proiz koji slijedi nakon prve srednje crte, 
pri čemu se u slučaju da četverocifreni dio počinje 0 ta 0 odbacuje. 
U slučaju da nakon prve srednje crte ne slijedi četverocifreni broj ne vrši se nikakvo dodavanje (ni prije, ni poslije postojeće vrijednosti)
*/
ALTER TABLE dobavljac_proizvod
ADD constraint PK_dobavljac_proizvod primary key(proizvod_id, dobavljac_id)
ALTER COLUMN proizvod_id NVARCHAR(20) NOT NULL
SELECT* FROM dobavljac_proizvod


--brojcana vrijednost
UPDATE dobavljac_proizvod
SET proizvod_id = 'pr-'+CONVERT(NVARCHAR,CONVERT(INT,LEFT(proizvod_id,1))*100)+'-'+SUBSTRING(serij_oznaka_proiz,CHARINDEX('-',serij_oznaka_proiz,1)+1,LEN(serij_oznaka_proiz)-CHARINDEX('-',serij_oznaka_proiz,1)+1)
FROM dobavljac_proizvod
WHERE LEFT(SUBSTRING(serij_oznaka_proiz,CHARINDEX('-',serij_oznaka_proiz,1)+1,LEN(serij_oznaka_proiz)-CHARINDEX('-',serij_oznaka_proiz,1)+1),1)!='0' AND
	  ISNUMERIC(SUBSTRING(serij_oznaka_proiz,CHARINDEX('-',serij_oznaka_proiz,1)+1,LEN(serij_oznaka_proiz)-CHARINDEX('-',serij_oznaka_proiz,1)+1))=1

--prva cifra nula
SELECT 'pr-'+CONVERT(NVARCHAR,CONVERT(INT,LEFT(proizvod_id,1))*100)+'-'+RIGHT(SUBSTRING(serij_oznaka_proiz,CHARINDEX('-',serij_oznaka_proiz,1)+1,LEN(serij_oznaka_proiz)-CHARINDEX('-',serij_oznaka_proiz,1)+1),3)
FROM dobavljac_proizvod
WHERE LEFT(SUBSTRING(serij_oznaka_proiz,CHARINDEX('-',serij_oznaka_proiz,1)+1,LEN(serij_oznaka_proiz)-CHARINDEX('-',serij_oznaka_proiz,1)+1),1)='0' AND
	  ISNUMERIC(SUBSTRING(serij_oznaka_proiz,CHARINDEX('-',serij_oznaka_proiz,1)+1,LEN(serij_oznaka_proiz)-CHARINDEX('-',serij_oznaka_proiz,1)+1))=1	

--poslije crte nije brojcana vrijednost
SELECT CONVERT(NVARCHAR,CONVERT(INT,LEFT(proizvod_id,1))*100)
FROM dobavljac_proizvod
WHERE ISNUMERIC(SUBSTRING(serij_oznaka_proiz,CHARINDEX('-',serij_oznaka_proiz,1)+1,LEN(serij_oznaka_proiz)-CHARINDEX('-',serij_oznaka_proiz,1)+1))=0

/*
Primjer nekoliko konačnih podatka:

proizvod_id		serij_oznaka_proit

pr-300-1200		FW-1200
pr-300-820 		GT-0820 (odstranjena 0)
700				HL-U509-R (nije izvršeno nikakvo dodavanje)
*/
--13 bodova

----------------------------
--10.
----------------------------
/*
a) Kreirati backup baze na default lokaciju.
b) Napisati kod kojim će biti moguće obrisati bazu.
c) Izvršiti restore baze.
Uslov prihvatanja kodova je da se mogu pokrenuti.
*/
--2 boda
alter authorization on database::indeks35 to sa
backup database indeks35
to disk = 'indeks35.bak'

alter database indeks35
set offline

drop database indeks35


restore database indeks35
from disk= 'indeks35.bak'
with replace
BPII_2020_6_23_NBP_postavke.sql
Displaying BPII_2020_6_23_NBP_postavke.sql.