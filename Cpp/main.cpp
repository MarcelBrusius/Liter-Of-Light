/*
* main.cpp
*
*  Updated on: 29.05.2017
*      Author: Marcel Brusius
*			   University of Kaiserslautern
*/
// defines which library should be used to prevent link-errors, see several tutorials
#pragma comment(lib, "libmx.lib")
#pragma comment(lib, "libmat.lib")
#pragma comment(lib, "libmex.lib")

#include <numeric>
#include <cmath>
#include <vector> // vector<class> template
#include <iostream>
#include <ctime> // ermöglicht timer
#include <Eigen\Eigen> // matrix, vector classes for easy computations
#include <mex.h> // provides Matlab pipeline
#include <matrix.h>

#include "ImportData.h"
#include "Structures.h"
#include "RayTracer.h"
#include "basicOperations.h"

using namespace std;
using namespace Eigen;

// -------------------------- Mex2Eigen Function -------------------------------

vector<Vector3d> Mex2Vector3d(double *Data, size_t Size, const mwSize *Num)
{
	if (Size > 2)
	{
		mexErrMsgTxt("Too many dimensions.");
	}
	if (Size < 2)
	{
		mexErrMsgTxt("Not enough dimensions, expected matrix of dimension m by 3.");
	}

	mwSize ItemSize = Num[1];

	if (ItemSize != 3)
	{
		mexErrMsgTxt("Expected matrix of dimension m by 3.");
	}

	vector<Vector3d> vec = vector<Vector3d>((int)Num[0]);

	for (mwSize i = 0; i < Num[0]; ++i)
	{
		for (mwSize j = 0; j < 3; ++j)
		{
			vec[i][j] = Data[i + 3 * j];
		}
	}

	return vec;
}

vector<double> Mex2Double(double *Data, size_t Size, const mwSize *Num)
{
	if (Size > 1)
	{
		mexErrMsgTxt("Too many dimensions.");
	}
	if (Size < 1)
	{
		mexErrMsgTxt("Not enough dimensions, expected matrix of dimension m by 3.");
	}

	mwSize ItemSize = Num[0];

	if (ItemSize != 3)
	{
		mexErrMsgTxt("Expected matrix of dimension m by 3.");
	}

	vector<double> vec = vector<double>((int)Num[0]);

	for (mwSize i = 0; i < Num[0]; ++i)
	{
		vec[i] = Data[i];
	}

	return vec;
}

Light Mex2Light(const mxArray *Direction, const mxArray *Origin, const mxArray *Intensity)
{
	Light light;

	double *DirectionData = mxGetPr(Direction);
	size_t Size = mxGetNumberOfDimensions(Direction);
	const mwSize *Num = mxGetDimensions(Direction);

	light.Direction = Mex2Vector3d(DirectionData, Size, Num);
	light.RayNumber = Num[0];

	double *OriginData = mxGetPr(Origin);
	size_t Size = mxGetNumberOfDimensions(Origin);
	const mwSize *Num = mxGetDimensions(Origin);
	
	light.Origin = Mex2Vector3d(OriginData, Size, Num);

	double *IntensityData = mxGetPr(Intensity);
	size_t Size = mxGetNumberOfDimensions(Intensity);
	const mwSize *Num = mxGetDimensions(Intensity);

	light.Intensity = Mex2Double(IntensityData, Size, Num);

	return light;
}

Surface Mex2Surface(const mxArray *Normal, const mxArray *Vertices, const mxArray *Facets)
{
	Surface surface;

	double *NormalData = mxGetPr(Normal);
	size_t Size = mxGetNumberOfDimensions(Normal);
	const mwSize *Num = mxGetDimensions(Normal);

	surface.Normal = Mex2Vector3d(NormalData, Size, Num);

	double *VerticesData = mxGetPr(Vertices);
	size_t Size = mxGetNumberOfDimensions(Vertices);
	const mwSize *Num = mxGetDimensions(Vertices);

	surface.Vertices = Mex2Vector3d(VerticesData, Size, Num);

	double *FacetsData = mxGetPr(Facets);
	size_t Size = mxGetNumberOfDimensions(Facets);
	const mwSize *Num = mxGetDimensions(Facets);

	surface.Facets = Mex2Vector3d(FacetsData, Size, Num);
	surface.NumFacets = Num[0];

	return surface;
}



void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
//int main(int argc, char** argv)
{
	//		IN:
	// Surface Normal
	// Surface Vertices
	// Surface Facets
	//
	// Light Direction
	// Light Origin
	// Light Intensity
	
	// --------------------------- Mex2Eigen Surface --------------------------------
	Surface surface = Mex2Surface(prhs[0], prhs[1], prhs[2]);

	// --------------------------- Mex2Eigen Light --------------------------------
	Light light = Mex2Light(prhs[3], prhs[4], prhs[5]);

	//		OUT:
	// Refraction Direction
	// Refraction Origin
	// Refraction Intensity
	//
	// Reflection Direction
	// Reflection Origin
	// Reflection Intensity

	double *RefractionDirection, *RefractionOrigin, *RefractionIntensity;
	double *ReflectionDirection, *ReflectionOrigin, *ReflectionIntensity;




	// ---------------------------- RayTracing ----------------------------
	// initialize variables:
	/*Light light;
	Surface surface;

	ImportData im;
	light.Direction = im.Import("Data/LightDirection.dat", light.Direction);
	light.Origin = im.Import("Data/LightOrigin.dat", light.Origin);
	light.Intensity = im.Import("Data/LightIntensity.dat", light.Intensity);
	light.RayNumber = light.Direction.size();

	surface.Vertices = im.Import("Data/SurfaceVertex.dat", surface.Vertices);
	surface.Normal = im.Import("Data/SurfaceNormal.dat", surface.Normal);
	surface.Facets = im.Import("Data/SurfaceFacets.dat", surface.Facets);
	surface.NumFacets = surface.Facets.size();*/

	RayTrace Interaction;
	Interaction.Reflection = light;
	Interaction.Reflection.Intensity = vector<double>(light.RayNumber,0);
	Interaction.Refraction = light;
	Interaction.Refraction.Intensity = vector<double>(light.RayNumber,0);

	clock_t start = clock();
	Interaction = RayTracer(light, Interaction, surface, false);
	clock_t end = clock();

	cout << "Elapsed time is: " << (end - start) / (double)CLOCKS_PER_SEC << '\n';
	cout << "Incoming light intensity: " << sumVector(light.Intensity) << '\n';
	cout << "Reflected light intensity :" << sumVector(Interaction.Reflection.Intensity) << '\n';
	cout << "Refracted light intensity :" << sumVector(Interaction.Refraction.Intensity) << '\n';

	//return 0;
}