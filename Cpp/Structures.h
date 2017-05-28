#pragma once
#ifndef STRUCTURE_H
#define STRUCTURE_H

#include <numeric>
#include <cmath>
#include <vector> // vector<class> template

#include <Eigen\Eigen> // matrix, vector classes for easy computations

using namespace std;
using namespace Eigen;

// ---------------------------- structures ---------------------------------

struct Light
{
	vector<Vector3d> Origin;
	vector<Vector3d> Direction; // normalized
	vector<double> Intensity;
	int RayNumber;
};

struct Surface
{
	vector<Vector3d> Vertices;
	vector<Vector3d> Normal; // normalized
	vector<Vector3d> Facets;
	int NumFacets;
};

struct Contact
{
	vector<double> RayNumber;
	vector<Vector3d> Vertices;
	vector<double> Facets;
	//vector<Vector3d> BoundaryFacet;
	vector<double> Distance;
};

struct fresnelOutput
{
	double ReflectionRate;
	double RefractionRate;
};

struct snellsLawOutput
{
	Vector3d ReflectionDirection;
	Vector3d RefractionDirection;
	double ReflectionIntensity;
	double RefractionIntensity;
};

struct RayTrace
{
	Light Refraction;
	Light Reflection;
};

#endif // !STRUCTURE_H