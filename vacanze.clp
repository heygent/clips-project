
;;;======================================================
;;;   VACANZEEEEEX
;;;
;;;     WINEX: The WINe EXpert system.
;;;     This example selects an appropriate wine
;;;     to drink with a meal.
;;;
;;;     CLIPS Version 6.0 Example
;;;
;;;     To execute, merely load, reset and run.
;;;======================================================

(defmodule MAIN (export ?ALL))

;;****************
;;* DEFFUNCTIONS *
;;****************


(deffunction MAIN::get-question-input (?question ?multiple)
   (printout t ?question)
   (bind ?answer (lowcase (readline)))
   (if ?multiple then (explode$ ?answer) else (string-to-field ?answer)))

(deffunction MAIN::ask-multiple-symbols-question (?question ?allowed-values)
   (bind ?answer (get-question-input ?question TRUE))
   (while (not (subsetp ?answer ?allowed-values)) do
      (bind ?answer (get-question-input ?question TRUE))
   ?answer
))

(deffunction MAIN::ask-single-symbol-question (?question ?allowed-values)
   (bind ?answer (get-question-input ?question FALSE))
   (while (not (member$ ?answer ?allowed-values)) do
      (bind ?answer (get-question-input ?question FALSE)))
   ?answer
)

(deffunction MAIN::ask-single-number-question (?question ?allowed-values)
   (bind ?answer (get-question-input ?question FALSE))
   (while (and (not (integerp ?Answer)) (not (member ?answer ?allowed-values)))
      (bind ?answer (get-question-input ?question FALSE)))
)

(deffunction MAIN::ask-numeric-question (?question ?allowed-values)
  
   (bind ?answer (get-question-input ?question FALSE))
   (while (and (integerp ?answer) (not (member ?answer ?allowed-values)) (or
   ?stars ?budget )) do
      (printout t ?question)
      (bind ?answer (get-question-input ?question FALSE)))
    ?answer)

;;*****************
;;* INITIAL STATE *
;;*****************

(deftemplate MAIN::attribute
   (slot name)
   (slot value)
   (slot certainty (default 100.0)))

(defrule MAIN::start
  (declare (salience 10000))
  =>
  (set-fact-duplication TRUE)
  (focus QUESTIONS CHOOSE-QUALITIES WINES PRINT-RESULTS))

(defrule MAIN::combine-certainties ""
  (declare (salience 100)
           (auto-focus TRUE))
  ?rem1 <- (attribute (name ?rel) (value ?val) (certainty ?per1))
  ?rem2 <- (attribute (name ?rel) (value ?val) (certainty ?per2))
  (test (neq ?rem1 ?rem2))
  =>
  (retract ?rem1)
  (modify ?rem2 (certainty (/ (- (* 100 (+ ?per1 ?per2)) (* ?per1 ?per2)) 100))))
  
;;******************
;;* QUESTION RULES *
;;******************

(defmodule QUESTIONS (import MAIN ?ALL) (export ?ALL))

(deftemplate QUESTIONS::question
   (slot attribute (default ?NONE))
   (slot the-question (default ?NONE))
   (slot multiple)
   (slot answer-type)
   (multislot valid-answers (default ?NONE))
   (slot already-asked (default FALSE))
   (multislot precursors (default ?DERIVE))
   (slot budget (range 0 ?VARIABLE))
   (slot stars (range 1 5))
   )

  ; Salva la risposta a una determinata domanda  
(defrule QUESTIONS::ask-a-question
   ?f <- (question (already-asked FALSE)
                   (precursors)
                   (the-question ?the-question)
                   (attribute ?the-attribute)
                   (valid-answers $?valid-answers))
   =>
   (modify ?f (already-asked TRUE))
   (assert (attribute (name ?the-attribute)
                      (value (ask-question ?the-question ?valid-answers)))))

(defrule QUESTIONS::precursor-is-satisfied
   ?f <- (question (already-asked FALSE)
                   (precursors ?name is ?value $?rest))
         (attribute (name ?name) (value ?value))
   =>
   (if (eq (nth 1 ?rest) and) 
    then (modify ?f (precursors (rest$ ?rest)))
    else (modify ?f (precursors ?rest))))

(defrule QUESTIONS::precursor-is-not-satisfied
   ?f <- (question (already-asked FALSE)
                   (precursors ?name is-not ?value $?rest))
         (attribute (name ?name) (value ~?value))
   =>
   (if (eq (nth 1 ?rest) and) 
    then (modify ?f (precursors (rest$ ?rest)))
    else (modify ?f (precursors ?rest))))

;;*******************
;;* DOMANDE VACANZE *
;;*******************

(defmodule WINE-QUESTIONS (import QUESTIONS ?ALL))

