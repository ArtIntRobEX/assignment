(define (problem gripper-problem)
    (:domain gripper-continuous)

    (:objects
        mover1 mover2 - mover
        crate1 crate2 - crate
        loader1 loader2 - loader
        G0 GA - group
    )

    (:init
        (free mover1)
        (free mover2)
        (toPositive mover1)
        (toPositive mover2)
        (different mover1 mover2)
        (different mover2 mover1)
        (= (rob_position mover1) 0)  
        (= (rob_position mover2) 0)  
        (not (moving mover1))
        (not (moving mover2))
        (= (battery mover1) 20)
        (= (battery mover2) 20)
        (= (maxBattery) 20)
        
        (= (max_vel mover1) 10)
        (= (max_vel mover2) 10)
        
        (= (velocity mover1) 10)
        (= (velocity mover2) 10)

        (not(coefficientSet))
        
        (available crate1)
        (available crate2)

        (inGroup crate1 G0)
        (inGroup crate2 GA)

        (isCurrentGroup GA)
        (next-group GA G0)

        (= (remaining-in-group G0) 1)
        (= (remaining-in-group GA) 1)

        (not (isLoaded crate1))
        (not (isLoaded crate2))
        (not (isCarried crate1))
        (not (isCarried crate2))
        (= (position crate1) 10)
        (= (position crate2) 20)
        (= (weight crate1) 70)
        (= (weight crate2) 20)
        (not (isFragile crate1))
        (not (isFragile crate2))

        (= (loaderTimer loader1) 0)
        (= (loaderTimer loader2) 0)
        (freeLoader loader1)
        (freeLoader loader2) 
        (not (isCheap loader2))
        (isCheap loader1)

        (freeLoader loader1)
        (freeLoader loader2)

    )

    (:goal
        (and 
            ; (isCarried crate1)
            (isCarried crate2)
        )
    )

    ; (:metric minimize (total-time))

)
