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

# PHOTOSYNTHESIS in C3

light_reactions = @reaction_network  begin
    (kgass, kgass), 0 <--> CO2
    (kgass, kgass), 0 <--> O2
    klight, ADP + NADP --> 2ATP + 2NADPH + O2
  end klight kgass


dark_reactions = @reaction_network dark_reactions begin
    k1, RuBP + CO2 --> 2PGA  # assimilation
    k2, PGA + ATP + NADPH --> G3P + ADP + NADP  
    k3, 5G3P + 3ATP --> 3RuBP + 3ADP  # recovery of RuBP
    k4, 2G3P --> glucose
    kpr, RuBP + O2 --> PGP + PGA  # photorespiration
end k1 k2 k3 k4 kpr

@named photosynthesis = extend(light_reactions, dark_reactions)

convert(ODESystem, photosynthesis; combinatoric_ratelaws=false)

# Exercise?

photorespiration = @reaction_network begin
    kpr, RuBP + O2 --> PGP + PGA
end kpr

@named photosynthesis_extended = extend(photosynthesis, photorespiration)


# PHOTOSYNTHESIS in C4

C4assimilation = @reaction_network begin
    k6, PEP + CO2 + NADPH --> malate + NADP
    k7, Pyr + ATP --> PEP + ADP
end kC4 k6

C4release = @reaction_network begin
    k7, malate + NADP --> Pyr + NADPH + CO2
end k8


@named mesophyl = extend(light_reactions, C4assimilation)
@named bundle_sheet = extend(dark_reactions, C4release)

# compartment C4 model

c4_model = @reaction_network begin
    kmal, $(mesophyl.malate) --> $(bundle_sheet.malate)
    kpyr, $(bundle_sheet.Pyr) --> $(mesophyl.Pyr)
end kmal kpyr

c4_model = compose(c4_model, [mesophyl, bundle_sheet])