(define (problem numeric-sort-3groups)
  (:domain numbered-ball-sorting)

  (:objects
    g1 g2 g3 - group
    ball1 ball2 ball3 ball4 ball5 ball6 - ball
  )

  (:init
    ;; All balls start as available
    (available ball1)
    (available ball2)
    (available ball3)
    (available ball4)
    (available ball5)
    (available ball6)

    ;; Group assignments using predicate
    (ball-in-group ball1 g3)
    (ball-in-group ball2 g3)
    (ball-in-group ball3 g2)
    (ball-in-group ball4 g2)
    (ball-in-group ball5 g1)
    (ball-in-group ball6 g1)

    ;; Starting group is g3 (highest)
    (is-current-group g3)

    ;; Initial remaining ball counts per group
    (= (remaining-in-group g1) 2)
    (= (remaining-in-group g2) 2)
    (= (remaining-in-group g3) 2)
  )

  (:goal
    (and
      (ball-in-box ball1)
      (ball-in-box ball2)
      (ball-in-box ball3)
      (ball-in-box ball4)
      (ball-in-box ball5)
      (ball-in-box ball6)
    )
  )
)
