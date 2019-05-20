; Ciao!

(deftemplate vototur
    (slot nomecit)
    (slot tipo)
    (slot valutazione)
)

(deftemplate localita "località turistica"
    (slot nome)
    (slot regione)
    (multislot turismo)
)

(deffacts voti
    (vototur (nomecit torino) (tipo balneare) (valutazione 0))
    (vototur (nomecit torino) (tipo sessuale) (valutazione grande))
    (vototur (nomecit milano) (tipo sanitario) (valutazione 10))
)

(deffacts città
    (localita (nome torino) (turismo balneare))
    (localita (nome milano) (turismo sanitario))
)

(defrule dammivoti
    (vototur (nomecit torino) (tipo ?tipo) (valutazione ?val))
=>
    (printout t "ecco il voto per torino "  ?tipo ?val crlf)
)

(defrule esistetorino 
    (esistetorino true)
=>
    (printout t "esiste e come torino" crlf)
)

(defrule ciaotorino "we"
    ?citta <- (localita (nome Torino))
    
=>
    (printout t "ciao sono la città di" ?citta crlf)
    (assert (esistetorino  true))
)

(defrule ciaotorino2 "we"
    (localita (nome ?name))  
=>
    (printout t "ciao sono la città di " ?name crlf)
)

