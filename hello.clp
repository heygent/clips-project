; Ciao!

(deftemplate localita "località turistica"
    (slot nome)
    (slot regione)
    (multislot turismo)
)

(deffacts voti
    (vototur torino  balneare  0 )
    (vototur torino  sessuale  grande)
    (vototur milano  sanitario  10)
)

(deffacts città
    (localita (nome torino) (turismo balneare))
    (localita (nome milano) (turismo sanitario))
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