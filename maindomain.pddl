(define (domain gripper-continuous)
    (:requirements :typing :strips :conditional-effects :negative-preconditions :disjunctive-preconditions :fluents :durative-actions)
    ; (:requirements :conditional-effects :typing :strips :fluents :processes :events)

    (:types mover loader crate group)

    (:predicates
        (free ?m - mover)
        (carry ?c - crate ?m - mover)
        (isCarried ?c - crate ) 
        (moving ?m - mover) 
        (toPositive ?m)
        (moverTarget ?m - mover ?c - crate )
        (busyLoading ?l - loader ?c - crate)
        (isLoaded ?c - crate)
        (equal ?m1 - mover ?m2 - mover)
        (isCheap ?l - loader)
        (isFragile ?c - crate)
        (currentGroupSet)
        (freeloader ?l - loader)
        (at_company ?c - crate)
        (coefficientSet)
    )

    (:functions
        (velocity ?m - mover)
        (max_vel ?m - mover)
        (rob_position ?m - mover)
        (position ?c - crate)
        (loaderTimer ?l - loader)
        (weight ?c - crate)
        (belong ?c - crate)
        (currentGroup)
        (numOfGroup ?g - group)
        (elementsPerGroup ?g - group)
        (battery ?m - mover)
        (maxBattery)
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
            (not(moving ?m))(=(rob_position ?m)0) (< (battery ?m) (maxBattery))(free ?m)
        )
        :effect (and
            (assign (battery ?m)  (maxBattery))
        )
    )
    
    (:action move_to_crate
        :parameters (?m - mover ?c - crate)
        :precondition (and
            (not (moving ?m)) (= (rob_position ?m) 0)  (> (position ?c) 0)
            (not (isCarried ?c )) (not (isLoaded ?c)) (free ?m)
        )
        :effect (and 
            (moving ?m) (toPositive ?m) 
            (moverTarget ?m ?c)
        )
    )

    (:process moving_to_crate
        :parameters (?m - mover)
        :precondition (and
            (moving ?m) (toPositive ?m) (free ?m) 
        )
        :effect (and
            (increase (rob_position ?m) (* #t (velocity ?m)))
        )
    )

    (:event stop_at_crate
        :parameters (?m - mover ?c - crate)
        :precondition (and
            (moving ?m) (toPositive ?m) 
            (moverTarget ?m ?c)
            (= (rob_position ?m) (position ?c)) 
            (not (isLoaded ?c)) (> (position ?c) 0) 
        )
        :effect (and
            (not (moving ?m))
        )
    )

    (:event switch_group
        :parameters (?g - group )
        :precondition (and 
            (= (elementsPerGroup ?g) 0) 
            (= (numOfGroup ?g) 
            (currentGroup)) 
            (currentGroupSet)
        )
        :effect (and (not (currentGroupSet)))
    )
    
    ; for picking up stray crates
    (:action pickup_crate
        :parameters (?m - mover ?c - crate )
        :precondition (and
            (> (battery ?m) 0)
            (moverTarget ?m ?c )
            (not (moving ?m)) (= (rob_position ?m) (position ?c)) (toPositive ?m) 
            (not (isLoaded ?c)) (not (isCarried ?c)) (free ?m)
            (> (position ?c) 0) (<= (weight ?c) 50) (not (isFragile ?c)) 
            (not (currentGroupSet)) (= (belong ?c) 0) (= (currentGroup) 0)
        )
        :effect (and
            (moving ?m) (not (toPositive ?m))
            (not (moverTarget ?m ?c ))
            (carry ?c ?m)  (not (isCarried ?c)) (not (free ?m))
            (assign (velocity ?m) (/ 100 (weight ?c)))
            ;(assign (velocity ?m) (/ (* (position ?c) (weight ?c)) 100))
            
        )
    )
    ; for setting new groups or following previously-set groups
    (:action pickup_crate_same_group
        :parameters (?m - mover ?c - crate ?g - group)
        :precondition (and
            (> (battery ?m) 0)
            (moverTarget ?m ?c )
            (not (moving ?m)) (= (rob_position ?m) (position ?c))  (toPositive ?m) 
            (not (isLoaded ?c)) (not (isCarried ?c)) (free ?m)
            (> (position ?c) 0) (<= (weight ?c) 50) (not (isFragile ?c)) 
            (= (belong ?c) (numOfGroup ?g)) (>= (belong ?c) 0)
            (or (not (currentGroupSet)) (= (belong ?c) (currentGroup)))
        )
        :effect (and
            (moving ?m) (not (toPositive ?m))
            (not (moverTarget ?m ?c ))
            (carry ?c ?m) (isCarried ?c) (not (free ?m))
            (assign (velocity ?m) (/ 100 (weight ?c)))
            (assign (currentGroup) (belong ?c)) 
            (currentGroupSet) 
            (decrease (elementsPerGroup ?g) 1) 
            ;(assign (velocity ?m) (/ (* (position ?c) (weight ?c)) 100))
        )
    )
    
    (:action pickup_by_two
        :parameters (?m1 - mover ?m2 - mover ?c - crate)
        :precondition (and
            (> (battery ?m1) 0)
            (> (battery ?m2) 0)
            (moverTarget ?m1 ?c )
            (moverTarget ?m1 ?c )
            (not (equal ?m1 ?m2)) (free ?m1) (free ?m2)
            (not (moving ?m1)) (toPositive ?m1) (= (rob_position ?m1) (position ?c))
            (not (moving ?m2)) (toPositive ?m2) (= (rob_position ?m2) (position ?c))
            (or (isFragile ?c) (>= (weight ?c) 50))
            (not (isLoaded ?c)) (not (isCarried ?c)) (> (position ?c) 0)
            (not (currentGroupSet)) (= (belong ?c) 0) (= (currentGroup) 0)
            (not (coefficientSet))
        )
        :effect (and        
            (moving ?m1) (not (toPositive ?m1)) (carry ?c ?m1) (not (free ?m1))
            (moving ?m2) (not (toPositive ?m2)) (carry ?c ?m2) (not (free ?m2))
            (not (moverTarget ?m1 ?c ))
            (not (moverTarget ?m1 ?c ))
            (isCarried ?c)
            (coefficientSet)
        )
    )
    (:action pickup_by_two_same_group
        :parameters (?m1 - mover ?m2 - mover ?c - crate ?g - group)
        :precondition (and
            (> (battery ?m1) 0)
            (> (battery ?m2) 0)
            (moverTarget ?m1 ?c )
            (moverTarget ?m1 ?c )
            (not (equal ?m1 ?m2)) (free ?m1) (free ?m2)
            (not (moving ?m1)) (toPositive ?m1) (= (rob_position ?m1) (position ?c))
            (not (moving ?m2)) (toPositive ?m2) (= (rob_position ?m2) (position ?c)) 
            (not (isLoaded ?c)) (not (isCarried ?c)) (> (position ?c) 0)
            (or (isFragile ?c) (>= (weight ?c) 50))
            (= (belong ?c) (numOfGroup ?g)) (> (belong ?c) 0) 
            (or (not (currentGroupSet)) (= (belong ?c) (currentGroup)))
            (not (coefficientSet))
        )
        :effect (and        
            (moving ?m1) (not (toPositive ?m1)) (carry ?c ?m1) (not (free ?m1))
            (moving ?m2) (not (toPositive ?m2)) (carry ?c ?m2) (not (free ?m2))
            (not (moverTarget ?m1 ?c ))
            (not (moverTarget ?m1 ?c ))
            (isCarried ?c)
            (coefficientSet)
            (assign (currentGroup) (belong ?c)) 
            (currentGroupSet) 
            (decrease (elementsPerGroup ?g) 1) 
        )
    )

    (:event coefficient_changer_light
        :parameters(?m1 - mover ?m2 - mover ?c - crate)
        :precondition (and (coefficientSet) (carry ?c ?m1) (carry ?c ?m2) (not (equal ?m1 ?m2)) (< (weight ?c) 50))
        :effect(and
            (assign (velocity ?m1) (/ 150 (weight ?c)))
            (assign (velocity ?m2) (/ 150 (weight ?c)))
            ;(assign (velocity ?m1) (/ (* (position ?c) (weight ?c)) 150))
            ;(assign (velocity ?m2) (/ (* (position ?c) (weight ?c)) 150))
            (not(coefficientSet))
        )
    )

    (:event coefficient_changer_heavy
        :parameters(?m1 - mover ?m2 - mover ?c - crate)
        :precondition (and (coefficientSet) (carry ?c ?m1) (carry ?c ?m2) (not (equal ?m1 ?m2)) (>= (weight ?c) 50))
        :effect(and
            (assign (velocity ?m1) (/ 100 (weight ?c)))
            (assign (velocity ?m2) (/ 100 (weight ?c)))
            ; (assign (velocity ?m1) (/ (* (position ?c) (weight ?c)) 100))
            ; (assign (velocity ?m2) (/ (* (position ?c) (weight ?c)) 100))
            (not(coefficientSet))
        )
    )

    (:action move_back
        :parameters (?m - mover ?c - crate)
        :precondition (and
            (> (battery ?m) 0)
            (carry ?c ?m)
            (isCarried ?c)
            (> (rob_position ?m) 0)
            (> (position ?c) 0)
            (not (free ?m))
            (not (toPositive ?m))
        )
        :effect (moving ?m)
    )

    (:process moving_back
        :parameters (?m - mover)
        :precondition (and (moving ?m) (not (toPositive ?m)))
        :effect (decrease (rob_position ?m) (* #t (velocity ?m)))
    )

    (:event release_crate
        :parameters (?m - mover ?c - crate ?l - loader)
        :precondition (and
            (<= (rob_position ?m) 0) (moving ?m) (not (toPositive ?m)) (carry ?c ?m) 
            (<= (weight ?c) 50)
            (not (isFragile ?c))
            (not (busyLoading ?l ?c)) (freeloader ?l) (isCarried ?c )
            (or 
                (and (= (belong ?c) 0) ) ; (not (currentGroupSet)) can be added, it's correct but may reduce parallelism 
                (and (> (belong ?c) 0) (= (belong ?c) (currentGroup)))
            )
        )
        :effect (and
            (not (moving ?m)) (toPositive ?m) 
            (not (carry ?c ?m)) (not (isCarried ?c )) (free ?m)
            (busyLoading ?l ?c) (not (freeloader ?l))
            (assign (rob_position ?m) 0) (assign (position ?c) 0)
            (assign (velocity ?m) (max_vel ?m))
            

        )
    )

    (:event release_crate_by_two
        :parameters (?m1 - mover ?m2 - mover ?c - crate ?l - loader)
        :precondition (and
            (not (equal ?m1 ?m2))
            (<= (rob_position ?m1) 0) (moving ?m1) (not (toPositive ?m1)) (carry ?c ?m1)
            (<= (rob_position ?m2) 0) (moving ?m2) (not (toPositive ?m2)) (carry ?c ?m2) 
            (not (busyLoading ?l ?c)) (freeloader ?l) (isCarried ?c )
            (or (not (isCheap ?l)) (<= (weight ?c) 50))
            (or 
                (and (= (belong ?c) 0) ) ; (not (currentGroupSet)) can be added, it's correct but may reduce parallelism 
                (and (> (belong ?c) 0) (= (belong ?c) (currentGroup)))
            )
        )
        :effect (and
            (not (moving ?m1)) (toPositive ?m1) (not (carry ?c ?m1)) (free ?m1) 
            (not (moving ?m2)) (toPositive ?m2) (not (carry ?c ?m2)) (free ?m2)
            (not (isCarried ?c ))
            (assign (rob_position ?m1) 0) (assign (rob_position ?m2) 0) (assign (position ?c) 0)
            (assign (velocity ?m1) (max_vel ?m1))
            (assign (velocity ?m2) (max_vel ?m2))
        )
    )

    (:action start_loading
        :parameters (?l - loader ?c - crate )
        :precondition (and
            ;; Crate just released
            (not (isCarried ?c))
            (not (isLoaded ?c))
            (not (busyLoading ?l ?c))
            (= (position ?c) 0)
        )
        :effect (and
            (assign (loaderTimer ?l) 0)
            (busyLoading ?l ?c)
            (not (freeloader ?l))
        )
    )

    (:process loading_in_progress
        :parameters (?l - loader ?c - crate)
        :precondition (and
            (busyLoading ?l ?c)
            (not (freeloader ?l))
            (or 
                (and (< (loaderTimer ?l) 4) (not (isFragile ?c)))
                (and (< (loaderTimer ?l) 6) (isFragile ?c))
            )
        )
        :effect (increase (loaderTimer ?l) (* #t 1))
    )

    (:event loading_done
        :parameters (?l - loader ?c - crate)
        :precondition (and
            (busyLoading ?l ?c)
            (not (freeloader ?l))
            (or 
                (and (= (loaderTimer ?l) 4) (not (isFragile ?c)))
                (and (= (loaderTimer ?l) 6) (isFragile ?c))
            )
        )
        :effect (and
            (freeloader ?l)
            (not (busyLoading ?l ?c))
            (isLoaded ?c)
            (assign (loaderTimer ?l) 0)
        )
    )
)
