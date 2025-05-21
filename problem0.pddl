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
        (= (maxbattery) 20)
        
        (= (max_vel mover1) 10)
        (= (max_vel mover2) 10)
        
        (= (velocity mover1) 10)
        (= (velocity mover2) 10)

        (not(coeff_set))
        
        (crate crate1)
        (crate crate2)
        (not (isloaded crate1))
        (not (isloaded crate2))
        (not (iscarried crate1))
        (not (iscarried crate2))
        (= (position crate1) 10)
        (= (position crate2) 20)
        (= (weight crate1) 70)
        (= (weight crate2) 20)
        (not (isfragile crate1))
        (not (isfragile crate2))
        (= (belong crate1) 0)
        (= (belong crate2) 1)
        (group A)
        (= (numofgroup A) 1)
        
        (= (elementspergroup A) 1)
        
        (not (currentgroupset))
        (= (currentgroup) 0)

        (loader loader1)
        (loader loader2)
        (= (loadertimer loader1) 0)
        (= (loadertimer loader2) 0)
        (not (loading loader1))
        (not (loading loader2))
        (not (busyloading loader1 crate1)) 
        (not (busyloading loader2 crate1))
        (not (busyloading loader1 crate2)) 
        (not (busyloading loader2 crate2)) 
        (not (ischeap loader2))
        (ischeap loader1)

        (freeloader loader1)
        (freeloader loader2)

    )

    (:goal
        (and 
            (isloaded crate1)
            ; (isloaded crate2)
        )
    )

    ; (:metric minimize (total-time))

)
