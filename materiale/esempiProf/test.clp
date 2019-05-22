

(defrule  test-and
	(eta ?age&:(>= ?age 0)&:(< ?age 18))
=>
	(printout t "ok: " ?age crlf)
)


(defrule  test-or
	(eta ?age&:(< ?age 0) |: (>= ?age 18))
=>
	(printout t "ko: " ?age crlf)
)

(defrule  test-not
	(eta ?age&~: (<> ?age 15))
=>
	(printout t "quindici: " ?age crlf)
)



(deffacts init
	(eta 84)
	(eta 14)
	(eta 15)
)
