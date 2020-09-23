/*1.Kroz SQL kod, napraviti bazu podataka koja nosi ime vašeg broja dosijea sa default postavkama*/
CREATE DATABASE Integralni_18_9_2018
USE Integralni_18_9_2018
GO

/*2.
Unutar svoje baze podataka kreirati tabele sa sljedećem strukturom:
Autori
- AutorID, 11 UNICODE karaktera i primarni ključ
- Prezime, 25 UNICODE karaktera (obavezan unos)
- Ime, 25 UNICODE karaktera (obavezan unos)
- ZipKod, 5 UNICODE karaktera, DEFAULT je NULL
- DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
- DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL
*/
CREATE TABLE Autori
(
	AutorID NVARCHAR(11) CONSTRAINT PK_AutorID PRIMARY KEY,
	Prezime NVARCHAR(25) NOT NULL,
	Ime NVARCHAR(25) NOT NULL,
	ZipKod NVARCHAR(5) DEFAULT NULL,
	DatumKreiranjaZapisa DATE NOT NULL DEFAULT GETDATE(),
	DatumModifikovanjaZapisa DATE DEFAULT NULL
)

/*
Izdavaci
- IzdavacID, 4 UNICODE karaktera i primarni ključ
- Naziv, 100 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
- Biljeske, 1000 UNICODE karaktera, DEFAULT tekst je Lorem ipsum
- DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
- DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL
*/
CREATE TABLE Izdavaci
(
	IzdavacID NVARCHAR(4) CONSTRAINT PK_IzdavacID PRIMARY KEY,
	Naziv NVARCHAR(100) NOT NULL UNIQUE,
	Biljeske NVARCHAR(100) DEFAULT 'Lorem ipsum',
	DatumKreiranjaZapisa DATE NOT NULL DEFAULT GETDATE(),
	DatumModifikovanjaZapisa DATE DEFAULT NULL
)

/*Naslovi
- NaslovID, 6 UNICODE karaktera i primarni ključ
- IzdavacID, spoljni ključ prema tabeli „Izdavaci“
- Naslov, 100 UNICODE karaktera (obavezan unos)
- Cijena, monetarni tip podatka
- Biljeske, 200 UNICODE karaktera, DEFAULT tekst je The quick brown fox jumps over the lazy dog
- DatumIzdavanja, datum izdanja naslova (obavezan unos) DEFAULT je datum unosa zapisa
- DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
- DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL
*/
CREATE TABLE Naslovi
(
	NaslovID NVARCHAR(6) CONSTRAINT PK_NaslovID PRIMARY KEY,
	IzdavacID NVARCHAR(4) CONSTRAINT FK_IzdavacID FOREIGN KEY REFERENCES Izdavaci(IzdavacID),
	Naslov NVARCHAR(100) NOT NULL,
	Cijena MONEY,
	Biljeske NVARCHAR(200) DEFAULT 'The quick brown fox jumps over the lazy dog',
	DatumIzdavanja DATE NOT NULL DEFAULT GETDATE(),
	DatumKreiranjaZapisa DATE NOT NULL DEFAULT GETDATE(),
	DatumModifikovanjaZapisa DATE DEFAULT NULL
)

/*NasloviAutori (Više autora može raditi na istoj knjizi)
- AutorID, spoljni ključ prema tabeli „Autori“
- NaslovID, spoljni ključ prema tabeli „Naslovi“
- DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
- DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL
*/
CREATE TABLE NasloviAutori
(
	AutorID NVARCHAR(11) CONSTRAINT FK_AutorID FOREIGN KEY REFERENCES Autori(AutorID),
	NaslovID NVARCHAR(6) CONSTRAINT FK_NaslovID FOREIGN KEY REFERENCES Naslovi(NaslovID),
	DatumKreiranjaZapisa DATE NOT NULL DEFAULT GETDATE(),
	DatumModifikovanjaZapisa DATE DEFAULT NULL,
	CONSTRAINT PK_NaslovAutor PRIMARY KEY(AutorID, NaslovID)
)


/*2b
Generisati testne podatake i obavezno testirati da li su podaci u tabelema za svaki korak zasebno :
- Iz baze podataka pubs tabela „authors“, a putem podupita u tabelu „Autori“ importovati sve slučajno sortirane
zapise. Vodite računa da mapirate odgovarajuće kolone.
*/
INSERT INTO Autori(AutorID,Prezime,Ime,ZipKod)
SELECT au_id, au_lname,au_fname,zip
FROM pubs.dbo.authors
ORDER BY newid()

SELECT* FROM Autori

