#include "IDs.h"

PID::PID()
{
	m_id = 0;
}

PID::~PID()
{
}

int PID::GetID()
{
	return m_id++;
}

MID::MID()
{
	m_id = 0;
}

MID::~MID()
{
}

int MID::GetID()
{
	return m_id++;
}
