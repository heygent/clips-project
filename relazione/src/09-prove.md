# Prove

Il dominio con cui abbiamo testato ...

## Prove su tipo di turismo

In questa situazione abbiamo come itinerari preferiti (Milano, Pavia) e
(Torino, LontanoPiemontese), dato che entrambi gli itinerari contengono città
con buoni punteggi per i tipi di turismo montano ed enogastronomico. Dato il
budget basso, il sistema può consigliare soltanto gli alberghi meno costosi.

```lisp
(query
   (giorni 3)
   (numero-persone 3)
   (numero-città 2)
   (turismo montano enogastronomico)
   (budget 500))
```

: Itinerario 1, costo totale: 450

Località            Albergo             Stelle    Notti   Camere    Costo
------------------  ------------------- --------- ------- --------- ---------
Milano              Milano2             **        2       2         300
Pavia               Pavia2              **        1       2         150


: Itinerario 2, costo totale: 450

Località            Albergo             Stelle    Notti   Camere    Costo
------------------  ------------------- --------- ------- --------- ---------
Torino              Torino2             **        2       2         300
LontanoPiemontese   LontanoPiemontese2  **        1       2         150

Andando a inserire il Piemonte nelle regioni escluse, la situazione cambia e il
sistema consiglia come itinerari (Milano, Pavia) e (Macerata,
ColonnettaDiProdo).
```lisp
(query
   (giorni 3)
   (numero-persone 3)
   (numero-città 2)
   (regioni-da-escludere Piemonte)
   (turismo montano enogastronomico)
   (budget 500))
```

: Itinerario 1, costo totale: 450

Località            Albergo             Stelle    Notti   Camere    Costo
------------------  ------------------- --------- ------- --------- ---------
Milano              Milano2             ★★        2       2         300
Pavia               Pavia2              ★★        1       2         150


: Itinerario 2, costo totale: 650

Località            Albergo             Stelle    Notti   Camere    Costo
------------------  ------------------- --------- ------- --------- ---------
Macerata            Macerata1           ★★★★      2       2         500
ColonettaDiProdo    ColonettaDiProdo2   ★★        1       2         150

L'itinerario (Macerata, ColonnettaDiProdo) è fuori budget di 150, e la soglia
di superamento budget è impostata a 100, per cui il CF assegnato agli alberghi
dato il budget è di -0.5 (ha anche un buon punteggio in base all'occupazione,
0.3, ma dato che la combinazione dei punteggi degli alberghi avviene in base al
minimo questo non viene considerato). 
