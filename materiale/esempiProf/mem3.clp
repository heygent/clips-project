(defmodule MAIN (export ?ALL))
(deftemplate memory
	(slot size)
	(slot available)
	(multislot usage)
)

(deftemplate application
	(slot name)
	(slot mem-req)
)

(deftemplate allocate
	(slot name)
)

(deftemplate deallocate
	(slot name)
)


(deffacts init
	(phases ACCEPT DEALLOCATION ALLOCATION)

	(memory (size 15) (available 15) (usage))
	(application (name word) (mem-req 2))
	(application (name word2) (mem-req 7))
	(application (name word3) (mem-req 6))
	(application (name gnumeric) (mem-req 5))
	(application (name gnumeric2) (mem-req 5))

	(allocate (name word))
)



(defrule MAIN::change-phase
	?list <- (phases ?next-phase $?other-phases)
=>
	(focus ?next-phase)
	(retract ?list)
	(assert (phases ?other-phases ?next-phase))
)


(defmodule ALLOCATION (import MAIN deftemplate allocate memory application))

(defrule allocation-ok
	(application (name ?x) (mem-req ?y))
	?f1 <- (allocate (name ?x))
	?f <- (memory (available ?z&:(> ?z ?y)) (usage $?u) )
=>	
	(bind ?m (- ?z ?y))
	(modify ?f (available ?m) (usage ?x ?u))
	(retract ?f1)
)

(defmodule DEALLOCATION (import MAIN deftemplate deallocate memory application))

(defrule deallocation-ok
	(application (name ?x) (mem-req ?y))
	?f1 <- (deallocate (name ?x))
	?f <- (memory (available ?z) (usage $?prima ?x $?dopo))
=>
	(bind ?m (+ ?z ?y))
	(modify ?f (available ?m) (usage $?prima $?dopo))
	(retract ?f1)
)

(defmodule ACCEPT)
(deffacts stop-me
	(stop))

(defrule accept-reqs
	?f <- (stop)	
=>
	(retract ?f)
	(assert (stop))
	(pop-focus)
	(halt)
)


