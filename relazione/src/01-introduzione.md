---
# vim: spell spelllang=it
title: CLIPS
subtitle: Progetto di Intelligenze Artificiali e Laboratorio - Parte 2
author:
  - Emanuele Gentiletti
  - Alessandro Caputo
lang: it
titlepage: true
toc-own-page: true
listings-disable-line-numbers: true
listings-no-page-break: true
---

# Introduzione

Il progetto consisteva nella realizzazione di un sistema esperto per la
raccomandazione di itinerari di viaggio tramite l'applicativo CLIPS. In questa
relazione descriviamo le scelte fatte nella realizzazione del sistema e alcuni
scenari di prova a cui lo abbiamo sottoposto.

## Esecuzione

Il programma viene eseguito nella REPL di CLIPS. Una volta eseguiti i comandi
`(load main.clp)`, `(reset)` e `(run)`, il programma mostra all'utente una
schermata di aiuto.

```
Benvenuto in DoveAndareVai©, il sistema esperto per 
organizzare i tuoi viaggi.
Per procedere, asserisci una query ed esegui il comando (run).

Esempio:

(assert
  (query
    (giorni 5)
    (numero-persone 2)
    (numero-città 3)
    (regioni-da-includere Piemonte Puglia)
    (regioni-da-escludere Marche)
    (turismo balneare geologico)
    (budget 10000)))

(run)
```

Per procedere, l'utente esegue l'`assert` di un fatto non ordinato di tipo
`query`, per poi eseguire `run`. Il sistema esperto inizia quindi con la
computazione, per poi alla fine mostrare la query eseguita dall'utente
(comprensiva di criteri scelti dal sistema di default) e un elenco
di itinerari proposti.

```
CLIPS> (assert
         (query
           (giorni 3)
           (numero-persone 3)
           (numero-città 2)
           (regioni-da-includere)
           (regioni-da-escludere Piemonte)
           (turismo montano enogastronomico)
           (budget 500))

Abbiamo alcuni itinerari da suggerirti.

Località            Albergo             Stelle       Notti   Costo
------------------  ------------------- ---------  ------- -------
__Itinerario 1__
Milano              Milano2             * *              2     300
Pavia               Pavia2              * *              1     150
Totale                                                         450
__Itinerario 2__
Foggia              Foggia2             * *              1     150
Zapponeta           Zapponeta2          *                2     200
Totale                                                         350
__Itinerario 3__
DuaneraLaRocca      DuaneraLaRocca1     * * * *          1     250
Zapponeta           Zapponeta2          *                2     200
Totale                                                         450
```

Una volta terminato, il sistema mostra di nuovo la schermata di aiuto
all'utente, e permette di effettuare una nuova query con le stesse modalità
precedenti. L'utente può quindi raffinare la sua query aggiungendo nuovi
criteri, per poi mandarla in esecuzione.

## Struttura

Il programma è strutturato in diversi moduli. La maggior parte di questi
riguarda conoscenza di dominio, mentre la conoscenza di controllo è molto
semplice ed è racchiusa interamente nei moduli `MAIN` e `PRINT-RESULTS`. Di
base, il programma è organizzato in diverse fasi sequenziali, ognuna contenuta
in un modulo. Il modulo `MAIN`, come prima operazione, mette nel focus stack
ogni modulo utile all'esecuzione. Al termine, dell'elaborazione della query, il
modulo `PRINT-RESULTS` esegue il reset e restituisce il focus a `MAIN` che
ricomincia la sua esecuzione da capo. Inoltre, il modulo `MAIN` contiene il
template `attribute` per la gestione dei CF e la regola che serve a combinare i
CF che indicano la stessa conoscenza.

