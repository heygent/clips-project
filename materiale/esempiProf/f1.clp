(deftemplate human 
    (slot name)
    (slot gender)
    (multislot children))

(deftemplate ancestor
    (slot anc)
    (slot des))

(deftemplate parent
    (slot par)
    (slot chl))

(deftemplate father
    (slot fat)
    (slot chl))


(deftemplate mother
    (slot mot)
    (slot chl))


(defrule ancerstors
   (parent (par ?p) (chl ?c))
=>
   (assert (ancestor (anc ?p) (des ?c)))
)

(defrule father
   (human (name ?n) (gender male) (children $? ?x $?))
=> 
   (assert 
        (father (fat ?n) (chl ?x))
        (parent (par ?n) (chl ?x))
    )

)


(defrule mother
   (human (name ?n) (gender female) (children $? ?x $?))
=> 
   (assert (mother (mot ?n) (chl ?x))
            (parent (par ?n) (chl ?x))
    )
)

(defrule ancestors2
   (parent (par ?p) (chl ?c))
   (ancestor (anc ?c) (des ?d))
=>
  (assert (ancestor (anc ?p) (des ?d)))
)

(defrule success (declare (salience -10))
   ?g<-(goal ancestor ?x ?y)
   (ancestor (anc ?x) (des ?y))
=>
   (printout t "YES " ?x " e' un antenato di " ?y crlf)
   (retract ?g)
   (halt)
)

(defrule failure (declare (salience -20))
   (goal ancestor ?x ?y)
;;   (not (ancestor (anc ?x) (des ?y)))
=>
   (printout t "NO " ?x " non e' un antenato di " ?y crlf)
)



(deffacts init
  (human (name Luigi) (gender male) (children Marta Luca))
  (human (name Marta) (gender female) (children Maria Lucrezia Ludovico))
  (human (name Luca) (gender male) )
  (human (name Maria) (gender female) (children Ludovico))
  (human (name Lucrezia) (gender female))
  (human (name Ludovico) (gender male) (children Miriam))
)

