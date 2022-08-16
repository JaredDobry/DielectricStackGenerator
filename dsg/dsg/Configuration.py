from dataclasses import dataclass
from enum import Enum


class FilterType(Enum):
    LOW_PASS = 0
    HIGH_PASS = 1
    FULL = 2


@dataclass
class Configuration:
    exclusion_high: float
    exclusion_low: float
    exclusion_weight: float
    filter_type: FilterType
    inclusion_high: float
    inclusion_low: float
    inclusion_weight: float
    mutation_pairs_chance: float
    mutation_z_chance: float
    mutation_z_factor: float
    pairs_max: int
    pairs_min: int
    population_size: int
    reproduction_size: int
    samples: int
    z_max: float
    z_min: float
