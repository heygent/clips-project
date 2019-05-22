(deftemplate person
	(multislot name)
	(slot SSN))

(defrule Blue-Family-SSN
	(person (name ? Blue) (SSN ?ssn))
=>
	(printout t ?ssn crlf)
)

(deffacts people
	(person (name Bill Blue) (SSN 3))
	(person (name John Blue) (SSN 6))
	(person (name Bill Black) (SSN 8))
	(person (name Nolan Blue) (SSN 1))
)



