(define (problem simple-problem)
  (:domain simple-warehouse)

  (:objects
    m1 m2 - mover
    l1 - loader
    c1 c2 - crate
    GA G0 - group
  )

  (:init
    ;; Loader and movers
    (free m1)
    (free m2)
    (different m1 m2)
    (= (position m1) 0)
    (= (position m2) 0)
    (= (velocity m1) 10)
    (= (velocity m2) 10)
    (= (max_vel m1) 10)
    (= (max_vel m2) 10)
    (= (battery m1) 20)
    (= (battery m2) 20)
    (= (maxBattery) 50)
    (loading-bay-free)

    ;; Group setup
    (active-group G0)
    (crate-in-group c1 GA)
    (crate-in-group c2 G0)
    (= (remaining-in-group GA) 1)
    (= (remaining-in-group G0) 1)
    (next-group G0 GA)

    ;; Crate c1
    (= (weight c1) 70)
    (available c1)
    (= (distance c1) 10)
    (needs-loading c1)
    (= (time-to-load c1) 0)

    ;; Crate c2
    (= (weight c2) 20)
    (available c2)
    (= (distance c2) 20)
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
