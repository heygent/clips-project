(defmodule MAIN (export ?ALL))

(defglobal ?*DEBUG* = TRUE)

(deftemplate query
    (slot durata (default 5))
    (slot numero-persone)
    (slot numero-città (default 4))
    (multislot regioni-da-includere)
    (multislot regioni-da-escludere)
    (multislot turismo)
    (slot budget))

(deftemplate attribute
    (slot name)
    (slot value)
    (slot certainty))

(defrule start
  (declare (salience 10000))
  =>
  (set-fact-duplication TRUE)
  (focus DOMINIO DOMINIO-ITINERARI DOMINIO-ALBERGHI-PER-ITINERARIO REGOLE REASONING PRINT-RESULTS))

(deffunction da-stelle-a-prezzo
  (?stelle)
  (+ 25 (* ?stelle 25))
  )

(deffunction limita (?min ?max ?num)
  "Confina il valore di ?num tra ?min e ?max."
  (min ?max (max ?min ?num)))

(deffunction combined-certainty
  (?cert1 ?cert2)
  (if (and (>= ?cert1 0) (>= ?cert2 0)) then
    (return (- (+ ?cert1 ?cert2) (* ?cert1 ?cert2))))
  (if (and (<= ?cert1 0) (<= ?cert2 0)) then
    (return (+ (+ ?cert1 ?cert2) (* ?cert1 ?cert2))))
  (/ (+ ?cert1 ?cert2) (- 1 (min (abs ?cert1) (abs ?cert2)))))

(defrule combine-certainties
  (declare (salience 100)
           (auto-focus TRUE))
  ?rem1 <- (attribute (name ?rel) (value ?val) (certainty ?cert1))
  ?rem2 <- (attribute (name ?rel) (value ?val) (certainty ?cert2))
  (test (neq ?rem1 ?rem2))
  =>
  (if ?*DEBUG* then
    (printout t "defrule combine-certainties" crlf)
    (printout t "name: " ?rel crlf)
    (printout t "value: " ?val crlf)
    (printout t "certainty 1: " ?cert1 crlf)
    (printout t "certainty 2: " ?cert2 crlf)
    (printout t "combined: " (combined-certainty ?cert1 ?cert2) crlf)
    (printout t crlf)
  )
  (retract ?rem1)
  (modify ?rem2 (certainty (combined-certainty ?cert1 ?cert2))))

(defmodule DOMINIO (export ?ALL)(import MAIN ?ALL))

(deftemplate località "località turistica"
    (slot nome)
    (slot lat)
    (slot lon))

(deftemplate regione
    (slot nome)
    (slot lat)
    (slot lon)
    (slot raggio))

(deftemplate località-tipo-turismo
    (slot nome-località)
    (slot tipo)
    (slot punteggio))

(deffunction punteggio-località-to-cf (?punteggio)
    (- (/ (* ?punteggio 2) 5) 1))

(deftemplate albergo
    (slot id)
    (slot località)
    (slot stelle (type INTEGER))
    (slot camere-libere)
    (slot occupazione (type FLOAT)))

(deftemplate itinerario
  (slot id)
  (multislot località)
)

(deftemplate alberghi-per-itinerario
  (slot id)
  (slot id-itinerario)
  (multislot alberghi)
  (slot definitivo (default FALSE))
)

(deftemplate pernottamenti-per-itinerario
  (slot id-itinerario)
  (slot id-alberghi-per-itinerario)
  (multislot pernottamenti)
)

(deffacts query
  (query
   (budget 500)
   (numero-persone 1)
   (numero-città 3)
   (turismo balneare)
   (regioni-da-includere Piemonte Lombardia Marche Puglia)
   )
  )

