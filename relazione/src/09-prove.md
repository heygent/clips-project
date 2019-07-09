\newpage

# Prove

Il dominio con cui abbiamo testato ...

\newpage

## Prove su esclusione regione e tipo di turismo

Il dominio su cui abbiamo eseguito questa query è in `dominio1.txt`.

Nel corso di questa prova abbiamo dato in input al sistema due query, in cui
l'unica differenza tra le due è che la seconda contiene il Piemonte tra le
regioni escluse.

```lisp
(query
   (giorni 3)
   (numero-persone 3)
   (numero-città 2)
   (turismo montano enogastronomico)
   (budget 500))
```


Località            Albergo             Stelle       Notti    Camere     Costo
------------------  ------------------- ---------  ------- --------- ---------
**Itinerario 1**
Milano              Milano2             * *              2         2       300
Pavia               Pavia2              * *              1         2       150
Totale                                                                     450
**Itinerario 2**
Torino              Torino2             * *              2         2       300
LontanoPiemontese   LontanoPiemontese2  * *              1         2       150
Totale                                                                     450
**Itinerario 3**
Foggia              Foggia2             * *              1         2       150
Zapponeta           Zapponeta2          *                2         2       200
Totale                                                                     350
**Itinerario 4**
DuaneraLaRocca      DuaneraLaRocca1     * * * *          1         2       250
Zapponeta           Zapponeta2          *                2         2       200
Totale                                                                     450

: Risultati mostrati dal sistema per la prima query

value                               certainty
--------------------------------- -----------
Milano Pavia                             0.75
LontanoPiemontese Torino                 0.65
Foggia Zapponeta                         0.35
DuaneraLaRocca Zapponeta                 0.35
ColonettaDiProdo Macerata               -0.08
Foggia OrtaNova                         -0.50
DuaneraLaRocca Foggia                   -0.50
DuaneraLaRocca OrtaNova                 -0.50
OrtaNova Zapponeta                      -0.50

: CF assegnati agli itinerari nel corso della prima interrogazione.

Il sistema mostra quattro itinerari, quelli che alla fine dell'elaborazione
hanno CF positivo. Andando ad aggiungere il Piemonte alle regioni escluse,
vengono mostrati gli stessi itinerari mostrati in precedenza, ad eccezione di
(Torino, LontanoPiemontese), che dopo la nuova query assume CF negativo.

```lisp
(query
   (giorni 3)
   (numero-persone 3)
   (numero-città 2)
   (regioni-da-escludere Piemonte)
   (turismo montano enogastronomico)
   (budget 500))
```

Località            Albergo             Stelle       Notti    Camere     Costo
------------------  ------------------- ---------  ------- --------- ---------
**Itinerario 1**
Milano              Milano2             * *              2         2       300
Pavia               Pavia2              * *              1         2       150
Totale                                                                     450
**Itinerario 2**
Foggia              Foggia2             * *              1         2       150
Zapponeta           Zapponeta2          *                2         2       200
Totale                                                                     350
**Itinerario 3**
DuaneraLaRocca      DuaneraLaRocca1     * * * *          1         2       250
Zapponeta           Zapponeta2          *                2         2       200
Totale                                                                     450

: Risultati della seconda interrogazione

value                                              certainty
------------------------------------------------- ----------
Milano Pavia                                            0.75
Foggia Zapponeta                                        0.35
DuaneraLaRocca Zapponeta                                0.35
ColonettaDiProdo Macerata                              -0.03
LontanoPiemontese Torino                               -0.35
Foggia OrtaNova                                        -0.50
DuaneraLaRocca Foggia                                  -0.50
DuaneraLaRocca OrtaNova                                -0.50
OrtaNova Zapponeta                                     -0.50

: CF assegnati agli itinerari nel corso della seconda interrogazione


## Prova con budget alto e alta disponibilità di camere

```lisp
  (query
     (giorni 5)
     (numero-persone 5)
     (numero-città 3)
     (turismo sportivo)
     (budget 2000)
   )
```

Il dominio su cui abbiamo effettuato questa prova è in `dominio2.txt`. Rispetto
al dominio precedente, è stata aggiunta la località di Bergamo, e si è
aumentato il numero di camere disponibili in diversi alberghi. Il sistema ora
valuta sei itinerari diversi con CF positivo, di cui mostra i primi cinque in
ordine decrescente di certezza.

Località            Albergo             Stelle       Notti    Camere     Costo
------------------  ------------------- ---------  ------- --------- ---------
**Itinerario 1**
Milano              Milano2             * *              3         3       675
Pavia               Pavia2              * *              1         3       225
Bergamo             Bergamo2            * *              1         3       225
Totale                                                                    1125
**Itinerario 2**
Macerata            Macerata1           * * * *          1         3       375
Camerino            Camerino1           * * * *          3         3      1125
Acquasparta         Acquasparta1        * * * *          1         3       375
Totale                                                                    1875
**Itinerario 3**
Macerata            Macerata1           * * * *          1         3       375
Camerino            Camerino1           * * * *          3         3      1125
ColonettaDiProdo    ColonettaDiProdo2   * *              1         3       225
Totale                                                                    1725
**Itinerario 4**
Macerata            Macerata1           * * * *          3         3      1125
Acquasparta         Acquasparta1        * * * *          1         3       375
ColonettaDiProdo    ColonettaDiProdo2   * *              1         3       225
Totale                                                                    1725
**Itinerario 5**
OrtaNova            OrtaNova1           * * * *          3         3      1125
DuaneraLaRocca      DuaneraLaRocca2     * * *            1         3       300
Zapponeta           Zapponeta2          *                1         3       150
Totale                                                                    1575

: Output della query su `dominio2.txt`

value                                              certainty
------------------------------------------------- ----------
Bergamo Milano Pavia                                    0.75
Acquasparta Camerino Macerata                           0.57
Camerino ColonettaDiProdo Macerata                      0.57
Acquasparta ColonettaDiProdo Macerata                   0.47
DuaneraLaRocca OrtaNova Zapponeta                       0.35
Acquasparta Camerino ColonettaDiProdo                   0.25

: CF assegnati dal sistema nel corso dell'elaborazione della query.
