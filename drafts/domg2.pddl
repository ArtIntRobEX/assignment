
; == CONTINUOUS WITH LOADER TIME ===============================================

(define (domain gripper-continuous)
    ; (:requirements :typing :strips :fluents :processes :events)

    (:types mover loader crate group)

    (:predicates
        (free ?m - mover)
        (carry ?c - crate ?m - mover) 
        (moving ?m - mover) 
        (topositive ?m)
        (busyloading ?l - loader ?c - crate)
        (isloaded ?c - crate)
        (equal ?m1 - mover ?m2 - mover)
        (ischeap ?l - loader)
        (isfragile ?c - crate)

        (belongtogroup ?c - crate ?g - group)
        (curr_group ?g - group)
        (iscurrentgroup ?g - group ?curr_gr - group)
        (hasgoup ?c - crate)

    )

    (:functions
        (rob_position ?m - mover)
        (position ?c - crate)
        (velocity)
        (loadertimer ?l - loader)
        (weight ?c - crate)
        
        (belongto)
        
    )

    (:action start_forward
        :parameters (?m - mover)
        :precondition (and 
            (not (moving ?m)) (= (rob_position ?m) 0) (free ?m)
        )
        :effect (and 
            (moving ?m) (topositive ?m) 
        )
    )
    (:process goto_pickup
        :parameters (?m - mover)
        :precondition (and
            (moving ?m) (topositive ?m) (free ?m) 
        )
        :effect (and
            (increase (rob_position ?m) (* #t 1))
        )
    )
    (:action stop_at_crate
        :parameters (?m - mover ?c - crate)
        :precondition (and
            (moving ?m) (topositive ?m) (= (rob_position ?m) (position ?c)) (not (isloaded ?c)) (> (position ?c) 0) 
        )
        :effect (and
            (not (moving ?m))
        )
    )
    (:action pickup
        :parameters (?m - mover ?c - crate ) 
        :precondition (and
            (not(hasgoup ?c))
            (not (moving ?m)) (topositive ?m) (= (rob_position ?m) (position ?c)) (not (isloaded ?c)) (> (position ?c) 0) (<= (weight ?c) 50) (not (isfragile ?c)) (free ?m)
        )
        :effect (and
            (moving ?m) (not (topositive ?m)) (carry ?c ?m) (not (free ?m))
        )
    )

    (:action pickup_group
        :parameters (?c - crate ?g - group ?curr_g - group ?m - mover)
        :precondition (and 
            (belongtogroup ?c ?g) (hasgoup ?c)
            (not (moving ?m)) (topositive ?m) (= (rob_position ?m) (position ?c)) (not (isloaded ?c)) (> (position ?c) 0) (<= (weight ?c) 50) (not (isfragile ?c)) (free ?m)
            (exists (?c - crate) (and (belongtogroup ?c ?g) (not(isloaded ?c))))
            
        )
        :effect (and 
            (when (and(iscurrentgroup ?g ?curr_g)) 
               (and (moving ?m) (not (topositive ?m)) (carry ?c ?m) (not (free ?m)))
            )
            (when(and(not(iscurrentgroup ?g ?curr_g)) (not(exists (?c - crate) (and (belongtogroup ?c ?g) (not(isloaded ?c))))))
                (and  (moving ?m) ( not (topositive ?m)) (carry ?c ?m) (not (free ?m)) (curr_group ?g))
            )
        )
     )



    (:action pickup_by_two
        :parameters (?m1 - mover ?m2 - mover ?c - crate)
        :precondition (and
            (not (equal ?m1 ?m2)) (free ?m1) (free ?m2)
            (not (moving ?m1)) (topositive ?m1) (= (rob_position ?m1) (position ?c))
            (not (moving ?m2)) (topositive ?m2) (= (rob_position ?m2) (position ?c)) 
            (not (isloaded ?c)) (> (position ?c) 0)
        )
        :effect (and
            (moving ?m1) (not (topositive ?m1)) (carry ?c ?m1) (not (free ?m1))
            (moving ?m2) (not (topositive ?m2)) (carry ?c ?m2) (not (free ?m2))
        )
    )
    (:process backto_loader
        :parameters (?m - mover ?c - crate)
        :precondition (and
            (moving ?m) (not (topositive ?m)) (carry ?c ?m) (> (rob_position ?m) 0) (<= (weight ?c) 50) (not (isfragile ?c))
        )
        :effect (and
            (decrease (rob_position ?m) (* #t 1.0)) (decrease (position ?c) (* #t 1.0))
        )
    )
    (:process backto_loader_by_two
        :parameters (?m1 - mover ?m2 - mover ?c - crate)
        :precondition (and
            (not (equal ?m1 ?m2))
            (moving ?m1) (not (topositive ?m1)) (carry ?c ?m1) (> (rob_position ?m1) 0) 
            (moving ?m2) (not (topositive ?m2)) (carry ?c ?m2) (> (rob_position ?m2) 0)
        )
        :effect (and
            (decrease (rob_position ?m1) (* #t 1.0)) (decrease (rob_position ?m2) (* #t 1.0))
            (decrease (position ?c) (* #t 1.0))
        )
    )
    (:event stop_handover
        :parameters (?m - mover ?c - crate ?l - loader)
        :precondition (and
            (or (= (rob_position ?m) 0) (= (position ?c) 0)) (moving ?m) (not (topositive ?m)) (carry ?c ?m) (not (busyloading ?l ?c)) (<= (weight ?c) 50) (not (isfragile ?c))
        )
        :effect (and
            (not (moving ?m)) (topositive ?m) (not (carry ?c ?m)) (busyloading ?l ?c) (free ?m)
        )
    )
    (:event stop_handover_by_two
        :parameters (?m1 - mover ?m2 - mover ?c - crate ?l - loader)
        :precondition (and
            (not (equal ?m1 ?m2))
            (= (rob_position ?m1) 0) (= (position ?c) 0) (moving ?m1) (not (topositive ?m1)) (carry ?c ?m1)
            (= (rob_position ?m2) 0) (moving ?m2) (not (topositive ?m2)) (carry ?c ?m2) (or (not (ischeap ?l)) (<= (weight ?c) 50))
            (not (busyloading ?l ?c))
        )
        :effect (and
            (not (moving ?m1)) (topositive ?m1) (not (carry ?c ?m1)) (free ?m1) 
            (not (moving ?m2)) (topositive ?m2) (not (carry ?c ?m2)) (free ?m2)
            (busyloading ?l ?c)
        )
    )
    (:process load
        :parameters (?l - loader ?c - crate)
        :precondition (and 
            (busyloading ?l ?c) 
            (or (and (< (loadertimer ?l) 4) (not (isfragile ?c))) (and (< (loadertimer ?l) 6) (isfragile ?c))) 
        )
        :effect (increase (loadertimer ?l) (* #t 1))
    )
    (:event doneload
        :parameters (?c - crate ?l - loader)
        :precondition (and 
            (busyloading ?l ?c)
            (or (and (= (loadertimer ?l) 4) (not (isfragile ?c))) (and (= (loadertimer ?l) 6) (isfragile ?c))) 
        )
        :effect (and (assign (loadertimer ?l) 0) (not (busyloading ?l ?c)) (isloaded ?c))
    )
       
)