```
(defrule start
  (declare (salience ?*max-salience*))
  (query)
  =>
  (set-fact-duplication TRUE)
  (focus
    DOMINIO
    ITINERARI
    ALBERGHI-PER-ITINERARIO
    REGOLE-ALBERGHI
    REASONING-ALBERGHI
    REGOLE-LOCALITÀ
    REASONING-LOCALITÀ
    REGOLE-ITINERARIO
    REASONING-ITINERARIO
    PRINT-RESULTS
  )
)
```

Il modulo `DOMINIO` contiene i template utili alla modellazione del problema,
ovvero `itinerario`, `località`, `albergo` e `regione`. I moduli `ITINERARIO` e
`ALBERGHI-PER-ITINERARIO` contengono le regole che servono a generare prima
ogni possibile itinerario, e poi ogni possibile lista di alberghi per ogni
itinerario.

Successivamente, il modulo `REGOLE-ALBERGHI` assegna dei CF alle varie liste di
alberghi in base alle preferenze dell'utente, mentre `REASONING-ALBERGHI`
sceglie la lista di alberghi migliore in base ai criteri stabiliti in
`REGOLE-ALBERGHI` e la associa definitivamente all'itinerario.

Questa convenzione vale per ogni modulo: i moduli prefissati con `REGOLE`
assegnano dei CF che indicano la preferenza in base ad alcuni criteri per
l'oggetto che prendono in considerazione, mentre i moduli prefissati con
`REASONING` usano questi CF per fare delle scelte.

Infine, il modulo `PRINT-RESULTS` stampa gli itinerari che il sistema ha
giudicato come migliori.


## Località

```
(deftemplate località
  (slot nome)
  (slot lat)
  (slot lon)
  (multislot turismo)
)
```

Ogni località ha il suo nome, una coppia di coordinate e informazioni sui suoi
tipi di turismo. Le coordinate della località sono rappresentate da `lat` e
`lon` (nonostante i loro nomi, in realtà rappresentano un punto in un piano
cartesiano). I tipi di turismo sono indicati nel multislot corrispondente, che
contiene ogni tipo di turismo associato alla località e il suo punteggio.

```{caption="Esempio di un fatto località."}
(località
  (nome Torino)
  (lat -300)
  (lon 290)
  (turismo
    montano 4
    naturalistico 3
    culturale 5
    religioso 5
  )
)
```

## Alberghi

```
(deftemplate albergo
  (slot id)
  (slot località)
  (slot stelle)
  (slot camere-libere)
  (slot occupazione)
)
```

Ogni albergo mantiene l'associazione alla sua località di appartenenza tramite
lo slot `località`, che ne conterrà il nome. Lo slot `camere-libere` contiene
il numero di camere doppie disponibili, mentre l'occupazione è il rapporto tra
il numero di camere occupate e quello di camere totali dell'albergo .

## Regioni

```
(deftemplate regione
  (slot nome)
  (slot lat)
  (slot lon)
  (slot raggio)
)
```

Le regioni sono caratterizzate da `lat` e `lon`, che hanno lo stesso
significato attribuito in `località`, e un raggio. Di base, ogni regione è
modellata come una circonferenza, e le località che hanno coordinate
all'interno della circonferenza appartengono alla regione. 

## Itinerari

```
(deftemplate itinerario
  (slot id)
  (multislot località)
  (multislot alberghi)
  (multislot pernottamenti)
  (slot costo)
)
```

Ogni itinerario è caratterizzato dai tre multislot `località`, `alberghi` e
`pernottamenti`. Una stessa posizione all'interno dei multislot fa riferimento
allo stesso elemento, ad esempio alla località in posizione 3 corrisponde un
soggiorno nell'albergo di posizione 3 per il numero di notti presente nella
posizione 3 di `pernottamenti`. Lo slot `costo` contiene il costo totale
dell'itinerario. Infine, l'`id` è necessario per identificare univocamente
l'itinerario.

# Flusso di esecuzione

## Generazione degli itinerari

