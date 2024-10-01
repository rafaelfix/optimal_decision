# Kund Backend

Backend som kunden har givet. Innehåller en fil som agerar som databas och http koppling. Matlab koden för visualisering av datan finns även i `Matlab`.

# Hur programmet körs
```
python3 serverEducation.py
```
Vid körning öppnas en http server på port 8080 och `singleDigit.db` (databasen) skapas i samma katalogen som python kördes i.

# Saker som är oklara
- Kommunikation från/till android appen
- Hur man läser av `.db` filen
- Verkar använda sqlite och inget ramverk?
- Vad matlab koden exakt gör? 

