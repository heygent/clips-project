(defmodule MAIN (export ?ALL))

(deftemplate query
    (slot durata)
    (slot numero-di-persone)
    (slot numero-di-città)
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

(deffunction punteggio-to-cf (?punteggio)
    (- (/ (* ?punteggio 2) 5) 1))

(deftemplate albergo
    (slot id)
    (slot città)
    (slot stelle)
    (slot costo)
    (slot posti-liberi))

(defmodule REASONING (export deftemplate OAV))

(deftemplate attribute
    (slot name)
    (slot value)
    (slot certainty))


(defmodule REGOLE (export ?ALL))

(defrule località-preferita
    ?q <- (query (turismo $? ?tipo-turismo $?))
    ?loc <- (località (nome ?nome))
=>
    (assert (attribute (name località-preferita-per-turismo)
                       (value ?nome)
                       (certainty 1))))



(defrule )