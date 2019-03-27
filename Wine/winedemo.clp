
;;;======================================================
;;;   Wine Expert Sample Problem
;;;
;;;     WINEX: The WINe EXpert system.
;;;     This example selects an appropriate wine
;;;     to drink with a meal.
;;;
;;;     CLIPS Version 6.3 Example
;;;
;;;     For use with the CLIPSJNI
;;;======================================================

(defmodule MAIN (export ?ALL))

;;*****************
;;* INITIAL STATE *
;;*****************

(deftemplate MAIN::attribute
   (slot name)
   (slot value)
   (slot certainty (default 100.0)))

(defrule MAIN::start
  (declare (salience 10000))
  =>
  (set-fact-duplication TRUE)
  (focus CHOOSE-QUALITIES WINES))

(defrule MAIN::combine-certainties ""
  (declare (salience 100)
           (auto-focus TRUE))
  ?rem1 <- (attribute (name ?rel) (value ?val) (certainty ?per1))
  ?rem2 <- (attribute (name ?rel) (value ?val) (certainty ?per2))
  (test (neq ?rem1 ?rem2))
  =>
  (retract ?rem1)
  (modify ?rem2 (certainty (/ (- (* 100 (+ ?per1 ?per2)) (* ?per1 ?per2)) 100))))
  
 
;;******************
;; The RULES module
;;******************

(defmodule RULES (import MAIN ?ALL) (export ?ALL))

(deftemplate RULES::rule
  (slot certainty (default 100.0))
  (multislot if)
  (multislot then))

(defrule RULES::throw-away-ands-in-antecedent
  ?f <- (rule (if and $?rest))
  =>
  (modify ?f (if ?rest)))

(defrule RULES::throw-away-ands-in-consequent
  ?f <- (rule (then and $?rest))
  =>
  (modify ?f (then ?rest)))

(defrule RULES::remove-is-condition-when-satisfied
  ?f <- (rule (certainty ?c1) 
              (if ?attribute is ?value $?rest))
  (attribute (name ?attribute) 
             (value ?value) 
             (certainty ?c2))
  =>
  (modify ?f (certainty (min ?c1 ?c2)) (if ?rest)))

(defrule RULES::remove-is-not-condition-when-satisfied
  ?f <- (rule (certainty ?c1) 
              (if ?attribute is-not ?value $?rest))
  (attribute (name ?attribute) (value ~?value) (certainty ?c2))
  =>
  (modify ?f (certainty (min ?c1 ?c2)) (if ?rest)))

(defrule RULES::perform-rule-consequent-with-certainty
  ?f <- (rule (certainty ?c1) 
              (if) 
              (then ?attribute is ?value with certainty ?c2 $?rest))
  =>
  (modify ?f (then ?rest))
  (assert (attribute (name ?attribute) 
                     (value ?value)
                     (certainty (/ (* ?c1 ?c2) 100)))))

(defrule RULES::perform-rule-consequent-without-certainty
  ?f <- (rule (certainty ?c1)
              (if)
              (then ?attribute is ?value $?rest))
  (test (or (eq (length$ ?rest) 0)
            (neq (nth 1 ?rest) with)))
  =>
  (modify ?f (then ?rest))
  (assert (attribute (name ?attribute) (value ?value) (certainty ?c1))))

;;*******************************
;;* CHOOSE CAR QUALITIES RULES *
;;*******************************

(defmodule CHOOSE-QUALITIES (import RULES ?ALL)
                            (import MAIN ?ALL))

(defrule CHOOSE-QUALITIES::startit => (focus RULES))

