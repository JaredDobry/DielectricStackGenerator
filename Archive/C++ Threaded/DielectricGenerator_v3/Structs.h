#pragma once
struct GenerationParameters
{
	int lowerLength; //Lower limit of the vector length of the dielectric
	int upperLength; //Upper limit of the vector length of the dielectric
	double lowerWidth; //Lower limit of the width of any dielectric slice size
	double upperWidth; //Upper limit of the width of any dielectric slice size
};

struct EvaluationParameters
{
	double weightExclusion; //Determines the weight to give to raw # of values that are below the cutoff
	double weightAvgExclusion; //Determines the weight to give to the avg value of all wavelengths in the range compared to the cutoff
	double exclusionCutoff; //Determines the value below which a transmission coefficient is considered "excluded"
	double weightInclusion; //Determines the weight to give to raw # of values that are above the cutoff
	double weightAvgInclusion; //Determines the weight to give to the avg value of all wavelengths in the range compared to the cutoff
	double inclusionCutoff; //Determines the value above which a transmission coefficient is considered "included"
	double inclusionLowerBound;
	double inclusionUpperBound;
	double wlRangeLower; //Bottom of the wavelength range to test over
	double wlRangeUpper; //Top of the wavelength range to test over
	int samples; //Number of samples to take in the range
	bool evalZone1;
	bool evalZone2;
};

struct ReproductionParameters
{
	double chancePerMember; //Determines the chance of any random member being selected for reproduction
	bool randomSampling; //Determines whether reproduction is entirely random, No for top->bottom chance evaluation
	bool randomIfNoMatch; //Determines whether to pick a random member for reproduction if the top->bottom chance evaluation did not return a member
};

struct MutationParameters
{
	double lengthChangeChance; //The chance for the length of the member's DNA to change
	int maximumLengthChange; //The maximum amount of DNA to add/subtract. MUST BE EVEN
	double lowerWidth; //Lower limit of the width of a new dielectric slice size (only used for generating new random stacks)
	double upperWidth; //Upper limit of the width of a new dielectric slice size (only used for generating new random stacks)
	double elementRandomizeChance; //The chance to change any given dielectric width to a new random one
	double elementChangeChance; //The chance to change any given dielectric width
	double minumumPercentageElementChange; //The minimum percent to change the element width (goes up or down)
	double maximumPercentageElementChange; //The maximum percent to change the element width (goes up or down)
};