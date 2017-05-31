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

// ---- Mex2Eigen Functions -----------------------------------------------------------------------

//vector<Vector3d> Mex2Vector3d(double *Data, size_t Size, const mwSize *Num)
//{
//	if (Size > 2)
//	{
//		mexErrMsgTxt("Too many dimensions.");
//	}
//	if (Size < 2)
//	{
//		mexErrMsgTxt("Not enough dimensions, expected matrix of dimension m by 3.");
//	}
//
//	mwSize ItemSize = Num[1];
//
//	if (ItemSize != 3)
//	{
//		mexErrMsgTxt("Expected matrix of dimension m by 3.");
//	}
//
//	vector<Vector3d> vec = vector<Vector3d>((int)Num[0]);
//
//	for (mwSize i = 0; i < Num[0]; ++i)
//	{
//		for (mwSize j = 0; j < 3; ++j)
//		{
//			vec[i][j] = Data[i + 3 * j];
//		}
//	}
//
//	return vec;
//}

//vector<double> Mex2Double(double *Data, size_t Size, const mwSize *Num)
//{
//	if (Size > 2)
//	{
//		//mexPrintf("Size = %d", Size);
//		mexErrMsgTxt("Too many dimensions.");
//	}
//	if (Size < 2)
//	{
//		mexErrMsgTxt("Not enough dimensions, expected matrix of dimension m by 1.");
//	}
//
//	mwSize ItemSize = Num[1];
//
//	if (ItemSize != 1)
//	{
//		mexPrintf("ItemSize = %d, Num = [%d,%d].", ItemSize, Num[0], Num[1]);
//		mexErrMsgTxt("Expected matrix of dimension m by 1.");
//	}
//
//	vector<double> vec = vector<double>((int)Num[0]);
//
//	for (mwSize i = 0; i < Num[0]; ++i)
//	{
//		vec[i] = Data[i];
//		mexPrintf("Data[%i] = %d \n", i, Data[i]);
//		mexPrintf("Vec[%i] = %d \n", i, vec[i]);
//	}
//
//	return vec;
//}

//Light Mex2Light(const mxArray *Direction, const mxArray *Origin, const mxArray *Intensity)
//{
//	Light light;
//
//	double *DirectionData = mxGetPr(Direction);
//	size_t Size = mxGetNumberOfDimensions(Direction);
//	const mwSize *Num = mxGetDimensions(Direction);
//
//	light.Direction = Mex2Vector3d(DirectionData, Size, Num);
//	light.RayNumber = Num[0];
//
//	double *OriginData = mxGetPr(Origin);
//	Size = mxGetNumberOfDimensions(Origin);
//	Num = mxGetDimensions(Origin);
//	
//	light.Origin = Mex2Vector3d(OriginData, Size, Num);
//
//	double *IntensityData = mxGetPr(Intensity);
//	Size = mxGetNumberOfDimensions(Intensity);
//	Num = mxGetDimensions(Intensity);
//
//	light.Intensity = Mex2Double(IntensityData, Size, Num);
//
//
//	return light;
//}

//Surface Mex2Surface(const mxArray *Normal, const mxArray *Vertices, const mxArray *Facets)
//{
//	Surface surface;
//
//	double *NormalData = mxGetPr(Normal);
//	size_t Size = mxGetNumberOfDimensions(Normal);
//	const mwSize *Num = mxGetDimensions(Normal);
//
//	surface.Normal = Mex2Vector3d(NormalData, Size, Num);
//
//	double *VerticesData = mxGetPr(Vertices);
//	Size = mxGetNumberOfDimensions(Vertices);
//	Num = mxGetDimensions(Vertices);
//
//	surface.Vertices = Mex2Vector3d(VerticesData, Size, Num);
//
//	double *FacetsData = mxGetPr(Facets);
//	Size = mxGetNumberOfDimensions(Facets);
//	Num = mxGetDimensions(Facets);
//
//	surface.Facets = Mex2Vector3d(FacetsData, Size, Num);
//	surface.NumFacets = Num[0];
//
//
//
//	return surface;
//}

