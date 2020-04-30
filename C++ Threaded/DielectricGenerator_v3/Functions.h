#pragma once
#include <vector>
#include "Structs.h"

std::vector<double> cumsum(const std::vector<double>& in);

std::vector<double> nVector(const std::vector<double>& in);

double coefficient(double wl, const std::vector<double>& z, const std::vector<double>& n);

double fitness(const EvaluationParameters& p, const std::vector<double>& in);

void threadCoefficient(const std::vector<double>& z, const std::vector<double>& n, std::pair<double, double>& pr);