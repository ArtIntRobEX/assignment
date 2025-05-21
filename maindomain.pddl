(define (domain gripper-continuous)
    ; (:requirements :conditional-effects :typing :strips :fluents :processes :events)

    (:types mover loader crate group)

    (:predicates
        (free ?m - mover)
        (carry ?c - crate ?m - mover) 
        (iscarried ?c - crate )
        (moving ?m - mover) 
        (loading ?l - loader)
        (busyloading ?l - loader ?c - crate)
        (isloaded ?c - crate)
        (equal ?m1 - mover ?m2 - mover)
        (ischeap ?l - loader)
        (isfragile ?c - crate)
        (currentgroupset)
        (freeloader ?l - loader)
        (coeff_set)
    )

    (:functions
        (velocity ?m - mover)
        (max_vel ?m - mover)
        (rob_position ?m - mover)
        (position ?c - crate)
        (loadertimer ?l - loader)
        (weight ?c - crate)
        (belong ?c - crate)
        (currentgroup)
        (numofgroup ?g - group)
        (elementspergroup ?g - group)
        (battery ?m - mover)
        (maxbattery)
    )

    (:process consuming_battery
        :parameters (?m - mover)
        :precondition (and
            (moving ?m) (> (battery ?m) 0)(>(rob_position ?m)1)
        )
        :effect (decrease (battery ?m) (* #t 1)
        )
    )
    (:event charge_battery
        :parameters (?m - mover)
        :precondition (and
            (not(moving ?m))(=(rob_position ?m)0) (< (battery ?m) (maxbattery))(free ?m)
        )
        :effect (and
            (assign (battery ?m)  (maxbattery))
        )
    )    
    
    (:action move_to_crate
        :parameters (?m - mover)
        :precondition (and 
            (not (moving ?m)) (= (rob_position ?m) 0) (free ?m)
        )
        :effect (and 
            (moving ?m)  
        )
    )
    (:process moving_to_crate
        :parameters (?m - mover)
        :precondition (and
            (moving ?m) (free ?m) 
        )
        :effect (and
            (increase (rob_position ?m) (* #t (velocity ?m)))
        )
    )
    (:event stop_at_crate
        :parameters (?m - mover ?c - crate)
        :precondition (and
            (moving ?m) (>= (rob_position ?m) (position ?c)) (not (isloaded ?c)) (> (position ?c) 0) 
        )
        :effect (and
            (not (moving ?m))
        )
    )
    (:event switch_group
        :parameters (?g - group )
        :precondition (and 
            (= (elementspergroup ?g) 0) 
            (= (numofgroup ?g) 
            (currentgroup)) 
            (currentgroupset)
        )
        :effect (and (not (currentgroupset)))
    )
    
    ; for picking up stray crates
    (:action pickup_crate
        :parameters (?m - mover ?c - crate )
        :precondition (and
            (not (moving ?m)) (= (rob_position ?m) (position ?c)) 
            (not (iscarried ?c )) (not (isloaded ?c)) (free ?m)
            (> (position ?c) 0) (<= (weight ?c) 50) (not (isfragile ?c)) 
            (not (currentgroupset)) (= (belong ?c) 0) (= (currentgroup) 0)
            (> (battery ?m) 0)
        )
        :effect (and
            (moving ?m) (carry ?c ?m) (iscarried ?c) (not (free ?m))
            (assign (velocity ?m) (/ 100 (weight ?c)))
            ;(assign (velocity ?m) (/ (* (position ?c) (weight ?c)) 100))
        )
    )
    ; for setting new groups or following previously-set groups
    (:action pickup_crate_same_group
        :parameters (?m - mover ?c - crate ?g - group)
        :precondition (and
            (> (battery ?m) 0)
            (not (moving ?m)) (= (rob_position ?m) (position ?c)) 
            (not (iscarried ?c )) (not (isloaded ?c)) (free ?m)
            (> (position ?c) 0) (<= (weight ?c) 50) (not (isfragile ?c)) 
            (= (belong ?c) (numofgroup ?g)) (> (belong ?c) 0)
            (or (not (currentgroupset)) (= (belong ?c) (currentgroup)) )
        )
        :effect (and
            (assign (currentgroup) (belong ?c)) 
            (currentgroupset) 
            (decrease (elementspergroup ?g) 1) 
            (moving ?m)
            (carry ?c ?m) (iscarried ?c) (not (free ?m))
            (assign (velocity ?m) (/ 100 (weight ?c)))
            ;(assign (velocity ?m) (/ (* (position ?c) (weight ?c)) 100))
        )
    )
    
    (:action pickup_by_two
        :parameters (?m1 - mover ?m2 - mover ?c - crate)
        :precondition (and
            (> (battery ?m1) 0)
            (> (battery ?m2) 0)
            (not (equal ?m1 ?m2)) (free ?m1) (free ?m2)
            (not (moving ?m1)) (= (rob_position ?m1) (position ?c))
            (not (moving ?m2)) (= (rob_position ?m2) (position ?c)) 
            (not (iscarried ?c)) (not (isloaded ?c)) (> (position ?c) 0)
            (not (currentgroupset)) (= (belong ?c) 0) (= (currentgroup) 0)
            (not (coeff_set))
        )
        :effect (and        
            (moving ?m1) (carry ?c ?m1) (not (free ?m1))
            (moving ?m2) (carry ?c ?m2) (not (free ?m2))
            (iscarried ?c)
            (coeff_set)
        )
    )
    (:action pickup_by_two_same_group
        :parameters (?m1 - mover ?m2 - mover ?c - crate ?g - group)
        :precondition (and
            (> (battery ?m1) 0)
            (> (battery ?m2) 0)
            (not (equal ?m1 ?m2)) (free ?m1) (free ?m2)
            (not (moving ?m1)) (= (rob_position ?m1) (position ?c))
            (not (moving ?m2)) (= (rob_position ?m2) (position ?c)) 
            (not (iscarried ?c)) (not (isloaded ?c)) (> (position ?c) 0)
            (= (belong ?c) (numofgroup ?g)) (> (belong ?c) 0) 
            (or (not (currentgroupset)) (= (belong ?c) (currentgroup)))
            (not (coeff_set))
        )
        :effect (and        
            (moving ?m1) (carry ?c ?m1) (not (free ?m1))
            (moving ?m2) (carry ?c ?m2) (not (free ?m2))
            (assign (currentgroup) (belong ?c)) 
            (currentgroupset) 
            (decrease (elementspergroup ?g) 1) 
            (coeff_set)
            (iscarried ?c)
        )
    )

    (:event coeff_changer_light
        :parameters(?m1 - mover ?m2 - mover ?c - crate)
        :precondition (and (coeff_set) (carry ?c ?m1) (carry ?c ?m2) (not (equal ?m1 ?m2)) (< (weight ?c) 50))
        :effect(and
            (assign (velocity ?m1) (/ 150 (weight ?c)))
            (assign (velocity ?m2) (/ 150 (weight ?c)))
            ;(assign (velocity ?m1) (/ (* (position ?c) (weight ?c)) 150))
            ;(assign (velocity ?m2) (/ (* (position ?c) (weight ?c)) 150))
            (not(coeff_set))
        )
    )

    (:event coeff_changer_heavy
        :parameters(?m1 - mover ?m2 - mover ?c - crate)
        :precondition (and (coeff_set) (carry ?c ?m1) (carry ?c ?m2) (not (equal ?m1 ?m2)) (>= (weight ?c) 50))
        :effect(and
            (assign (velocity ?m1) (/ 100 (weight ?c)))
            (assign (velocity ?m2) (/ 100 (weight ?c)))
            ; (assign (velocity ?m1) (/ (* (position ?c) (weight ?c)) 100))
            ; (assign (velocity ?m2) (/ (* (position ?c) (weight ?c)) 100))
            (not(coeff_set))
        )
    )

    (:action move_back
        :parameters (?m - mover ?c - crate)
        :precondition (and
            (> (battery ?m) 0)
            (carry ?c ?m)
            (iscarried ?c)
            (> (rob_position ?m) 0)
            (> (position ?c) 0)
            (not (free ?m))
        )
        :effect (moving ?m)
    )

    (:process going_back
        :parameters (?m - mover)
        :precondition (moving ?m)
        :effect (decrease (rob_position ?m) (* #t (velocity ?m)))
    )

    (:event release_crate
        :parameters (?m - mover ?c - crate ?l - loader)
        :precondition (and
            (<= (rob_position ?m) 0)
            (moving ?m)
            (iscarried ?c)
            (carry ?c ?m)
            (<= (weight ?c) 50)
            (not (isfragile ?c))
            (freeloader ?l)
            (or 
                (and (= (belong ?c) 0))
                (and (> (belong ?c) 0) (= (belong ?c) (currentgroup)))
            )
        )
        :effect (and
            (not (moving ?m))
            (not (carry ?c ?m)) (not (iscarried ?c)) (free ?m)
            (assign (rob_position ?m) 0)
            (assign (position ?c) 0)
            (assign (velocity ?m) (max_vel ?m))
            (busyloading ?l ?c)
            (not (freeloader ?l))
        )
    )
    (:event release_crate_by_two
        :parameters (?m1 - mover ?m2 - mover ?c - crate ?l - loader)
        :precondition (and
            (not (equal ?m1 ?m2))
            (<= (rob_position ?m1) 0)
            (moving ?m1)
            (iscarried ?c)
            (carry ?c ?m1)

            (<= (rob_position ?m2) 0)
            (moving ?m2)
            (carry ?c ?m2)

            (or (not (ischeap ?l)) (<= (weight ?c) 50))
            (freeloader ?l)
            (or 
                (and (= (belong ?c) 0))
                (and (> (belong ?c) 0) (= (belong ?c) (currentgroup)))
            )
        )
        :effect (and
            (not (moving ?m1)) (not (carry ?c ?m1)) (free ?m1)
            (not (moving ?m2)) (not (carry ?c ?m2)) (free ?m2)
            (not (iscarried ?c))
            (assign (rob_position ?m1) 0)
            (assign (rob_position ?m2) 0)
            (assign (position ?c) 0)
            (assign (velocity ?m1) (max_vel ?m1))
            (assign (velocity ?m2) (max_vel ?m2))
            (busyloading ?l ?c)
            (not (freeloader ?l))
        )
    )

    (:action start_loading
        :parameters (?l - loader ?c - crate)
        :precondition (and
        (busyloading ?l ?c)
        (not (isloaded ?c))
        (not (loading ?l))
        (not (freeloader ?l))
        (= (position ?c) 0)
        (or 
            (and (< (loadertimer ?l) 4) (not (isfragile ?c))) 
            (and (< (loadertimer ?l) 6) (isfragile ?c))
        )
        )
        :effect (loading ?l)
    )


    (:process loading_in_progress
        :parameters (?l - loader ?c - crate)
        :precondition (and
            (busyloading ?l ?c)
            (not (freeloader ?l))
            (loading ?l)
        )
        :effect (increase (loadertimer ?l) (* #t 1))
    )

    (:event finished_loading
        :parameters (?c - crate ?l - loader)
        :precondition (and 
            (loading ?l)
            (busyloading ?l ?c)
            (not (freeloader ?l))
            (or 
                (and (= (loadertimer ?l) 4) (not (isfragile ?c))) 
                (and (= (loadertimer ?l) 6) (isfragile ?c))
            )
        )
        :effect (and 
            (freeloader ?l)
            (assign (loadertimer ?l) 0)
            (not (busyloading ?l ?c))
            (not (loading ?l))
            (isloaded ?c)
        )
    )
)