// ---- Mex Gateway -------------------------------------------------------------------------------

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	// ---- Assert input and output count ---------------------------------------------------------
	if (nrhs != 6)
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
	
	// ---- Mex2Eigen Surface ---------------------------------------------------------------------
	//Surface surface = Mex2Surface(prhs[0], prhs[1], prhs[2]);
	Surface surface;

	double *NormalData = mxGetPr(prhs[0]);
	size_t NormalSize = mxGetNumberOfDimensions(prhs[0]);
	const mwSize *NormalNum = mxGetDimensions(prhs[0]);

	//surface.Normal = Mex2Vector3d(NormalData, NormalSize, NormalNum);

	double *VerticesData = mxGetPr(prhs[1]);
	size_t VerticesSize = mxGetNumberOfDimensions(prhs[1]);
	const mwSize *VerticesNum = mxGetDimensions(prhs[1]);

	//surface.Vertices = Mex2Vector3d(VerticesData, VerticesSize, VerticesNum);

	double *FacetsData = mxGetPr(prhs[2]);
	size_t FacetsSize = mxGetNumberOfDimensions(prhs[2]);
	const mwSize *FacetsNum = mxGetDimensions(prhs[2]);

	//surface.Facets = Mex2Vector3d(FacetsData, FacetsSize, FacetsNum);
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

	for (mwSize i = 0; i < VerticesNum[0]; ++i)
	{
		for (mwSize j = 0; j < 3; ++j)
		{
			surface.Vertices[i][j] = VerticesData[j + 3 * i];
		}
	}

	for (mwSize i = 0; i < NormalNum[0]; ++i)
	{
		for (mwSize j = 0; j < 3; ++j)
		{
			surface.Normal[i][j] = NormalData[j + 3 * i];
			surface.Facets[i][j] = FacetsData[j + 3 * i];
		}
	}

	Surface *surfacePtr = &surface;

	// ---- Mex2Eigen Light -----------------------------------------------------------------------
	//Light light = Mex2Light(prhs[3], prhs[4], prhs[5]);
	Light light;

	double *DirectionData = mxGetPr(prhs[3]);
	size_t DirectionSize = mxGetNumberOfDimensions(prhs[3]);
	const mwSize *DirectionNum = mxGetDimensions(prhs[3]);

	//light.Direction = Mex2Vector3d(DirectionData, DirectionSize, DirectionNum);

	double *OriginData = mxGetPr(prhs[4]);
	size_t OriginSize = mxGetNumberOfDimensions(prhs[4]);
	const mwSize *OriginNum = mxGetDimensions(prhs[4]);

	//light.Origin = Mex2Vector3d(OriginData, OriginSize, OriginNum);

	double *IntensityData = mxGetPr(prhs[5]);
	size_t IntensitySize = mxGetNumberOfDimensions(prhs[5]);
	const mwSize *IntensityNum = mxGetDimensions(prhs[5]);

	Light *lightPtr = &light;

	//light.Intensity = Mex2Vector3d(IntensityData, IntensitySize, IntensityNum);
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
	for (mwSize i = 0; i < DirectionNum[0]; ++i)
	{
		light.Intensity[i] = IntensityData[i];
		for (mwSize j = 0; j < 3; ++j)
		{
			light.Direction[i][j] = DirectionData[j + 3 * i];
			light.Origin[i][j] = OriginData[j + 3 * i];
			
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

	RayTrace Interaction;
	Interaction.Reflection = light;
	Interaction.Reflection.Intensity = vector<double>(light.RayNumber,0);
	Interaction.Refraction = light;
	Interaction.Refraction.Intensity = vector<double>(light.RayNumber,0);
	RayTrace *InteractionPtr = &Interaction;

	clock_t start = clock();
	/*Interaction = */
	RayTracer(lightPtr, InteractionPtr, surfacePtr, false);
	clock_t end = clock();

	/*
	cout << "Elapsed time is: " << (end - start) / (double)CLOCKS_PER_SEC << '\n';
	cout << "Incoming light intensity: " << sumVector(light.Intensity) << '\n';
	cout << "Reflected light intensity :" << sumVector(Interaction.Reflection.Intensity) << '\n';
	cout << "Refracted light intensity :" << sumVector(Interaction.Refraction.Intensity) << '\n';
	*/

	mexPrintf("Elapsed time is           : %f \n", (double)(end - start) / (double)CLOCKS_PER_SEC);
	mexPrintf("Incoming light intensity  : %f \n", sumVector(light.Intensity));
	mexPrintf("Reflected light intensity : %f \n", sumVector(Interaction.Reflection.Intensity));
	mexPrintf("Refracted light intensity : %f \n", sumVector(Interaction.Refraction.Intensity));

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
		for (mwSize j = 0; j < 3; ++j)
		{
			RefractionDirection[j + 3 * i] = Interaction.Refraction.Direction[i][j];
			RefractionOrigin[j + 3 * i] = Interaction.Refraction.Origin[i][j];
			ReflectionDirection[j + 3 * i] = Interaction.Reflection.Direction[i][j];
			ReflectionOrigin[j + 3 * i] = Interaction.Reflection.Origin[i][j];
		}
		RefractionIntensity[i] = Interaction.Refraction.Intensity[i];
		ReflectionIntensity[i] = Interaction.Reflection.Intensity[i];
	}
}