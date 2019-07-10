(defmodule MAIN (export ?ALL))

(defglobal
  ; Mostra o nasconde i messaggi di debug
  ?*DEBUG* = FALSE
  ; name degli attribute da stampare
  ?*DEBUG-ATTRIBUTE-NAMES* = (create$
     località-preferita-per-regione
     località-preferita-per-turismo
     località-preferita
     itinerario-preferito-per-località
     itinerario-preferito-per-alberghi
     alberghi-preferiti
     alberghi-preferiti-per-budget
     alberghi-preferiti-per-occupazione
     itinerario-preferito
   )
  ; Se la distanza di due località A e B è inferiore a questo numero, allora A
  ; può essere inclusa come tappa successiva di B in un itinerario e viceversa.
  ?*SOGLIA-LOCALITÀ-VICINA* = 100
  ; Se la località A è distante ?*SOGLIA-DISTANZA-REGIONE* o più dalla regione
  ; R, il suo punteggio sarà tendente a 1 o -1 (a seconda se R sia da escludere
  ; o includere). Se è meno distante, allora il suo punteggio sarà tra 0 e 1
  ; (oppure -1).
  ?*SOGLIA-DISTANZA-REGIONE* = 10
  ; Se il costo di un'itinerario supera di questo numero il budget dell'utente,
  ; il CF relativo all'itinerario in base al budget sarà 0. Se lo supera del
  ; doppio, il CF sarà -1 (anche i valori intermedi sono rappresentati nel CF).
  ?*SOGLIA-MAX-SUPERAMENTO-PREZZO* = 50
)

(defglobal
  ?*max-salience* = 10000
  ?*high-salience* = 1000
  ?*low-salience* = -1000
  ?*min-salience* = -10000
)

(defglobal
  ?*welcome-screen-shown* = FALSE)

(deftemplate query
  (slot giorni (type INTEGER) (range 1 ?VARIABLE) (default 5))
  (slot numero-persone (type INTEGER) (range 1 ?VARIABLE) (default 2))
  (slot numero-città (range 0 ?VARIABLE) (type INTEGER) (default 3))
  (multislot regioni-da-includere (type SYMBOL))
  (multislot regioni-da-escludere (type SYMBOL))
  (multislot turismo (type SYMBOL))
  (slot budget (type INTEGER) (range 0 ?VARIABLE) (default 10000))
)

(deftemplate attribute
  (slot name)
  (slot value)
  (slot certainty))

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

