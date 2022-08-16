from dsg.Configuration import Configuration, FilterType
import numpy as np
from typing import List, Tuple


generator = np.random.default_rng()


def coefficient(z: np.ndarray, refractive_indices: np.ndarray, wavelength) -> float:
    k_air = refractive_indices[0] * 2.0 * np.pi / wavelength
    k_2 = k_air
    m = np.identity(2, dtype="complex128")
    for i in range(0, len(z)):
        k_1 = k_2
        k_2 = refractive_indices[i + 1] * 2.0 * np.pi / wavelength

        m_11 = 0.5 * (1.0 + k_2 / k_1) * np.exp(1j * (k_2 - k_1) * z[i])
        m_12 = 0.5 * (1.0 - k_2 / k_1) * np.exp(-1j * (k_2 + k_1) * z[i])
        m_21 = 0.5 * (1.0 - k_2 / k_1) * np.exp(1j * (k_2 + k_1) * z[i])
        m_22 = 0.5 * (1.0 + k_2 / k_1) * np.exp(-1j * (k_2 - k_1) * z[i])

        m = np.matmul(m, np.array([[m_11, m_12], [m_21, m_22]]))

    return k_2 / k_air * np.square(np.abs(1 / m[0][0]))


def coefficient_params(substrate: List[float]) -> Tuple[np.ndarray, np.ndarray]:
    z = np.cumsum(substrate)
    refractive_indices = np.concatenate(
        (np.array([1]), np.tile([2.2, 4.2], int(len(z) / 2)))
    )
    return z, refractive_indices


# individuals must be ascending sorted (0.1, 0.2, 0.3, ...)
def cull_individuals(config: Configuration, individuals):
    culled = individuals
    while len(culled) > config.population_size - config.reproduction_size:
        death_chance = 1 / len(culled)
        for i in range(0, len(culled) - 1):  # Don't kill the best member
            die = generator.uniform(0, 1)
            if die < death_chance:
                culled.remove(culled[i])
                break
    return culled


def exclusion_wavelength(config: Configuration, wavelength: float) -> bool:
    if wavelength < config.inclusion_low or wavelength > config.inclusion_high:
        return True
    return False


def generate_child(config: Configuration, parent_1: List[float], parent_2: List[float]):
    child = []
    if len(parent_1) > len(parent_2):
        for i in range(0, len(parent_2)):
            coin = generator.integers(0, 1)
            if coin == 0:
                child.append(parent_1[i])
            else:
                child.append(parent_2[i])
        child += parent_1[len(parent_2):]
    else:
        for i in range(0, len(parent_1)):
            coin = generator.integers(0, 1)
            if coin == 0:
                child.append(parent_1[i])
            else:
                child.append(parent_2[i])
        child += parent_2[len(parent_1):]
    return mutate_substrate(config, child)


def generate_substrate(config: Configuration) -> List[float]:
    n_pairs = generator.integers(config.pairs_min, config.pairs_max)
    substrate = []
    for i in range(0, n_pairs):
        p_1 = generator.triangular(left=config.z_min, mode=(config.z_min + config.z_max) / 2.0, right=config.z_max)
        p_2 = generator.triangular(left=config.z_min, mode=(config.z_min + config.z_max) / 2.0, right=config.z_max)
        substrate.append(p_1)
        substrate.append(p_2)
    return substrate


def mutate_substrate(config: Configuration, substrate: List[float]) -> List[float]:
    mutated = substrate
    # Flip to mutate n_pairs
    coin = generator.integers(0, 1)
    if coin == 1:
        # Flip to add or remove
        coin = generator.integers(0, 1)
        if coin == 1:  # add
            p_1 = generator.triangular(left=config.z_min, mode=(config.z_min + config.z_max) / 2.0, right=config.z_max)
            p_2 = generator.triangular(left=config.z_min, mode=(config.z_min + config.z_max) / 2.0, right=config.z_max)
            mutated.append(p_1)
            mutated.append(p_2)
        elif len(mutated) > 2:
            index = generator.integers(0, int(len(mutated) / 2))
            p_1 = mutated[index]
            p_2 = mutated[index + 1]
            mutated.remove(p_1)
            mutated.remove(p_2)

    # Z mutation
    for i in range(0, len(mutated)):
        die = generator.uniform(0, 1)
        if die < config.mutation_z_chance:
            coin = generator.integers(0, 1)
            amount = generator.uniform(0, config.mutation_z_factor)
            if coin == 1:
                new_z = mutated[i] * (1 + amount)
            else:
                new_z = mutated[i] * (1 - amount)
            mutated[i] = new_z

    return mutated


def select_parent(individuals):
    reproduction_chance = 1 / len(individuals)
    parent = None
    index = 0
    while parent is None:
        die = generator.uniform(0, 1)
        if die < reproduction_chance:
            parent = individuals[index]
        else:
            index += 1
            if index >= len(individuals):
                index = 0
    return parent


def select_parents(individuals):
    parent_1 = select_parent(individuals)
    parent_2 = None
    while parent_2 is None:
        candidate = select_parent(individuals)
        if parent_1 != candidate:
            parent_2 = candidate
    return parent_1, parent_2


def wavelengths(config: Configuration) -> np.ndarray:
    if config.filter_type == FilterType.LOW_PASS:
        return np.linspace(config.inclusion_low, config.exclusion_high, config.samples)
    elif config.filter_type == FilterType.HIGH_PASS:
        return np.linspace(config.exclusion_low, config.inclusion_high, config.samples)
    elif config.filter_type == FilterType.FULL:
        return np.linspace(config.exclusion_low, config.exclusion_high, config.samples)
