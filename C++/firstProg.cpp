#include <iostream> // ermöglicht z.B. cout, cin,
#include <numeric> // ermöglicht z.B. inner_product, iota, partial_sum
#include <cmath> // ermöglicht z.B. abs, fmod (Rest), ceil, floor, exp, sqrt,...
#include <ctime> // ermöglicht timer


using namespace std; // vermeidet Doppelbenennung von Variablen

#include "basicOperations.h"


struct fresnelOutput {
	double reflectionRate;
	double refractionRate;
};

fresnelOutput fresnel( double n1 , double n2 , double c1 , double c2 ) {

	//FRESNEL computes the rate of reflection R
	//and the rate of transmission T when light moves
	//from medium M1 into medium M2,
	//using the fresnel equations.
	//Input: - n1 refractive index from medium M1
	//       - n2 refractive index from medium M2
	//       - c1 cosine value of incidence angle
	//       - c2 cosine value of refraction angle.

	fresnelOutput fresnelout;
	double nrel = n2/n1;
	double frel = c2/c1;

	//s-polarized light
	double rs = pow(((-nrel*frel+1)/(nrel*frel+1)),2);
	//p-polarized light
	double rp = pow(((nrel-frel)/(nrel+frel)),2);
	//assume unpolarised light
	fresnelout.reflectionRate = 0.5*(rs+rp);
	//conservation of energy
	fresnelout.refractionRate = 1-fresnelout.reflectionRate;
	return fresnelout;
}


struct snellsLawOutput {
	vector<double> reflectionDirection;
	vector<double> refractionDirection;
	double reflectionIntensity;
	double refractionIntensity;
};


snellsLawOutput snellsLaw( vector<double> normal , vector<double> direction , double intensity , double n1 , double n2 ) {

	//REFLECTLIGHT Calculate reflection and refraction of a light ray at the bottle surface
	//   http://www.thefullwiki.org/Snells_law
	//   Output:
	//   - reflection: Direction vector of reflected light ray
	//   - refraction: Direction vector of refracted light ray
	//   - reflectionIntensity: Calculate the intensity of light, that is reflected
	//   - refractionIntensity: Calculate the intensity of light, that is refracted
	//   Input:
	//   - normal: Normal vector of the penetrated triangle
	//   - direction: Direction of the incident light ray
	//   - intensity: Intensity of incident light ray
	//   - n1: Refractive index of the medium, where the light ray is coming from
	//   - n2: Refractive index of the medium of the transmitted light ray

	snellsLawOutput snellsout;
	normal=normVector(normal);
	direction=normVector(direction);
	double stmp1 = -1;
	vector<double> vtmp1 = multVectorScalar(direction,stmp1);
	vtmp1 = multVectors(normal,vtmp1);
	if(sumVector(vtmp1)<0) {
		cout << "Fehler: Verkehrte Richtung des Lichtstrahls in Funktion 'snellsLaw'.\n";
	}
	double cosTheta1 = sumVector(vtmp1); // angle of incident light ray
	double cosTheta2 = sqrt(1-pow((n1/n2),2)*(1-pow(cosTheta1,2))); // angle of refracted light ray

	if(1-pow((n1/n2),2)*(1-pow(cosTheta1,2)) > 0) {  // check for total reflection
		stmp1=n1/n2;
		double stmp2=(n1/n2)*cosTheta1-((cosTheta1>0)-(cosTheta1<0))*cosTheta2;
		vtmp1 = multVectorScalar(direction,stmp1);
		vector<double> vtmp2 = multVectorScalar(normal,stmp2);
		vtmp1 = addVectors(vtmp1,vtmp2);
		vtmp1 = normVector(vtmp1);
		snellsout.refractionDirection = vtmp1;

		// Methode 1: Assume plastic doesn't change intensities
		fresnelOutput fresnelout = fresnel(n1,n2,cosTheta1,cosTheta2);
		snellsout.reflectionIntensity = intensity * fresnelout.reflectionRate;
		snellsout.refractionIntensity = intensity * fresnelout.refractionRate;
	}else{
		snellsout.refractionDirection = {0,0,0};
		snellsout.refractionIntensity = 0;
		snellsout.reflectionIntensity = intensity;
	}
	stmp1 = 2*cosTheta1;
	vtmp1 = multVectorScalar(normal,stmp1);
	snellsout.reflectionDirection = addVectors(direction,vtmp1);
	snellsout.reflectionDirection = normVector(snellsout.reflectionDirection);

	return snellsout;
}


int main() {

	clock_t start;
	double duration;
	start=clock();

	double n1 = 1;
	double n2 = 1.33;
	double intensity = 1;
	vector<double> normal {1,2,3};
	vector<double> direction {-4,-5,-6};
	snellsLawOutput output;
	for (unsigned int i=0; i<1000000; i++) {
		output = snellsLaw( normal, direction , intensity , n1 , n2 );  // ray goes from air to water
	}
	cout << "Reflektionsrichtung:   "; printVector(output.reflectionDirection); cout << "\n";
	cout << "Refraktionsrichtung:   "; printVector(output.refractionDirection); cout << "\n";
	cout << "Refraktionsintensität: " << output.reflectionIntensity <<"\n";
	cout << "Refraktionsintensität: " << output.refractionIntensity <<"\n";

	duration = ( std::clock() - start ) / (double) CLOCKS_PER_SEC;
	cout<<"Dauer: "<< duration <<"\n";

	return 0;
}