Una volta eseguita la regola `start`, la prima operazione eseguita dal
programma è caricare i fatti che corrispondono al dominio dal file
`dominio.txt`, che contiene i fatti non ordinati `località`, `alberghi` e
`regioni` che modellano la situazione in cui effettuare la ricerca.

Successivamente, si passa al modulo `ITINERARI`. Questo modulo ha la
responsabilità di produrre i fatti corrispondente a ogni itinerario da
valutare, tenendo in considerazione il numero di città che l'utente ha indicato
voler visitare. Questo viene fatto tramite la seguente regola:

```
(defrule crea-itinerari-da-località
  (query (numero-città ?numero-città))
  =>
  (do-for-all-facts ((?località località)) TRUE
    (asserisci-itinerari (create$ ?località:nome) ?numero-città)
  )
  ; elimina gli itinerari che contengono le stesse città
  (do-for-all-facts ((?it1 itinerario) (?it2 itinerario))
    (and
      (eq ?it1:id ?it2:id)
      (neq ?it1 ?it2))
    (retract ?it2)
  )
)
```

La regola prende tutti i fatti `località`, e per ognuno di questi chiama la
funzione `asserisci-itinerari`.

`asserisci-itinerari` è una funzione ricorsiva, che a ogni invocazione
controlla i suoi argomenti `?lista-località-itinerario` e
`?lunghezza-itinerario`. Se la lunghezza della lista di località e la lunghezza
dell'itinerario richiesta dall'utente coincidono, la funzione asserisce il
fatto `itinerario` corrispondente alla lista di località in argomento.

```
(deffunction asserisci-itinerari
  (?lista-località-itinerario ?lunghezza-itinerario)
  (if (= (length$ ?lista-località-itinerario) ?lunghezza-itinerario)
    then
    (assert
      (itinerario
        (id (implode$ (sort compare-strings ?lista-località-itinerario)))
        (località ?lista-località-itinerario)
      )
    )
```

Se invece l'itinerario non contiene ancora abbastanza località, la funzione
cerca tutte le località che può aggiungere all'itinerario. Per poter essere
aggiunta all'itinerario, la località deve rispettare due condizioni:

- deve avere una distanza rispetto alla località di partenza non superiore a 100.
- non deve essere già nell'itinerario.

La località di partenza è sempre considerata l'ultima località all'interno
della lista di località.

Per ognuna delle località trovate che rispettano la condizione, la funzione si
richiama ricorsivamente, aggiungendo alla lista di località la nuova località
trovata. A ogni iterazione, la lista di località conterrà una località in più,
finché l'itinerario non sarà completo.

```
    else
    (do-for-all-facts
      ((?località-partenza località) (?località-destinazione località))
      (and
        (eq ?località-partenza:nome (last ?lista-località-itinerario))
        ; Prendi località distanti al massimo ?*SOGLIA-LOCALITÀ-VICINA
        ; dall'ultima località.
        (<
        (distanza-coordinate ?località-partenza:lat ?località-partenza:lon
          ?località-destinazione:lat ?località-destinazione:lon)
        ?*SOGLIA-LOCALITÀ-VICINA*)
        ; Non mettere due volte la stessa località in un itinerario.
        (not (member$ ?località-destinazione:nome ?lista-località-itinerario))
      )
      (asserisci-itinerari
        (create$ ?lista-località-itinerario ?località-destinazione:nome)
        ?lunghezza-itinerario
      )
    )
```

Alla fine della generazione degli itinerari, la regola procede a eliminare gli
itinerari che contengono le stesse località, eliminando gli itinerari che hanno
lo stesso id. Gli id degli itinerari sono stringhe che contengono i nomi delle
località che contengono in ordine alfabetico. Per cui, itinerari che contengono
le stesse città avranno lo stesso id.

Il nostro approccio iniziale è stato usare più regole e dei fatti intermedi per
rappresentare gli itinerari incompleti, andando a fare il match mano a mano con
ognuno di questi per aggiungere una località finché non fossero completi.
Abbiamo poi preferito questo approccio, perché non sporca la working memory con
fatti incompleti dopo l'esecuzione.

