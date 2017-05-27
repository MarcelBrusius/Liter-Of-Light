#include <numeric>
#include <cmath>
#include <vector> // vector<class> template
//#include <iostream> // input, output interaction via console
//
//#include <fstream> // file interactions
//#include <iterator>
//#include <sstream>
//#include <string>
//#include <stdlib.h> // string to double conversion

#include <ctime> // ermöglicht timer

#include <Eigen\Eigen> // matrix, vector classes for easy computations

using namespace std;
using namespace Eigen;

#include "ImportData.h"
#include "Structures.h"
#include "RayTracer.h"

int main(int argc, char** argv)
{
	// initialize variables:
	Light light, reflection, refraction;
	Surface surface;

	ImportData im;
	light.Direction = im.Import("Data/LightDirection.dat", light.Direction);
	light.Origin = im.Import("Data/LightOrigin.dat", light.Origin);
	light.Intensity = im.Import("Data/LightIntensity.dat", light.Intensity);
	light.RayNumber = light.Direction.size();

	surface.Vertices = im.Import("Data/SurfaceVertex.dat", surface.Vertices);
	surface.Normal = im.Import("Data/SurfaceNormal.dat", surface.Normal);
	surface.Facets = im.Import("Data/SurfaceFacets.dat", surface.Facets);
	surface.NumFacets = surface.Facets.size();

	RayTrace Interaction;
	Interaction.reflection = light;
	Interaction.refraction = light;

	clock_t start = clock();
	Interaction = RayTracer(light, Interaction, surface, false);
	clock_t end = clock();

	cout << "Elapsed time is: " << (end - start) / (double)CLOCKS_PER_SEC;

	return 0;
}