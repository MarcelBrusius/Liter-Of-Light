#include <iostream> // ermöglicht z.B. cout, cin,
#include <numeric> // ermöglicht z.B. inner_product, iota, partial_sum
#include <cmath> // ermöglicht z.B. abs, fmod (Rest), ceil, floor, exp, sqrt,...
#include <ctime> // ermöglicht timer


using namespace std; // std:: nicht mehr notwendig



//int main() {
//
//	clock_t start;
//	double duration;
//	start=clock();
//
//	double n1 = 1;
//	double n2 = 1.33;
//	double intensity = 1;
//	vector<double> normal {1,2,3};
//	vector<double> direction {-4,-5,-6};
//	snellsLawOutput output;
//	for (unsigned int i=0; i<1000000; i++) {
//		output = snellsLaw( normal, direction , intensity , n1 , n2 );  // ray goes from air to water
//	}
//	cout << "Reflektionsrichtung:   "; printVector(output.reflectionDirection); cout << "\n";
//	cout << "Refraktionsrichtung:   "; printVector(output.refractionDirection); cout << "\n";
//	cout << "Refraktionsintensität: " << output.reflectionIntensity <<"\n";
//	cout << "Refraktionsintensität: " << output.refractionIntensity <<"\n";
//
//	duration = ( std::clock() - start ) / (double) CLOCKS_PER_SEC;
//	cout <<"Dauer: "<< duration <<"\n";
//
//	int i;
//	cin >> i;
//
//	return 0;
//}
