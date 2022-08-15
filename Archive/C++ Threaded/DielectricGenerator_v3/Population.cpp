#include "Population.h"
#include <algorithm>
#include <random>
#include <thread>
#include <assert.h>

Population::Population(int pid)
{
	m_id = pid;
}


Population::~Population()
{
}

void Population::GenerateMember(const GenerationParameters& p)
{
	std::vector<double> m;
	//Determine size of this member
	std::random_device rd;
	std::default_random_engine generator(rd());
	std::uniform_int_distribution<int> lengthDist(p.lowerLength, p.upperLength);
	std::uniform_real_distribution<double> widthDist(p.lowerWidth, p.upperWidth);
	int length = lengthDist(generator);
	//It can't be odd, so force it to even randomly
	if (length % 2 != 0)
	{
		if (length == p.upperLength)
			length--;
		else if (length == p.lowerLength)
			length++;
		else //force them all smaller for better memory management
			length--;
	}
	m.reserve(length);
	//Populate the reserved vector with random widths
	for (int i = 0; i < length; i++)
	{
		m.push_back(widthDist(generator));
	}
	//Put into member and put on our data
	Member mem(m_id, m_mid.GetID());
	mem.SetVector(m);
	//assert(mem.GetVector().size() != 0);
	m_data.push_back(std::make_pair<>(0.0, mem));
}

void Population::GenerateMemberFromSeed(const MutationParameters& p, const Member& m)
{
	Member newMem(m_id, m_mid.GetID());
	newMem.SetVector(m.GetVector());
	Mutate(p, newMem);
	m_data.push_back(std::make_pair<>(0.0, newMem));
}

void Population::GenerateMembers(const GenerationParameters& p, int n)
{
	m_data.reserve(m_data.size() + n);
	for (int i = 0; i < n; i++)
		GenerateMember(p);
}

void Population::GenerateMembersFromSeed(const MutationParameters& p, const Member& m, int n)
{
	m_data.reserve(m_data.size() + n);
	for (int i = 0; i < n; i++)
		GenerateMemberFromSeed(p, m);
}

void Population::GenerateMembersFromSeeds(const MutationParameters& p, const std::vector<Member>& in)
{
	m_data.reserve(m_data.size() + in.size());
	for (Member m : in)
		GenerateMemberFromSeed(p, m);
}

void Population::EvaluateMembers(const EvaluationParameters& p)
{
	//Threaded dispatch all members to calculate their fitness
	std::vector<std::thread> threads;
	for (size_t i = 0; i < m_data.size(); i++)
	{
		threads.push_back(std::thread(&Member::EvaluateFitness, &m_data.at(i).second, p));
	}

	//Join all threads
	for (int i = 0; i < (int)threads.size(); i++)
		threads.at(i).join();

	//Update their pair values
	for (size_t i = 0; i < m_data.size(); i++)
		m_data.at(i).first = m_data.at(i).second.GetFitness();

	//Rank
	RankMembers();
}

void Population::Reproduce(const ReproductionParameters& p, const MutationParameters& m, int n)
{
	m_data.reserve(m_data.size() + n);
	for (int i = 0; i < n; i++)
	{
		Member newMember(m_id, m_mid.GetID());
		//First parent is always from the top of the rankings
		const Member& p1 = BestMember();
		//Second parent should be selected randomly via chance, favoring the top of the list if the option is selected (can't be yourself)
		const Member& p2 = SecondParent(p, p1);
		//"Genes" are sets of 2, so do this in those chunks
		std::random_device rd;
		std::default_random_engine generator(rd());
		std::uniform_real_distribution<double> dist(0.0, 1.0);
		const std::vector<double>& p1Vec = p1.GetVector();
		const std::vector<double>& p2Vec = p2.GetVector();
		if (p1Vec.size() >= p2Vec.size())
		{
			std::vector<double> newVec;
			newVec.reserve(p1Vec.size());
			for (size_t i = 0; i < p1Vec.size(); i += 2)
			{
				if (p2Vec.size() >= i + 2)
				{
					if (dist(generator) < 0.5) //go with p1
					{
						newVec.push_back(p1Vec.at(i));
						newVec.push_back(p1Vec.at(i + 1));
					}
					else //go with p2
					{
						newVec.push_back(p2Vec.at(i));
						newVec.push_back(p2Vec.at(i + 1));
					}
				}
				else
				{
					newVec.push_back(p1Vec.at(i));
					newVec.push_back(p1Vec.at(i + 1));
				}
			}
			newMember.SetVector(newVec);
		}
		else
		{
			std::vector<double> newVec;
			newVec.reserve(p2Vec.size());
			for (size_t i = 0; i < p2Vec.size(); i += 2)
			{
				if (p1Vec.size() >= i + 2)
				{
					if (dist(generator) < 0.5) //go with p1
					{
						newVec.push_back(p1Vec.at(i));
						newVec.push_back(p1Vec.at(i + 1));
					}
					else //go with p2
					{
						newVec.push_back(p2Vec.at(i));
						newVec.push_back(p2Vec.at(i + 1));
					}
				}
				else
				{
					newVec.push_back(p2Vec.at(i));
					newVec.push_back(p2Vec.at(i + 1));
				}
			}
			newMember.SetVector(newVec);
		}
		Mutate(m, newMember);
		m_data.push_back(std::make_pair<>(0.0, newMember));
	}
}

