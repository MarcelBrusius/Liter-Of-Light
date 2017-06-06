/*
* main.cpp
*
*  Updated on: 05.06.2017
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

// ---- Mex Gateway -------------------------------------------------------------------------------

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	// ---- Assert input and output count ---------------------------------------------------------
	if (nrhs != 7)
	{
		mexErrMsgTxt("Not enough input arguments. \n");
	}
	if (nlhs != 6)
	{
		mexErrMsgTxt("Not enough output arguments. \n");
	}

	// ---- Mex2Eigen -----------------------------------------------------------------------------

	//		IN:
	// Surface Normal
	// Surface Vertices
	// Surface Facets
	//
	// Light Direction
	// Light Origin
	// Light Intensity
	//
	// inside/outside
	
	// ---- Mex2Eigen Surface ---------------------------------------------------------------------

	//Surface surface = Mex2Surface(prhs[0], prhs[1], prhs[2]);
	Surface surface;

	double *NormalData = mxGetPr(prhs[0]);
	size_t NormalRow = mxGetM(prhs[0]), NormalCol = mxGetN(prhs[0]);
	size_t NormalSize = mxGetNumberOfDimensions(prhs[0]);
	const mwSize *NormalNum = mxGetDimensions(prhs[0]);

	double *VerticesData = mxGetPr(prhs[1]);
	size_t VerticesRow = mxGetM(prhs[1]), VerticesCol = mxGetN(prhs[1]);
	size_t VerticesSize = mxGetNumberOfDimensions(prhs[1]);
	const mwSize *VerticesNum = mxGetDimensions(prhs[1]);

	double *FacetsData = mxGetPr(prhs[2]);
	size_t FacetsRow = mxGetM(prhs[2]), FacetsCol = mxGetN(prhs[2]);
	size_t FacetsSize = mxGetNumberOfDimensions(prhs[2]);
	const mwSize *FacetsNum = mxGetDimensions(prhs[2]);

	surface.NumFacets = NormalNum[0];

	if ((NormalSize > 2) || (VerticesSize > 2) || (FacetsSize > 2))
	{
		mexErrMsgTxt("Too many dimensions. \n");
	}
	if ((NormalSize < 2) || (VerticesSize < 2) || (FacetsSize < 2))
	{
		mexErrMsgTxt("Not enough dimensions, expected matrix of dimension m by 3. \n");
	}
	if ((NormalNum[1] != 3) || (VerticesNum[1] != 3) || (FacetsNum[1] != 3))
	{
		mexErrMsgTxt("Expected matrix of dimension m by 3. \n");
	}

	surface.Normal = vector<Vector3d>((int)NormalNum[0]);
	surface.Vertices = vector<Vector3d>((int)VerticesNum[0]);
	surface.Facets = vector<Vector3d>((int)FacetsNum[0]);

	for (mwSize i = 0; i < VerticesRow; ++i)
	{
		for (mwSize j = 0; j < VerticesCol; ++j)
		{
			surface.Vertices[i][j] = VerticesData[j*VerticesRow + i];
		}
	}

	for (mwSize i = 0; i < NormalRow; ++i)
	{
		for (mwSize j = 0; j < NormalCol; ++j)
		{
			surface.Normal[i][j] = NormalData[j*NormalRow + i];
			surface.Facets[i][j] = FacetsData[j*NormalRow + i];
		}
	}

	Surface *surfacePtr = &surface;

	// get boolean specifying inside/outside
	
	double *insideData = mxGetPr(prhs[6]);
	size_t insideSize = mxGetNumberOfDimensions(prhs[6]);
	const mwSize *insideNum = mxGetDimensions(prhs[6]);
	if ((insideSize > 2) || (insideNum[0] > 1))
	{
		mexErrMsgTxt("Expected boolean value but was given an array.");
	}
	bool inside = (bool)&insideData;

	// ---- Mex2Eigen Light -----------------------------------------------------------------------

	Light light;

	double *DirectionData = mxGetPr(prhs[3]);
	size_t DirectionRow = mxGetM(prhs[3]), DirectionCol = mxGetN(prhs[3]);
	size_t DirectionSize = mxGetNumberOfDimensions(prhs[3]);
	const mwSize *DirectionNum = mxGetDimensions(prhs[3]);

	double *OriginData = mxGetPr(prhs[4]);
	size_t OriginRow = mxGetM(prhs[4]), OriginCol = mxGetN(prhs[4]);
	size_t OriginSize = mxGetNumberOfDimensions(prhs[4]);
	const mwSize *OriginNum = mxGetDimensions(prhs[4]);

	double *IntensityData = mxGetPr(prhs[5]);
	size_t IntensityRow = mxGetM(prhs[5]), IntensityCol = mxGetN(prhs[5]);
	size_t IntensitySize = mxGetNumberOfDimensions(prhs[5]);
	const mwSize *IntensityNum = mxGetDimensions(prhs[5]);

	Light *lightPtr = &light;

	light.RayNumber = DirectionNum[0];

	if ((DirectionSize > 2) || (OriginSize > 2) || (IntensitySize > 2))
	{
		mexErrMsgTxt("Too many dimensions. \n");
	}
	if ((DirectionSize < 2) || (OriginSize < 2) || (IntensitySize < 2))
	{
		mexErrMsgTxt("Not enough dimensions, expected matrix of dimension m by 3. \n");
	}

	if ((DirectionNum[1] != 3) || (OriginNum[1] != 3))
	{
		mexErrMsgTxt("Expected matrix of dimension m by 3. \n");
	}
	if (IntensityNum[1] != 1)
	{
		mexErrMsgTxt("Expected matrix of dimension m by 1.");
	}
	if ((DirectionNum[0] != OriginNum[0]) || (IntensityNum[0] != OriginNum[0]) || (DirectionNum[0] != IntensityNum[0]))
	{
		mexErrMsgTxt("Input 4 - 6 are not of same size. \n");
	}

	light.Direction = vector<Vector3d>((int)DirectionNum[0]);
	light.Origin = vector<Vector3d>((int)OriginNum[0]);
	light.Intensity = vector<double>((int)IntensityNum[0]);
	for (mwSize i = 0; i < DirectionRow; ++i)
	{
		light.Intensity[i] = IntensityData[i];
		for (mwSize j = 0; j < DirectionCol; ++j)
		{
			light.Direction[i][j] = DirectionData[j*DirectionRow + i];
			light.Origin[i][j] = OriginData[j*DirectionRow + i];
			
		}
	}
	// ---- RayTracing ----------------------------------------------------------------------------
	// Read Data:
	/*
	Light light;
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
	*/

	Light Reflection = light;
	Reflection.Intensity = vector<double>(light.RayNumber,0);
	Light Refraction = light;
	Refraction.Intensity = vector<double>(light.RayNumber,0);
	Light *Refract = &Refraction, *Reflect = &Reflection;

	clock_t start = clock();
	RayTracer(lightPtr, Reflect, Refract, surfacePtr, inside);
	clock_t end = clock();

	mexPrintf("Elapsed time is           : %f \n", (double)(end - start) / (double)CLOCKS_PER_SEC);
	//mexPrintf("Incoming light intensity  : %f \n", sumVector(light.Intensity));
	//mexPrintf("Reflected light intensity : %f \n", sumVector(Reflection.Intensity));
	//mexPrintf("Refracted light intensity : %f \n", sumVector(Refraction.Intensity));

	// ---- Eigen2Mex -----------------------------------------------------------------------------
	
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

	size_t Size = mxGetNumberOfDimensions(prhs[3]);
	const mwSize *NumVec = mxGetDimensions(prhs[3]);

	plhs[0] = mxCreateNumericArray(Size, NumVec, mxDOUBLE_CLASS, mxREAL);
	RefractionDirection = mxGetPr(plhs[0]);
	plhs[1] = mxCreateNumericArray(Size, NumVec, mxDOUBLE_CLASS, mxREAL);
	RefractionOrigin = mxGetPr(plhs[1]);
	plhs[3] = mxCreateNumericArray(Size, NumVec, mxDOUBLE_CLASS, mxREAL);
	ReflectionDirection = mxGetPr(plhs[3]);
	plhs[4] = mxCreateNumericArray(Size, NumVec, mxDOUBLE_CLASS, mxREAL);
	ReflectionOrigin = mxGetPr(plhs[4]);

	//size_t SizeIntensity = mxGetNumberOfDimensions(prhs[5]);
	const mwSize *NumInt = mxGetDimensions(prhs[5]);

	plhs[2] = mxCreateNumericArray(Size, NumInt, mxDOUBLE_CLASS, mxREAL);
	RefractionIntensity = mxGetPr(plhs[2]);
	plhs[5] = mxCreateNumericArray(Size, NumInt, mxDOUBLE_CLASS, mxREAL);
	ReflectionIntensity = mxGetPr(plhs[5]);

	for (mwSize i = 0; i < NumVec[0]; ++i)
	{
		for (mwSize j = 0; j < NumVec[1]; ++j)
		{
			RefractionDirection[i + NumVec[0] * j] = Refraction.Direction[i][j];
			RefractionOrigin[i + NumVec[0] * j] = Refraction.Origin[i][j];
			ReflectionDirection[i + NumVec[0] * j] = Reflection.Direction[i][j];
			ReflectionOrigin[i + NumVec[0] * j] = Reflection.Origin[i][j];
		}
		RefractionIntensity[i] = Refraction.Intensity[i];
		ReflectionIntensity[i] = Reflection.Intensity[i];
	}
}