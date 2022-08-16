from dsg.Configuration import Configuration
from dsg.Individual import Individual
from dsg.Utils import cull_individuals, generate_child, generate_substrate, select_parents
from typing import List, Tuple


class Population:
    _config: Configuration
    _individuals: List[Individual] = None

    def __init__(self, config: Configuration):
        self._config = config

    def cull(self, ranked_individuals: List[Individual]):
        individuals = ranked_individuals
        individuals.reverse()
        return cull_individuals(self._config, individuals)

    def generate(self):
        self._individuals = [Individual(generate_substrate(self._config)) for _ in range(0, self._config.population_size)]

    def iterate(self) -> Tuple[float, Individual]:
        ranks = self.rank()
        ranked_individuals = [r[1] for r in ranks]
        children = self.reproduce(ranked_individuals)
        culled = self.cull(ranked_individuals)
        self._individuals = culled + children
        return ranks[0][0], ranks[0][1]

    def rank(self):
        ranks = []
        for individual in self._individuals:
            ranks.append([individual.fitness(config=self._config), individual])
        ranks.sort(key=lambda x: x[0], reverse=True)
        return ranks

    def reproduce(self, ranked_individuals: List[Individual]) -> List[Individual]:
        children = []
        while len(children) < self._config.reproduction_size:
            parent_1, parent_2 = select_parents(ranked_individuals)
            children.append(Individual(generate_child(self._config, parent_1.substrate(), parent_2.substrate())))
        return children
