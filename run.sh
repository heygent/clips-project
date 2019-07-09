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
     (numero-persone 3)
     (numero-città 2)
     (turismo montano enogastronomico)
     (budget 500)
   )
)
(run)
(exit)
EOF
