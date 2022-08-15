#pragma once
#include <vector>
#include "Structs.h"

class Member
{
public:
	Member(int pid, int id);
	Member();
	~Member();

	int GetMID() const;
	int GetPID() const;
	void SetVector(const std::vector<double>& ref);
	const std::vector<double>& GetVector() const;
	double GetFitness() const;
	double EvaluateFitness(const EvaluationParameters& p);
	std::string Stringify() const;

	bool operator==(const Member& rhs) const;

private:
	double m_fitness;
	std::vector<double> m_data;
	int m_pid;
	int m_id;
};

