#include <iostream>
#include <string>
#include <assert.h>
#include <thread>

#include "Population.h"
#include "Structs.h"
#include "IDs.h"
#include "Member.h"

void GenerateSWLBPF(Population& p, const GenerationParameters& g, const EvaluationParameters& e, const ReproductionParameters& r, const MutationParameters& m, int N);
void GenerateLWLBPF(Population& p, const GenerationParameters& g, const EvaluationParameters& e, const ReproductionParameters& r, const MutationParameters& m, int N);
void GenerateFullBPF(Population& p, const GenerationParameters& g, const EvaluationParameters& e, const ReproductionParameters& r, const MutationParameters& m, int N);

int main()
{
	int N = 128;
	//assert(N % 4 == 0);
	PID pid;
	Population pSWL(pid.GetID());
	Population pLWL(pid.GetID());
	GenerationParameters g;
	g.lowerLength = 2;
	g.upperLength = 8;
	g.lowerWidth = 10.0;
	g.upperWidth = 800.0;
	pSWL.GenerateMembers(g, N);
	pLWL.GenerateMembers(g, N);

	EvaluationParameters eSWL;
	eSWL.evalZone1 = true;
	eSWL.evalZone2 = false;
	eSWL.exclusionCutoff = 0.1;
	eSWL.inclusionCutoff = 0.9;
	eSWL.inclusionLowerBound = 4000.0;
	eSWL.inclusionUpperBound = 5000.0;
	eSWL.samples = 256;
	eSWL.weightAvgExclusion = .3;
	eSWL.weightAvgInclusion = .3;
	eSWL.weightExclusion = .2;
	eSWL.weightInclusion = .2;
	eSWL.wlRangeLower = 3000.0;
	eSWL.wlRangeUpper = 6000.0;

	EvaluationParameters eLWL = eSWL;
	eLWL.evalZone1 = false;
	eLWL.evalZone2 = true;

	ReproductionParameters r;
	r.chancePerMember = 1.0 / (double)N;
	r.randomIfNoMatch = true;
	r.randomSampling = false;

	MutationParameters m;
	m.elementChangeChance = .2;
	m.elementRandomizeChance = .05;
	m.lengthChangeChance = .05;
	m.lowerWidth = 10.0;
	m.upperWidth = 800.0;
	m.maximumLengthChange = 10;
	m.maximumPercentageElementChange = 0.2;
	m.minumumPercentageElementChange = 0.01;

	std::thread swlThread = std::thread(GenerateSWLBPF, std::ref(pSWL), std::ref(g), std::ref(eSWL), std::ref(r), std::ref(m), N);
	std::thread lwlThread = std::thread(GenerateLWLBPF, std::ref(pLWL), std::ref(g), std::ref(eLWL), std::ref(r), std::ref(m), N);

	swlThread.join();
	lwlThread.join();

	std::vector<double> swl = pSWL.GetBestMember();
	std::vector<double> lwl = pLWL.GetBestMember();
	std::vector<double> full;
	full.reserve(swl.size() + lwl.size());
	for (double d : swl)
		full.push_back(d);
	for (double d : lwl)
		full.push_back(d);
	Population p(pid.GetID());
	p.AddMember(full);
	g.lowerLength = full.size() - 8;
	g.upperLength = full.size() + 8;
	p.GenerateMembersFromSeed(m, p.BestMember(), N - 1);
	EvaluationParameters e = eSWL;
	e.evalZone1 = true;
	e.evalZone2 = true;
	e.exclusionCutoff = 0.05;
	e.inclusionCutoff = 0.95;
	m.maximumLengthChange = 2;
	m.elementChangeChance = .4;
	m.elementRandomizeChance = .005;
	m.lengthChangeChance = 0.01;
	std::thread fullThread = std::thread(GenerateFullBPF, std::ref(p), std::ref(g), std::ref(e), std::ref(r), std::ref(m), N);

	fullThread.join();

	std::cout << "Done" << std::endl;
	while (true) {} //System hang
	return 0;
}

void GenerateSWLBPF(Population& p, const GenerationParameters& g, const EvaluationParameters& e, const ReproductionParameters& r, const MutationParameters& m, int N)
{
	//Do iteration loop for SWL BPF
	std::cout << "[Generating SWL BPF]" << std::endl;
	p.EvaluateMembers(e);
	double f = 0.0;
	int i = 0;
	while (f < 0.95)
	{
		p.RemoveMembers(1.0 / (double)N, 3 * N / 4, true);
		p.Reproduce(r, m, N / 4);
		std::vector<Member> seeds = p.RandomlySelectMembersAsSeeds(N / 4);
		p.GenerateMembersFromSeeds(m, seeds);
		p.GenerateMembers(g, N / 4);
		p.EvaluateMembers(e);
		i++;
		if (p.BestMember().GetFitness() > f)
			std::cout << "SWL New Best: " << p.BestMember().GetFitness() << ", iteration: " << i << std::endl;
		f = p.BestMember().GetFitness();
	}
	std::cout << "[SWL Complete] in iteration: " << i << std::endl;
	std::cout << p.StringifyBestMember() << std::endl;
}

void GenerateLWLBPF(Population& p, const GenerationParameters& g, const EvaluationParameters& e, const ReproductionParameters& r, const MutationParameters& m, int N)
{
	//Do iteration loop for LWL BPF
	std::cout << "[Generating LWL BPF]" << std::endl;
	p.EvaluateMembers(e);
	int i = 0;
	double f = 0.0;
	while (f < 0.95)
	{
		p.RemoveMembers(1.0 / (double)N, 3 * N / 4, true);
		p.Reproduce(r, m, N / 4);
		std::vector<Member> seeds = p.RandomlySelectMembersAsSeeds(N / 4);
		p.GenerateMembersFromSeeds(m, seeds);
		p.GenerateMembers(g, N / 4);
		p.EvaluateMembers(e);
		i++;
		if (p.BestMember().GetFitness() > f)
			std::cout << "LWL New Best: " << p.BestMember().GetFitness() << ", iteration: " << i << std::endl;
		f = p.BestMember().GetFitness();
	}
	std::cout << "[LWL Complete] in iteration: " << i << std::endl;
	std::cout << p.StringifyBestMember() << std::endl;
}

void GenerateFullBPF(Population& p, const GenerationParameters& g, const EvaluationParameters& e, const ReproductionParameters& r, const MutationParameters& m, int N)
{
	//Do iteration loop for Full BPF
	std::cout << "[Generating Full BPF]" << std::endl;
	p.EvaluateMembers(e);
	int i = 0;
	double f = 0.0;
	while (f < 0.95)
	{
		p.RemoveMembers(1.0 / (double)N, 3 * N / 4, true);
		p.Reproduce(r, m, N / 4);
		std::vector<Member> seeds = p.RandomlySelectMembersAsSeeds(N / 4);
		p.GenerateMembersFromSeeds(m, seeds);
		p.GenerateMembers(g, N / 4);
		p.EvaluateMembers(e);
		i++;
		if (p.BestMember().GetFitness() > f)
			std::cout << "Full New Best: " << p.BestMember().GetFitness() << ", iteration: " << i << std::endl;
		f = p.BestMember().GetFitness();
	}
	std::cout << "[Full Complete] in iteration: " << i << std::endl;
	std::cout << p.StringifyBestMember() << std::endl;
}