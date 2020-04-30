#pragma once
#include <atomic>
class PID
{
public:
	PID();
	~PID();
	int GetID();

private:
	std::atomic<int> m_id;
};

class MID
{
public:
	MID();
	~MID();
	int GetID();

private:
	std::atomic<int> m_id;
};

