#pragma once
#include <vector>
#include "Member.h"
#include "IDs.h"
#include "Structs.h"
class Population
{
public:
	Population(int pid);
	~Population();

	//Generation
	void GenerateMember(const GenerationParameters& p);
	void GenerateMemberFromSeed(const MutationParameters& p, const Member& m);
	void GenerateMembers(const GenerationParameters& p, int n);
	void GenerateMembersFromSeed(const MutationParameters& p, const Member& m, int n);
	void GenerateMembersFromSeeds(const MutationParameters& p, const std::vector<Member>& in);

	//Evaluation
	void EvaluateMembers(const EvaluationParameters& p);

	//Reproduction
	void Reproduce(const ReproductionParameters& p, const MutationParameters& m, int n);
	const Member& SecondParent(const ReproductionParameters& p, const Member& p1);

	//Mutation
	void Mutate(const MutationParameters& m, Member& ref);
	const Member& RandomlySelectMemberAsSeed() const;
	std::vector<Member> RandomlySelectMembersAsSeeds(int n) const;

	//Vector stuff
	void AddMember(const std::vector<double>& in);
	void AddMember(const Member& in);
	void AddMembers(const std::vector<Member>& in);
	void RemoveMember(const Member& in);
	void RemoveMembers(size_t startIndex, size_t endIndex);
	void RemoveMembers(double chance, int n, bool bestMemberHasImmunity);
	const std::vector<double>& GetBestMember() const;

	//Rankings
	void RankMembers();
	const Member& BestMember() const;

	std::string StringifyBestMember() const;

private:
	void ThreadCallMemberEvaluateFitness(const EvaluationParameters& p, Member& ref);

	std::vector<std::pair<double, Member>> m_data;
	int m_id; //PID
	MID m_mid; //MID
};

