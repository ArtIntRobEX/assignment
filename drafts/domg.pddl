
; == CONTINUOUS WITH LOADER TIME ===============================================

(define (domain gripper-continuous)
    ; (:requirements :typing :strips :fluents :processes :events)

    (:types 
        mover loader crate
        group
    )

    (:predicates
        (free ?m - mover)
        (carry ?c - crate ?m - mover) 
        (moving ?m - mover) 
        (toPositive ?m)
        (busyLoading ?l - loader ?c - crate)
        (isLoaded ?c - crate)
        (equal ?m1 - mover ?m2 - mover)
        (isCheap ?l - loader)
        (isFragile ?c - crate)
        (belong ?c - crate ?g - group)
    )

    (:functions
        (rob_position ?m - mover)
        (position ?c - crate)
        (velocity)
        (loaderTimer ?l - loader)
        (weight ?c - crate)
    )

    (:action start_forward
        :parameters (?m - mover)
        :precondition (and 
            (not (moving ?m)) (= (rob_position ?m) 0) (free ?m)
        )
        :effect (and 
            (moving ?m) (toPositive ?m) 
        )
    )
    (:process goto_pickup
        :parameters (?m - mover)
        :precondition (and
            (moving ?m) (toPositive ?m) (free ?m) 
        )
        :effect (and
            (increase (rob_position ?m) (* #t 1))
        )
    )
    (:action stop_at_crate
        :parameters (?m - mover ?c - crate)
        :precondition (and
            (moving ?m) (toPositive ?m) (= (rob_position ?m) (position ?c)) (not (isLoaded ?c)) (> (position ?c) 0) 
        )
        :effect (and
            (not (moving ?m))
        )
    )
    (:action pickup
        :parameters (?m - mover ?c ?c2 - crate ?g - group)
        :precondition (and
            (not (moving ?m))
            (toPositive ?m)
            (= (rob_position ?m)
            (position ?c))
            (not (isLoaded ?c))
            (> (position ?c) 0)
            (<= (weight ?c) 50)
            (not (isFragile ?c))
            (free ?m)
            ; supercool logic below
            (or 
                (and 
                    (not (isLoaded ?c))
                    (belong ?c ?g)
                    (isLoaded ?c2)
                    (belong ?c2 ?g)
                )
                (not (isLoaded ?c))
            )
        )
        :effect (and
            (moving ?m) (not (toPositive ?m)) (carry ?c ?m) (not (free ?m))
        )
    )
    (:action pickup_by_two
        :parameters (?m1 - mover ?m2 - mover ?c - crate)
        :precondition (and
            (not (equal ?m1 ?m2)) (free ?m1) (free ?m2)
            (not (moving ?m1)) (toPositive ?m1) (= (rob_position ?m1) (position ?c))
            (not (moving ?m2)) (toPositive ?m2) (= (rob_position ?m2) (position ?c)) 
            (not (isLoaded ?c)) (> (position ?c) 0)
        )
        :effect (and
            (moving ?m1) (not (toPositive ?m1)) (carry ?c ?m1) (not (free ?m1))
            (moving ?m2) (not (toPositive ?m2)) (carry ?c ?m2) (not (free ?m2))
        )
    )
    (:process backto_loader
        :parameters (?m - mover ?c - crate)
        :precondition (and
            (moving ?m) (not (toPositive ?m)) (carry ?c ?m) (> (rob_position ?m) 0) (<= (weight ?c) 50) (not (isFragile ?c))
        )
        :effect (and
            (decrease (rob_position ?m) (* #t 1.0)) (decrease (position ?c) (* #t 1.0))
        )
    )
    (:process backto_loader_by_two
        :parameters (?m1 - mover ?m2 - mover ?c - crate)
        :precondition (and
            (not (equal ?m1 ?m2))
            (moving ?m1) (not (toPositive ?m1)) (carry ?c ?m1) (> (rob_position ?m1) 0) 
            (moving ?m2) (not (toPositive ?m2)) (carry ?c ?m2) (> (rob_position ?m2) 0)
        )
        :effect (and
            (decrease (rob_position ?m1) (* #t 1.0)) (decrease (rob_position ?m2) (* #t 1.0))
            (decrease (position ?c) (* #t 1.0))
        )
    )
    (:event stop_handover
        :parameters (?m - mover ?c - crate ?l - loader)
        :precondition (and
            (or (= (rob_position ?m) 0) (= (position ?c) 0)) (moving ?m) (not (toPositive ?m)) (carry ?c ?m) (not (busyLoading ?l ?c)) (<= (weight ?c) 50) (not (isFragile ?c))
        )
        :effect (and
            (not (moving ?m)) (toPositive ?m) (not (carry ?c ?m)) (busyLoading ?l ?c) (free ?m)
        )
    )
    (:event stop_handover_by_two
        :parameters (?m1 - mover ?m2 - mover ?c - crate ?l - loader)
        :precondition (and
            (not (equal ?m1 ?m2))
            (= (rob_position ?m1) 0) (= (position ?c) 0) (moving ?m1) (not (toPositive ?m1)) (carry ?c ?m1)
            (= (rob_position ?m2) 0) (moving ?m2) (not (toPositive ?m2)) (carry ?c ?m2) (or (not (isCheap ?l)) (<= (weight ?c) 50))
            (not (busyLoading ?l ?c))
        )
        :effect (and
            (not (moving ?m1)) (toPositive ?m1) (not (carry ?c ?m1)) (free ?m1) 
            (not (moving ?m2)) (toPositive ?m2) (not (carry ?c ?m2)) (free ?m2)
            (busyLoading ?l ?c)
        )
    )
    (:process load
        :parameters (?l - loader ?c - crate)
        :precondition (and 
            (busyLoading ?l ?c) 
            (or (and (< (loaderTimer ?l) 4) (not (isFragile ?c))) (and (< (loaderTimer ?l) 6) (isFragile ?c))) 
        )
        :effect (increase (loaderTimer ?l) (* #t 1))
    )
    (:event doneload
        :parameters (?c - crate ?l - loader)
        :precondition (and 
            (busyLoading ?l ?c)
            (or (and (= (loaderTimer ?l) 4) (not (isFragile ?c))) (and (= (loaderTimer ?l) 6) (isFragile ?c))) 
        )
        :effect (and (assign (loaderTimer ?l) 0) (not (busyLoading ?l ?c)) (isLoaded ?c))
    )
       
)

