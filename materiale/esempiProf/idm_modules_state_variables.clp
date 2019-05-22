(defmodule MAIN (export ?ALL))

(deftemplate solution (slot value (default no))) 
(deftemplate maxdepth (slot max))
(deffacts param
       (solution (value no)) 
       (maxdepth (max 0))
)

(deftemplate sv (slot t) (slot var) (slot obj) (slot value))

(deftemplate goal (slot var) (slot obj) (slot value))

(deffacts S0
      (sv (t 0) (var position) (obj a) (value b))
      (sv (t 0) (var top) (obj a) (value nil))
      (sv (t 0) (var position) (obj b) (value table))
      (sv (t 0) (var top) (obj b) (value a))
      (sv (t 0) (var position) (obj c) (value table))
      (sv (t 0) (var top) (obj c) (value nil))
      (sv (t 0) (var hand) (obj nil) (value empty))     
)

(deffacts final
      (goal (var position) (obj a)  (value b))
      (goal (var position) (obj b) (value c))
      (goal (var position) (obj c) (value table))
)


(defrule got-solution
(declare (salience 100))
(solution (value yes)) 
(maxdepth (max ?n))
        => (assert (stampa (- ?n 1)))
           )



(defrule stampaSol
(declare (salience 101))
?f<-(stampa ?n)
(exec ?n ?k ?a ?b)
=> (printout t " PASSO: "?n " " ?k " " ?a " " ?b crlf)
   (assert (stampa (- ?n 1)))
   (retract ?f)
)

(defrule stampaSol0
(declare (salience 102))
(stampa -1)
=> (halt)
)



(defrule no-solution
(declare (salience -1))
(solution (value no))
?f <-  (maxdepth (max ?d))
 => (reset)
    (assert (resetted ?d))
    )


(defrule resetted
?f <- (resetted ?d)
?m <-     (maxdepth (max ?))
=>
    (modify ?m (max (+ ?d 1))) 
    (printout t " fail with Maxdepth:" ?d crlf)
    (focus EXPAND)
    (retract ?f)
)

(defmodule EXPAND (import MAIN ?ALL) (export ?ALL))

(defrule pick

   (sv (t ?s) (var position) (obj ?x) (value ?y&:(neq ?y table)))
   (sv (t ?s) (var top) (obj ?x) (value nil))
   (sv (t ?s) (var hand) (obj nil) (value empty))
   (maxdepth (max ?d))
    (test (< ?s ?d))
      (not (exec ?s pick ?x ?y)) 
   => (assert (apply ?s pick ?x ?y)))

(defrule apply-pick1
        (apply ?s pick ?x ?y)
 ?f <-  (sv (t ?t&:(> ?t ?s)))
 =>     (retract ?f))

(defrule apply-pick2
       (apply ?s pick ?x ?y)
?f <-  (exec ?t&:(> ?t ?s) ? ? ?)
 =>    (retract ?f))

(defrule apply-pick3
?f <- (apply ?s pick ?x ?y)
 =>    (retract ?f)
      (assert (sv (t (+ ?s 1)) (var hand) (obj nil) (value ?x)) )
      (assert (sv (t (+ ?s 1)) (var position) (obj ?x) (value hand)) )
      (assert (sv (t (+ ?s 1)) (var top) (obj ?x) (value nil)) )
      (assert (sv (t (+ ?s 1)) (var top) (obj ?y) (value nil)) )
      (assert (current ?s))
      (assert (news (+ ?s 1)))
      (focus CHECK)
      (assert (exec ?s pick ?x ?y )))


;;DA RIVEDERE CON LE VARIABILI DI STATO
(defrule picktable
   (status ?s ontable ?x ?)
   (status ?s clear ?x ?)
   (status ?s handempty ? ?)
   (maxdepth (max ?d))
   (test (< ?s ?d))
   (not (exec ?s picktable ?x NA)) 
   => (assert (apply ?s picktable ?x NA)))

;;DA RIVEDERE CON LE VARIABILI DI STATO
(defrule apply-picktable1
        (apply ?s picktable ?x ?y)
 ?f <-  (status ?t ? ? ?)
        (test (> ?t ?s))
 =>     (retract ?f))

;;DA RIVEDERE CON LE VARIABILI DI STATO
(defrule apply-picktable2
        (apply ?s picktable ?x ?y)
?f <-  (exec ?t ? ? ?)
       (test (> ?t ?s))
 =>    (retract ?f))

;;DA RIVEDERE CON LE VARIABILI DI STATO
(defrule apply-picktable3
?f <- (apply ?s picktable ?x ?y)
 =>   (retract ?f)
      (assert (delete ?s ontable ?x NA))
      (assert (delete ?s clear ?x NA))
      (assert (delete ?s handempty NA NA))
      (assert (status (+ ?s 1) holding ?x NA))
      (assert (current ?s))
      (assert (news (+ ?s 1)))
      (focus CHECK)
      (assert (exec ?s picktable ?x NA)))

