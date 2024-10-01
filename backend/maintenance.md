# Maintenance
Här följer lite tips för att underhålla koden.


## Kodstandard
Koden är skriven efter Pythons stilguider pep8 och pep257,
för att hålla en hög kvalitet på koden. 

- https://peps.python.org/pep-0008/

- https://peps.python.org/pep-0257/

Koden använder även type hinting för att hålla bättre koll på typerna. Här följer en guide
på hur man installerar verktygen och använder dem.

## Pycodestyle och pydocstyle
I python har man oftast ganska strikt kodstandard. Två användbara linters, pycodestyle och pydocstyle, kan installeras med pip på följande vis

```
>> python3 -m pip install pycodestyle pydocstyle
```

För att testa om en fil följer kodstandarden kan man köra ```pycodestyle [filnamn]```(syntaxmässigt) och ```pydocstyle [filnamn]```(se till så att inga docstrings fattas). Man kan också lägga till så att textredigeraren automatiskt markerar fel (rekomenderas).

## Type hinting
I python finns det stöd för s.k. type hinting, vilket är ett sätt att deklarera typerna på parametrar och variabler.
Se https://docs.python.org/3/library/typing.html

Kan checkas med hjälp av mypy (http://mypy-lang.org/).
```
>> python3 -m pip install mypy
>> mypy [filnamn]
```

## Cyklomatisk komplexitet
För att få en överblick över den cyklomatiska komplexiteten i koden används verktyget Radon. 

```
>> python3 -m pip install radon
>> radon cc [filnamn/mapp] -a
```
Flaggan -a säger åt Radon att beräkna medelkomplexiteten i slutet. 

Vill man filtrera efter betyg kan man lägga till -n[betyg], exempelvis -nc för att visa 
alla resultat med C eller sämre betyg. 

Betygen som ges förklaras i tabellen nedan. 
(https://radon.readthedocs.io/en/latest/commandline.html)

|CC|score|Rank|Risk|
|---|---|---|-----|
|1 - 5|A|low|simple block|
|6-10|B|low|well structured and stable block|
|11-20|C|moderate|slightly complex block|
|21-30|D|more than moderate|more complex block|
|31-40|E|high|complex block, alarming|
|41+|F|very high|error-prone, unstable block|

