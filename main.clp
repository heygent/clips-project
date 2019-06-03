(defmodule MAIN (export ?ALL))

(deftemplate query
    (slot durata)
    (slot numero-persone)
    (slot numero-città)
    (multislot regioni-da-includere)
    (multislot regioni-da-escludere)
    (multislot turismo)
    (slot budget))

(defmodule DOMINIO (export ?ALL))

(deftemplate località "località turistica"
    (slot nome)
    (slot regione)
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

(deffunction da-superficie-a-raggio (?superficie-in-km2)
    (/ (sqrt (* 1000 ?superficie-in-km2)) 2))

(deffacts regioni "AAAAAAAAAAAAAAAAAAAH"
    (regione 
        (nome Lombardia)
        (lat 45.6209)
        (lon 9.768893)
        (raggio (da-superficie-a-raggio 23863.65)))
    (regione
        (nome Piemonte)
        (lat 45.060735)
        (lon 7.923549)
        (raggio (da-superficie-a-raggio 25387.07)))
    (regione
        (nome Marche)
        (lat 43.3458388)
        (lon 13.1415872)
        (raggio (da-superficie-a-raggio 9401.38)))
    (regione
        (nome Puglia) 
        (lat 40.9842539)
        (lon 16.6210027)
        (raggio (da-superficie-a-raggio 19540.9)))
)

(defmodule REASONING (export deftemplate OAV))

(deftemplate attribute
    (slot name)
    (slot value)
    (slot certainty))

(defmodule REGOLE (export ?ALL))

(deffunction distanza-coordinate (?lat1 ?lon1 ?lat2 ?lon2)
    (bind ?phi1 (deg-rad ?lat1))
    (bind ?phi2 (deg-rad ?lat2))
    (bind ?dphi (deg-rad (- ?lat2 ?lat1)))
    (bind ?dlamb (deg-rad (- ?lon2 ?lon1)))
    (bind ?a
        (+ (* (sin (/ ?dphi 2)) (sin (/ ?dphi 2)))
           (* (cos ?phi1) (cos ?phi2) (sin (/ ?dlamb 2)) (sin (/ ?dlamb 2)))))
    (bind ?q (/ (sqrt ?a) (sqrt (- 1 ?a))))
    (bind ?c (* 2 (atan ?q)))
    (* 6371e3 ?c))

(defrule pappa "afadfas"
    (query (durata ?dur)) => (printout t "dafdfadaf"))

(defrule località-preferita-per-turismo
    (query (turismo $? ?tipo-turismo $?))
    (località-tipo-turismo (nome-località ?nome) (tipo ?tipo-turismo) (punteggio ?punteggio))
=>
    (assert (attribute (name località-preferita-per-turismo)
                       (value ?nome)
                       (certainty (punteggio-località-to-cf ?punteggio)))))

(bind ?MAX-DISTANZA 25000)

(defrule località-preferita-per-regioni-incluse
    (query (regioni-da-includere $? ?regione $?))
    (località (nome-località ?nome) (lat ?lat-località) (lon ?lon-località))
    (regione (lat ?lat-regione) (lon ?lon-regione) (raggio ?r))
=>  
    (bind ?distanza-da-regione (distanza-coordinate ?lat-località ?lon-località ?lat-regione ?lon-regione))
    (bind ?differenza-distanze (- ?r ?distanza-da-regione))
    (assert (attribute (name località-preferita-per-regioni-incluse)
                       (value ?nome)
                       (certainty 
                            (if (< ?differenza-distanze 0) then 1 else 
                            (if (> ?differenza-distanze ?MAX-DISTANZA) then -1 else 
                            (- 1 (* 2 (/ ?differenza-distanze ?MAX-DISTANZA)))))))))
