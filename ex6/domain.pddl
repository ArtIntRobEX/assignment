;; Simplified DOMAIN without groups
(define (domain simple-warehouse)
    (:requirements :typing :strips :conditional-effects :negative-preconditions :disjunctive-preconditions :fluents :durative-actions)
    (:types loader mover crate group)

    (:predicates
        (free ?m - mover)
        (different ?m1 ?m2 - mover)
        (carrying ?m - mover ?c - crate)
        (carrying-pair ?m1 ?m2 - mover ?c - crate)
        (mover-moving-to-crate ?m - mover ?c - crate)
        (movers-moving-to-crate ?m1 ?m2 - mover ?c - crate)
        (moving ?m)
        (mover-at-crate ?m - mover ?c - crate)
        (available ?c - crate)
        (is-fragile-crate ?c - crate)
        (crate-in-group ?c - crate ?g - group)
        (crate-at-loading-bay ?c - crate)
        (loading-bay-free)
        (needs-loading ?c - crate)
        (being-loaded ?c - crate)
        (is-carried ?c - crate)
        (loaded ?c - crate)
        (is-cheap-loader ?l - loader)
        
    )

    (:functions
        (weight ?c - crate)
        (distance ?c - crate)
        (position ?m - mover)
        (velocity ?m - mover)
        (current-group-index)
        (group-id ?g - group)
        (time-to-load ?c - crate)
        (remaining-in-group ?g - group)
        (battery ?m - mover) 
        (maxBattery)
    )
    
    (:process consuming_battery
        :parameters (?m - mover)
        :precondition (and
            (moving ?m)
            (> (battery ?m) 0)
            (>(position ?m) 1)
        )
        :effect (decrease (battery ?m) (* #t 1)
        )
    )

    (:event charge_battery
        :parameters (?m - mover)
        :precondition (and
            (not(moving ?m))
            (< (battery ?m) (maxBattery))
            (free ?m)
        )
        :effect (and
            (assign (battery ?m)  (maxBattery))
        )
    )

    ; == Move one mover to the crate ===============================================
    (:action start-move-to-crate
        :parameters (?m - mover ?c - crate ?g - group)
        :precondition (and (free ?m)
            (needs-loading ?c)
            (not (loaded ?c))
            (not (is-carried ?c))
            (available ?c)
            (not (crate-at-loading-bay ?c))
            (not (is-fragile-crate ?c))
            (< (weight ?c) 50)
            (< (position ?m) (distance ?c))
            (> (battery ?m) 0)
            (crate-in-group ?c ?g)
            (= (group-id ?g) (current-group-index))
        )
        :effect (and 
                (mover-moving-to-crate ?m ?c) 
                (not (available ?c))
                (moving ?m)
                (not (free ?m))
        )
    )

    (:process moving-to-crate
        :parameters (?m - mover ?c - crate)
        :precondition (mover-moving-to-crate ?m ?c)
        :effect (increase (position ?m) (* #t (velocity ?m)))
    )

    (:event arrived-at-crate
        :parameters (?m - mover ?c - crate)
        :precondition (and 
                (mover-moving-to-crate ?m ?c) 
                (not (is-fragile-crate ?c))
                (= (position ?m) (distance ?c))
        )
        :effect (and 
                (mover-at-crate ?m ?c) 
                (not (mover-moving-to-crate ?m ?c))
                (not (moving ?m))
                (assign (velocity ?m) (/ 100 (weight ?c)))
            )
    )

    ; == Move two movers to the crate =============================================
    (:action start-move-to-crate-pair
        :parameters (?m1 - mover ?m2 - mover ?c - crate ?g - group)
        :precondition (and 
            (needs-loading ?c)
            (not (loaded ?c))
            (not (is-carried ?c))
            (not (crate-at-loading-bay ?c))
            (or (is-fragile-crate ?c) (>= (weight ?c) 50))
            (different ?m1 ?m2)
            (< (position ?m1) (distance ?c)) 
            (< (position ?m2) (distance ?c))
            (> (battery ?m1) 0) (> (battery ?m2) 0)
            (free ?m1) (free ?m2)
            (needs-loading ?c)
            (= (group-id ?g) (current-group-index))
            (crate-in-group ?c ?g)
        )
        :effect ( and 
            (movers-moving-to-crate ?m1 ?m2 ?c)
            (not (available ?c))
            (moving ?m1) (moving ?m2)
            (not (free ?m1)) (not (free ?m2))
        )
    )

    (:process moving-to-crate-pair
        :parameters (?m1 - mover ?m2 - mover ?c - crate)
        :precondition (movers-moving-to-crate ?m1 ?m2 ?c)
        :effect (and 
            (increase (position ?m1) (* #t (velocity ?m1))) 
            (increase (position ?m2) (* #t (velocity ?m2)))
        )
    )

    (:event arrived-at-crate-pair
        :parameters (?m1 - mover ?m2 - mover ?c - crate)
        :precondition (and 
            (movers-moving-to-crate ?m1 ?m2 ?c)
            (different ?m1 ?m2) 
            (>= (position ?m1) (distance ?c)) 
            (>= (position ?m2) (distance ?c))
        )
        :effect (and 
            (mover-at-crate ?m1 ?c) (mover-at-crate ?m2 ?c) 
            (not (movers-moving-to-crate ?m1 ?m2 ?c))
            (not (moving ?m1)) (not (moving ?m2))
            (assign (velocity ?m1) (/ 150 (weight ?c)))
            (assign (velocity ?m2) (/ 150 (weight ?c)))
        )
    )

    ; == Move one mover back to the loading bay ===================================
    (:action start-moving-back
        :parameters (?m - mover ?c - crate)
        :precondition (and 
                (not (is-carried ?c))
                (mover-at-crate ?m ?c)
                (needs-loading ?c)
                (not (is-fragile-crate ?c))
                (< (weight ?c) 50)
                (> (battery ?m) 0)
            )
        :effect (and 
                (is-carried ?c)
                (not (mover-at-crate ?m ?c))
                (not (free ?m)) 
                (carrying ?m ?c)
                (moving ?m)
            )
    )

    (:process moving-crate
        :parameters (?m - mover ?c - crate)
        :precondition (carrying ?m ?c)
        :effect (and (decrease (position ?m) (* #t (velocity ?m))))
    )

    (:event finish-moving
        :parameters (?m - mover ?c - crate)
        :precondition (and 
                (carrying ?m ?c) 
                (<= (position ?m) 0) 
                (not (is-fragile-crate ?c))
        )
        :effect (and 
                (crate-at-loading-bay ?c) 
                (not (carrying ?m ?c)) 
                (free ?m)
                (not (moving ?m))
                (assign (position ?m) 0)
            )
    )

    ; == Move two movers back to the loading bay =================================
    (:action start-moving-pair
        :parameters (?m1 - mover ?m2 - mover ?c - crate)
        :precondition (and 
            (not (is-carried ?c))
            (mover-at-crate ?m1 ?c) (mover-at-crate ?m2 ?c)
            (different ?m1 ?m2)
            (needs-loading ?c)
            (or (is-fragile-crate ?c) (>= (weight ?c) 50))
            (> (battery ?m1) 0) (> (battery ?m2) 0)
        )
        :effect (and
            (is-carried ?c)
            (not (mover-at-crate ?m1 ?c))
            (not (mover-at-crate ?m2 ?c))
            (not (free ?m1)) (not (free ?m2)) 
            (carrying-pair ?m1 ?m2 ?c)
            (moving ?m1) (moving ?m2)
        )
    )
        
    (:process moving-crate-pair
        :parameters (?m1 - mover ?m2 - mover ?c - crate)
        :precondition (carrying-pair ?m1 ?m2 ?c)
        :effect (and 
            (decrease (position ?m1) (* #t (velocity ?m1))) 
            (decrease (position ?m2) (* #t (velocity ?m2))) 
        )
    )

    (:event finish-moving-pair
        :parameters (?m1 - mover ?m2 - mover ?c - crate)
        :precondition (and
            (carrying-pair ?m1 ?m2 ?c)
            (different ?m1 ?m2)
            (<= (position ?m1) 0) (<= (position ?m2) 0)
        )
        :effect (and 
            (crate-at-loading-bay ?c) 
            (not (carrying-pair ?m1 ?m2 ?c))
            (free ?m1) (free ?m2)
            (assign (position ?m1) 0) (assign (position ?m2) 0)
            (not (moving ?m1)) (not (moving ?m2))
        )
    )
    
    ; == Loading by normal loader ==================================================
    (:action start-loading
        :parameters (?l - loader ?c - crate)
        :precondition (and 
                (crate-at-loading-bay ?c)
                (loading-bay-free) 
                (needs-loading ?c)
                (not (is-cheap-loader ?l))
        )
        :effect (and 
                (not (loading-bay-free)) 
                (being-loaded ?c) 
                (not (needs-loading ?c))
            )
    )

    (:process loading-progress
        :parameters (?c - crate)
        :precondition (being-loaded ?c)
        :effect (and (increase (time-to-load ?c) (* #t 1)))
    )

    (:event finish-loading
        :parameters (?c - crate ?g - group)
        :precondition (and (being-loaded ?c) (>= (time-to-load ?c) 4) (crate-in-group ?c ?g))
        :effect (and 
            (loaded ?c) 
            (not (being-loaded ?c)) 
            (loading-bay-free)
            (decrease (remaining-in-group ?g) 1)
        )
    )

    ; == Loading by cheap loader ==================================================
    (:action start-loading-cheap
        :parameters (?l - loader ?c - crate)
        :precondition (and 
                    (crate-at-loading-bay ?c)
                    (loading-bay-free) 
                    (needs-loading ?c)
                    (is-cheap-loader ?l)
                    (< (weight ?c) 50)
                    (not (is-fragile-crate ?c))
                )
        :effect (and 
            (not (loading-bay-free)) 
            (being-loaded ?c) 
            (not (needs-loading ?c))
            )
    )

    ; == Loading by cheap loader for fragile crates ===============================
    (:action start-loading-cheap-fragile
        :parameters (?l - loader ?c - crate )
        :precondition (and 
                (crate-at-loading-bay ?c)
                (loading-bay-free) 
                (needs-loading ?c)
                (is-cheap-loader ?l)
                (< (weight ?c) 50)
                (is-fragile-crate ?c)
                )
        :effect (and 
            (not (loading-bay-free)) 
            (being-loaded ?c) 
            (not (needs-loading ?c))
            )
    )

    (:event finish-loading-cheap-fragile
        :parameters (?c - crate ?g - group)
        :precondition (and 
                    (being-loaded ?c)                 
                    (is-fragile-crate ?c)
                    (>= (time-to-load ?c) 6)
                    (crate-in-group ?c ?g)
        )
        :effect (and 
            (loaded ?c) 
            (not (being-loaded ?c)) 
            (loading-bay-free)
            (decrease (remaining-in-group ?g) 1)
        )
    )
    
    ;; === GROUP MANAGEMENT ===
    (:event advance-group
        :parameters (?g - group)
        :precondition (and
            (= (group-id ?g) (current-group-index))
            (= (remaining-in-group ?g) 0)
        )
        :effect (and (increase (current-group-index) 1))
    )
)


