; Ciao!

(deftemplate localita "località turistica"
    (slot nome)
    (slot regione)
    (slot lat)
    (slot lon)
    (multislot turismo)
)


(deffacts voti
    (vototur torino  balneare  0 )
    (vototur torino  sessuale  grande)
    (vototur milano  sanitario  10)
)

(deffacts città
    (localita (nome torino) (lat 45.0677551) (lon 7.6824892) (turismo balneare))
    (localita (nome milano) (lat 45.465454) (lon 9.186516) (turismo sanitario))
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

(defrule dammivoti
    (vototur torino ?tipo ?val)
=>
    (printout t "ecco il voto per torino " ?tipo  ?val crlf)
)

(defrule ciaotorino "we"
    ?citta <- (localita (nome Torino))
    
=>
    (printout t "ciao sono la città di" ?citta crlf)
    (assert (esistetorino  true))
)