const Member& Population::SecondParent(const ReproductionParameters& p, const Member& p1)
{
	std::random_device rd;
	std::default_random_engine generator(rd());
	std::uniform_int_distribution<int> intDist(0, m_data.size() - 1);
	if (p.randomSampling)
	{
		const Member& m = m_data.at(intDist(generator)).second;
		if (m == p1)
			return SecondParent(p, p1);
		else
			return m;
	}
	else
	{
		std::uniform_real_distribution<double> dist(0.0, 1.0);
		for (size_t i = 0; i < m_data.size(); i++)
		{
			if (m_data.at(i).second == p1)
				continue;
			else if (dist(generator) <= p.chancePerMember)
				return m_data.at(i).second;
		}
		//Didn't get one, check term conditions
		if (p.randomIfNoMatch)
			return m_data.at(intDist(generator)).second;
		else
			return SecondParent(p, p1);
	}
}

void Population::Mutate(const MutationParameters& m, Member& ref)
{
	std::random_device rd;
	std::default_random_engine generator(rd());
	std::uniform_real_distribution<double> dist(0.0, 1.0);
	std::vector<double> temp = ref.GetVector();
	//assert(temp.size() != 0);
	//Check for length change first
	if (m.lengthChangeChance >= dist(generator))
	{
		//How many to change
		std::uniform_int_distribution<int> intDist(2, m.maximumLengthChange);
		int num = intDist(generator);
		if (num % 2 != 0) //force it even
			num++;

		//Figure out where to insert/delete the elements
		std::uniform_int_distribution<int> posDist(0, temp.size() - 1);
		int pos = posDist(generator);
		if (pos % 2 != 0) //force it even
		{
			if (pos == temp.size() - 1)
				pos--;
			else
				pos++;
		}

		//Add or remove?
		if (dist(generator) < 0.5) //sub
		{
			if (num > (int)temp.size() - 2) //can't have less than 2 elements
				num = temp.size() - 2;
			for (int i = 0; i < num; i++) //remove the elements
			{
				if (pos == temp.size())
					break;

				auto it = temp.begin() + pos;
				temp.erase(it);
			}
		}
		else //add
		{
			//Create the new elements
			std::vector<double> newElements;
			std::uniform_real_distribution<double> widthDist(m.lowerWidth, m.upperWidth);
			for (int i = 0; i < num; i++)
			{
				newElements.push_back(widthDist(generator));
			}

			//Put the new elements into the vector
			if (pos >= (int)temp.size() - 1) //put at end, don't do expensive copy
			{
				temp.reserve(temp.size() + newElements.size());
				for (double d : newElements)
					temp.push_back(d);
			}
			else
			{
				auto it = temp.begin() + pos;
				temp.insert(it, newElements.begin(), newElements.end());
			}
		}
	}
	//Iterate over the whole member
	for (size_t i = 0; i < temp.size(); i++)
	{
		//Randomize this element?
		if (dist(generator) <= m.elementRandomizeChance)
		{
			std::uniform_real_distribution<double> widthDist(m.lowerWidth, m.upperWidth);
			temp.at(i) = widthDist(generator);
		}
		//Change this elements width?
		else if (dist(generator) <= m.elementChangeChance)
		{
			std::uniform_real_distribution<double> percentDist(m.minumumPercentageElementChange, m.maximumPercentageElementChange);
			double percent = 1.0 + percentDist(generator);
			//Do we go up or down?
			if (dist(generator) < 0.5) //up
			{
				temp.at(i) *= percent;
			}
			else //down
			{
				temp.at(i) /= percent;
			}
		}
	}
	ref.SetVector(temp);
}

