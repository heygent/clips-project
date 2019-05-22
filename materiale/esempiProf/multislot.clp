(deftemplate person "persona"
	(multislot name)
	(multislot children (type SYMBOL)(cardinality 0 5)  ) )

(defrule find-child
	(find-child ?child)
	(person (name $?name) (children $?before ?child $?after))
=> 
	(printout t ?name " has child " ?child crlf)
	(printout t "other children befor " ?before " and after " ?after crlf) 
)

(deffacts i-facts
	(person (name Luigi Maria Lodi) (children Antonluca Gian Antongiulio))
	(person (name Luca Verdi) (children Gian Gian Gian))
	(person (name Mario Rossi))
)

(deffacts goal-facts
	(find-child Gian)
)
