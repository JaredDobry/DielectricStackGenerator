#include <string>
#include <assert.h>
#include "Member.h"
#include "Functions.h"

Member::Member(int pid, int id)
{
	m_pid = pid;
	m_id = id;
	m_fitness = 0.0;
	m_data;
}

Member::Member()
{
	m_pid = 0;
	m_id = 0;
	m_fitness = 0.0;
	m_data;
}

Member::~Member()
{
}

int Member::GetMID() const
{
	return m_id;
}

int Member::GetPID() const
{
	return m_pid;
}

void Member::SetVector(const std::vector<double>& ref)
{
	//assert(ref.size() != 0);
	m_data = ref;
}

const std::vector<double>& Member::GetVector() const
{
	//assert(m_data.size() != 0);
	return m_data;
}

double Member::GetFitness() const
{
	return m_fitness;
}

double Member::EvaluateFitness(const EvaluationParameters& p)
{
	//assert(m_data.size() != 0);
	if (m_fitness == 0.0)
		m_fitness = fitness(p, m_data);
	//assert(!isnan(m_fitness));
	return m_fitness;
}

std::string Member::Stringify() const
{
	std::string toReturn = "P" + std::to_string(m_pid) + "M" + std::to_string(m_id) + ": Fitness: " + std::to_string(m_fitness) + " [";
	for (size_t i = 0; i < m_data.size(); i++)
	{
		if (i == m_data.size() - 1)
			toReturn += std::to_string(m_data.at(i)) + "]";
		else
			toReturn += std::to_string(m_data.at(i)) + ", ";
	}
	return toReturn;
}

bool Member::operator==(const Member& rhs) const
{
	return m_id == rhs.m_id && m_pid == rhs.m_pid;
}
