### A Pluto.jl notebook ###
# v0.19.10

using Markdown
using InteractiveUtils

# ╔═╡ 6bcad41e-255e-11ed-17c5-fd62445d09cf
begin
    import Pkg
	Pkg.add("Plots")
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    # instantiate, i.e. make sure that all packages are downloaded
    Pkg.instantiate()
	

	using Catalyst, DifferentialEquations, Plots
end

# ╔═╡ 19c02792-8d31-4722-845d-1af63d4dd427
md"""
# Simulation of biochemical reaction networks using Julia

The Catalyst.jl Julia package allows users to programmatically define symbolic reaction systems using a domain-specific language. We can then simulate these reaction systems to ascertain various properties of the chemical system.
"""

# ╔═╡ 56936de0-8874-4cf0-8022-11eea738d97c
md"""
To illustrate the usage of Catalyst.jl to solve chemical networks, we consider the hypothetical chemical reaction system given below.

Here the rate constant parameters (or values thereof) are placed before the symbolic notation of the chemical reactions.
"""

# ╔═╡ cfe975e5-61a4-4077-8458-969bb463f8b3
rn = @reaction_network begin
  2.0, X + Y --> XY
  1.0, XY --> Z1 + Z2
end

# ╔═╡ f27124cd-7f29-4898-92cc-dfeea24069c2
md"""
We start by generating the mass action ODE model from the reaction network through the use of the convert function.
"""

# ╔═╡ 489f91f4-b646-4214-ae42-59df8302fba3
odesys = convert(ODESystem, rn)

# ╔═╡ ccc01235-34a2-433c-96ae-d346a8659b61
md"""
Next, we define the initial conditions $U_{o}map$ and the time window to solve over $tspan$. 
"""

# ╔═╡ 38583db0-6f9d-49e5-9afd-b3760d11bd8e
u₀map = [:X => 2.0, :Y => 5., :XY => 0., :Z1 => 0.1, :Z2 => 0.]

# ╔═╡ 272668d0-e588-45d3-b989-f0e70ddeaa39
tspan = (0., 10000.)

# ╔═╡ 64a87bf9-7820-431d-839b-9f4a6c94946d
md"""
Now that we have our ODE model, initial conditions and time window, we can solve the chemical system using DifferentialEquations.jl's ODEProblem and solve functions.
"""

# ╔═╡ 9b97a96d-17c6-455f-aedb-2ac4c558398d
oprob = ODEProblem(rn, u₀map, tspan, [])

# ╔═╡ 5ee45a9e-bf0e-4283-b359-1d0ab55141cd
sol = solve(oprob)

# ╔═╡ cc3b6646-44c8-435e-8170-c3b1c4bd5098
plot(sol)

# ╔═╡ 46029492-f2fe-43f4-b23e-5f8b83e73475
md"""
## Photosynthesis case study
Photosynthesis is the biochemical process in which green plants fix light energy from sunlight to synthesize carbohydrates using water and carbon dioxide. This process takes place in the chloroplasts.

The biochemical reactions comprising photosynthesis are divided into the light reaction and the dark reaction. In the light reaction, light energy is used
to synthesize ATM and the NADPH2 coenzyme, whereas the dark reaction is where these two molecules are used to synthesize simple carbohydrates through the fixation of carbon dioxide.

Plants can be categorized into C3, C4, and CAM, depending on the types of dark reactions they use. 

### Photosynthesis in C3 plants

In C3 plants, the first stable product of photosynthesis is a compound with three carbon moieties, called 3-phosphoglyceric acid (3-PGA).

"""

# ╔═╡ d60e8c57-eb14-4245-8d2a-f7b84cc67acb
md"""

The light reactions of photosynthesis can be modeled in a reaction network using the domain specific language of Catalyst.jl, as seen below.

"""

# ╔═╡ 34516474-248c-4ca4-aa01-70b0cb350258
light_reactions = @reaction_network  begin
    (kgass, kgass), 0 <--> CO2
    (kgass, kgass), 0 <--> O2
    klight, ADP + NADP --> 2ATP + 2NADPH + O2
  end klight kgass

# ╔═╡ 845dbcf9-ec1f-476f-a246-8b3a1941a377


# ╔═╡ 8f7cb1e6-b6e5-446f-a403-d32b760f79df
dark_reactions = @reaction_network dark_reactions begin
    k1, RuBP + CO2 --> 2PGA  # assimilation
    k2, PGA + ATP + NADPH --> G3P + ADP + NADP  
    k3, 5G3P + 3ATP --> 3RuBP + 3ADP  # recovery of RuBP
    k4, 2G3P --> glucose
    kpr, RuBP + O2 --> PGP + PGA  # photorespiration
end k1 k2 k3 k4 kpr

# ╔═╡ fc2389d6-7958-4b5e-99e2-9459b1a6125b
md"""
Two reaction networks can be combined using the *extend* function. This is done below for the light and dark reactions of photosynthesis.
"""