;;DA RIVEDERE CON LE VARIABILI DI STATO
(defrule put
   (status ?s holding ?x ?)
   (status ?s clear ?y ?)
   (maxdepth (max ?d))
   (test (< ?s ?d)) 
   (not (exec ?s put ?x ?y)) 
   => (assert (apply ?s put ?x ?y)))

;;DA RIVEDERE CON LE VARIABILI DI STATO
(defrule apply-put1
        (apply ?s put ?x ?y)
 ?f <-  (status ?t ? ? ?)
        (test (> ?t ?s))
 =>     (retract ?f))

;;DA RIVEDERE CON LE VARIABILI DI STATO
(defrule apply-put2
        (apply ?s put ?x ?y)
 ?f <-  (exec ?t ? ? ?)
        (test (> ?t ?s))
 =>     (retract ?f))

;;DA RIVEDERE CON LE VARIABILI DI STATO
(defrule apply-put3
?f <- (apply ?s put ?x ?y)
 =>   (retract ?f)
      (assert (delete  ?s holding ?x NA))
      (assert (delete  ?s clear ?y NA))
      (assert (status (+ ?s 1) on ?x ?y))
      (assert (status (+ ?s 1) clear ?x NA))
      (assert (status (+ ?s 1) handempty NA NA))
      (assert (current ?s))
      (assert (news (+ ?s 1)))
      (focus CHECK)
      (assert (exec ?s put ?x ?y)))

;;DA RIVEDERE CON LE VARIABILI DI STATO
(defrule puttable
   (status ?s holding ?x ?)
   (maxdepth (max ?d))
   (test (<  ?s  ?d))
   (not (exec ?s puttable ?x NA)) 
   => (assert (apply ?s puttable ?x NA)))

;;DA RIVEDERE CON LE VARIABILI DI STATO
(defrule apply-puttable1
        (apply ?s puttable ?x ?y)
 ?f <-  (status ?t ? ? ?)
        (test (> ?t ?s))
 =>     (retract ?f))

;;DA RIVEDERE CON LE VARIABILI DI STATO
(defrule apply-puttable2
        (apply ?s puttable ?x ?y)
 ?f <-  (exec ?t ? ? ?)
        (test (> ?t ?s))
 =>     (retract ?f))

;;DA RIVEDERE CON LE VARIABILI DI STATO
(defrule apply-puttable3
?f <- (apply ?s puttable ?x ?y)
 =>    (retract ?f)(assert (delete ?s holding ?x NA))
      (assert (status (+ ?s 1) ontable ?x NA))
      (assert (status (+ ?s 1) clear ?x NA))
      (assert (status (+ ?s 1)handempty NA NA))
      (assert (current ?s))
      (assert (news (+ ?s 1)))
      (focus CHECK)
      (assert (exec ?s puttable ?x NA)))

(defmodule CHECK (import MAIN ?ALL) (import EXPAND ?ALL) (export ?ALL))

(defrule persistence
    (declare (salience 100))
    (current ?s)
    (news ?snext)
    (sv (t ?s) (var ?v) (obj ?o) (value ?val))
    (not (sv (t ?snext)  (var ?v) (obj ?o))  )
 => 
    (assert  (sv (t ?snext) (var ?v) (obj ?o) (value ?val)) )
)

(defrule goal-not-yet
      (declare (salience 50))
      (news ?s)
      (goal (var ?v) (obj ?o) (value ?val))
      (not (sv (t ?s) (var ?v) (obj ?o) (value ?val)))
      => 
	(assert (task go-on)) 
        (assert (ancestor (- ?s 1)))
        (focus NEW))

(defrule solution-exist
 ?f <-  (solution (value no))
         => 
        (modify ?f (value yes))
        (pop-focus)
        (pop-focus)
)

(defmodule NEW (import CHECK ?ALL) (export ?ALL))

(defrule check-ancestor
    (declare (salience 50))
?f1 <- (ancestor ?a) 
    (or (test (> ?a 0)) (test (= ?a 0)))
    (news ?s)
    (sv (t ?s) (var ?v) (obj ?o) (value ?val) )
    (not (sv (t ?a) (var ?v) (obj ?o) (value ?val) )  ) 
    =>
    (assert (ancestor (- ?a 1)))
    (retract ?f1)
)

(defrule all-checked
       (declare (salience 25))
       (ancestor -1)
?f2 <- (news ?n)
?f3 <- (task go-on) 
=>
       (retract ?f2)
       (retract ?f3)
       (focus DEL))

(defrule already-exist
?f <- (task go-on)
      => 
         (retract ?f)
         (assert (remove newstate))
         (focus DEL))

(defmodule DEL (import NEW ?ALL))          
       

(defrule del3
(declare (salience 25))
       (remove newstate)
       (news ?s)
 ?f <- (sv (t ?s))
=> (retract ?f))

(defrule del4
(declare (salience 10))
?f1 <- (remove newstate)
?f2 <- (news ?s)
=> (retract ?f1)
   (retract ?f2))

(defrule done
 ?f <- (current ?x) => 
(retract ?f)
(pop-focus)
(pop-focus)
(pop-focus)
)


