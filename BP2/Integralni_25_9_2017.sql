/*
1.	Kroz SQL kod napraviti bazu podataka koja nosi ime vašeg broja dosijea, 
a zatim u svojoj bazi podataka kreirati tabele sa sljedećom strukturom:
*/
CREATE DATABASE Integralni_25_9_2017
USE Integralni_25_9_2017
GO

/*
a)	Klijenti
i.	Ime, polje za unos 50 karaktera (obavezan unos)
ii.	Prezime, polje za unos 50 karaktera (obavezan unos)
iii.Drzava, polje za unos 50 karaktera (obavezan unos)
iv.	Grad, polje za  unos 50 karaktera (obavezan unos)
v.	Email, polje za unos 50 karaktera (obavezan unos)
vi.	Telefon, polje za unos 50 karaktera (obavezan unos)*/
CREATE TABLE Klijenti
(
	KlijentID INT CONSTRAINT PK_KlijentID PRIMARY KEY IDENTITY(1,1),
	Ime NVARCHAR(50) NOT NULL,
	Prezime NVARCHAR(50) NOT NULL,
	Drzava NVARCHAR(50) NOT NULL,
	Grad NVARCHAR(50) NOT NULL,
	Email NVARCHAR(50) NOT NULL,
	Telefon NVARCHAR(50) NOT NULL
)


/*b)	Izleti
i.	Sifra, polje za unos 10 karaktera (obavezan unos)
ii.	Naziv, polje za unos 100 karaktera (obavezan unos)
iii.	DatumPolaska, polje za unos datuma (obavezan unos)
iv.	DatumPovratka, polje za unos datuma (obavezan unos)
v.	Cijena, polje za unos decimalnog broja (obavezan unos)
vi.	Opis, polje za unos dužeg teksta (nije obavezan unos)*/
CREATE TABLE Izleti
(
	IzletID INT CONSTRAINT PK_IzletID PRIMARY KEY IDENTITY(1,1),
	Sifra NVARCHAR(10) NOT NULL,
	Naziv NVARCHAR(100) NOT NULL,
	DatumPolaska DATE NOT NULL,
	DatumPovratka DATE NOT NULL,
	Cijena DECIMAL NOT NULL,
	Opis TEXT NULL
)

/*c)	Prijave
i.	Datum, polje za unos datuma i vremena (obavezan unos)
ii.	BrojOdraslih polje za unos cijelog broja (obavezan unos)
iii.	BrojDjece polje za unos cijelog broja (obavezan unos)
Napomena: Na izlet se može prijaviti više klijenata, dok svaki klijent može prijaviti više izleta. 
Prilikom prijave klijent je obavezan unijeti broj odraslih i broj djece koji putuju u sklopu izleta.
*/
CREATE TABLE Prijave
(
	KlijentID INT CONSTRAINT FK_KlijentID_Prijave FOREIGN KEY REFERENCES Klijenti(KlijentID) NOT NULL,
	IzletID INT CONSTRAINT FK_IzletID_Prijave FOREIGN KEY REFERENCES Izleti(IzletID) NOT NULL,
	Datum DATETIME NOT NULL,
	BrojOdraslih INT NOT NULL,
	BrojDjece INT NOT NULL,
	CONSTRAINT PK_Prijave PRIMARY KEY(KlijentID, IzletID)
)