/*- Iz baze podataka pubs i tabela („publishers“ i pub_info“), a putem podupita u tabelu „Izdavaci“ importovati sve
slučajno sortirane zapise. Kolonu pr_info mapirati kao bilješke i iste skratiti na 100 karaktera. Vodite računa da
mapirate odgovarajuće kolone i tipove podataka.
*/
INSERT INTO Izdavaci(IzdavacID,Naziv,Biljeske)
SELECT b.pub_id,b.pub_name,b.bilj
FROM (SELECT P.pub_id,P.pub_name,LEFT(CONVERT(NVARCHAR,PII.pr_info),100) AS bilj FROM pubs.dbo.publishers AS P INNER JOIN pubs.dbo.pub_info AS PII 
	  ON PII.pub_id = P.pub_id) AS b
ORDER BY NEWID()

/*
- Iz baze podataka pubs tabela „titles“, a putem podupita u tabelu „Naslovi“ importovati one naslove koji imaju
bilješke. Vodite računa da mapirate odgovarajuće kolone.
*/
INSERT INTO Naslovi(NaslovID,IzdavacID,Naslov,Cijena,Biljeske,DatumIzdavanja)
SELECT t.title_id,t.pub_id,t.title,t.price,t.notes,t.pubdate
FROM (SELECT title_id, pub_id, title, price, notes,pubdate FROM pubs.dbo.titles WHERE notes IS NOT NULL) AS t

/*- Iz baze podataka pubs tabela „titleauthor“, a putem podupita u tabelu „NasloviAutori“ zapise. Vodite računa da
mapirate odgovarajuće kolone.
*/
INSERT INTO NasloviAutori(AutorID,NaslovID)
SELECT t.au_id, t.title_id
FROM (SELECT au_id,title_id FROM pubs.dbo.titleauthor) AS t


/*2c
Kreiranje nove tabele, importovanje podataka i modifikovanje postojeće tabele:
Gradovi
- GradID, automatski generator vrijednosti koji generiše neparne brojeve, primarni ključ
- Naziv, 100 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
- DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
- DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL
- Iz baze podataka pubs tabela „authors“, a putem podupita u tabelu „Gradovi“ importovati nazive gradove bez
duplikata.
- Modifikovati tabelu Autori i dodati spoljni ključ prema tabeli Gradovi:
*/
CREATE TABLE Grad
(
	GradID INT CONSTRAINT PK_GradID PRIMARY KEY IDENTITY (1,2),
	Naziv NVARCHAR(100) NOT NULL UNIQUE,
	DatumKreiranjaZapisa DATE NOT NULL DEFAULT GETDATE(),
	DatumModifikovanjaZapisa DATE DEFAULT NULL
)
INSERT INTO Grad(Naziv)
SELECT t.city
FROM (SELECT DISTINCT city FROM pubs.dbo.authors) AS t

ALTER TABLE Autori
ADD GradID INT CONSTRAINT FK_GradIDAutori FOREIGN KEY REFERENCES Grad(GradID)

/*2d
Kreirati dvije uskladištene proceduru koja će modifikovati podataka u tabeli Autori:
- Prvih pet autora iz tabele postaviti da su iz grada: Salt Lake City
- Ostalim autorima podesiti grad na: Oakland
Vodite računa da se u tabeli modifikuju sve potrebne kolone i obavezno testirati da li su podaci u tabeli za svaku proceduru
posebno.
*/
CREATE PROCEDURE proc_1
AS
BEGIN
UPDATE TOP(5) Autori
SET GradID = (SELECT GradID FROM Grad WHERE Naziv = 'Salt Lake City'),
	DatumModifikovanjaZapisa = GETDATE()
END

ALTER PROCEDURE proc_2
AS
BEGIN
UPDATE Autori
SET GradID = (SELECT GradID FROM Grad WHERE Naziv = 'Oakland'),
	DatumModifikovanjaZapisa = GETDATE()
WHERE GradID IS NULL 
END

EXEC proc_2
SELECT* FROM Autori

/*3.
Kreirati pogled sa sljedećom definicijom: Prezime i ime autora (spojeno), grad, naslov, cijena, bilješke o naslovu i naziv
izdavača, ali samo za one autore čije knjige imaju određenu cijenu i gdje je cijena veća od 5. Također, naziv izdavača u sredini
imena ne smije imati slovo „&“ i da su iz autori grada Salt Lake City 
*/

CREATE VIEW view_1
AS
SELECT A.Ime+' '+A.Prezime AS "Ime prezime", G.Naziv AS Grad, N.Naslov,N.Cijena, N.Biljeske,
	   I.Naziv
FROM Autori AS A INNER JOIN NasloviAutori AS NA 
ON NA.AutorID = A.AutorID INNER JOIN Naslovi AS N 
ON N.NaslovID = NA.NaslovID INNER JOIN Izdavaci AS I
ON I.IzdavacID = N.IzdavacID INNER JOIN Grad AS G
ON G.GradID = A.GradID
WHERE N.Cijena IS NOT NULL AND N.Cijena > 5 AND I.Naziv NOT LIKE '%&%' AND G.Naziv  = 'Salt Lake City'