(deffacts the-cars-rules

  ; Rules for picking the best car_city

  (rule (if has-sauce is yes and 
            sauce is spicy)
        (then best-car_city is full))

  (rule (if tastiness is delicate)
        (then best-car_city is car_light))

  (rule (if tastiness is average)
        (then best-car_city is car_light with certainty 30 and
              best-car_city is car_medium with certainty 60 and
              best-car_city is full with certainty 30))

  (rule (if tastiness is strong)
        (then best-car_city is car_medium with certainty 40 and
              best-car_city is full with certainty 80))

  (rule (if has-sauce is yes and
            sauce is cream)
        (then best-car_city is car_medium with certainty 40 and
              best-car_city is full with certainty 60))

  (rule (if preferred-car is full)
        (then best-car_city is full with certainty 40))

  (rule (if preferred-car is car_medium)
        (then best-car_city is car_medium with certainty 40))

  (rule (if preferred-car is car_light) 
        (then best-car_city is car_light with certainty 40))

  (rule (if preferred-car is car_light and
            best-car_city is full)
        (then best-car_city is car_medium))

  (rule (if preferred-body is full and
            best-car_city is car_light)
        (then best-car_city is car_medium))

  (rule (if preferred-car is unknown) 
        (then best-car_city is car_light with certainty 20 and
              best-car_city is car_medium with certainty 20 and
              best-car_city is full with certainty 20))

  ; Rules for picking the best car village

  (rule (if main-component is meat)
        (then best-car_village is  with certainty 90))

  (rule (if main-component is poultry and
            has-turkey is no)
        (then best-car_village is car_u with certainty 90 and
              best-car_village is car_h with certainty 30))

  (rule (if main-component is poultry and
            has-turkey is yes)
        (then best-car_village is car_h with certainty 80 and
              best-car_village is car_u with certainty 50))

  (rule (if main-component is fish)
        (then best-car_village is car_u))

  (rule (if main-component is-not fish and
            has-sauce is yes and
            sauce is tomato)
        (then best-car_village is car_h))

  (rule (if has-sauce is yes and
            sauce is cream)
        (then best-car_village is car_u with certainty 40))
                   
  (rule (if preferred-car is car_h)
        (then best-car_village is car_h with certainty 40))

  (rule (if preferred-car is car_u)
        (then best-car_village is car_u with certainty 40))

  (rule (if preferred-car is unknown)
        (then best-car_village is car_h with certainty 20 and
              best-car_village is car_u with certainty 20))
  
  ; Rules for picking the best car_mix

  (rule (if has-sauce is yes and
            sauce is car_m)
        (then best-car_mix is car_m with certainty 90 and
              best-car_mix is car_medium with certainty 40))

  (rule (if preferred-car_mix is car_none)
        (then best-car_mix is car_none with certainty 40))

  (rule (if preferred-car_mix is car_medium)
        (then best-car_mix is car_medium with certainty 40))

  (rule (if preferred-car_mix is car_m)
        (then best-car_mix is car_m with certainty 40))

  (rule (if best-Car_mix is car_m and
            preferred-car_mix is car_none)
        (then best-car_mix is car_medium))

  (rule (if best-car_mix is car_none and
            preferred-car_mix is car_m) 
        (then best-sweetness is car_medium))

  (rule (if preferred-car_m is unknown)
        (then best-car_m is car_none with certainty 20 and
              best-car_m is car_medium with certainty 20 and
              best-car_m is car_m with certainty 20))

)

;;************************
;;* CAR SELECTION RULES *
;;************************

(defmodule CARS (import MAIN ?ALL)
                 (export deffunction get-car-list))

(deffacts any-attributes
  (attribute (name best-car_city) (value any))
  (attribute (name best-car_village) (value any))
  (attribute (name best-car_mix) (value any)))

(deftemplate CARS::cars
  (slot name (default ?NONE))
  (multislot car_city (default any))
  (multislot car_village (default any))
  (multislot car_m (default any)))

(deffacts CARS::the-cars-list 
  (car (name "Wolkswagen-golf") (car_city) (car_medium) (car_m medium car_m))
  (car (name "Wolkswagen-toureg") (car_u) ( car_light) (car_m car_none))
  (car (name "Pagany") (car_u) ( car_medium) (car_m car_none))
  (car (name "Maserati") (car_u) (car_medium full) (car_m car_medium car_none))
  (car(name "Mersedes -gle") (car_u) ( car_light) (car_m car_medium car_none))
  (car (name "Bugatti") (car_u) (car_light car_medium) (car_m car_medium car_m))
  (car (name "BMW- m1") (car_u) (car_city full))
  (car (name "BMW- x6") (car_u) (car_light) (car_m medium car_m))
  (car (name "Ferrari") (car_h) ( car_light))
  (car (name "Lanos") (car_h) (sweetness dry medium))
  (car (name "Mersedes-a180") (car_h) (car_m car_none car_medium))
  (car (name "Seat") (car_h) (car_city car_medium) (car_m car_medium))
  (car (name "Fiat") (car_h) (car_city full))
  (car (name "Mercury") (car_h) (car_m car_none car_medium)))
  
  
(defrule CARS::generate-cars
  (wine (name ?name)
        (color $? ?c $?)
        (body $? ?b $?)
        (sweetness $? ?s $?))
  (attribute (name best-car_village) (value ?c) (certainty ?certainty-1))
  (attribute (name best-car_city) (value ?b) (certainty ?certainty-2))
  (attribute (name best-car_mix) (value ?s) (certainty ?certainty-3))
  =>
  (assert (attribute (name car) (value ?name)
                     (certainty (min ?certainty-1 ?certainty-2 ?certainty-3)))))

(deffunction CARS::cars-sort (?w1 ?w2)
   (< (fact-slot-value ?w1 certainty)
      (fact-slot-value ?w2 certainty)))
      
(deffunction CARS::get-type-list ()
  (bind ?facts (find-all-facts ((?f attribute))
                               (and (eq ?f:name car)
                                    (>= ?f:certainty 20))))
  (sort car-sort ?facts))
  