(deffacts località-tipo-turismo
    (località-tipo-turismo
      (nome-località Torino)
      (tipo balneare)
      (punteggio 3))
    (località-tipo-turismo (nome-località Torino) (tipo balneare) (punteggio 3))
    (località-tipo-turismo (nome-località Milano) (tipo balneare) (punteggio 2))
    (località-tipo-turismo (nome-località MonculoPiemontese) (tipo balneare) (punteggio 4))
    (località-tipo-turismo (nome-località Macerata) (tipo balneare) (punteggio 1))
    (località-tipo-turismo (nome-località Camerino) (tipo balneare) (punteggio 2))
    (località-tipo-turismo (nome-località acquasparta) (tipo balneare) (punteggio 4))
    (località-tipo-turismo (nome-località ColonettaDiProdo) (tipo balneare) (punteggio 5))
    (località-tipo-turismo (nome-località Foggia) (tipo balneare) (punteggio 3))
    (località-tipo-turismo (nome-località OrtaNova) (tipo balneare) (punteggio 2))
    (località-tipo-turismo (nome-località DuaneraLaRocca) (tipo balneare) (punteggio 5))
    (località-tipo-turismo (nome-località Zapponeta) (tipo balneare) (punteggio 4))
)

;LATITUDINE        LONGITUDINE
;EST 50 100       SUD 0 -100
;CENTRO 0 50      CENTRO 0 100
;OVEST -50 0      NORD 100 200
(deffacts località
    (località (nome Torino) (lat -30) (lon 150))
    (località (nome Milano) (lat 20) (lon 150))
    (località (nome MonculoPiemontese) (lat -50) (lon 188))
    (località (nome Macerata) (lat 80 ) (lon 80))
    (località (nome Camerino) (lat 80) (lon 70))
    (località (nome acquasparta) (lat 70 ) (lon 60))
    (località (nome ColonettaDiProdo)(lat 75) (lon 50))
    (località (nome Foggia) (lat 80) (lon -50))
    (località (nome OrtaNova) (lat 70) (lon -80))
    (località (nome DuaneraLaRocca) (lat 20) (lon -10))
    (località (nome Zapponeta) (lat 10) (lon -100))
    )

(deffacts alberghi
    (albergo (id Torino1) (località Torino) (stelle 4) (camere-libere 5) (occupazione 0.3))
    (albergo (id Torino2) (località Torino) (stelle 2) (camere-libere 5) (occupazione 0.7))
    (albergo (id Milano1) (località Milano) (stelle 4) (camere-libere 5) (occupazione 0.7))
    (albergo (id Milano2) (località Milano) (stelle 2) (camere-libere 5) (occupazione 0.5))
    (albergo (id MonculoPiemontese1) (località MonculoPiemontese) (stelle 4) (camere-libere 5) (occupazione 0.5))
    (albergo (id MonculoPiemontese2) (località MonculoPiemontese) (stelle 2) (camere-libere 5) (occupazione 0.7))
    (albergo (id Macerata1) (località Macerata) (stelle 4) (camere-libere 1) (occupazione 0.7))
    (albergo (id Macerata2) (località Macerata) (stelle 2) (camere-libere 1) (occupazione 0.3))
    (albergo (id Camerino1) (località Camerino) (stelle 4) (camere-libere 1) (occupazione 0.5))
    (albergo (id Camerino2) (località Camerino) (stelle 2) (camere-libere 1) (occupazione 0.7))
    (albergo (id acquasparta1) (località acquasparta) (stelle 4) (camere-libere 1) (occupazione 0.7))
    (albergo (id acquasparta2) (località acquasparta) (stelle 2) (camere-libere 1) (occupazione 0.3))
    (albergo (id ColonettaDiProdo1) (località ColonettaDiProdo)(stelle 4) (camere-libere 1) (occupazione 0.7))
    (albergo (id ColonettaDiProdo2) (località ColonettaDiProdo)(stelle 2) (camere-libere 1) (occupazione 0.7))
    (albergo (id Foggia1) (località Foggia) (stelle 4) (camere-libere 1) (occupazione 0.5))
    (albergo (id Foggia2) (località Foggia) (stelle 2) (camere-libere 1) (occupazione 0.7))
    (albergo (id OrtaNova1) (località OrtaNova) (stelle 4) (camere-libere 1) (occupazione 0.3))
    (albergo (id OrtaNova2) (località OrtaNova) (stelle 2) (camere-libere 1) (occupazione 0.7))
    (albergo (id DuaneraLaRocca1) (località DuaneraLaRocca) (stelle 4) (camere-libere 1) (occupazione 0.5))
    (albergo (id DuaneraLaRocca2) (località DuaneraLaRocca) (stelle 2) (camere-libere 1) (occupazione 0.7))
    (albergo (id Zapponeta1) (località Zapponeta) (stelle 4) (camere-libere 1) (occupazione 0.5))
    (albergo (id Zapponeta2) (località Zapponeta) (stelle 2) (camere-libere 1) (occupazione 0.3))
    )

