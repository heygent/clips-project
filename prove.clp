(defmodule SEARCH (import MAIN ?ALL) (export ?ALL))

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

(deffacts pino
    (turismo (città torino) (balneare 3))
    (turismo (città milano) (balneare 2))
    (turismo (città marina-di-lesina) (balneare 10))
    )

(deffacts adsf
  (tipo-turismo-richiesto balneare))

(defrule stampa-tipo-turismo
  (tipo-turismo-richiesto ?tipo-turismo)
  ?tur <- (turismo (città ?città))
  =>
  (bind ?valore-tipo-turismo (fact-slot-value ?tur ?tipo-turismo))
  (printout t "Il voto per il tipo turismo " ?tipo-turismo " a " ?città " è " ?valore-tipo-turismo crlf)
  (printout t "check" crlf))

  (defrule trova-alberghi
    (prenotazione (id-prenotazione ?id))
    (preferenza (id-prenotazione ?id) (città ?cit))
    (località (nome ?cit) )
    (albergo (città ?cit) (costo ?costo) (posti-occupati ?occupati) (posti-totali ?totali))
    (test(< ?occupati ?totali))
    =>
    (printout t "puoi effettuare  una prenotazione a " ?cit " per un costo di " ?costo  crlf)
    )