/*4.
Modifikovati tabelu Autori i dodati jednu kolonu:
- Email, polje za unos 100 UNICODE karaktera, DEFAULT je NULL
*/
ALTER TABLE Autori
ADD Email NVARCHAR(100) DEFAULT NULL

/*5.
Kreirati dvije uskladištene proceduru koje će modifikovati podatke u tabelu Autori i svim autorima generisati novu email
adresu:
- Prva procedura: u formatu: Ime.Prezime@fit.ba svim autorima iz grada Salt Lake City
- Druga procedura: u formatu: Prezime.Ime@fit.ba svim autorima iz grada Oakland
*/
CREATE PROCEDURE mail_1
AS
BEGIN
UPDATE Autori
SET Email = Ime+'.'+Prezime+'@fit.ba'
WHERE GradID = (SELECT GradID FROM Grad WHERE Naziv = 'Salt Lake City')
END

CREATE PROCEDURE mail_2
AS
BEGIN
UPDATE Autori
SET Email = Prezime+'.'+Ime+'@fit.ba'
WHERE GradID = (SELECT GradID FROM Grad WHERE Naziv = 'Oakland')
END
EXEC mail_1
EXEC mail_2

/*6.
z baze podataka AdventureWorks2014 u lokalnu, privremenu, tabelu u vašu bazi podataka importovati zapise o osobama, a
putem podupita. Lista kolona je: Title, LastName, FirstName, EmailAddress, PhoneNumber i CardNumber. Kreirate
dvije dodatne kolone: UserName koja se sastoji od spojenog imena i prezimena (tačka se nalazi između) i kolonu Password
za lozinku sa malim slovima dugačku 24 karaktera. Lozinka se generiše putem SQL funkciju za slučajne i jedinstvene ID
vrijednosti. Iz lozinke trebaju biti uklonjene sve crtice „-“ i zamijenjene brojem „7“. Uslovi su da podaci uključuju osobe koje
imaju i nemaju kreditnu karticu, a NULL vrijednost u koloni Titula zamjeniti sa podatkom 'N/A'. Sortirati prema prezimenu i
imenu istovremeno. Testirati da li je tabela sa podacima kreirana.
*/

SELECT t.Title, t.LastName,t.FirstName,t.EmailAddress,t.PhoneNumber,t.CardNumber,t.Username,t.Password
INTO #privremena
FROM (
	SELECT ISNULL(P.Title,'N/A') AS Title, P.LastName,P.FirstName,EA.EmailAddress,PN.PhoneNumber, CC.CardNumber, P.FirstName+'.'+P.LastName AS Username,
		   REPLACE(LEFT(NEWID(),24),'-','7') AS Password
	FROM AdventureWorks2017.Person.Person AS P INNER JOIN AdventureWorks2017.Person.EmailAddress AS EA
	ON EA.BusinessEntityID = P.BusinessEntityID INNER JOIN AdventureWorks2017.Person.PersonPhone AS PN
	ON PN.BusinessEntityID = P.BusinessEntityID LEFT JOIN AdventureWorks2017.Sales.PersonCreditCard AS PCC
	ON PCC.BusinessEntityID = P.BusinessEntityID LEFT JOIN AdventureWorks2017.Sales.CreditCard AS CC
	ON CC.CreditCardID = PCC.CreditCardID
) AS t
ORDER BY t.LastName,t.FirstName

SELECT* FROM #privremena

/*7.
Kreirati indeks koji će nad privremenom tabelom iz prethodnog koraka, primarno, maksimalno ubrzati upite koje koriste
kolone LastName i FirstName, a sekundarno nad kolonam UserName. Napisati testni upit.
*/
CREATE NONCLUSTERED INDEX IX_Privremena_FirstLastNm
ON #privremena(FirstName, LastName)
INCLUDE(Username)

SELECT FirstName, LastName, Username
FROM #privremena
WHERE FirstName LIKE '[BC]%' AND LastName LIKE 'A%' AND LEN(Username) > 10

/*8.
Kreirati uskladištenu proceduru koja briše sve zapise iz privremene tabele koji imaju kreditnu karticu Obavezno testirati
funkcionalnost procedure.
*/
DELETE FROM #privremena
WHERE CardNumber IS NOT NULL
/*9. Kreirati backup vaše baze na default lokaciju servera i nakon toga obrisati privremenu tabelu*/
BACKUP DATABASE Integralni_18_9_2018
TO DISK = 'Integralni_18_9_2018.bak'

DROP TABLE #privremena

/*10a Kreirati proceduru koja briše sve zapise iz svih tabela unutar jednog izvršenja. Testirati da li su podaci obrisani*/


/*10b Uraditi restore rezervene kopije baze podataka i provjeriti da li su svi podaci u izvornom obliku*/
USE Integralni_18_9_2018
USE master
RESTORE DATABASE Integralni_18_9_2018
FROM DISK = 'Integralni_18_9_2018.bak'