## Generazione delle liste di alberghi

Una volta generati gli itinerari, il sistema procede a generare le liste di
alberghi da valutare, in modo simile a come fatto per gli itinerari. Le liste
di alberghi sono rappresentati dal template `alberghi-per-itinerario`, definito
nel modulo `ALBERGHI-PER-ITINERARIO`:

```
(deftemplate alberghi-per-itinerario
  (slot id)
  (slot id-itinerario)
  (multislot alberghi)
  (multislot pernottamenti)
  (slot costo)
)
```

La regola che si occupa della generazione delle liste di alberghi è la
seguente:

```
(defrule crea-liste-alberghi
  (query (numero-persone ?persone))
  (itinerario (id ?id-itinerario) (località $?lista-località))
  =>
  (crea-lista-alberghi
    ?id-itinerario
    ?lista-località
    (camere-per-persone ?persone)
    (create$)
  )
)
```

Questa regola scatta per ogni itinerario generato, e procede a creare,
appoggiandosi alla funzione `crea-liste-alberghi`, ogni possibile lista di
alberghi per l'itinerario preso in considerazione. La funzione procede
prendendo in considerazione, a ogni chiamata, una delle località contenute
nell'itinerario, trovando tutti gli alberghi di quella località che hanno
una disponibilità di camere sufficiente ad accomodare l'utente. Per ognuno
degli alberghi chiamati, la funzione si richiama ricorsivamente, aggiungendo
l'albergo alla lista degli alberghi. Una volta che la funzione viene richiamata
con una lista di alberghi che contiene un albergo per ogni località, questa
asserisce la nuova lista di alberghi e termina.

Oltre a creare le liste di alberghi, il modulo si occupa di assegnare a ognuna
delle liste i pernottamenti e il costo corrispondente. I pernottamenti sono
gestiti dalla regola `pernottamenti`, che distribuisce le notti negli alberghi
in base a questo criterio:

- fai la divisione intera dei giorni, e assegna a tutti gli alberghi il
  risultato.
- prendi il resto della divisione fatta prima, e assegna i giorni restanti
  all'albergo con occupazione minore.

Il costo di una data lista di alberghi viene invece calcolato in base al numero
di giorni, di camere richieste e al costo di una camera all'interno
dell'albergo. Il costo della camera è considerato in funzione del numero di
stelle, in base al seguente calcolo:

```
(deffunction da-stelle-a-prezzo
  "Dato il numero di stelle di un albergo, restituisce il prezzo corrispondente"
  (?stelle)
  (+ 25 (* ?stelle 25)))
```

## Valutazione degli alberghi

Una volta generate le liste di alberghi, il sistema procede a valutarle in base
a due criteri: favorire la prenotazione degli alberghi meno occupati, e
mantenere il budget necessario entro i limiti richiesti dall'utente.

L'occupazione è gestita dalla regola `alberghi-preferiti-per-occupazione`, che
calcola il CF per una lista di alberghi considerando l'albergo all'interno
della lista che ha occupazione minore, assegnando alla lista un punteggio
uguale a 1 meno l'occupazione dell'albergo.

Il budget è gestito dalla regola `alberghi-preferiti-per-budget`, che prende il
costo totale della prenotazione degli alberghi nella lista e assegna un
punteggio da 0 a 1 basato tra il rapporto tra il budget e il costo.

Il punteggio per il budget è calcolato in base a una soglia massima costante,
in base alla seguente logica.

- Se il costo è contenuto nel budget, il CF assegnato sarà 1.
- Se invece il costo supera il budget di un valore inferiore alla soglia, il CF
  sarà compreso tra 0 e 1, dove un valore vicino 0 indica un valore tendente
  alla soglia.
- Se invece il costo supera il budget di un valore superiore alla soglia, il CF
  sarà compreso tra 0 e -1.

