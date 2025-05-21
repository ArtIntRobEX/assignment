# Heuristic Function for Crate Delivery Domain (Problem 0.5)

This heuristic estimates the cost-to-go for each crate based on the distance from movers, pending actions (pickup, release, loading), and the number of movers. It is designed to be informative yet efficient for use in symbolic planners like ENHSP.

## Heuristic Definition

We define the heuristic function h(n) for a state n as:

```math
h(n) = \sum_{i=0}^{c} \sum_{j=0}^{m} \left[ (bp \cdot d_{ij} + br \cdot d_{j}) \cdot m_j \right] + bp \cdot p + br \cdot r + bl \cdot L
```
### Where:

- `c` — Number of crates  
- `m` — Number of movers  
- `d_{ij}` — Distance from mover j to crate i
- `d_{j}` — Distance from mover j to the loading bay   
- `m_j` — Binary or weighted indicator if mover j is available  
- `bp` — Binary flag: 1 if crate i has not been picked up, 0 otherwise  
- `br` — Binary flag: 1 if crate i has not been released, 0 otherwise  
- `bl` — Binary flag: 1 if crate i has not started loading, 0 otherwise  
- `p` — Fixed pickup cost  
- `r` — Fixed release cost  
- `l` — Fixed loading time/cost  

## Component Explanation

- **Pickup Distance Term**: $bp \cdot d_{ij}$ penalizes distance to the crate if it has not yet been picked up.
- **Return Distance Term**: $br \cdot d_{ij}$ penalizes the return trip cost if the crate has not yet been released.
- **Action Costs**:
  - $bp \cdot p$ adds fixed pickup effort
  - $br \cdot r$ adds fixed release effort
  - $bl \cdot l$ adds fixed loading cost if not started
- **Mover Scaling**: All distance terms are scaled by m_j, which represents the number of robots that take part in moving this crate.

## Example Use Case

### Case 1: Standard Crate

For a crate at distance d = 10:
- bp = 1, br = 1, bl = 1
- p = 2, r = 2, L = 4

Then:

h(n) = 2 * 10 + 2 + 2 + 4 = 28

### Case 2: All Actions Completed

If the crate has already been picked, released, and loaded:
- bp = 0, br = 0, bl = 0
- All action costs and distance terms are ignored.

Then:

h(n) = 0

### Case 3: Heavy Crate (Requires Two Movers)

For a heavy crate weighing 70 kg, requiring two movers:
- Assume d = 10
- Both movers are available: m_j = 2
- bp = 1, br = 1, bl = 1
- p = 2, r = 2, L = 4

Then:

h(n) = (1 * 10 + 1 * 10) * 2 + 2 + 2 + 4 = 40 + 8 = 48