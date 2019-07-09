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
   (numero-città 3)
   (numero-persone 4) 
   (budget 700)
 )
)
(run)
(exit)
EOF
