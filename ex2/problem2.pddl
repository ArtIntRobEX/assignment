(define (problem simple-problem)
  (:domain simple-warehouse)

  (:objects
    ;; Movers and loader
    m1 m2 - mover
    l1 - loader

    ;; Crates
    c1 c2 - crate
    c3 c4 - crate
    c5 c6 - crate

    ;; Groups
    GA GB GC - group
  )

  (:init
    ;; Loader and movers
    (free m1)
    (free m2)
    (= (position m1) 0)
    (= (position m2) 0)
    (= (velocity m1) 10)
    (= (velocity m2) 10)
    (loading-bay-free)

    ;; Group A setup
    (active-group GA)
    (crate-in-group c1 GA)
    (crate-in-group c2 GA)
    (= (remaining-in-group GA) 2)

    ;; Group B setup
    (next-group GA GB)
    (crate-in-group c3 GB)
    (crate-in-group c4 GB)
    (= (remaining-in-group GB) 2)

    ;; Group C setup
    (next-group GB GC)
    (crate-in-group c5 GC)
    (crate-in-group c6 GC)
    (= (remaining-in-group GC) 2)

    ;; Crates in Group A
    (= (weight c1) 30)
    (available c1)
    (= (distance c1) 10)
    (needs-loading c1)
    (= (time-to-load c1) 0)

    (= (weight c2) 30)
    (available c2)
    (= (distance c2) 20)
    (needs-loading c2)
    (= (time-to-load c2) 0)

    ;; Crates in Group B
    (= (weight c3) 30)
    (available c3)
    (= (distance c3) 30)
    (needs-loading c3)
    (= (time-to-load c3) 0)

    (= (weight c4) 30)
    (available c4)
    (= (distance c4) 40)
    (needs-loading c4)
    (= (time-to-load c4) 0)

    ;; Crates in Group C
    (= (weight c5) 30)
    (available c5)
    (= (distance c5) 50)
    (needs-loading c5)
    (= (time-to-load c5) 0)

    (= (weight c6) 30)
    (available c6)
    (= (distance c6) 60)
    (needs-loading c6)
    (= (time-to-load c6) 0)
  )

  (:goal
    (and
      (loaded c1)
      (loaded c2)
      (loaded c3)
      (loaded c4)
      (loaded c5)
      (loaded c6)
    )
  )
)
