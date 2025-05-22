(define (problem gripper-problem)
    (:domain gripper-continuous)

    (:objects
        mover1 mover2 - mover
        crate1 crate2 - crate
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
        (not (isLoaded crate1))
        (not (isLoaded crate2))
        (at_company crate1)
        (at_company crate2)
        (= (position crate1) 10)
        (= (position crate2) 20)
        (= (weight crate1) 70)
        (= (weight crate2) 20)
        (not (isFragile crate1))
        (not (isFragile crate2))
        (= (belong crate1) 0)
        (= (belong crate2) 1)
        (group A)
        (= (numOfGroup A) 1)
        
        (= (elementsPerGroup A) 1)
        
        (not (currentGroupSet))
        (= (currentGroup) 0)

        (loader loader1)
        (loader loader2)
        (= (loaderTimer loader1) 0)
        (= (loaderTimer loader2) 0)
        (freeloader loader1)
        (freeloader loader2) 
        (not (isCheap loader2))
        (isCheap loader1)

        (freeloader loader1)
        (freeloader loader2)

    )

    (:goal
        (and 
            (isLoaded crate1)
            (isLoaded crate2)
        )
    )

    ; (:metric minimize (total-time))

)