L'idea dietro questo meccanismo è che l'utente potrebbe preferire comunque un
itinerario il cui costo supera di poco il budget. Il calcolo usato per ottenere
il CF è $1 - \frac{costo - budget}{soglia}$. In caso di valori al di fuori del
range [-1, 1], si assegna al CF -1 o 1 a seconda del caso.

Una volta creati i CF basati sull'occupazione e il budget, il modulo li combina
in un unico CF che rappresenta la preferenza complessiva per una certa lista di
alberghi. Questo avviene nella regola `alberghi-preferiti`. Il CF è combinato
eseguendo il minimo tra i due CF. Questo viene fatto affinché il CF riguardante
il budget abbia più peso quando negativo, dato che il CF sull'occupazione è
sempre positivo.

Una volta creati i CF, il focus passa al modulo `REASONING-ALBERGHI`, che
contiene la regola `scegli-lista-alberghi-per-cf-maggiore`. La regola, per ogni
itinerario, trova la lista di alberghi relativa all'itinerario a cui è stato
assegnato il CF massimo. Una volta trovata, il fatto `itinerario`
corrispondente viene modificato per incorporare le informazioni sulla lista di
alberghi trovata.

```
(modify ?itinerario
  (alberghi (fact-slot-value ?lista-alberghi-migliore alberghi))
  (pernottamenti (fact-slot-value ?lista-alberghi-migliore pernottamenti))
  (costo (fact-slot-value ?lista-alberghi-migliore costo))
)
```

Inoltre, per non perdere il CF assegnato alla lista di alberghi, lo riasserisce
con un nuovo nome e associandolo all'itinerario:

```
(assert
  (attribute
    (name itinerario-preferito-per-alberghi)
    (value ?id-itinerario)
    (certainty ?max-certainty)
  )
)
```

A questo punto, il template `alberghi-per-itinerario` non viene più usato
all'interno del programma, e si procede a lavorare soltanto con `itinerario`.

## Valutazione delle località

Dopo la valutazione degli alberghi, si passa al modulo `REGOLE-LOCALITÀ`, che
si occupa di assegnare un CF a ogni località in base alle preferenze indicate
dall'utente. Il punteggio è valutato in base a:

- i tipi di turismo che l'utente ha indicato come preferiti
- le regioni che l'utente ha indicato come da includere
- le regioni che l'utente ha indicato come da escludere

I tipi di turismo sono gestiti dalla regola `località-preferita-per-turismo`,
che per ogni tipo di turismo specificato dall'utente trova le località che
specificano un punteggio per questo. Una volta trovate, la regola assegna un CF
pari a $\frac{punteggio}{5}$ alla località corrispondente.

```
(defrule località-preferita-per-turismo
  (query (turismo $? ?tipo $?))
  (località
    (nome ?nome)
    (turismo $? ?tipo&:(symbolp ?tipo) ?punteggio&:(numberp ?punteggio) $?))
  =>
    (assert
      (attribute
        (name località-preferita-per-turismo)
        (value ?nome)
        (certainty (da-punteggio-turismo-località-a-cf ?punteggio)))))
```

Questa regola asserisce un `attribute` con `name`
`località-preferita-per-turismo` per ogni tipo di turismo della località. Si
può dire quindi che la preferenza per la località in base al turismo sia
derivabile tramite path distinti, uno per ogni tipo di turismo specificato, che
vengono poi combinati insieme tramite le regole di combinazione degli
`attribute` specificate nel modulo `MAIN`.

Lo stesso discorso si applica per la preferenza sulle regioni, che vengono
gestite dalle regole `località-preferita-per-regioni-incluse` e la controparte
per quelle escluse.