# ╔═╡ 3367c17f-9722-4cfd-8cd7-a1e3a04b4a30
@named photosynthesis = extend(light_reactions, dark_reactions)

# ╔═╡ ea3d6f00-fd40-495b-bdf8-f59e2bfd702d
convert(ODESystem, photosynthesis; combinatoric_ratelaws=false)

# ╔═╡ 8412837f-a624-4f48-aa60-24b19fb66c3b
md"""

When too much oxigen is present, the Calvin cycle is inhibited, leading to the loss of fixed carbon dioxide and a decreased carbohydrate synthesis. This process is called photorespiration. 

"""

# ╔═╡ d2bf1bc0-fa06-4531-a943-18cde170e401
photorespiration = @reaction_network begin
    kpr, RuBP + O2 --> PGP + PGA
end kpr

# ╔═╡ cf52dc3e-91d1-4420-b660-4e4e04f3186f
@named photosynthesis_extended = extend(photosynthesis, photorespiration)

# ╔═╡ 2fe7ba4a-7d4d-4c54-96bd-1e56ef2cde80
md"""
### Photosynthesis in C4 plants.

In C4 plants, the first stable product of photosynthesis is a compound with four carbon moieties, called malate.

They minimize photorespiration by compartmentalizing carbon dioxide fixation and the Calvin cycle in separate cells. 

"""

# ╔═╡ dafb574a-b542-4951-882c-47eb31bdc6ef
C4assimilation = @reaction_network begin
    k6, PEP + CO2 + NADPH --> malate + NADP
    k7, Pyr + ATP --> PEP + ADP
end kC4 k6

# ╔═╡ 957c8973-4c24-45e5-9747-63ea1d451dfb
C4release = @reaction_network begin
    k7, malate + NADP --> Pyr + NADPH + CO2
end k8

# ╔═╡ 8948836d-7c61-4db7-8103-619b4e980298
@named mesophyl = extend(light_reactions, C4assimilation)

# ╔═╡ 78a58747-abcd-4631-9c4d-52d5f5afed68
@named bundle_sheath = extend(dark_reactions, C4release)

# ╔═╡ bf525643-5b5a-496a-be90-a85d65989837
c4_model = @reaction_network begin
    kmal, $(mesophyl.malate) --> $(bundle_sheath.malate)
    kpyr, $(bundle_sheath.Pyr) --> $(mesophyl.Pyr)
end kmal kpyr

# ╔═╡ d7f8b806-cc82-4214-9abc-63006e4e1344
c4_model_extended = compose(c4_model, [mesophyl, bundle_sheath])

# ╔═╡ Cell order:
# ╟─19c02792-8d31-4722-845d-1af63d4dd427
# ╠═6bcad41e-255e-11ed-17c5-fd62445d09cf
# ╠═56936de0-8874-4cf0-8022-11eea738d97c
# ╠═cfe975e5-61a4-4077-8458-969bb463f8b3
# ╠═f27124cd-7f29-4898-92cc-dfeea24069c2
# ╠═489f91f4-b646-4214-ae42-59df8302fba3
# ╠═ccc01235-34a2-433c-96ae-d346a8659b61
# ╠═38583db0-6f9d-49e5-9afd-b3760d11bd8e
# ╠═272668d0-e588-45d3-b989-f0e70ddeaa39
# ╠═64a87bf9-7820-431d-839b-9f4a6c94946d
# ╠═9b97a96d-17c6-455f-aedb-2ac4c558398d
# ╠═5ee45a9e-bf0e-4283-b359-1d0ab55141cd
# ╠═cc3b6646-44c8-435e-8170-c3b1c4bd5098
# ╠═46029492-f2fe-43f4-b23e-5f8b83e73475
# ╠═d60e8c57-eb14-4245-8d2a-f7b84cc67acb
# ╠═34516474-248c-4ca4-aa01-70b0cb350258
# ╠═845dbcf9-ec1f-476f-a246-8b3a1941a377
# ╠═8f7cb1e6-b6e5-446f-a403-d32b760f79df
# ╠═fc2389d6-7958-4b5e-99e2-9459b1a6125b
# ╠═3367c17f-9722-4cfd-8cd7-a1e3a04b4a30
# ╠═ea3d6f00-fd40-495b-bdf8-f59e2bfd702d
# ╠═8412837f-a624-4f48-aa60-24b19fb66c3b
# ╠═d2bf1bc0-fa06-4531-a943-18cde170e401
# ╠═cf52dc3e-91d1-4420-b660-4e4e04f3186f
# ╠═2fe7ba4a-7d4d-4c54-96bd-1e56ef2cde80
# ╠═dafb574a-b542-4951-882c-47eb31bdc6ef
# ╠═957c8973-4c24-45e5-9747-63ea1d451dfb
# ╠═8948836d-7c61-4db7-8103-619b4e980298
# ╠═78a58747-abcd-4631-9c4d-52d5f5afed68
# ╠═bf525643-5b5a-496a-be90-a85d65989837
# ╠═d7f8b806-cc82-4214-9abc-63006e4e1344