(deffacts WINE-QUESTIONS::question-attributes
  (question (attribute numero-mete)
            (the-question "Quante mete vorresti visitare ")
            (answer-type int))
            
  (question (attribute numero-persone)
            (the-question "In quante persone siete?")
            (answer-type int))
            
  (question (attribute tipi-turismo)
            (the-question "Quali aspetti turistici preferisci?")
            (answer-type symbol)
            (multiple true))

  (question (attribute regioni)
            (the-question "Quali regioni vorresti visitare?")
            (answer-type symbol)
            (multiple true))

  (question (attribute budget)
            (the-question "Qual'è il vostro budget?")
            (answer-type int))

  (question (attribute durata)
            (the-question "Quanti giorni durerà la vostra vacanza?")
            (answer-type int))

  (question (attribute stelle-minime)
            (the-question "Stelle minime hotel?")
            (answer-type int)
            ))
            

 
;;******************
;; The RULES module
;;******************

(defmodule RULES (import MAIN ?ALL) (export ?ALL))

(deftemplate RULES::rule
  (slot certainty (default 100.0))
  (multislot if)
  (multislot then))

;toglie and antecedente
(defrule RULES::throw-away-ands-in-antecedent
  ?f <- (rule (if and $?rest))
  =>
  (modify ?f (if ?rest)))

;toglie and conseguente 
(defrule RULES::throw-away-ands-in-consequent
  ?f <- (rule (then and $?rest))
  =>
  (modify ?f (then ?rest)))

;se esiste una regola che abbia if ?attributo is ?valore ugual a un dato
;attributo modifico quel fatto cambiando cf (prendendo il minim dei due)
;e lasciando nel fatto solo if e tutto il resto 
 
(defrule RULES::remove-is-condition-when-satisfied
  ?f <- (rule (certainty ?c1) 
              (if ?attribute is ?value $?rest))
  (attribute (name ?attribute) 
             (value ?value) 
             (certainty ?c2))
  =>
  (modify ?f (certainty (min ?c1 ?c2)) (if ?rest)))

;quando la condizione isnot è soddisfatta rimuovo isnot
(defrule RULES::remove-is-not-condition-when-satisfied
  ?f <- (rule (certainty ?c1) 
              (if ?attribute is-not ?value $?rest))
  (attribute (name ?attribute) (value ~?value) (certainty ?c2))
  =>
  (modify ?f (certainty (min ?c1 ?c2)) (if ?rest)))

;
(defrule RULES::perform-rule-consequent-with-certainty
  ?f <- (rule (certainty ?c1) 
              (if) 
              (then ?attribute is ?value with certainty ?c2 $?rest))
  =>
  (modify ?f (then ?rest))
  (assert (attribute (name ?attribute) 
                     (value ?value)
                     (certainty (/ (* ?c1 ?c2) 100)))))

(defrule RULES::perform-rule-consequent-without-certainty
  ?f <- (rule (certainty ?c1)
              (if)
              (then ?attribute is ?value $?rest))
  (test (or (eq (length$ ?rest) 0)
            (neq (nth 1 ?rest) with)))
  =>
  (modify ?f (then ?rest))
  (assert (attribute (name ?attribute) (value ?value) (certainty ?c1))))

;;*******************************
;;* CHOOSE WINE QUALITIES RULES *
;;*******************************

(defmodule CHOOSE-QUALITIES (import RULES ?ALL)
                            (import QUESTIONS ?ALL)
                            (import MAIN ?ALL))

(defrule CHOOSE-QUALITIES::startit => (focus RULES))

