; Ciao!

(defmodule MAIN (export ?ALL))

(deftemplate località "località turistica"
    (slot nome)
    (slot regione)
    (slot lat)
    (slot lon)
)

(deftemplate turismo
    (slot città) 
    (slot balneare (default 0)) 
    (slot lacustre (default 0))
    (slot naturalistico (default 0))
    (slot termale  (default 0))
    (slot culturale (default 0))
    (slot religioso (default 0))
    (slot sportivo (default 0))
    (slot enogastronomico (default 0)) 
)

(deftemplate albergo
    (slot id)
    (slot città)
    (slot stelle)
    (slot costo)
    (slot posti-occupati) 
    (slot posti-totali)
)

(deftemplate preferenza
    (slot id-prenotazione)
    (slot mese-arrivo)
    (slot mese-partenza)
    (slot giorno-arrivo)
    (slot giorno-partenza)
    (slot città)
    (multislot turismo)
    (slot prezzo-massimo)
    (slot stelle-albergo)
    )

(deftemplate prenotazione
    (slot id-prenotazione)
    (slot numero-di-persone)
    (slot numero-di-città) 
    )

(deffacts località
    (località (nome torino) (lat 45.0677551) (lon 7.6824892))
    (località (nome milano) (lat 45.465454) (lon 9.186516))
    )
    
(deffacts turismo
    (turismo (città torino) (balneare 3))
    (turismo (città milano) (balneare 2))
    (turismo (città marina-di-lesina) (balneare 10))
    )

;(albergo città stelle costo posti-occupati post-totali)
(deffacts albergo
    (albergo (città torino) (stelle 3) (costo 50) (posti-occupati 100) (posti-totali 200))
    (albergo (città torino) (stelle 4) (costo 75) (posti-occupati 50) (posti-totali 80))
    (albergo (città torino) (stelle 5) (costo 100) (posti-occupati 150) (posti-totali 180))
    (albergo (città milano) (stelle 2) (costo 25) (posti-occupati 30) (posti-totali 50))
    (albergo (città milano) (stelle 1) (costo 5) (posti-occupati 60) (posti-totali 60))
    )

(deffacts prenotazione
    (prenotazione (id-prenotazione 1) (numero-di-persone 1) (numero-di-città 1))
    )


(deffacts preferenza
    (preferenza (id-prenotazione 1) (città torino))
    )

(deffacts adsf
  (tipo-turismo-richiesto balneare))

(deffacts pino
    (turismo (città torino) (balneare 3))
    (turismo (città milano) (balneare 2))
    (turismo (città marina-di-lesina) (balneare 10))
    )

(deffunction calcolo-posizione

    (?lat1 ?lon1 ?lat2 ?lon2)

    (bind ?phi1 (deg-rad ?lat1))
    (bind ?phi2 (deg-rad ?lat2))
    (bind ?dphi (deg-rad (- ?lat2 ?lat1)))
    (bind ?dlamb (deg-rad (- ?lon2 ?lon1))) 

    (bind ?a   
        (+  (* (sin (/ ?dphi 2))   (sin (/ ?dphi 2)) )
            (* (cos ?phi1) (cos ?phi2) (sin (/ ?dlamb 2)) (sin (/ ?dlamb 2))))   
      )

    (bind ?q
        (/ (sqrt ?a) (sqrt (- 1 ?a)))
        )

    (bind ?c
        (* 2 (atan ?q))
        )

    (* 6371e3 ?c)
    
  )

(defrule start => (focus SEARCH))

(defmodule SEARCH (import MAIN ?ALL) (export ?ALL))

(defrule trova-alberghi
    (prenotazione (id-prenotazione ?id))
    (preferenza (id-prenotazione ?id) (città ?cit))
    (località (nome ?cit) )
    (albergo (città ?cit) (costo ?costo) (posti-occupati ?occupati) (posti-totali ?totali))
    (test(< ?occupati ?totali))
    =>
    (printout t "puoi effettuare  una prenotazione a " ?cit " per un costo di " ?costo  crlf)
    )

(defrule stampa-tipo-turismo
  (tipo-turismo-richiesto ?tipo-turismo)
  ?tur <- (turismo (città ?città))
  =>
  (bind ?valore-tipo-turismo (fact-slot-value ?tur ?tipo-turismo))
  (printout t "Il voto per il tipo turismo " ?tipo-turismo " a " ?città " è " ?valore-tipo-turismo crlf)
  (printout t "check" crlf))
  
(defmodule CHECK (import MAIN ?ALL) (import SEARCH ?ALL))