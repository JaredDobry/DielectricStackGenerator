#include "Functions.h"
#include "Matrix.h"
#include <assert.h>
#include <thread>
#include <future>

const double PI = 3.141592653589793238463;

std::vector<double> cumsum(const std::vector<double>& in)
{
	//assert(in.size() != 0);
	std::vector<double> out;
	out.reserve(in.size());
	double sum = in.at(0);
	out.push_back(sum);
	for (size_t i = 1; i < in.size(); i++)
	{
		sum += in.at(i);
		out.push_back(sum);
	}
	return out;
}

std::vector<double> nVector(const std::vector<double>& in)
{
	//assert(in.size() != 0 && in.size() % 2 == 0);
	std::vector<double> out;
	out.reserve(in.size() + 1);
	out.push_back(1.0);
	for (size_t i = 0; i < in.size(); i++)
	{
		if (i % 2 == 0)
			out.push_back(4.2);
		else
			out.push_back(2.2);
	}
	//assert(out.size() == in.size() + 1);
	return out;
}

double coefficient(double wl, const std::vector<double>& z, const std::vector<double>& n)
{
	//assert(z.size() != 0);
	//assert(n.size() != 0);
	Matrix m = Matrix(1.0, 0.0, 0.0, 1.0);
	double kL = 2.0 * PI / wl;
	double k2 = kL;
	for (size_t i = 0; i < z.size(); i++)
	{
		double k1 = k2;
		k2 = n.at(i + 1) * 2.0 * PI / wl;

		std::complex<double> aa = 0.5 * (1.0 + n.at(i + 1) / n.at(i)) * exp(std::complex<double>(0.0, (k2 - k1) * z.at(i)));
		std::complex<double> ab = 0.5 * (1.0 - n.at(i + 1) / n.at(i)) * exp(std::complex<double>(0.0, -(k2 + k1) * z.at(i)));
		std::complex<double> ba = 0.5 * (1.0 - n.at(i + 1) / n.at(i)) * exp(std::complex<double>(0.0, (k2 + k1) * z.at(i)));
		std::complex<double> bb = 0.5 * (1.0 + n.at(i + 1) / n.at(i)) * exp(std::complex<double>(0.0, -(k2 - k1) * z.at(i)));

		m *= Matrix(aa, ab, ba, bb);
	}
	//flip the value of the imaginary part on 1/aa
	std::complex<double> invAA = std::complex<double>(m.aa().real(), -m.aa().imag());
	double T = ((1.0 / invAA * 1.0 / m.aa()) * (k2 / kL)).real();
	//assert(!isnan(T));
	return T; //transmission coefficient
}

double fitness(const EvaluationParameters& p, const std::vector<double>& in)
{
	//assert(in.size() != 0);
	double stepSize = (p.wlRangeUpper - p.wlRangeLower) / (double)p.samples;
	const std::vector<double> z = cumsum(in);
	const std::vector<double> n = nVector(in);

	//Fill the map with the wavelengths we need
	std::vector<std::pair<double, double>> wl_c_map;
	wl_c_map.reserve(p.samples);
	for (int i = 0; i < p.samples; i++)
		wl_c_map.push_back(std::pair<double, double>(p.wlRangeLower + stepSize * (double)i, 0.0));

	int exclusionPassedCount = 0;
	int inclusionPassedCount = 0;
	int exclusionTotalCount = 0;
	int inclusionTotalCount = 0;
	double sumInclusion = 0.0;
	double sumExclusion = 0.0;

	//Generate threads
	std::vector<std::future<void>> threads;
	for (int i = 0; i < p.samples; i++) 
	{
		threads.push_back(std::async(std::launch::async, threadCoefficient, std::ref(z), std::ref(n), std::ref(wl_c_map.at(i))));
	}
	//Join threads
	for (size_t i = 0; i < threads.size(); i++)
		threads.at(i).wait();

	for (std::pair<double, double> pr : wl_c_map)
	{
		double wl = pr.first;
		double c = pr.second;
		if (wl < p.inclusionLowerBound) //Exclusion zone 1
		{
			if (p.evalZone1)
			{
				sumExclusion += c;
				exclusionTotalCount++;
				if (c <= p.exclusionCutoff)
					exclusionPassedCount++;
			}
		}
		else if (wl > p.inclusionUpperBound) //Exclusion zone 2
		{
			if (p.evalZone2)
			{
				sumExclusion += c;
				exclusionTotalCount++;
				if (c <= p.exclusionCutoff)
					exclusionPassedCount++;
			}
		}
		else //Inclusion zone
		{
			sumInclusion += c;
			inclusionTotalCount++;
			if (c >= p.inclusionCutoff)
				inclusionPassedCount++;
		}
	}
	double inclusionScore = p.weightInclusion * ((double)inclusionPassedCount / (double)inclusionTotalCount);
	double exclusionScore = p.weightExclusion * ((double)exclusionPassedCount / (double)exclusionTotalCount);
	double inclusionAvg = sumInclusion / (double)inclusionTotalCount;
	double exclusionAvg = sumExclusion / (double)exclusionTotalCount;
	double inclusionAvgScore = p.weightAvgInclusion * inclusionAvg / p.inclusionCutoff;
	double exclusionAvgScore = p.weightAvgExclusion * (1.0 - exclusionAvg) / (1.0 - p.exclusionCutoff);
	double totalScore = inclusionScore + exclusionScore + inclusionAvgScore + exclusionAvgScore;
	//assert(!isnan(totalScore));
	return totalScore;
}

void threadCoefficient(const std::vector<double>& z, const std::vector<double>& n, std::pair<double, double>& pr)
{
	pr.second = coefficient(pr.first, z, n);
}