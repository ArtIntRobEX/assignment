(define (problem gripper-problem)
    (:domain gripper-continuous)

    (:objects
        mover1 mover2 - mover
        crate1 crate2 crate3 - crate
        loader1 loader2 - loader
        A - group
    )

    (:init
        (mover mover1)
        (mover mover2)
        (free mover1)
        (free mover2)
        (equal mover1 mover1)
        (equal mover2 mover2)
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
        
        (crate crate1)
        (crate crate2)
        (crate crate3)
        (not (isLoaded crate1))
        (not (isLoaded crate2))
        (not (isLoaded crate3))
        (not (isCarried crate1))
        (not (isCarried crate2))
        (not (isCarried crate3))
        (= (position crate1) 10)
        (= (position crate2) 20)
        (= (position crate3) 20)
        (= (weight crate1) 70)
        (= (weight crate2) 20)
        (= (weight crate3) 20)
        (not (isFragile crate1))
        (isFragile crate2)
        (not (isFragile crate3))
        (= (belong crate1) 0)
        (= (belong crate2) 1)
        (= (belong crate3) 1)
        (group A)
        (= (numOfGroup A) 1)
        
        (= (elementsPerGroup A) 2)
        
        (not (currentGroupSet))
        (= (currentGroup) 0)

        (loader loader1)
        (loader loader2)
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
            (isLoaded crate1)
            (isLoaded crate2)
            (isLoaded crate3)
        )
    )

    ; (:metric minimize (total-time))

)
