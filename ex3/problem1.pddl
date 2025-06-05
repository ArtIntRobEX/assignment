(define (problem simple-problem)
  (:domain simple-warehouse)

  (:objects
    m1 m2 - mover
    l1 - loader
    c1 c2 - crate
    GA - group
  )

  (:init
    ;; Loader and movers
    (free m1)
    (free m2)
    (= (position m1) 0)
    (= (position m2) 0)
    (= (velocity m1) 10)
    (= (velocity m2) 10)
    (= (battery m1) 20)
    (= (battery m2) 20)
    (= (maxBattery) 20)
    (loading-bay-free)

    ;; Group setup
    (active-group GA)
    (crate-in-group c1 GA)
    (crate-in-group c2 GA)
    (= (remaining-in-group GA) 2)

    ;; Crate c1
    (= (weight c1) 30)
    (available c1)
    (= (distance c1) 10)
    (needs-loading c1)
    (= (time-to-load c1) 0)

    ;; Crate c2
    (= (weight c2) 30)
    (available c2)
    (= (distance c2) 10)
    (needs-loading c2)
    (= (time-to-load c2) 0)
  )

  (:goal
    (and
      (loaded c1)
      (loaded c2)
    )
  )
)
