; Ciao!

(deftemplate località "località turistica"
    (slot nome)
    (slot regione)
    (slot lat)
    (slot lon)
    (multislot turismo)
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

(deffacts voto
    (voto torino  balneare  0 )
    (voto torino  sessuale  grande)
    (voto milano  sanitario  10)
)

(deffacts località
    (località (nome torino) (lat 45.0677551) (lon 7.6824892) (turismo balneare))
    (località (nome milano) (lat 45.465454) (lon 9.186516) (turismo sanitario))
)

(deffacts prenotazione
    (prenotazione (id-prenotazione 1) (numero-di-persone 1) (numero-di-città 1))
)

(deffacts preferenza
    (preferenza (id-prenotazione 1) (città torino))
)

;(albergo città stelle costo posti-occupati post-totali)
(deffacts albergo
    (albergo torino 3 50 100 200 )
    (albergo torino 4 75 50 100) 
    (albergo torino 5 100 130 130)
    (albergo milano 3 50 12 50)
    (albergo milano 5 100 1 80)
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

;(deffunction distanza ()

  
 ; (printout t "queste so le coordinate" ?nome1 ?nome crlf)
  
;)

(defrule dammivoto
    (voto ?nome ?tipo ?val)
=>
    (printout t "ecco i voto " ?nome ?tipo  ?val crlf)
)

(defrule find_data
(località)
=>)

(defrule  trova-alberghi
    (prenotazione (id-prenotazione ?id))
    (preferenza (id-prenotazione ?id) (città ?cit))
    (località (nome ?cit) )
    (albergo  ?cit ? ? ?occupati ?totali) 
    (test(< ?occupati ?totali))
=>
    (printout t "puoi effettuare  una prenotazione a: "  ?id ?cit  crlf)
)