
;;;======================================================
;;;   car Expert Sample Problem
;;;
;;;     carX: The car EXpert system.
;;;     This example selects an appropriate car
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
  (focus CHOOSE-QUALITIES CARS))

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

(deffacts the-car-rules

  ; Rules for picking the best road

  (rule (if has-tuning is yes and 
            tuning is amg)
        (then best-road is track))

  (rule (if fuel is gas)
        (then best-road is offroad))

  (rule (if fuel is dizel)
        (then best-road is offroad with certainty 30 and
              best-road is highway with certainty 60 and
              best-road is track with certainty 30))

  (rule (if fuel is benzine)
        (then best-road is highway with certainty 40 and
              best-road is track with certainty 80))

  (rule (if has-tuning is yes and
            tuning is brabus)
        (then best-road is highway with certainty 40 and
              best-broad is track with certainty 60))

  (rule (if preferred-road is track)
        (then best-road is track with certainty 40))

  (rule (if preferred-road is highway)
        (then best-road is highway with certainty 40))

  (rule (if preferred-road is offroad) 
        (then best-road is offroad with certainty 40))

  (rule (if preferred-road is offroad and
            best-road is track)
        (then best-road is highway))

  (rule (if preferred-road is track and
            best-road is offroad)
        (then best-road is highway))

  (rule (if preferred-road is unknown) 
        (then best-road is offroad with certainty 20 and
              best-road is highway with certainty 20 and
              best-road is track with certainty 20))

  ; Rules for picking the best type

  (rule (if main-mark is walkswagen)
        (then best-type is hatcback with certainty 90))

  (rule (if main-mark is mersedes and
            has-mansory is no)
        (then best-type is usf with certainty 90 and
              best-type is hatcback with certainty 30))

  (rule (if main-component is mersedes and
            has-mansory is yes)
        (then best-type is hatcback with certainty 80 and
              best-type is usf with certainty 50))

  (rule (if main-mark is bmw)
        (then best-type is usf))

  (rule (if main-mark is-not bmw and
            has-tuning is yes and
            tuning is garage)
        (then best-type is hatcback))

  (rule (if has-tuning is yes and
            tuning is brabus)
        (then best-type is usf with certainty 40))
                   
  (rule (if preferred-type is hatcback)
        (then best-type is hatcback with certainty 40))

  (rule (if preferred-type is usf)
        (then best-type is usf with certainty 40))

  (rule (if preferred-type is unknown)
        (then best-type is hatcback with certainty 20 and
              best-type is usf with certainty 20))
  
  ; Rules for picking the best drive

  (rule (if has-tuning is yes and
            tuning is garage)
        (then best-drive is fwd with certainty 90 and
              best-drive is rwd with certainty 40))

  (rule (if preferred-drive is 4wd)
        (then best-drive is 4wd with certainty 40))

  (rule (if preferred-drive is rwd)
        (then best-drive is rwd with certainty 40))

  (rule (if preferred-drive is fwd)
        (then best-drive is fwd with certainty 40))

  (rule (if best-drive is fwd and
            preferred-drive is 4wd)
        (then best-drive is rwd))

  (rule (if best-drive is 4wd and
            preferred-drive is fwd) 
        (then best-drive is rwd))

  (rule (if preferred-drive is unknown)
        (then best-drive is 4wd with certainty 20 and
              best-drive is rwd with certainty 20 and
              best-drive is fwd with certainty 20)))

;;************************
;;* CAR SELECTION RULES *
;;************************

(defmodule CARS (import MAIN ?ALL)
                 (export deffunction get-car-list))

(deffacts any-attributes
  (attribute (name best-type) (value any))
  (attribute (name best-road) (value any))
  (attribute (name best-drive) (value any)))

(deftemplate CARS::car
  (slot name (default ?NONE))
  (multislot type (default any))
  (multislot road (default any))
  (multislot drive (default any)))



(deffacts CARS::the-car-list 
  (car (name "a160") (type hatcback) (road highway) (drive rwd garage))
  (car (name "gle") (type usf) (road offroad) (drive 4wd))
  (car (name "x6") (type usf) (road highway) (drive 4wd))
  (car (name "gla") (type usf) (road highway track) (drive rwd 4wd))
  (car (name "tourag") (type usf) (road offroad) (drive rwd 4wd))
  (car (name "gla") (type usf) (road offroad rwd) (drive rwd fwd))
  (car (name "glc") (type usf) (road track))
  (car (name "x4") (type usf) (road offroad) (drive rwd fwd))
  (car (name "q8") (type usf) (road offroad))
  (car (name "ml") (type usf) (road offroad) (drive 4wd rwd))
  (car (name "a45") (type hatcback) (drive 4wd rwd))
  (car (name "polo") (type hatcback) (road highway) (drive rwd))
  (car (name "a180") (type hatcback) (road track))
  (car (name "x4") (type hatcback) (drive 4wd rwd)))
 
  
(defrule CARS::generate-cars
  (car (name ?name)
        (type $? ?c $?)
        (road $? ?b $?)
        (drive $? ?s $?))
  (attribute (name best-type) (value ?c) (certainty ?certainty-1))
  (attribute (name best-road) (value ?b) (certainty ?certainty-2))
  (attribute (name best-drive) (value ?s) (certainty ?certainty-3))
  =>
  (assert (attribute (name car) (value ?name)
                     (certainty (min ?certainty-1 ?certainty-2 ?certainty-3)))))

(deffunction CARS::car-sort (?w1 ?w2)
   (< (fact-slot-value ?w1 certainty)
      (fact-slot-value ?w2 certainty)))
      
(deffunction CARS::get-car-list ()
  (bind ?facts (find-all-facts ((?f attribute))
                               (and (eq ?f:name car)
                                    (>= ?f:certainty 20))))
  (sort car-sort ?facts))
  

