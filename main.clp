(defmodule MAIN (export ?ALL))

(deftemplate query
    (slot durata)
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
  (focus DOMINIO REGOLE PRINT-RESULTS))

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
    (slot città)
    (slot stelle)
    (slot costo)
    (slot posti-liberi))

(deffacts query
    (query
      (numero-città 3)
      (turismo balneare)
      (regioni-da-includere Piemonte)
    )
  )

(deffacts località-tipo-turismo
    (località-tipo-turismo
      (nome-località Torino)
      (tipo balneare)
      (punteggio 3))
)

(deffacts località
    (località (nome Torino) (lat -150) (lon 150))
    (località (nome Milano) (lat 150) (lon 150))
    (località (nome MonculoPiemontese) (lat -150) (lon 187))
    (località (nome Macerata) (lat -140) (lon -150))
    (località (nome Camerino) (lat -100) (lon -150))
    (località (nome acquasparta) (lat 50) (lon -120))
    (località (nome ColonettaDiProdo)(lat 75) (lon -100))
    (località (nome Foggia) (lat 150) (lon -150))
    (località (nome OrtaNova) (lat 249) (lon -150))
    (località (nome DuaneraLaRocca) (lat 348) (lon -150))
    (località (nome Zapponeta) (lat 448) (lon -150))
    )

(deffacts regioni
    (regione
        (nome Piemonte)
        (lat -150)
        (lon 150)
        (raggio 30))
    (regione
        (nome Lombardia)
        (lat 150)
        (lon 150)
        (raggio 30))
    (regione
        (nome Marche)
        (lat -150)
        (lon -150)
        (raggio 30))
    (regione
        (nome Puglia)
        (lat 150)
        (lon -150)
        (raggio 30))
)

(defmodule REGOLE (export ?ALL) (import MAIN ?ALL) (import DOMINIO ?ALL))

(deffunction distanza-coordinate (?x1 ?y1 ?x2 ?y2)
    (sqrt (+ (** (- ?x1 ?x2) 2) (** (- ?y1 ?y2) 2))))

(defrule località-preferita-per-turismo
    (query (turismo $? ?tipo-turismo $?))
    (località-tipo-turismo (nome-località ?nome) (tipo ?tipo-turismo) (punteggio ?punteggio))
=>
    (assert (attribute (name località-preferita-per-turismo)
                       (value ?nome)
                       (certainty (punteggio-località-to-cf ?punteggio)))))

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

(deffunction limita (?min ?max ?num)
  "Confina il valore di ?num tra ?min e ?max."
  (min ?max (max ?min ?num)))

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

(deftemplate itinerario
  (slot id)
  (multislot località)
)

(defrule inizia-itinerario
  (località (nome ?nome-località))
=>
  (assert (itinerario (id ?nome-località) (località ?nome-località)))
)

(defrule continua-itinerario
  (query (numero-città ?numero-città))
  (itinerario
    (id ?id)
    (località $?località-itinerario ?ultima-località))
  (località (nome ?ultima-località) (lat ?lat1) (lon ?lon1))
  (località (nome ?nuova-località) (lat ?lat2) (lon ?lon2))
  (test (< (+ 1 (length$ $?località-itinerario)) ?numero-città))
  (test (neq ?ultima-località ?nuova-località))
  (test (not (member$ ?nuova-località ?località-itinerario)))
  (test (< (distanza-coordinate ?lat1 ?lon1 ?lat2 ?lon2) 100))
=>
  (bind ?nuove-località (create$ ?località-itinerario ?ultima-località ?nuova-località))
  (assert (itinerario
    (id (implode$ ?nuove-località))
    (località ?nuove-località)))
)

(defrule pulisci-itinerari-incompleti
  (declare (salience -10))
  (query (numero-città ?numero-città))
  ?it <- (itinerario (località $?località))
  (test (< (length$ ?località) ?numero-città))
=>
  (retract ?it))

;(defrule itinerario-preferito-per-località-start
;  (declare (salience -101))
;  (itinerario (id ?id))
;=>
;  (assert (attribute
;            (name itinerario-preferito-per-località)
;            (value ?id)
;            (certainty 1))))

;(defrule itinerario-preferito-per-località
;  (declare (salience -102))
;  (itinerario
;    (id ?id)
;    (località $?località-iniziali ?località-corrente $?località-finali))
;  (attribute
;    (name località-preferita)
;    (value ?località-corrente)
;    (certainty ?certezza-località))
;  ?att <- (exists (attribute
;    (name itinerario-preferito-per-località)
;    (value ?id)))
;  =>
;  (printout t "Regola attivata" crlf)
;  (modify ?att (certainty (min (fact-slot-value ?att certainty) ?certezza-località))))

(defrule itinerario-preferito-per-località
  (declare (salience -103))
  (itinerario (id ?id) (località $?lista-località))
  =>
  (printout t "Regola attivata")
  (bind ?certezza 1)
  (do-for-all-facts ((?att attribute))
    (and
      (= ?att:name località-preferita)
      (member$ ?att:value ?lista-località))
    (bind ?certezza (min (fact-slot-value ?att certainty) ?certezza)))
  (assert (attribute (name itinerario-preferito-per-località) (value ?id) (certainty ?certezza))
  ))

; (defrule itinerario-preferito-per-località
;   (itinerario
;     (id ?id-it-nuovo)
;     (località $?località-itinerario ?nuova-località))
;   (itinerario
;     (id ?id-it-precedente)
;     (località $?località-itinerario))
;   (attribute
;     (name itinerario-preferito-per-località)
;     (value ?id-it-precedente)
;     (certainty ?certezza-precedente))
;   (attribute
;     (name località-preferita)
;     (value ?ultima-località)
;     (certainty ?certezza-nuova-località))
; =>
;   (assert (attribute itinerario-preferito-per-località)
;           (value ?id-it-nuovo)
;           (certainty (min ?certezza-nuova-località ?certezza-precedente))))
;

(defrule itenerario-attribute
  (declare (salience -100))
  (itinerario (id ?id))
  =>
  (assert (attribute (name itinerario-preferito)
                    (value ?id)
                    (certainty 1))))


(defmodule PRINT-RESULTS (import MAIN ?ALL))

(defrule stampa-attributi
  ?rem <-
    (attribute
      (name ?name)
      (value ?value)
      (certainty ?certainty))
  ; (test (eq itinerario-preferito ?name))
  =>
  ;(retract ?rem)
  (format t " %-40s %-30s %2f%n" ?name ?value ?certainty))
