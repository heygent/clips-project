---
# vim: spell spelllang=it
title: Clips
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

# Esecuzione

Il programma viene eseguito nella REPL di CLIPS. Una volta eseguiti i comandi
`(load main.clp)`, `(reset)` e `(run)`, il programma mostra all'utente una
schermata di aiuto.

```
Benvenuto a DoveAndareVai©™, il sistema esperto per organizzare i tuoi viaggi.
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

CLIPS> (assert (query (giorni 3) (numero-persone 4) (budget 500) (regioni-da-includere Piemonte)))
<Fact-49>
CLIPS> (run)

La tua richiesta:

(query
   (giorni 3)
   (numero-persone 4)
   (numero-città 3)
   (regioni-da-includere Piemonte)
   (regioni-da-escludere)
   (turismo)
   (budget 500))

Abbiamo alcuni itinerari da suggerirti.

-- Itinerario 1 --
Costo totale: 450

Località            Albergo             Stelle    Notti
-------------------------------------------------------
Torino              Torino2             **        1
Milano              Milano2             **        1
LontanoPiemontese   LontanoPiemontese2  **        1

-- Itinerario 2 --
Costo totale: 550

Località            Albergo             Stelle    Notti
-------------------------------------------------------
LontanoPiemontese   LontanoPiemontese2  **        1
Milano              Milano2             **        1
Macerata            Macerata1           ****      1

-- Itinerario 3 --
Costo totale: 550

Località            Albergo             Stelle    Notti
-------------------------------------------------------
Milano              Milano2             **        1
Macerata            Macerata1           ****      1
ColonettaDiProdo    ColonettaDiProdo2   **        1

-- Itinerario 4 --
Costo totale: 550

Località            Albergo             Stelle    Notti
-------------------------------------------------------
Torino              Torino2             **        1
Milano              Milano2             **        1
Macerata            Macerata1           ****      1
```

Una volta terminato, il sistema mostra di nuovo la schermata di aiuto
all'utente, e permette di effettuare una nuova query con le stesse modalità
precedenti. L'utente può quindi raffinare la sua query aggiungendo nuovi
criteri, per poi far rieseguire la computazione.


