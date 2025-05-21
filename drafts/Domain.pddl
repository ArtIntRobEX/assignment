(define (domain gripper-strips)
   (:predicates (room ?r)
        (crate ?c)
        (gripper ?g)
        (rob_position ?r)
        (at ?c ?r)
        (free ?g)
        (free2 ?g)
        (carry ?o ?g)
        (connected ?r1 ?r2))

   (:action move
       :parameters (?from ?to)
       :precondition (and (room ?from) (room ?to) (connected ?to ?from) (rob_position ?from))
       :effect (and (rob_position ?to)
             (not (rob_position ?from))))


   (:action pick
       :parameters (?obj ?room ?gripper)
       :precondition (and (crate ?obj) (room ?room) (gripper ?gripper)
                (at ?obj ?room) (rob_position ?room) (free ?gripper) (free2 ?gripper))
       :effect (and (carry ?obj ?gripper)
            (not (at ?obj ?room)) 
            (not (free ?gripper))))
            
 (:action pick2
       :parameters (?obj ?room ?gripper)
       :precondition (and (crate ?obj) (room ?room) (gripper ?gripper)
                (at ?obj ?room) (rob_position ?room) (not (free ?gripper)) (free2 ?gripper))
       :effect (and (carry ?obj ?gripper)
            (not (at ?obj ?room)) 
            (not (free2 ?gripper))))


   (:action drop
       :parameters (?obj ?room ?gripper)
       :precondition (and (crate ?obj) (room ?room) (gripper ?gripper)
                (carry ?obj ?gripper) (rob_position ?room) (free2 ?gripper))
       :effect (and (at ?obj ?room)
            (free ?gripper)
            (not (carry ?obj ?gripper))))
            
    (:action drop2
       :parameters (?obj ?room ?gripper)
       :precondition (and (crate ?obj) (room ?room) (gripper ?gripper)
                (carry ?obj ?gripper) (rob_position ?room) (not (free2 ?gripper)) (not (free ?gripper)))
       :effect (and (at ?obj ?room)
            (free2 ?gripper)
            (not (carry ?obj ?gripper)))))