(deffacts regioni
    (regione
        (nome Piemonte)
        (lat -30)
        (lon 140)
        (raggio 30))
    (regione
        (nome Lombardia)
        (lat 30)
        (lon 150)
        (raggio 30))
    (regione
        (nome Marche)
        (lat 90)
        (lon 90)
        (raggio 30))
    (regione
        (nome Puglia)
        (lat 70)
        (lon -30)
        (raggio 30))
)

(defmodule DOMINIO-ITINERARI (export ?ALL) (import MAIN ?ALL) (import DOMINIO ?ALL))

(deffunction distanza-coordinate (?x1 ?y1 ?x2 ?y2)
    (sqrt (+ (** (- ?x1 ?x2) 2) (** (- ?y1 ?y2) 2))))

(deffunction sort-cmp-string
  (?a ?b)
  (> (str-compare ?a ?b) 0))

(defglobal ?*SOGLIA-LOCALITÀ-VICINA* = 100)

(deffunction last
  (?multifield)
  (nth$ (length$ ?multifield) ?multifield))

(deffunction asserisci-itinerari
  (?lista-località-itinerario ?lunghezza-itinerario)
  (if (< (length$ ?lista-località-itinerario) ?lunghezza-itinerario)
    then
    (do-for-all-facts
      ((?località-partenza località) (?località-destinazione località))
      (and
        (eq ?località-partenza:nome (last ?lista-località-itinerario))
        (<
          (distanza-coordinate
            ?località-partenza:lat
            ?località-partenza:lon
            ?località-destinazione:lat
            ?località-destinazione:lon)
          ?*SOGLIA-LOCALITÀ-VICINA*)
        (not (member$ ?località-destinazione:nome ?lista-località-itinerario))
      )
      (asserisci-itinerari
        (create$ ?lista-località-itinerario ?località-destinazione:nome)
        ?lunghezza-itinerario
      )
    )
    else
    (assert
      (itinerario
        (id (implode$ (sort sort-cmp-string ?lista-località-itinerario)))
        (località ?lista-località-itinerario)
      )
    )
  )
)

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

(defmodule DOMINIO-ALBERGHI-PER-ITINERARIO (export ?ALL) (import MAIN ?ALL) (import DOMINIO ?ALL))

(deffunction crea-lista-alberghi
  (?id-itinerario ?lista-località ?lista-alberghi)
  (if (eq (length$ ?lista-località) (length$ ?lista-alberghi))
    then
    (if ?*DEBUG* then
      (printout t "deffunction crea-lista-alberghi" crlf)
      (printout t "Itinerario: " ?id-itinerario crlf)
      (printout t "Lista alberghi: " (implode$ ?lista-alberghi) crlf crlf)
    )
    (assert
      (alberghi-per-itinerario
        (id (implode$ ?lista-alberghi))
        (id-itinerario ?id-itinerario)
        (alberghi ?lista-alberghi)))
    else
    (bind ?nome-località-successiva
      (nth$
        (+ 1 (length$ ?lista-alberghi))
        ?lista-località
      )
    )
    (do-for-all-facts ((?albergo albergo))
      (eq ?albergo:località ?nome-località-successiva)
      (crea-lista-alberghi
        ?id-itinerario
        ?lista-località
        (create$ ?lista-alberghi ?albergo:id))
    )
  )
)

