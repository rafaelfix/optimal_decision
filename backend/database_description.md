# Databas
En beskrivning av databasen.

## PostgreSQL
Databasen kommuniceras med via databashanteraren PostgreSQL. Databasen är strukturerad efter relationsmodellen,
det är alltså en relationsdatabas. Läs mer om PostgreSQL på https://www.postgresql.org/.

## ER-Modell 
Följande är en modell över databasen och relationerna mellan entities. Modellen är enklare än den ser ut med alla attribut, i praktiken så har vi att:
- Blått markerar de tabeller som skapas.
- Grönt markerar relationerna mellan tabellerna.
- Grått markerar de attribut som skapas i tabellerna. 

Modellen utgår från en användare ("User") som kan ha en session ("Session") där användaren löser ett antal uppgifter ("Tasks") vars samtliga knapptryckningar ("Keypress") lagras. Vi har därför en rad kopplade svaga entitetstyper ("Weak entities") vilket innebär att de är osjälvständiga från sin kopplade entitet. En session kan inte existera utan en användare, en task kan inte existera utan en session, osv. 

![EER Model](/images/eer_diagram.png "Image Title")

## Relationsmodell
Följande är en detaljerad modell över de relationer som är implementerade i databasen och deras kopplingar till varandra. Se /olle/models.py för implementationen och datatyper. 

![Relationsmodell](/images/relational_model.png "Image Title")


