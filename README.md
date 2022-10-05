# Modelling Plants Using the Julia Language

This page contains the Pluto notebooks accompanying the PlantComp 2022 workshop on the use of the Julia language to develop and excecute plant models. You can access the slides [here](https://docs.google.com/presentation/d/1wZVotb_fyD5ymwLG6ZSjglV9_EspEBGPREP8ri7K9Zo/edit?usp=sharing).

## Contents

After a brief introduction to Julia and mathematics in Julia, we will dive in 

1. The first notebook [1_ODEs.jl](https://michielstock.github.io/PlantCompJuliaTutorial/1_ODEs.jl.html) introduces a highly efficient software package in Julia to solve differential equations.
2. Next the notebook [2_Catalyst.jl](https://michielstock.github.io/PlantCompJuliaTutorial/2_catalyst.jl.html) provides a demonstration of how to simulate biochemical reaction systems in Julia.
3. An optional third notebook [3_Turing.jl](https://michielstock.github.io/PlantCompJuliaTutorial/3_turing.jl.html) contains a general guide to probabilistic programming in Julia for plant applications.

## Running the Pluto notebooks

Those who want to run the notebook live with active code, must install the Pluto environment in Julia. This process takes 10 minutes (2 minutes active time).

1. Download and install [Julia for your system](https://julialang.org/downloads/).
2. Open the (just) installed Julia application.
2. Install Pluto by copy-pasting the following instruction in the REPL (the terminal that just appeared): `using Pkg; Pkg.add("Pluto")`. This will take two minutes.
3. Launch Pluto by copy-pasting `using Pluto; Pluto.run()`. It will open in your browser.
4. In the slot "open for file" past the link to the notebook: `https://github.com/MichielStock/MonteCarloLecture/blob/main/monte_carlo.jl`

Your system will download the notebook and install all required packages automatically. The first time, this might take up to ten minutes.