/*
2.	Iz baze podataka AdventureWorks2014 u svoju bazu podataka prebaciti sljede�e podatke:
a)	U tabelu Klijenti prebaciti sve uposlenike koji su radili u odjelu prodaje (Sales) 
i.	FirstName -> Ime
ii.	LastName -> Prezime
iii.CountryRegion (Name) -> Drzava
iv.	Addresss (City) -> Grad
v.	EmailAddress (EmailAddress)  -> Email (Izme�u imena i prezime staviti ta�ku)
vi.	PersonPhone (PhoneNumber) -> Telefon
*/
INSERT INTO Klijenti(Ime,Prezime,Drzava,Grad,Email,Telefon)
SELECT P.FirstName, P.LastName, CR.Name, A.City,P.FirstName+'.'+P.LastName+SUBSTRING(MAIL.EmailAddress,CHARINDEX('@',MAIL.EmailAddress,1),25) , PP.PhoneNumber
FROM AdventureWorks2017.HumanResources.Employee AS E INNER JOIN AdventureWorks2017.Person.Person AS P
ON P.BusinessEntityID = E.BusinessEntityID INNER JOIN AdventureWorks2017.Person.BusinessEntity AS BE
ON BE.BusinessEntityID = P.BusinessEntityID INNER JOIN AdventureWorks2017.Person.BusinessEntityAddress AS BEA
ON BEA.BusinessEntityID = BE.BusinessEntityID INNER JOIN AdventureWorks2017.Person.Address AS A
ON A.AddressID = BEA.AddressID INNER JOIN AdventureWorks2017.Person.StateProvince AS SP 
ON SP.StateProvinceID = A.StateProvinceID INNER JOIN AdventureWorks2017.Person.CountryRegion AS CR
ON CR.CountryRegionCode = SP.CountryRegionCode INNER JOIN AdventureWorks2017.Person.EmailAddress AS MAIL 
ON MAIL.BusinessEntityID = P.BusinessEntityID INNER JOIN AdventureWorks2017.Person.PersonPhone AS PP
ON PP.BusinessEntityID = P.BusinessEntityID 

/*
b)	U tabelu Izleti dodati 3 izleta (proizvoljno)	
*/
INSERT INTO Izleti(Sifra,Naziv,DatumPolaska,DatumPovratka,Cijena,Opis)
VALUES(LEFT(NEWID(),10),'Putovanje Beograd','20200505','20200512',250,'///'),
      (LEFT(NEWID(),10),'Putovanje Bec','20200607','20200612',300,'///'),
      (LEFT(NEWID(),10),'Putovanje Istanbul','20201005','20201012',320,'///')

SELECT* FROM Izleti

/*
3.	Kreirati uskladištenu proceduru za unos nove prijave. Proceduri nije potrebno proslijediti parametar Datum.
Datum se uvijek postavlja na trenutni. Koristeći kreiranu proceduru u tabelu Prijave dodati 10 prijava.
*/
CREATE PROCEDURE Unos_prijave
(
	@KlijentID INT,
	@IzletID INT,
	@BrojOdraslih INT,
	@BrojDjece INT
)
AS
BEGIN
INSERT INTO Prijave(KlijentID,IzletID,BrojDjece,BrojOdraslih,Datum)
VALUES (@KlijentID,@IzletID,@BrojDjece,@BrojOdraslih,GETDATE())
END

EXEC Unos_prijave 1,1,2,4
EXEC Unos_prijave 2,2,3,1
EXEC Unos_prijave 3,3,1,2
EXEC Unos_prijave 3,1,3,3
EXEC Unos_prijave 2,1,4,1
EXEC Unos_prijave 2,3,3,2
EXEC Unos_prijave 1,3,2,5
EXEC Unos_prijave 1,2,2,5
EXEC Unos_prijave 3,2,3,4
EXEC Unos_prijave 4,1,3,0

SELECT* FROM Prijave

/*
4.	Kreirati index koji će spriječiti dupliciranje polja Email u tabeli Klijenti. Obavezno testirati ispravnost kreiranog indexa.
*/
CREATE UNIQUE NONCLUSTERED INDEX UQ_Email_Klijent
ON Klijenti(Email)

--test
INSERT INTO Klijenti(Ime,Prezime,Drzava,Grad,Email,Telefon)
VALUES('test','test','test','test','Gabe.Mares@adventure-works.com','test')

/*
5.	Svim izletima koji imaju više od 3 prijave cijenu umanjiti za 10%.
*/
UPDATE Izleti
SET Cijena = Cijena-(Cijena*0.10)
WHERE IzletID IN (SELECT I.IzletID
				   FROM Izleti AS I INNER JOIN Prijave AS P
				   ON P.IzletID = I.IzletID
				   GROUP BY I.IzletID
				   HAVING COUNT(I.IzletID) > 3
				   )
SELECT* FROM Izleti

