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


(defrule ancestor-base-1
   (goal ancestor ?x ?y&~?x)
=>
   (assert (goal parent ?x ?y))
)

(defrule parent-dwn-1
   (goal parent ?x ?y&~?x)
   (human (name ?x) (gender male))
=>
   (assert (goal father ?x ?y))
)

(defrule parent-dwn-2
   (goal parent ?x ?y&~?x)
   (human (name ?x) (gender female))
=>
   (assert (goal mother ?x ?y))
)

(defrule father-dwn
   (goal father ?x ?y)
   (human (name ?x) (children $? ?y $?))
=>
   (assert (father (fat ?x) (chl ?y))
)

(defrule parent-up-1
   (goal parent ?x ?y&~?x)
   (father (fat ?x) (chl ?y))
=>
   (assert (parent (par ?x) (chl ?y)))
)

(defrule ancestor-base-1-up
   (goal ancestor ?x ?y)
   (parent (par ?x) (des ?y))
=> 
   (assert (ancestor (anc ?x) (des ?y)))
)


(defrule ancestor-base-2
    (goal ancestor ?x ?y&~?x)
    (human (name ?z&~?x&~?y) (children ?$ ?y $?))
=>
   (assert (goal parent ?z ?y)
           (goal ancestor ?x ?z))
)

(defrule ancestor-base-2-up
  (goal ancestor ?x ?y&~?x)
  (ancestor (anc ?x ?z))
  (ancestor (anc ?z ?y))
=>
  (assert (ancestor (anc ?x) (des ?y)))
)
    

(defrule start (declare (salience 100))
   (maingoal ancestor ?x ?y)
=>
   (assert (goal ancestor ?x ?y))
)

(defrule success (declare (salience 100))
   (maingoal ancestor ?x ?y)
   (ancestor (anc ?x) (des ?y))
=>
   (printout t "YES")
   (halt)
)



(deffacts init
  (human (name Luigi) (gender male) (children Marta Luca))
  (human (name Marta) (gender female) (children Maria Lucrezia Ludovico))
  (human (name Luca) (gender male) )
  (human (name Maria) (gender female) (children Ludovico))
  (human (name Lucrezia) (gender female))
  (human (name Ludovico) (gender male) (children Miriam))
)