```
(defrule località-preferita-per-regioni-incluse
  (query (regioni-da-includere $? ?regione $?))
  (località (nome ?nome) (lat ?lat-località) (lon ?lon-località))
  (regione (nome ?regione) (lat ?lat-regione) (lon ?lon-regione) (raggio ?raggio))
  =>
  (bind ?punteggio
    (punteggio-distanza-da-area
      ?lat-località ?lon-località ?lat-regione ?lon-regione ?raggio))
  (assert (attribute (name località-preferita-per-regione)
                     (value ?nome)
                     (certainty (- 1 ?punteggio)))))
```

Per ogni regione da includere specificata dall'utente e ogni località, la
regola va a verificare se la località è all'interno della regione. Se lo è,
assegna CF 1, altrimenti 0.

La regola può anche assegnare dei valori intermedi, nel caso la località sia di
poco distante dalla regione. Di base, si considera una soglia di
distanza entro cui la località viene considerata vicina, e se la località si
trova all'interno della circonferenza con lo stesso centro della regione e con
il raggio uguale a quello della regione più la soglia di vicinanza, la località
è considerata vicina e riceve un CF tra 0 e 1. Il punteggio è uguale al
rapporto tra la distanza della località dal confine della regione, e la soglia
di vicinanza, confinato tra 0 e 1.

```
(limita 0 1 (/ ?distanza-da-confine-regione ?*SOGLIA-DISTANZA-REGIONE*))
```

La regola `località-preferita-per-regioni-escluse` funziona allo stesso modo,
ma assegna il valore negato del punteggio ottenuto.

Una volta eseguite queste operazioni, il focus passa al modulo
`REASONING-LOCALITÀ`. In questo modulo, si prendono i CF relativi alla
preferenza per la località, e si combinano tra loro asserendo per ognuno di
questi il CF `località-preferita`.

```
(defrule località-preferita
  (attribute
    (name 
    ?name&località-preferita-per-regione|località-preferita-per-turismo)
    (value ?località)
    (certainty ?cert))
  =>
  (assert
    (attribute
      (name località-preferita)
      (value ?località)
      (certainty ?cert))))
```

Si è scelto di di riasserire i CF con nome diverso invece di asserire
direttamente il CF `località-preferita` in precedenza perché ci è sembrato più
corretto specificare esplicitamente il meccanismo in base a cui i CF vengono
combinati.

## Valutazione degli itinerari e stampa dei risultati

Si procede infine al modulo `REASONING-ITINERARIO`, che contiene la regola per
valutare ogni itinerario. A ogni itinerario viene assegnato un CF basato su
quelli assegnati per la preferenza sugli alberghi e sulle località, che vengono
combinati facendo una media tra questi.

```
(assert
  (attribute
    (name itinerario-preferito)
    (value ?id-itinerario)
    (certainty (+ (* 0.5 ?cert-per-località) (* 0.5 ?cert-per-alberghi)))))
```

Una volta assegnato il CF finale per ogni itinerario, il focus passa al modulo
`PRINT-RESULTS`, che stampa i risultati ottenuti.

Gli itinerari vengono stampati in ordine di certezza. La logica secondo cui si
sceglie quanti risultati stampare è la seguente:

- si stampano sempre i primi due itinerari ottenuti.
- si stampano gli altri risultati se hanno CF > 0.

Ci sono anche casi in cui la query dell'utente è troppo restrittiva, e non ci
sono risultati stampabili o ve ne è soltanto 1 (es. se non ci sono alberghi con
abbastanza camere da accomodare il numero di persone richiesto dall'utente).

Assegnando il valore `TRUE` alla variabile globale `?*DEBUG*`, il programma
stampa anche la lista dei CF assegnati nel corso dell'esecuzione.

Una volta terminata la stampa, il programma esegue la regola `restart`,
definita con salience bassa, che esegue il `reset` e riporta il focus su
`MAIN`, in modo da permettere all'utente di eseguire una nuova query.

```
(defrule restart
  (declare (salience ?*min-salience*))
  =>
  (reset)
  (focus MAIN))
```
