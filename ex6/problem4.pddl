(define (problem simple-problem)
  (:domain simple-warehouse)

  (:objects
    m1 m2 - mover
    l1 l2 - loader
    c1 c2 c3 c4 - crate
    GA GB G0 - group
  )

  (:init
    ;; Loader and movers
    (is-cheap-loader l1)
    (free m1)
    (free m2)
    (different m1 m2)
    (= (position m1) 0)
    (= (position m2) 0)
    (= (velocity m1) 10)
    (= (velocity m2) 10)
    (= (battery m1) 20)
    (= (battery m2) 20)
    (= (maxBattery) 20)
    (loading-bay-free)

    ;; Group setup
    (active-group G0)
    (crate-in-group c1 GA)
    (crate-in-group c2 GA)
    (crate-in-group c3 GA)
    (crate-in-group c4 G0)
    (= (remaining-in-group GA) 3)
    (= (remaining-in-group G0) 1)
    (next-group GA G0)
    (next-group G0 GA)

    ;; Crate c1: heavy
    (= (weight c1) 70)
    (available c1)
    (= (distance c1) 20)
    (needs-loading c1)
    (= (time-to-load c1) 0)

    ;; Crate c2: heavy and fragile
    (= (weight c2) 80)
    (available c2)
    (= (distance c2) 20)
    (needs-loading c2)
    (= (time-to-load c2) 0)
    (is-fragile-crate c2)

    ;; Crate c3: heavy
    (= (weight c3) 60)
    (available c3)
    (= (distance c3) 30)
    (needs-loading c3)
    (= (time-to-load c3) 0)

    ;; Crate c4: light
    (= (weight c4) 30)
    (available c4)
    (= (distance c4) 10)
    (needs-loading c4)
    (= (time-to-load c4) 0)

  )

  (:goal
    (and
      (loaded c1)
      (loaded c2)
      (loaded c3)
      (loaded c4)
    )
  )
)
