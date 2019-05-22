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
   (assert (father (fat ?n) (chld ?x)))


(deffacts init
  (human (name Luigi) (gender male) (children Marta Luca))
  (human (name Marta) (gender female) (children Maria Lucrezia Ludovico))
  (human (name 
)