(defrule crea-liste-alberghi
  (itinerario (id ?id-itinerario) (località $?lista-località))
=>
  (crea-lista-alberghi ?id-itinerario ?lista-località (create$))
)

(defrule cf-alberghi-per-occupazione
  (alberghi-per-itinerario (id ?id) (alberghi $?lista-alberghi))
=>
  (bind ?occupazione-minore 1.0)

  (foreach ?albergo ?lista-alberghi
    (do-for-fact
      ((?alb albergo))
      (and
        (eq ?alb:id ?albergo)
        (< ?alb:occupazione ?occupazione-minore))
      (bind ?occupazione-minore ?alb:occupazione)
    )
  )

  (assert
    (attribute
      (name alberghi-preferiti-per-occupazione)
      (value ?id)
      (certainty (- 1 ?occupazione-minore))
    ))
)

(defrule elimina-alberghi-per-disponibilità
  (alberghi-per-itinerario
    (id ?id)
    (alberghi $?lista-alberghi)
  )
  (query (numero-persone ?persone))
=>
  (bind ?camere-necessarie (+ (div ?persone 2) (mod ?persone 2)))

  (foreach ?albergo ?lista-alberghi

    (do-for-fact ((?alb albergo)) (eq ?alb:id ?albergo)
      (if (> ?camere-necessarie ?alb:camere-libere) then
        (do-for-fact ((?lista alberghi-per-itinerario)) (eq ?lista:id ?id)
          (retract ?lista)
        )
      )
    )
  )
)

(defrule pernottamenti
  (alberghi-per-itinerario
    (id ?id)
    (id-itinerario ?id-itinerario)
    (alberghi $?id-alberghi))
  (query (durata ?giorni))
=>
  (bind ?min-occupazione 1)
  (bind ?indice-min-albergo 0)

  (foreach ?id-albergo ?id-alberghi do
    (do-for-fact ((?albergo albergo)) (eq ?albergo:id ?id-albergo)
      (if (< ?albergo:occupazione ?min-occupazione) then
        (bind ?min-occupazione ?albergo:occupazione)
        (bind ?indice-min-albergo ?id-albergo-index))
    )
  )

  (bind ?pernottamenti (create$))

  (bind ?giorni-divisi-equamente (div ?giorni (length ?id-alberghi)))
  (bind ?giorni-rimanenti (mod ?giorni (length ?id-alberghi)))

  (foreach ?x ?id-alberghi do
    (bind ?pernottamenti (create$ ?pernottamenti ?giorni-divisi-equamente))
  )

  (bind ?pernottamenti
    (replace$ ?pernottamenti ?indice-min-albergo ?indice-min-albergo
      (+ ?giorni-divisi-equamente ?giorni-rimanenti)))

  (assert
    (pernottamenti-per-itinerario
      (id-itinerario ?id-itinerario)
      (id-alberghi-per-itinerario ?id)
      (pernottamenti ?pernottamenti)))
)

(defrule stampa-pernottamenti
  (pernottamenti-per-itinerario
    (id-alberghi-per-itinerario ?id-alb-per-it) (pernottamenti $?pernottamenti))
  (alberghi-per-itinerario
    (id ?id-alb-per-it) (alberghi $?alberghi))
=>
  (assert
    (attribute
      (name pernottamenti-per-itinerario)
      (value (str-cat (implode$ ?alberghi) " -> " (implode$ ?pernottamenti)))
      (certainty 1)

      ))
)

(defglobal ?*SOGLIA-MAX-SUPERAMENTO-PREZZO* = 50)

