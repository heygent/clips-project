(defmodule MAIN (export ?ALL))

(deftemplate person
   (slot name)
   (slot age))

(deffacts some-persons
   (person (name Luigi) (age 35))
   (person (name Maria) (age 20))
   (person (name Marco) (age 15))
)

(defrule start
  =>
  (focus FILM)
)

(defmodule FILM (import MAIN ?ALL) (export ?ALL))
(deftemplate film
     (slot title)
     (slot VM))

(deftemplate ticket
    (slot name)
    (slot title))

(deffacts some-films
   (film (title Shining) (VM YES))
   (film (title Dumbo) (VM NO))
)

(deffacts some-tickes
   (ticket (name Luigi) (title Dumbo))
   (ticket (name Maria) (title Shining))
   (ticket (name Marco) (title Shining))
)

(defrule print-tickets
   (ticket (name ?n) (title ?t))
=>
   (printout t ?n " goes to see " ?t crlf)
)

(defmodule CHECK (import MAIN ?ALL) (import FILM ?ALL))

(defrule checks (declare (auto-focus TRUE))
   ?x <- (ticket (name ?n) (title ?t))
   (film (title ?) (VM YES))
   (person (name ?n) (age ?a&:(< ?a 18)))
=>
   (printout t "No film for " ?n crlf)
   (retract ?x)
)
  