(defrule help
  (not (query))
  (test (eq ?*DEBUG* FALSE))
  =>
  (set-reset-globals FALSE)
  (if (not ?*welcome-screen-shown*) then
    (printout t "
  /$$$$$$$                                 /$$$$$$                  /$$                               /$$    /$$          /$$
 | $$__  $$                               /$$__  $$                | $$                              | $$   | $$         |__/
 | $$  \\ $$  /$$$$$$  /$$    /$$ /$$$$$$ | $$  \\ $$ /$$$$$$$   /$$$$$$$  /$$$$$$   /$$$$$$   /$$$$$$ | $$   | $$ /$$$$$$  /$$
 | $$  | $$ /$$__  $$|  $$  /$$//$$__  $$| $$$$$$$$| $$__  $$ /$$__  $$ |____  $$ /$$__  $$ /$$__  $$|  $$ / $$/|____  $$| $$
 | $$  | $$| $$  \\ $$ \\  $$/$$/| $$$$$$$$| $$__  $$| $$  \\ $$| $$  | $$  /$$$$$$$| $$  \\__/| $$$$$$$$ \\  $$ $$/  /$$$$$$$| $$
 | $$  | $$| $$  | $$  \\  $$$/ | $$_____/| $$  | $$| $$  | $$| $$  | $$ /$$__  $$| $$      | $$_____/  \\  $$$/  /$$__  $$| $$
 | $$$$$$$/|  $$$$$$/   \\  $/  |  $$$$$$$| $$  | $$| $$  | $$|  $$$$$$$|  $$$$$$$| $$      |  $$$$$$$   \\  $/  |  $$$$$$$| $$
 |_______/  \\______/     \\_/    \\_______/|__/  |__/|__/  |__/ \\_______/ \\_______/|__/       \\_______/    \\_/    \\_______/|__/

Benvenuto in DoveAndareVai©™, il sistema esperto per organizzare i tuoi viaggi.")
    (bind ?*welcome-screen-shown* TRUE)
  )
  (printout t "
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

"
  )
)

(deffunction combined-certainty
  "Date due certezze, restutuisce un unico fattore di certezza che rappresenta
  la loro combinazione."
  (?cert1 ?cert2)
  (if (and (>= ?cert1 0) (>= ?cert2 0)) then
    (return (- (+ ?cert1 ?cert2) (* ?cert1 ?cert2))))
  (if (and (<= ?cert1 0) (<= ?cert2 0)) then
    (return (+ (+ ?cert1 ?cert2) (* ?cert1 ?cert2))))
  ; Se un CF è -1 e l'altro è 1, la formula per la combinazione dei CF tenta
  ; una divisione per zero. Lo gestiamo come un caso particolare.
  (if (and (= (abs ?cert1) 1) (= (abs ?cert2) 1)) then
    (return 0)
  )
  (/ (+ ?cert1 ?cert2) (- 1 (min (abs ?cert1) (abs ?cert2)))))

(defrule combine-certainties
  "Se esiste una coppia di attribute con lo stesso name e value, combina le
  loro certezze."
  (declare (salience ?*high-salience*)
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

; Funzioni di utilità

(deffunction da-stelle-a-prezzo
  "Dato il numero di stelle di un albergo, restituisce il prezzo corrispondente"
  (?stelle)
  (+ 25 (* ?stelle 25)))

(deffunction costo-albergo
  "Calcola il costo totale di una prenotazione in un albergo."
  (?stelle ?camere ?pernottamenti)
  (*
    (da-stelle-a-prezzo ?stelle)
    ?camere
    ?pernottamenti
  )
)

(deffunction camere-per-persone
  "Dato un numero di persone, restituisce il numero di camere necessare da
  prenotare."
  (?persone)
  (+ (div ?persone 2) (mod ?persone 2))
)

(deffunction limita (?min ?max ?num)
  "Confina il valore di ?num tra ?min e ?max."
  (min ?max (max ?min ?num)))

(deffunction distanza-coordinate (?x1 ?y1 ?x2 ?y2)
  "Restituisce la distanza tra due coppie di coordinate."
  (sqrt (+ (** (- ?x1 ?x2) 2) (** (- ?y1 ?y2) 2))))

(deffunction compare-strings
  "Restituisce TRUE se ?a viene lessicograficamente prima di ?b. Scritta per
  essere usata con la funzione sort di clips."
  (?a ?b)
  (> (str-compare ?a ?b) 0))

(deffunction last
  "Dato un multifield, restituisce il suo ultimo valore."
  (?multifield)
  (nth$ (length$ ?multifield) ?multifield))

(defmodule DOMINIO (export ?ALL) (import MAIN ?ALL))

(defrule carica-dominio
  =>
  (load-facts dominio.txt)
)

(deftemplate località
  (slot nome)
  (slot lat)
  (slot lon)
  (multislot turismo)
)

(deftemplate regione
  (slot nome)
  (slot lat)
  (slot lon)
  (slot raggio)
)

(deftemplate albergo
  (slot id)
  (slot località)
  (slot stelle)
  (slot camere-libere)
  (slot occupazione)
)

(deftemplate itinerario
  (slot id)
  (multislot località)
  (multislot alberghi)
  (multislot pernottamenti)
  (slot costo)
)

(defmodule ITINERARI
  (import DOMINIO ?ALL))

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
    else
    (do-for-all-facts
      ((?località-partenza località) (?località-destinazione località))
      (and
        (eq ?località-partenza:nome (last ?lista-località-itinerario))
        ; Prendi località distanti al massimo ?*SOGLIA-LOCALITÀ-VICINA
        ; dall'ultima località.
        (<
          (distanza-coordinate
            ?località-partenza:lat
            ?località-partenza:lon
            ?località-destinazione:lat
            ?località-destinazione:lon)
          ?*SOGLIA-LOCALITÀ-VICINA*)
        ; Non mettere due volte la stessa località in un itinerario.
        (not (member$ ?località-destinazione:nome ?lista-località-itinerario))
      )
      (asserisci-itinerari
        (create$ ?lista-località-itinerario ?località-destinazione:nome)
        ?lunghezza-itinerario
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

(defmodule ALBERGHI-PER-ITINERARIO (export ?ALL) (import MAIN ?ALL) (import DOMINIO ?ALL))

(deftemplate alberghi-per-itinerario
  (slot id)
  (slot id-itinerario)
  (multislot alberghi)
  (multislot pernottamenti)
  (slot costo)
)

(deffunction crea-lista-alberghi
  (?id-itinerario ?lista-località ?camere-richieste ?lista-alberghi)
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
      (and
        (eq ?albergo:località ?nome-località-successiva)
        (>= ?albergo:camere-libere ?camere-richieste)
      )
      (crea-lista-alberghi
        ?id-itinerario
        ?lista-località
        ?camere-richieste
        (create$ ?lista-alberghi ?albergo:id))
    )
  )
)

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

(defrule pernottamenti
  ?alb-per-it <- (alberghi-per-itinerario
    (id ?id)
    (id-itinerario ?id-itinerario)
    (alberghi $?id-alberghi)
    (pernottamenti $?p&:(= (length ?p) 0))
  )
  (query (giorni ?giorni))
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

  (modify ?alb-per-it (pernottamenti ?pernottamenti))
)


(deffunction costo-totale-itinerario
  (?id-alberghi ?persone ?pernottamenti)
  (bind ?camere-necessarie (camere-per-persone ?persone))
  (bind ?costo-totale 0)
  (foreach ?id-albergo ?id-alberghi
    (do-for-fact ((?albergo albergo))
      (eq ?albergo:id ?id-albergo)
      (bind ?pernottamenti-albergo (nth$ ?id-albergo-index ?pernottamenti))
      (bind ?costo-albergo
        (costo-albergo
          ?albergo:stelle
          ?camere-necessarie
          ?pernottamenti-albergo
        )
      )
      (bind ?costo-totale (+ ?costo-totale ?costo-albergo)))
  )
  ?costo-totale
)

(defrule costo-alberghi-per-itinerario
  (query (numero-persone ?persone))
  ?alb-per-it <- (alberghi-per-itinerario
    (id ?id)
    (alberghi $?id-alberghi)
    (pernottamenti $?pernottamenti&:(> (length$ ?pernottamenti) 0))
    (costo nil)
  )
  =>
  (modify
    ?alb-per-it
    (costo (costo-totale-itinerario ?id-alberghi ?persone ?pernottamenti))
  )
)

(defmodule REGOLE-ALBERGHI
  (import DOMINIO deftemplate itinerario)
  (import ALBERGHI-PER-ITINERARIO ?ALL))

(defrule alberghi-preferiti-per-occupazione
  (alberghi-per-itinerario (id ?id) (alberghi $?lista-alberghi))
  =>
  (bind ?occupazione-minore 1)

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
    )
  )
)

(defrule alberghi-preferiti-per-budget
  (query (budget ?budget))
  (alberghi-per-itinerario
    (id ?id)
    (costo ?costo-totale))
  =>
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

(defmodule REASONING-ALBERGHI
  (import MAIN ?ALL)
  (import ALBERGHI-PER-ITINERARIO ?ALL))

(defrule scegli-lista-alberghi-per-cf-maggiore
  ?itinerario <- (itinerario (id ?id-itinerario) (costo nil))
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

  (if (eq ?lista-alberghi-migliore nil)
    ; Se non c'è una lista di alberghi corrispondente all'itinerario, elimino
    ; l'itinerario
    then
    (retract ?itinerario)
    else
    ; Imposta la lista di alberghi come definitiva.
    (modify ?itinerario
      (alberghi (fact-slot-value ?lista-alberghi-migliore alberghi))
      (pernottamenti (fact-slot-value ?lista-alberghi-migliore pernottamenti))
      (costo (fact-slot-value ?lista-alberghi-migliore costo))
    )
    ; Asserisco l'attribute qua per non perdere l'associazione tra l'itinerario
    ; e il CF (e non doverlo ricalcolare dopo).
    (assert
      (attribute
        (name itinerario-preferito-per-alberghi)
        (value ?id-itinerario)
        (certainty ?max-certainty)
      )
    )
  )
)

(defmodule REGOLE-LOCALITÀ (export ?ALL) (import MAIN ?ALL) (import DOMINIO ?ALL))

(deffunction punteggio-distanza-da-area
  "
  Date le coordinate di una regione e di una località, e il raggio della
  circonferenza che rappresenta la regione, restituisce un numero da 0 a 1.
  0 significa che la località si trova all'interno della regione, 1 che ne è al
  di fuori. I valori intermedi rappresentano quanto è lontana la località dalla
  regione, dove un valore che tende a 1 indica una distanza tendente a
  ?*SOGLIA-DISTANZA-REGIONE*.
  "
  (?x-località ?y-località ?x-regione ?y-regione ?raggio)
  (bind ?distanza-da-centro-regione
    (distanza-coordinate ?x-località ?y-località ?x-regione ?y-regione))
  (bind ?distanza-da-confine-regione (- ?distanza-da-centro-regione ?raggio))
  (limita 0 1 (/ ?distanza-da-confine-regione ?*SOGLIA-DISTANZA-REGIONE*))
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

(deffunction da-punteggio-turismo-località-a-cf
  (?punteggio)
  "Dato un punteggio da 0 a 5 per il turismo di una località, restituisce un
  valore di certezza corrispondente a quel turismo. Si considera un punteggio
  0 come neutro (che quindi restituirà come CF 0), e un punteggio al di sopra
  come positivo"
  (* ?punteggio (/ 1 5))
)

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


(defmodule REASONING-LOCALITÀ
  (import MAIN ?ALL)
  (import DOMINIO ?ALL))

(defrule località-preferita-no-info
  (località (nome ?nome-località))
  =>
  (assert
    (attribute
      (name località-preferita)
      (value ?nome-località)
      (certainty 0)))
)

(defrule località-preferita
  ?att <- (attribute
    (name ?name & località-preferita-per-regione | località-preferita-per-turismo)
    (value ?località)
    (certainty ?cert))
  =>
  (if ?*DEBUG* then
    (printout t "defrule località-preferita" crlf)
    (printout t ?name " " ?località " " ?cert crlf)
    (printout t crlf))

  (assert
    (attribute
      (name località-preferita)
      (value ?località)
      (certainty ?cert))))

(defmodule REGOLE-ITINERARIO
  (import MAIN ?ALL)
  (import DOMINIO deftemplate itinerario))

(defrule itinerario-preferito-per-località
  (itinerario (id ?id) (località $? ?località $?))
  (attribute
    (name località-preferita)
    (value ?località)
    (certainty ?cert)
  )
  =>
  (assert
    (attribute
      (name itinerario-preferito-per-località)
      (value ?id)
      (certainty ?cert))
  )
)

(defmodule REASONING-ITINERARIO
  (import MAIN ?ALL)
  (import DOMINIO deftemplate itinerario)
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
      (certainty (+ (* 0.5 ?cert-per-località) (* 0.5 ?cert-per-alberghi)))))
)

(defmodule PRINT-RESULTS (import MAIN ?ALL) (import DOMINIO ?ALL))

(deffunction compare-attributes-by-certainty
  (?it1 ?it2)
  (<
    (fact-slot-value ?it1 certainty)
    (fact-slot-value ?it2 certainty)
  )
)

(deffunction stampa-itinerario
  (?id-itinerario ?indice-itinerario)
  (do-for-fact ((?itinerario itinerario) (?query query))
    (eq ?itinerario:id ?id-itinerario)
    (bind ?camere (camere-per-persone ?query:numero-persone))

    (printout t "__Itinerario " ?indice-itinerario "__" crlf)
    (foreach ?id-albergo ?itinerario:alberghi
      (bind ?pernottamenti
        (nth$ ?id-albergo-index ?itinerario:pernottamenti))
      (do-for-fact
        ((?albergo albergo))
        (eq ?albergo:id ?id-albergo)
        (bind ?stelle-str "")
        (loop-for-count ?albergo:stelle do
          (bind ?stelle-str (str-cat ?stelle-str "* ")))
        (format t "%-20s%-20s%-10s%8g%10g%10g%n"
          ?albergo:località
          ?albergo:id
          ?stelle-str
          ?pernottamenti
          ?camere
          (costo-albergo ?albergo:stelle ?camere ?pernottamenti)
        )
      )
    )
    (format t "%-68s%10g%n" "Totale" ?itinerario:costo)
  )
)

(defrule stampa-itinerari-migliori
  ?query <- (query)
  =>
  (bind ?attribute-itinerari
    (find-all-facts ((?att attribute))
      (eq ?att:name itinerario-preferito)
    )
  )

  ; Ordina gli attribute in ordine decrescente di CF
  (bind ?attribute-itinerari
    (sort compare-attributes-by-certainty ?attribute-itinerari)
  )

  (printout t crlf "La tua richiesta:" crlf crlf)
  (ppfact ?query t FALSE)
  (printout t crlf)

  (if (> (length$ ?attribute-itinerari) 0)
    then
    (printout t "Abbiamo alcuni itinerari da suggerirti." crlf)

    (printout t crlf)
    (format t "%-21s%-20s%-10s%8s%10s%10s%n"
      "Località"
      "Albergo"
      "Stelle"
      "Notti"
      "Camere"
      "Costo"
    )
    (format t "%-20s%-20s%-10s%8s%10s%10s%n"
      "------------------"
      "-------------------"
      "---------"
      "-------"
      "---------"
      "---------"
    )
    else
    (printout t "Spiacente, il sistema non ha trovato risultati." crlf)
  )

  ; Stampa sempre i primi due risultati.
  ; Stampa i tre risultati successivi finché hanno certainty >= 0.
  (foreach ?att-itinerario (subseq$ ?attribute-itinerari 1 5)
    (if
      (and
        (< (fact-slot-value ?att-itinerario certainty) 0)
        (> ?att-itinerario-index 2)
      )
      then (break))
    (stampa-itinerario
      (fact-slot-value ?att-itinerario value)
      ?att-itinerario-index)
  )
)

(deffunction compare-attributes-by-value
  (?attr1 ?attr2)
  (compare-strings
    (fact-slot-value ?attr1 value)
    (fact-slot-value ?attr2 value)
  )
)

(defrule stampa-attribute
  (declare (salience ?*high-salience*))
  (test (eq ?*DEBUG* TRUE))
  =>
  (foreach ?name ?*DEBUG-ATTRIBUTE-NAMES*
    (printout t ?name crlf crlf)
    (format t "%-50s%10s%n" "value" "certainty")
    (printout t
      "------------------------------------------------- ----------" crlf
    )
    (bind ?attrs (find-all-facts ((?att attribute)) (eq ?att:name ?name)))
    (bind ?attrs (sort compare-attributes-by-certainty ?attrs))
    (foreach ?att ?attrs
      (format t "%-50s%10.2f%n"
        (fact-slot-value ?att value)
        (fact-slot-value ?att certainty))
    )
    (printout t crlf)
  )
)

(defrule restart
  (declare (salience ?*min-salience*))
  =>
  (reset)
  (focus MAIN))
