#=
Created on 29/08/2022 17:09:41
Last update: -

@author: Michiel Stock
michielfmstock@gmail.com

Example use of Catalyst
=#

using DifferentialEquations, Catalyst, Plots

# Example 

rn = @reaction_network begin
    2.0, X + Y --> XY
    1.0, XY --> Z1 + Z2
  end

  odesys = convert(ODESystem, rn)

  u₀map = [:X => 2.0, :Y => 5., :XY => 0., :Z1 => 0.1, :Z2 => 0.]

  tspan = (0., 2.)

  oprob = ODEProblem(rn, u₀map, tspan, [])

  sol = solve(oprob)

  plot(sol)

  # light reactions

light_reactions = @reaction_network begin
    (kgass, kgass), 0 <--> CO2
    (kgass, kgass), 0 <--> O2
    kph, ADP + NADP --> ATP + NADPH
  end kph


dark_reactions = @reaction_network begin
    kass, RuBP + 3CO2 + 9ATP + 6NADPH --> G3P + 9ATP +6NADP
    # TODO: add photorespiration
end kass

@named photosynthesis_C3 = extend(light_reactions, dark_reactions)

convert(ODESystem, photosynthesis_C3; combinatoric_ratelaws=false)

# TODO: add C3 model