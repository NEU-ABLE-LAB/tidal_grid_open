# Tidal Microgrids for Small Island

# Potential Project ideas
  * create a function that is passed the length of an islands coastline and determines the maximum possible generated power for the island
    * need to figure out a standardized kW per km of coastline amount
	* would allow for an upper bound on amount of tidal power and island would be capeable of supporting

  * create a function that is given a sys object and determines the amount of tidal energy needed to reduce the stored energy delta

# Key files
  * `make_island_aspirational` - creates sys object
  * `main_LIB_simple` - Simulates the Lithium-ion battery with simple controller
  * `main_flow_simple` - Simulates the Flow battery
  
# make_island_aspirational
  * must be passed a battery type either 'simple LIB' || 'simple flow'
  * called as `make_island_aspirational('simple LIB')` will result in a sys object based on aspirational estimate from 'Model numbers for Mike.docx'
  
    ## variable input options - `make_island_aspirational('simple LIB',...`
	### Demand inputs
	* `...households, int)`     - number of households on the island
	### LIB inputs
	* `...LIB_cost_E, int)`     - Lithium ion battery energy capacity cost ($/kWh)
	* `...LIB_cost_P, int)`     - Lithium ion battery power capacity cost ($/kW)
	* `...LIB_cycle_life, int)` - Lithium ion battery cycle life (cycles) 
	### flow inputs
	* `...flow_cost_E, int)`     - flow battery energy capacity cost ($/kWh)
	* `...flow_cost_P, int)`     - flow battery power capacity cost ($/kW)
	* `...flow_cycle_life, int)` - flow battery cycle life (cycles)
	### generator inputs
	* `...gen_cost_P, int)`      - generator Cost per rated kW
	* `...gen_lifetime, int)`    - lifetime in years
	### island inputs
	* `...grid_costs, int)`      - grid Cost per rated kW