(defrule alberghi-preferiti-per-budget
  (query (budget ?budget) (numero-persone ?persone))
  (alberghi-per-itinerario (id ?id) (alberghi $?id-alberghi))
  (pernottamenti-per-itinerario
    (id-alberghi-per-itinerario ?id)
    (pernottamenti $?pernottamenti))
  =>
  (bind ?camere-necessarie (+ (div ?persone 2) (mod ?persone 2)))
  (bind ?costo-totale 0)

  (foreach ?id-albergo ?id-alberghi
    (do-for-fact ((?albergo albergo))
      (eq ?albergo:id ?id-albergo)
      (bind ?pernottamenti-albergo (nth$ ?id-albergo-index ?pernottamenti))
      (bind ?costo-albergo
        (*
          (da-stelle-a-prezzo ?albergo:stelle)
          ?camere-necessarie
          ?pernottamenti-albergo))
      (bind ?costo-totale (+ ?costo-totale ?costo-albergo)))
  )

  ; 1 - (costo - budget) / soglia
  (bind ?certainty
     (limita -1 1
       (- 1 (/ (- ?costo-totale ?budget) ?*SOGLIA-MAX-SUPERAMENTO-PREZZO*))))

  (if ?*DEBUG* then
    (printout t "defrule alberghi-preferiti-per-budget" crlf)
    (printout t "Alberghi: " ?id crlf)
    (printout t "Costo totale: " ?costo-totale crlf)
    (printout t "Budget: " ?budget crlf)
    (printout t "CF: " ?certainty crlf)
    (printout t crlf)
  )

  (assert
    (attribute
      (name alberghi-preferiti-per-budget)
      (value ?id)
      (certainty ?certainty)))
)

(defrule alberghi-preferiti
  (attribute
    (name alberghi-preferiti-per-budget)
    (value ?id)
    (certainty ?certainty-budget))
  (attribute
    (name alberghi-preferiti-per-occupazione)
    (value ?id)
    (certainty ?certainty-occupazione))
=>
  (assert
    (attribute
      (name alberghi-preferiti)
      (value ?id)
      (certainty (min ?certainty-budget ?certainty-occupazione)))))

(defrule scegli-lista-alberghi-per-cf-maggiore
  ?itinerario <- (itinerario (id ?id-itinerario))
=>
  (bind ?max-certainty -2)
  (bind ?lista-alberghi-migliore nil)

  (do-for-all-facts
    ((?alb-per-it alberghi-per-itinerario) (?att attribute))
    (and
      (eq ?alb-per-it:id-itinerario ?id-itinerario)
      (eq ?att:name alberghi-preferiti)
      (eq ?att:value ?alb-per-it:id)
      (> ?att:certainty ?max-certainty)
    )
    (bind ?max-certainty ?att:certainty)
    (bind ?lista-alberghi-migliore ?alb-per-it)
  )
  (if (neq ?lista-alberghi-migliore nil)
    then
    (modify ?lista-alberghi-migliore (definitivo TRUE))
    else (retract ?itinerario)
  )
)

(defmodule REGOLE (export ?ALL) (import MAIN ?ALL) (import DOMINIO ?ALL)  (import DOMINIO-ITINERARI ?ALL))

(defglobal ?*MAX-DISTANZA* = 10)

(deffunction punteggio-distanza-da-area
  "
  Date le coordinate di una regione e di una località, e il raggio della
  circonferenza che rappresenta la regione, restituisce un numero da 0 a 1.
  0 significa che la località si trova all'interno della regione, 1 che ne è al
  di fuori. I valori intermedi rappresentano quanto è lontana la località dalla
  regione, dove un valore che tende a 1 indica una distanza tendente a
  ?*MAX-DISTANZA*.
  "
  (?x-località ?y-località ?x-regione ?y-regione ?raggio)
  (bind ?distanza-da-centro-regione
    (distanza-coordinate ?x-località ?y-località ?x-regione ?y-regione))
  (bind ?distanza-da-confine-regione (- ?distanza-da-centro-regione ?raggio))
  (limita 0 1 (/ ?distanza-da-confine-regione ?*MAX-DISTANZA*))
)

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

