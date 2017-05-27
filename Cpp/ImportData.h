#pragma once
#ifndef IMPORTDATA_H_
#define IMPORTDATA_H_

#include <numeric>
#include <cmath>
#include <vector> // vector<class> template
#include <iostream> // input, output interaction via console

#include <fstream> // file interactions
#include <iterator>
#include <stdlib.h> // string to double conversion


#include <Eigen\Eigen> // matrix, vector classes for easy computations

using namespace std;
using namespace Eigen;

class ImportData
{
public:
	vector<Vector3d> ImportData::Import(string filename, vector<Vector3d> v);

	Vector3d ImportData::Import(string filename, Vector3d v);

	vector<double> ImportData::Import(string filename, vector<double> v);
};

#endif

