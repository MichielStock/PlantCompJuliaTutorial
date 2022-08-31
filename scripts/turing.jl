#=
Created on 31/08/2022 14:52:17
Last update: -

@author: Michiel Stock
michielfmstock@gmail.com

Examples using Turing
=#

using Turing, Plots, StatsPlots

# Example of comparing two treatments effects

@model function treatment(N_A₊, N_A₋, N_B₊, N_B₋)
    # prior distributions of probability of success
    p_A ~ Uniform(0, 1)  # probability that A is effective
    p_B ~ Uniform(0, 1)  # probability that B is effective
    # number of cases for each treatment
    N_A = N_A₊ + N_A₋
    N_B = N_B₊ + N_B₋
    # sample successes
    N_A₊ ~ Binomial(N_A, p_A)
    N_B₊ ~ Binomial(N_B, p_B)
end

N_A₊ = 29
N_A₋ = 1
N_B₊ = 17
N_B₋ = 3

chain1 = sample(treatment(N_A₊, N_A₋, N_B₊, N_B₋), NUTS(), 1000, drop_warmup=true)

plot(chain1)

p_A_better_than_B = mean(chain1[:p_A] .> chain1[:p_B])

p_A_much_better_than_B = mean(chain1[:p_A] .> 2chain1[:p_B])

# Fitting a curve probability

data = [(14.4, 1.0), (15.9, 2.3), (17.3, 4.0), (18.7, 6.0), (20.1, 7.9), (21.6, 9.2), (23.1, 9.8), (24.6, 9.9)]

t, y = first.(data), last.(data)

# Gompertz model

gompertz(t; a, b, c) = a * exp(-b * exp(-c * t))

@model function gompertz_fit(t, y)
    a ~ Exponential(5)
    b ~ Exponential(5)
    c ~ Exponential(5)
    σ² ~ Gamma(2)
    σ = √(σ²)
    for (i, tᵢ) in enumerate(t)
        y[i] ~ Normal(gompertz(tᵢ; a, b, c), σ)
    end
end

chain2 = sample(gompertz_fit(t, y), NUTS(), 1000, drop_warmup=true)

â = mean(chain2[:a])
b̂ = mean(chain2[:b])
ĉ = mean(chain2[:c])

plot(t->gompertz(t, a=â, b=b̂, c=ĉ), 0, 26)
scatter!(t, y)

# logisitic model

logistic(t; t₀, L, k) = L / (1 + exp(-k * (t - t₀)))

@model function gompertz_logistic(t, y)
    t₀ ~ Uniform(0, 25)
    L ~ Exponential(10)
    k ~ LogNormal()
    σ² ~ Gamma(2)
    σ = √(σ²)
    for (i, tᵢ) in enumerate(t)
        y[i] ~ Normal(logistic(tᵢ; t₀, L, k), σ)
    end
end

chain3 = sample(gompertz_logistic(t, y), NUTS(), 1000, drop_warmup=true)

t̂₀ = mean(chain3[:t₀])
L̂ = mean(chain3[:L])
k̂ = mean(chain3[:k])

plot(chain3)

p = plot(t->logistic(t; t₀=t̂₀, L=L̂, k=k̂), 0, 26)
scatter!(p, t, y)

for i in 1:10:1000
    plot!(p, t->logistic(t; t₀=chain3[:t₀][i], L=chain3[:L][i], k=chain3[:k][i]),
            0, 26, alpha=0.1, color="blue", label="")
end
p

scatter(chain3[:L][:], chain3[:k][:], alpha=0.6, ylabel="k", xlabel="L")

# Exercise?