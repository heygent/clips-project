; Ciao!

(deftemplate localita "località turistica"
    (slot nome)
    (slot regione )
    (multislot turismo )
)

(deffacts cittaditorino "yeah"
   (localita 
    (nome Torino)
    (regione Piemonte)
    (turismo montano culturale religioso enogastronomico)
    ) 
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

