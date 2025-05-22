(define (problem gripper-problem)
    (:domain gripper-continuous)

    (:objects
        mover1 mover2 - mover
        crate1 crate2 crate3 crate4 crate5 - crate
        loader1 loader2 - loader
    )

    (:init
        (mover mover1)
        (mover mover2)
        (free mover1)
        (free mover2)
        (= (velocity) 1)
        (equal mover1 mover1)
        (equal mover2 mover2)
        
        ; (= (max_vel mover1) 6)
        ; (= (max_vel mover2) 6)
        
        (= (rob_position mover1) 0)  
        ; (= (velocity mover1) 6)
        (= (rob_position mover2) 0)  
        ; (= (velocity mover2) 6)
        
        (not (moving mover1))
        (not (moving mover2))
        
        (crate crate1)
        (crate crate2)
        (crate crate3)
        (crate crate4)
        (crate crate5)
        (not (isLoaded crate1))
        (not (isLoaded crate2))
        (not (isLoaded crate3))
        (not (isLoaded crate4))
        (not (isLoaded crate5))
        (= (position crate1) 10)
        (= (position crate2) 20)
        (= (position crate3) 30)
        (= (position crate4) 40)
        (= (position crate5) 40)
        (= (weight crate1) 7)
        (= (weight crate2) 90)
        (= (weight crate3) 2)
        (= (weight crate4) 6)
        (= (weight crate5) 7)
        (not (isFragile crate1))
        (not (isFragile crate2))
        (not (isFragile crate3))
        (isFragile crate4)
        (not (isFragile crate5))
        
        (loader loader1)
        (= (loaderTimer loader1) 0)
        (not (busyLoading loader1)) 
        (loader loader2)
        (= (loaderTimer loader2) 0)
        (not (busyLoading loader2)) 
        (not (isCheap loader2))
        (not (isCheap loader1))
    )

    (:goal
        (and 
            (isLoaded crate1)
            (isLoaded crate2)
            (isLoaded crate3)
            (isLoaded crate4)
            (isLoaded crate5)
        )
    )

)