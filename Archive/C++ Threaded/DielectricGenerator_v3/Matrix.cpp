#include "Matrix.h"

Matrix::Matrix()
{
	m_aa = 0.0;
	m_ab = 0.0;
	m_ba = 0.0;
	m_bb = 0.0;
}

Matrix::Matrix(std::complex<double> aa, std::complex<double> ab, std::complex<double> ba, std::complex<double> bb)
{
	m_aa = aa;
	m_ab = ab;
	m_ba = ba;
	m_bb = bb;
}

Matrix::~Matrix()
{
}

std::complex<double> Matrix::aa() const
{
	return m_aa;
}

std::complex<double> Matrix::ab() const
{
	return m_ab;
}

std::complex<double> Matrix::ba() const
{
	return m_ba;
}

std::complex<double> Matrix::bb() const
{
	return m_bb;
}

Matrix Matrix::operator*(const Matrix& rhs) const
{
	std::complex<double> aa = m_aa * rhs.aa() + m_ab * rhs.ba();
	std::complex<double> ab = m_aa * rhs.ab() + m_ab * rhs.bb();
	std::complex<double> ba = m_ba * rhs.aa() + m_bb * rhs.ba();
	std::complex<double> bb = m_ba * rhs.ab() + m_bb * rhs.bb();
	return Matrix(aa, ab, ba, bb);
}

void Matrix::operator*=(const Matrix & rhs)
{
	std::complex<double> aa = m_aa * rhs.aa() + m_ab * rhs.ba();
	std::complex<double> ab = m_aa * rhs.ab() + m_ab * rhs.bb();
	std::complex<double> ba = m_ba * rhs.aa() + m_bb * rhs.ba();
	std::complex<double> bb = m_ba * rhs.ab() + m_bb * rhs.bb();
	m_aa = aa;
	m_ab = ab;
	m_ba = ba;
	m_bb = bb;
}

bool Matrix::operator==(const Matrix & rhs) const
{
	return m_aa == rhs.aa() && m_ab == rhs.ab() && m_ba == rhs.ba() && m_bb == rhs.bb();
}

std::string Matrix::Stringify() const
{
	return "Matrix:\n|" + std::to_string(m_aa.real()) + "+i" + std::to_string(m_aa.imag()) + ", " +
		std::to_string(m_ab.real()) + "+i" + std::to_string(m_ab.imag()) + "|\n|" +
		std::to_string(m_ba.real()) + "+i" + std::to_string(m_ba.imag()) + ", " +
		std::to_string(m_bb.real()) + "+i" + std::to_string(m_bb.imag()) + "|";
}
