test $DEBUG && DEBUG_STR='(bind ?*DEBUG* TRUE)'

clips << EOF | tee output.txt
(set-reset-globals FALSE)
(load main.clp)
$DEBUG_STR
(reset)
(run)
(assert
 (query
   (giorni 3)
   (numero-città 2)
   (numero-persone 3) 
   (budget 500)
   (regioni-da-escludere Piemonte)
   (turismo montano enogastronomico)))
(run)
(exit)
EOF
