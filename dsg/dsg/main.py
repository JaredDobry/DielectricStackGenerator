from dsg.Configuration import Configuration, FilterType
from dsg.Individual import Individual
from dsg.Population import Population
from dsg.Utils import wavelengths
import matplotlib.pyplot as plt
import numpy as np


c = 3e10
reference_substrate = [
    97.33,
    48.60,
    761.47,
    412.85,
    720.06,
    382.28,
    705.03,
    370.42,
    709.26,
    358.23,
    718.52,
    353.08,
    724.86,
    360.01,
    710.47,
    398.52,
    564.95,
    40.79,
    224.72,
    125.31,
    133.58,
    98.28,
    268.21,
    138.25,
    238.01,
    125.48,
    232.65,
    68.54,
    168.55,
    150.14,
    254.28,
    125.25,
    307.19,
    165.16,
    256.22,
    133.04,
    289.60,
    147.63,
    266.04,
    134.34,
    265.60,
    156.86,
    294.15,
    123.17,
    250.12,
    178.96,
    528.64,
    0,
]
reference_substrate.reverse()


def main():
    config_hpf = Configuration(
        exclusion_high=7000,
        exclusion_low=2000,
        exclusion_weight=0.5,
        filter_type=FilterType.HIGH_PASS,
        inclusion_high=5000,
        inclusion_low=3300,
        inclusion_weight=0.5,
        mutation_pairs_chance=0.05,
        mutation_z_chance=0.25,
        mutation_z_factor=0.25,
        pairs_max=6,
        pairs_min=4,
        population_size=256,
        reproduction_size=128,
        samples=64,
        z_max=1000.0,
        z_min=10.0
    )

    pop_hpf = Population(config_hpf)
    pop_hpf.generate()
    f = 0
    count = 0
    fig, (ax1, ax2) = plt.subplots(1, 2)
    fs = []
    counts = []
    while f < 0.9:
        f, i = pop_hpf.iterate()
        count += 1
        fs.append(f)
        counts.append(count)

        ws = wavelengths(config_hpf)

        ax1.clear()
        ax1.plot(ws, i.coefficients(config_hpf))
        ax1.set_title(f"High Pass Filter - Generation {count} - Fitness {int(f * 100)}%")
        ax1.set_xlabel("Wavelength (nm)")
        ax1.set_ylabel("Transmission (%)")

        ax2.clear()
        ax2.plot(counts, fs)
        ax2.set_title("Fitness vs. Generation")
        ax2.set_xlabel("Generation")
        ax2.set_ylabel("Fitness (%)")

        plt.draw()
        plt.pause(0.25)


if __name__ == "__main__":
    main()
