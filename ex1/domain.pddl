(define (domain numbered-ball-sorting)
  (:requirements :typing :strips :negative-preconditions :fluents :durative-actions)

  (:types ball group)

  (:predicates
    (ball-in-box ?b - ball) ;isLoaded
    (available ?b - ball) ;new one
    (ball-in-group ?b - ball ?g - group) ;new
    (is-current-group ?g - group)
  )

  (:functions
    (remaining-in-group ?g - group) ;new
  )

  (:action put-in-box
    :parameters (?b - ball ?g - group)
    :precondition (and
      (available ?b)
      (ball-in-group ?b ?g)
      (is-current-group ?g)
    )
    :effect (and
      (ball-in-box ?b)
      (not (available ?b))
      (decrease (remaining-in-group ?g) 1)
    )
  )

  (:action advance-group
    :parameters (?g1 ?g2 - group)
    :precondition (and
      (is-current-group ?g1)
      (= (remaining-in-group ?g1) 0)
    )
    :effect (and
      (not (is-current-group ?g1))
      (is-current-group ?g2)
    )
  )
)