const Member& Population::RandomlySelectMemberAsSeed() const
{
	std::random_device rd;
	std::default_random_engine generator(rd());
	std::uniform_int_distribution<int> dist(0, m_data.size() - 1);
	return m_data.at(dist(generator)).second;
}

std::vector<Member> Population::RandomlySelectMembersAsSeeds(int n) const
{
	std::random_device rd;
	std::default_random_engine generator(rd());
	std::uniform_int_distribution<int> dist(0, m_data.size() - 1);
	std::vector<Member> out;
	out.reserve(n);
	for (int i = 0; i < n; i++)
		out.push_back(m_data.at(dist(generator)).second);
	return out;
}

void Population::AddMember(const std::vector<double>& in)
{
	//assert(in.size() != 0);
	Member m(m_id, m_mid.GetID());
	m.SetVector(in);
	m_data.push_back(std::make_pair<>(0.0, m));
}

void Population::AddMember(const Member& in)
{
	//assert(in.GetVector().size() != 0);
	m_data.push_back(std::make_pair<>(0.0, in));
}

void Population::AddMembers(const std::vector<Member>& in)
{
	m_data.reserve(m_data.size() + in.size());
	for (Member m : in)
		m_data.push_back(std::make_pair<>(0.0, m));
}

void Population::RemoveMember(const Member& in)
{
	auto it = std::find_if(m_data.begin(), m_data.end(), [&](std::pair<double, Member> p)
	{
		return p.second == in;
	});

	if (it != m_data.end())
		m_data.erase(it);
}

void Population::RemoveMembers(size_t startIndex, size_t endIndex)
{
	std::vector<std::pair<double, Member>> temp;
	temp.reserve(m_data.size() - (endIndex - startIndex));
	for (size_t i = 0; i < m_data.size(); i++)
	{
		if (i < startIndex || i > endIndex)
			temp.push_back(m_data.at(i));
	}
	m_data = temp;
}

void Population::RemoveMembers(double chance, int n, bool bestMemberHasImmunity)
{
	std::random_device rd;
	std::default_random_engine generator(rd());
	std::uniform_real_distribution<double> dist(0.0, 1.0);
	std::vector<Member> toRemove;
	int chosen = 0;
	for (size_t i = 0; i < m_data.size(); i++)
	{
		if (chosen == n)
			break;
		else
		{
			if (i == 0 && bestMemberHasImmunity)
				continue;
			else
			{
				if (dist(generator) <= chance) //Selected to die
				{
					//See if its already in the list
					auto it = std::find_if(toRemove.begin(), toRemove.end(), [&](Member m)
					{
						if (m == m_data.at(i).second)
							return true;
						return false;
					});
					if (it == toRemove.end())
					{
						toRemove.push_back(m_data.at(i).second);
						chosen++;
					}
				}
			}
		}
		if (i == m_data.size() - 1 && chosen < n) //repeat if we didn't select enough to kill
			i == 0;
	}

	for (Member m : toRemove)
		RemoveMember(m);
}

const std::vector<double>& Population::GetBestMember() const
{
	return m_data.at(0).second.GetVector();
}

void Population::RankMembers()
{
	std::sort(m_data.begin(), m_data.end(), [](const std::pair<double, Member>& a, const std::pair<double, Member>& b) 
	{
		return a.first > b.first;
	});
}

const Member& Population::BestMember() const
{
	return m_data.at(0).second;
}

std::string Population::StringifyBestMember() const
{
	return m_data.at(0).second.Stringify();
}

void Population::ThreadCallMemberEvaluateFitness(const EvaluationParameters& p, Member& ref)
{
	ref.EvaluateFitness(p);
}