(defrule località-preferita-per-regioni-escluse
    (query (regioni-da-escludere $? ?regione $?))
    (località (nome ?nome) (lat ?lat-località) (lon ?lon-località))
    (regione (nome ?regione) (lat ?lat-regione) (lon ?lon-regione) (raggio ?raggio))
=>
    (bind ?punteggio
      (punteggio-distanza-da-area
        ?lat-località ?lon-località ?lat-regione ?lon-regione ?raggio))
    (assert (attribute (name località-preferita-per-regione)
                       (value ?nome)
                       (certainty (- ?punteggio 1)))))

(defrule località-preferita-per-turismo
    (query (turismo $? ?tipo-turismo $?))
    (località-tipo-turismo
      (nome-località ?nome)
      (tipo ?tipo-turismo)
      (punteggio ?punteggio))
=>
    (assert
      (attribute
        (name località-preferita-per-turismo)
        (value ?nome)
        (certainty (punteggio-località-to-cf ?punteggio)))))


(defmodule REASONING (export ?ALL) (import MAIN ?ALL) (import DOMINIO ?ALL)  (import DOMINIO-ITINERARI ?ALL) (import REGOLE ?ALL))

(defrule località-preferita-no-info
  (località (nome ?nome-località))
=>
  (assert
    (attribute
      (name località-preferita-per-regione)
      (value ?nome-località)
      (certainty 0)))
  (assert
    (attribute
      (name località-preferita-per-turismo)
      (value ?nome-località)
      (certainty 0)))
)

(defrule località-preferita
  (attribute
    (name località-preferita-per-regione)
    (value ?località)
    (certainty ?certezza-regione))
  (attribute
    (name località-preferita-per-turismo)
    (value ?località)
    (certainty ?certezza-turismo))
=>
  (assert
    (attribute
      (name località-preferita)
      (value ?località)
      (certainty (min ?certezza-regione ?certezza-turismo)))))


(defrule itinerario-preferito-per-località
  (itinerario (id ?id) (località $?lista-località))
  =>
  (do-for-all-facts ((?att attribute))
    (and
      (eq ?att:name località-preferita)
      (member$ ?att:value ?lista-località))
    (assert
      (attribute
        (name itinerario-preferito-per-località)
        (value ?id)
        (certainty ?att:certainty))
    )
  )
)

(defrule itinerario-preferito-per-alberghi
  (itinerario (id ?id-itinerario))
  (alberghi-per-itinerario
    (id-itinerario ?id-itinerario)
    (id ?id-alb-per-it)
    (definitivo TRUE))
  (attribute
    (name alberghi-preferiti)
    (value ?id-alb-per-it)
    (certainty ?cert))
=>
  (assert
    (attribute
      (name itinerario-preferito-per-alberghi)
      (value ?id-itinerario)
      (certainty ?cert)
    )
  )
)

(defrule itinerario-preferito
  (attribute
    (name itinerario-preferito-per-località)
    (value ?id-itinerario)
    (certainty ?cert-per-località))
  (attribute
    (name itinerario-preferito-per-alberghi)
    (value ?id-itinerario)
    (certainty ?cert-per-alberghi))
  =>

  (assert
    (attribute
      (name itinerario-preferito)
      (value ?id-itinerario)
      (certainty (min ?cert-per-località ?cert-per-alberghi))))
)

(defmodule PRINT-RESULTS (import MAIN ?ALL))

(defrule stampa-attributi
  ?rem <-
    (attribute
      (name ?name)
      (value ?value)
      (certainty ?certainty))
   ;(test (member$ ?name (create$ alberghi-per-itinerario itinerario-preferito itinerario-preferito-per-località itinerario-preferito-per-alberghi)))
   (test (member$ ?name (create$ itinerario-preferito)))
  =>
  ;(retract ?rem)
  (format t " %-40s %-30s %2f%n" ?name ?value ?certainty))
