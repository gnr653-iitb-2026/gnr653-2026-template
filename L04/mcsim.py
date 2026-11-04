"""Monte Carlo study of the two-sample t-test when the data are autocorrelated.

Used by L04_parallel.ipynb. The functions live in this file, not in the notebook,
because worker processes must be able to import them.

One task = one setting of
    n       sample size of each of the two groups
    rho     lag-1 autocorrelation of the data (0 means independent)
    effect  true difference in means, in standard deviations (0 means no difference)
For each task we simulate n_sim pairs of samples, run Welch's t-test on each pair,
and report the fraction of tests that reject at alpha = 0.05.
"""
import itertools

import numpy as np
import pandas as pd
from scipy import stats

N_VALUES = [10, 20, 50, 100, 200]
RHO_VALUES = [0.0, 0.2, 0.4, 0.6, 0.8]
EFFECT_VALUES = [0.0, 0.2, 0.5, 0.8]


def make_grid():
    """All combinations of n, rho and effect: 5 x 5 x 4 = 100 tasks."""
    rows = itertools.product(N_VALUES, RHO_VALUES, EFFECT_VALUES)
    grid = pd.DataFrame(rows, columns=["n", "rho", "effect"])
    grid.insert(0, "task", range(len(grid)))
    return grid


def ar1(rng, size, rho):
    """AR(1) series with mean 0 and variance 1 along the last axis.

    x[t] = rho * x[t-1] + sqrt(1 - rho**2) * e[t],  with e[t] ~ N(0, 1)
    """
    e = rng.standard_normal(size)
    x = np.empty(size)
    x[..., 0] = e[..., 0]
    s = np.sqrt(1 - rho**2)
    for t in range(1, size[-1]):
        x[..., t] = rho * x[..., t - 1] + s * e[..., t]
    return x


def simulate_loop(n, rho, effect, n_sim=200, seed=0, alpha=0.05):
    """Rejection rate of Welch's t-test, one simulated data set at a time."""
    rng = np.random.default_rng(seed)
    k = 0
    for _ in range(n_sim):
        x = ar1(rng, (2, n), rho)
        a, b = x[0], x[1] + effect
        if stats.ttest_ind(a, b, equal_var=False).pvalue < alpha:
            k += 1
    return k / n_sim


def simulate_vec(n, rho, effect, n_sim=200, seed=0, alpha=0.05):
    """Same simulation, all data sets at once (and the same random numbers as the loop)."""
    rng = np.random.default_rng(seed)
    x = ar1(rng, (n_sim, 2, n), rho)
    a, b = x[:, 0], x[:, 1] + effect
    p = stats.ttest_ind(a, b, axis=1, equal_var=False).pvalue
    return float(np.mean(p < alpha))


def run_task(row, n_sim=200, base_seed=653, vectorized=False):
    """Run one grid row (task, n, rho, effect). Returns (task, rejection rate)."""
    task, n, rho, effect = row
    seed = np.random.SeedSequence([base_seed, int(task)])  # each task has its own random numbers
    simulate = simulate_vec if vectorized else simulate_loop
    return int(task), simulate(int(n), float(rho), float(effect), n_sim, seed)


def square(x):
    """A task that is far too small to be worth sending to another process."""
    return x * x
