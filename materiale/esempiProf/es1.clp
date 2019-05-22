(deffacts data-facts  
        (data 1.0 blue "red")  
        (data 1 blue)  
        (data 1 blue red)  
        (data 1 blue RED)  
        (data 1 blue red 6.9)
        (pippo)
        (data 2 red))
        
(defrule find-data1
  (data ? blue red $?)
  =>  (assert (r1)))
  
  
(defrule find-data2
  (data ?x blue red $?)
  => (assert (result ?x)))

(defrule find-data-3
  (data ?x ?y ?z)
  =>
  (assert (primo ?x) (secondo ?y) (terzo ?z)))
  
 
 
 (defrule find-data-4
  (data ?x $?y ?z)
  =>
  (printout t "?x = " ?x crlf
              "?y = " ?y crlf
              "?z = " ?z crlf
              "------" crlf))
