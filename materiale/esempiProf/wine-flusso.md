# Stack iniziale focus

```
(focus QUESTIONS CHOOSE-QUALITIES WINES PRINT-RESULTS)
```

# Modulo QUESTIONS

```
(defrule QUESTIONS::ask-a-question
   ?f <- (question (already-asked FALSE)
                   (precursors)
                   ; La stringa da mandare in output
                   (the-question ?the-question)
                   ; L'attributo con cui verrà salvata la risposta
                   (attribute ?the-attribute)
                   (valid-answers $?valid-answers))
   =>
   ; Qua imposta il flag per non far richiedere due volte la stessa domanda
   (modify ?f (already-asked TRUE))
   ; E qua la salva
   (assert (attribute (name ?the-attribute)
                      (value (ask-question ?the-question ?valid-answers)))))
```

Per ogni fatto `question`, la regola `ask-a-question` presenta un prompt
all'utente dove pone la domanda, se lo slot `already-asked` è impostato a
`FALSE` (sempre vero all'inizio).

Esempio di fatto `question`:

```
(question (attribute main-component)
          (the-question "Is the main component of the meal meat, fish, or poultry? ")
          (valid-answers meat fish poultry unknown))
```

## Funzione `ask-a-question`

```
(deffunction MAIN::ask-question (?question ?allowed-values)
   (printout t ?question)
   (bind ?answer (read))
   (if (lexemep ?answer) then (bind ?answer (lowcase ?answer)))
   (while (not (member ?answer ?allowed-values)) do
      (printout t ?question)
      (bind ?answer (read))
      (if (lexemep ?answer) then (bind ?answer (lowcase ?answer))))
   ?answer)
```

La funzione fa la domanda all'utente e restituisce la risposta quando questa è
valida.

# Modulo CHOOSE-QUALITIES

```
(defrule CHOOSE-QUALITIES::startit => (focus RULES))
```

Appena avviato, CHOOSE-QUALITIES passa il focus a RULES, dopo aver definito
alcuni fatti di tipo `rule`.

```
(rule (if tastiness is average)
      (then best-body is light with certainty 30 and
            best-body is medium with certainty 60 and
            best-body is full with certainty 30))
```

# Cose a cui rispondere

- Cos'è un precursore?
- Che è sta roba?

```
(deffacts any-attributes
  (attribute (name best-color) (value any))
  (attribute (name best-body) (value any))
  (attribute (name best-sweetness) (value any)))
```
