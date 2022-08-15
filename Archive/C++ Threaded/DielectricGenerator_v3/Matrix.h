#pragma once
#include <complex>

class Matrix
{
public:
	Matrix();
	Matrix(std::complex<double> aa, std::complex<double> ab, std::complex<double> ba, std::complex<double> bb);
	~Matrix();

	std::complex<double> aa() const;
	std::complex<double> ab() const;
	std::complex<double> ba() const;
	std::complex<double> bb() const;

	Matrix operator*(const Matrix& rhs) const;
	void operator*=(const Matrix& rhs);
	bool operator==(const Matrix& rhs) const;

	std::string Stringify() const;

private:
	std::complex<double> m_aa;
	std::complex<double> m_ab;
	std::complex<double> m_ba;
	std::complex<double> m_bb;
};

