\newpage

# Prove

Il dominio con cui abbiamo testato ...

\newpage

## Prove su esclusione regione e tipo di turismo

La query inviata al sistema è la seguente:

```{.lisp caption="Query eseguita per la prima prova"}
(query
   (giorni 3)
   (numero-persone 3)
   (numero-città 2)
   (turismo montano enogastronomico)
   (budget 500))
```

In questa situazione abbiamo come itinerari preferiti (Milano, Pavia) e
(Torino, LontanoPiemontese), dato che entrambi gli itinerari contengono città
con buoni punteggi per i tipi di turismo montano ed enogastronomico. Dato il
budget basso, il sistema consiglia gli alberghi meno costosi.


: Query 1, itinerario 1, costo totale: 450

Località            Albergo             Stelle    Notti   Camere    Costo
------------------  ------------------- --------- ------- --------- ---------
Milano              Milano2             * *       2       2         300
Pavia               Pavia2              * *       1       2         150


: Query 1, itinerario 2, costo totale: 450

Località            Albergo             Stelle    Notti   Camere    Costo
------------------  ------------------- --------- ------- --------- ---------
Torino              Torino2             * *       2       2         300
LontanoPiemontese   LontanoPiemontese2  * *       1       2         150


: CF assegnati agli itinerari dopo la query

value                          certainty
----------------------------- ----------
Milano Pavia                        0.50
LontanoPiemontese Torino            0.30
ColonettaDiProdo Macerata          -0.50
DuaneraLaRocca OrtaNova            -1.00

L'itinerario (ColonnettaDiProdo, Macerata) è fuori budget di 150, e la soglia
di superamento budget è impostata a 100, per cui il CF assegnato agli alberghi
dato il budget è di -0.5 (ha anche un buon punteggio in base all'occupazione,
0.3, ma dato che la combinazione dei punteggi degli alberghi avviene in base al
minimo questo non viene considerato). 

Andando a inserire il Piemonte nelle regioni escluse, la situazione cambia e il
sistema consiglia come itinerari (Milano, Pavia) e (Macerata,
ColonnettaDiProdo).

```{.lisp caption="Query eseguita per la seconda prova. Viene aggiunto il Piemonte alle regioni escluse."}
(query
   (giorni 3)
   (numero-persone 3)
   (numero-città 2)
   (regioni-da-escludere Piemonte)
   (turismo montano enogastronomico)
   (budget 500))
```


: Query 2, itinerario 1, costo totale: 450

Località            Albergo             Stelle    Notti   Camere    Costo
------------------  ------------------- --------- ------- --------- ---------
Milano              Milano2             * *       2       2         300
Pavia               Pavia2              * *       1       2         150


: Query 2, itinerario 2, costo totale: 650

Località            Albergo             Stelle    Notti   Camere    Costo
------------------  ------------------- --------- ------- --------- ---------
Macerata            Macerata1           * * * *   2       2         500
ColonettaDiProdo    ColonettaDiProdo2   * *       1       2         150


(ColonnettaDiProdo, Macerata) ha lo stesso CF di prima (-0.5) a causa del
budget, ma stavolta il sistema lo raccomanda, dato che raccomanda sempre almeno
due itinerari a prescindere dal fatto che i loro CF siano positivi o negativi.


: CF assegnati agli itinerari dopo la query

value                          certainty
----------------------------- ----------
Milano Pavia                     0.50
ColonettaDiProdo Macerata       -0.50
DuaneraLaRocca OrtaNova         -1.00
LontanoPiemontese Torino        -1.00


