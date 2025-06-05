;; Simplified DOMAIN without groups
(define (domain simple-warehouse)
    (:requirements :typing :strips :conditional-effects :negative-preconditions :disjunctive-preconditions :fluents :durative-actions)
    (:types loader mover crate group)

    (:predicates
        (free ?m - mover)
        (carrying ?m - mover ?c - crate)
        (mover-moving-to-crate ?m - mover ?c - crate)
        (mover-at-crate ?m - mover ?c - crate)
        (available ?c - crate)
        (crate-in-group ?c - crate ?g - group)
        (next-group ?g - group ?g - group)
        (active-group ?g - group)
        (crate-at-loading-bay ?c - crate)
        (loading-bay-free)
        (needs-loading ?c - crate)
        (being-loaded ?c - crate)
        (loaded ?c - crate)
    )

    (:functions
        (weight ?c - crate)
        (distance ?c - crate)
        (position ?m - mover)
        (velocity ?m - mover)
        (max_vel ?m - mover) 
        (time-to-move ?c - crate)
        (time-to-load ?c - crate)
        (remaining-in-group ?g - group)
    )
    
    (:action start-move-to-crate
        :parameters (?m - mover ?c - crate ?g - group)
        :precondition (and (free ?m)
            (needs-loading ?c)
            (< (position ?m) (distance ?c))
            (active-group ?g)
            (crate-in-group ?c ?g)
            )
        :effect (and (mover-moving-to-crate ?m ?c) (not (available ?c)))
    )

    (:process moving-to-crate
        :parameters (?m - mover ?c - crate)
        :precondition (mover-moving-to-crate ?m ?c)
        :effect (increase (position ?m) (* #t (velocity ?m)))
    )

    (:event arrived-at-crate
        :parameters (?m - mover ?c - crate)
        :precondition (and (mover-moving-to-crate ?m ?c) (= (position ?m) (distance ?c)))
        :effect (and (mover-at-crate ?m ?c) (not (mover-moving-to-crate ?m ?c)))
    )

    (:action start-moving-back
        :parameters (?m - mover ?c - crate)
        :precondition (and (free ?m) (mover-at-crate ?m ?c))
        :effect (and (not (free ?m)) (carrying ?m ?c))
    )

    (:process moving-crate
        :parameters (?m - mover ?c - crate)
        :precondition (carrying ?m ?c)
        :effect (and (increase (position ?m) (* #t (velocity ?m))))
    )

    (:event finish-moving
        :parameters (?m - mover ?c - crate)
        :precondition (and (carrying ?m ?c) (>= (position ?m) (distance ?c)))
        :effect (and (crate-at-loading-bay ?c) (not (carrying ?m ?c)) (free ?m))
    )

    (:action start-loading
        :parameters (?l - loader ?c - crate ?g - group)
        :precondition (and (crate-at-loading-bay ?c) (loading-bay-free) (needs-loading ?c))
        :effect (and 
            (not (loading-bay-free)) 
            (being-loaded ?c) 
            (not (needs-loading ?c))
            (crate-in-group ?c ?g)
            (decrease (remaining-in-group ?g) 1)
            )
    )

    (:process loading-progress
        :parameters (?c - crate)
        :precondition (being-loaded ?c)
        :effect (and (increase (time-to-load ?c) (* #t 1)))
    )

    (:event finish-loading
        :parameters (?c - crate)
        :precondition (and (being-loaded ?c) (>= (time-to-load ?c) 4))
        :effect (and 
            (loaded ?c) 
            (not (being-loaded ?c)) 
            (loading-bay-free)
        )
    )

    ;; === GROUP MANAGEMENT ===
    (:action advance-group
        :parameters (?g1 ?g2 - group)
        :precondition (and
            (active-group ?g1)
            (= (remaining-in-group ?g1) 0)
            (next-group ?g1 ?g2)
        )
        :effect (and
            (not (active-group ?g1))
            (active-group ?g2)
        )
    )
)