/*
6.	Kreirati view (pogled) koji prikazuje podatke o izletu: šifra, naziv, datum polaska, datum povratka i cijena, 
te ukupan broj prijava na izletu, 
ukupan broj putnika, ukupan broj odraslih i ukupan broj djece. Obavezno prilagoditi format datuma (dd.mm.yyyy).
*/
CREATE VIEW View_izlet
AS
SELECT I.Sifra,I.Naziv,I.DatumPolaska,I.DatumPovratka,I.Cijena,(SELECT COUNT(P.IzletID) FROM Prijave AS P WHERE P.IzletID = I.IzletID) AS "Ukupan broj prijava",
	   (SELECT SUM(P.BrojDjece+P.BrojOdraslih) FROM Prijave AS P WHERE P.IzletID = I.IzletID) AS "Ukupno putnika",
	   (SELECT SUM(P.BrojDjece) FROM Prijave AS P WHERE P.IzletID = I.IzletID) AS "Ukupno djece",
	   (SELECT SUM(P.BrojOdraslih) FROM Prijave AS P WHERE P.IzletID = I.IzletID) AS "Ukupno odraslih"
FROM Izleti AS I

SELECT* FROM View_izlet

/*
7.	Kreirati uskladištenu proceduru koja će na osnovu unesene šifre izleta prikazivati zaradu od izleta i 
to sljedeće kolone: naziv izleta, zarada od odraslih, zarada od djece, ukupna zarada. 
Popust za djecu se obračunava 50% na ukupnu cijenu za djecu. Obavezno testirati ispravnost kreirane procedure.
*/
CREATE PROCEDURE Prikaz_zarade
(
	@Sifra NVARCHAR(20)
)
AS 
BEGIN
SELECT I.Naziv, SUM(I.Cijena*P.BrojOdraslih) AS "Zarada od odraslih",SUM(I.Cijena*P.BrojDjece) AS "Zarada od djece", 
		SUM(I.Cijena*(P.BrojOdraslih+P.BrojDjece)) AS "Ukupna zarada" 
FROM Izleti AS I INNER JOIN Prijave AS P
ON P.IzletID = I.IzletID
WHERE Sifra = @Sifra
GROUP BY I.Naziv
END

EXEC Prikaz_zarade 'F24BE108-E'

/*
8.	a) Kreirati tabelu IzletiHistorijaCijena u koju je potrebno pohraniti identifikator izleta kojem je cijena izmijenjena, 
datum izmjene cijene, staru i novu cijenu. Voditi računa o tome da se jednom izletu može više puta mijenjati
cijena te svaku izmjenu treba zapisati u ovu tabelu.
b) Kreirati trigger koji će pratiti izmjenu cijene u tabeli Izleti te za svaku izmjenu u prethodno
kreiranu tabelu pohraniti podatke izmijeni.
c) Za određeni izlet (proizvoljno) ispisati sljdedeće podatke: naziv izleta, datum polaska, datum povratka, 
trenutnu cijenu te kompletnu historiju izmjene cijena tj. datum izmjene, staru i novu cijenu.
*/
--a)


CREATE TABLE IzletiHistorijaCijena
(
	HistorijaID INT PRIMARY KEY IDENTITY(1,1),
	IzletID INT,
	DatumIzmjene DATE,
	StaraCijena MONEY,
	NovaCijena MONEY
)

CREATE TRIGGER TR_Izmjena_Cijena
ON Izleti
AFTER UPDATE
AS
INSERT INTO IzletiHistorijaCijena(IzletID,DatumIzmjene,StaraCijena, NovaCijena)
SELECT i.IzletID, SYSDATETIME(), d.Cijena, i.Cijena
FROM deleted AS d INNER JOIN Izleti AS i
ON i.IzletID = d.IzletID

SELECT* FROM IzletiHistorijaCijena


/*9. Obrisati sve klijente koji nisu imali niti jednu prijavu na izlet. */

--nije pokretano
DELETE FROM Klijenti
WHERE KlijentID IN (SELECT K.KlijentID
					FROM Prijave AS P RIGHT JOIN Klijenti AS K ON K.KlijentID = P.KlijentID
					GROUP BY K.KlijentID
					HAVING COUNT(P.KlijentID) = 0)


/*10. Kreirati full i diferencijalni backup baze podataka na lokaciju servera D:\BP2\Backup*/