(deffacts the-wine-rules

  ; Rules for picking the best body

  (rule (if has-sauce is yes and 
            sauce is spicy)
        (then best-body is full))

  (rule (if tastiness is delicate)
        (then best-body is light))

  (rule (if tastiness is average)
        (then best-body is light with certainty 30 and
              best-body is medium with certainty 60 and
              best-body is full with certainty 30))

  (rule (if tastiness is strong)
        (then best-body is medium with certainty 40 and
              best-body is full with certainty 80))

  (rule (if has-sauce is yes and
            sauce is cream)
        (then best-body is medium with certainty 40 and
              best-body is full with certainty 60))

  (rule (if preferred-body is full)
        (then best-body is full with certainty 40))

  (rule (if preferred-body is medium)
        (then best-body is medium with certainty 40))

  (rule (if preferred-body is light) 
        (then best-body is light with certainty 40))

  (rule (if preferred-body is light and
            best-body is full)
        (then best-body is medium))

  (rule (if preferred-body is full and
            best-body is light)
        (then best-body is medium))

  (rule (if preferred-body is unknown) 
        (then best-body is light with certainty 20 and
              best-body is medium with certainty 20 and
              best-body is full with certainty 20))

  ; Rules for picking the best color

  (rule (if main-component is meat)
        (then best-color is red with certainty 90))

  (rule (if main-component is poultry and
            has-turkey is no)
        (then best-color is white with certainty 90 and
              best-color is red with certainty 30))

  (rule (if main-component is poultry and
            has-turkey is yes)
        (then best-color is red with certainty 80 and
              best-color is white with certainty 50))

  (rule (if main-component is fish)
        (then best-color is white))

  (rule (if main-component is-not fish and
            has-sauce is yes and
            sauce is tomato)
        (then best-color is red))

  (rule (if has-sauce is yes and
            sauce is cream)
        (then best-color is white with certainty 40))
                   
  (rule (if preferred-color is red)
        (then best-color is red with certainty 40))

  (rule (if preferred-color is white)
        (then best-color is white with certainty 40))

  (rule (if preferred-color is unknown)
        (then best-color is red with certainty 20 and
              best-color is white with certainty 20))
  
  ; Rules for picking the best sweetness

  (rule (if has-sauce is yes and
            sauce is sweet)
        (then best-sweetness is sweet with certainty 90 and
              best-sweetness is medium with certainty 40))

  (rule (if preferred-sweetness is dry)
        (then best-sweetness is dry with certainty 40))

  (rule (if preferred-sweetness is medium)
        (then best-sweetness is medium with certainty 40))

  (rule (if preferred-sweetness is sweet)
        (then best-sweetness is sweet with certainty 40))

  (rule (if best-sweetness is sweet and
            preferred-sweetness is dry)
        (then best-sweetness is medium))

  (rule (if best-sweetness is dry and
            preferred-sweetness is sweet) 
        (then best-sweetness is medium))

  (rule (if preferred-sweetness is unknown)
        (then best-sweetness is dry with certainty 20 and
              best-sweetness is medium with certainty 20 and
              best-sweetness is sweet with certainty 20)))



;;************************
;;* WINE SELECTION RULES *
;;************************

(defmodule WINES (import MAIN ?ALL))

(deffacts any-attributes
  (attribute (name best-color) (value any))
  (attribute (name best-body) (value any))
  (attribute (name best-sweetness) (value any)))

(deftemplate WINES::wine
  (slot name (default ?NONE))
  (multislot color (default any))
  (multislot body (default any))
  (multislot sweetness (default any)))

(deffacts WINES::the-wine-list 
  (wine (name Gamay) (color red) (body medium) (sweetness medium sweet))
  (wine (name Chablis) (color white) (body light) (sweetness dry))
  (wine (name Sauvignon-Blanc) (color white) (body medium) (sweetness dry))
  (wine (name Chardonnay) (color white) (body medium full) (sweetness medium dry))
  (wine (name Soave) (color white) (body light) (sweetness medium dry))
  (wine (name Riesling) (color white) (body light medium) (sweetness medium sweet))
  (wine (name Geverztraminer) (color white) (body full))
  (wine (name Chenin-Blanc) (color white) (body light) (sweetness medium sweet))
  (wine (name Valpolicella) (color red) (body light))
  (wine (name Cabernet-Sauvignon) (color red) (sweetness dry medium))
  (wine (name Zinfandel) (color red) (sweetness dry medium))
  (wine (name Pinot-Noir) (color red) (body medium) (sweetness medium))
  (wine (name Burgundy) (color red) (body full))
  (wine (name Zinfandel) (color red) (sweetness dry medium)))
  
(defrule WINES::generate-wines
  (wine (name ?name)
        (color $? ?c $?)
        (body $? ?b $?)
        (sweetness $? ?s $?))
  (attribute (name best-color) (value ?c) (certainty ?certainty-1))
  (attribute (name best-body) (value ?b) (certainty ?certainty-2))
  (attribute (name best-sweetness) (value ?s) (certainty ?certainty-3))
  =>
  (assert (attribute (name wine) (value ?name)
                     (certainty (min ?certainty-1 ?certainty-2 ?certainty-3)))))

;;*****************************
;;* PRINT SELECTED WINE RULES *
;;*****************************

(defmodule PRINT-RESULTS (import MAIN ?ALL))

(defrule PRINT-RESULTS::header ""
   (declare (salience 10))
   =>
   (printout t t)
   (printout t "        SELECTED WINES" t t)
   (printout t " WINE                  CERTAINTY" t)
   (printout t " -------------------------------" t)
   (assert (phase print-wines)))

(defrule PRINT-RESULTS::print-wine ""
  ?rem <- (attribute (name wine) (value ?name) (certainty ?per))      
  (not (attribute (name wine) (certainty ?per1&:(> ?per1 ?per))))
  =>
  (retract ?rem)
  (format t " %-24s %2d%%%n" ?name ?per))

(defrule PRINT-RESULTS::remove-poor-wine-choices ""
  ?rem <- (attribute (name wine) (certainty ?per&:(< ?per 20)))
  =>
  (retract ?rem))

(defrule PRINT-RESULTS::end-spaces ""
   (not (attribute (name wine)))
   =>
   (printout t t))


