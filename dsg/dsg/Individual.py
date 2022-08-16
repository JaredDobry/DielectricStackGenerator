from dsg.Configuration import Configuration, FilterType
from dsg.Utils import coefficient, coefficient_params, exclusion_wavelength, wavelengths
import numpy as np
from typing import List, Tuple


class Individual:
    _fitness: float = None
    _coefficients: List[float] = None
    _coefficient_params = Tuple[np.ndarray, np.ndarray]
    _substrate: List[float]

    def __init__(self, substrate: List[float]):
        self._coefficient_params = coefficient_params(substrate)
        self._substrate = substrate

    def coefficients(self, config: Configuration):
        if not self._coefficients:
            self.fitness(config, True)
        return self._coefficients

    def fitness(self, config: Configuration, save_coefficients: bool = False):
        if self._fitness is None or (self._coefficients is None and save_coefficients):
            ws = wavelengths(config)
            coefficients = [
                coefficient(self._coefficient_params[0], self._coefficient_params[1], w)
                for w in ws
            ]
            if save_coefficients:
                self._coefficients = coefficients

            exclusion_count = 0
            exclusion_sum = 0
            inclusion_count = 0
            inclusion_sum = 0
            for i in range(0, len(ws)):
                if exclusion_wavelength(config, ws[i]):
                    exclusion_count += 1
                    exclusion_sum += coefficients[i]
                else:
                    inclusion_count += 1
                    inclusion_sum += coefficients[i]
            self._fitness = (
                config.inclusion_weight * inclusion_sum / inclusion_count
                + config.exclusion_weight * (1 - exclusion_sum / exclusion_count)
            )

        return self._fitness

    def substrate(self) -> List[float]:
        return self._substrate
