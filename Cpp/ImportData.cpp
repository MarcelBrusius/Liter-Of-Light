/*
* ImportData.cpp
*
*  Updated on: 29.05.2017
*      Author: Marcel Brusius
*			   University of Kaiserslautern
*/

#include <numeric>
#include <cmath>
#include <vector> // vector<class> template
#include <iostream> // input, output interaction via console

#include <fstream> // file interactions
#include <iterator>
#include <stdlib.h> // string to double conversion


//#include <Eigen\Eigen> // matrix, vector classes for easy computations
#include <Eigen\Eigen> // matrix, vector classes for easy computations
#include "ImportData.h"

using namespace std;
using namespace Eigen;

// ------------------------- ImportData class -----------------------------

vector<Vector3d> ImportData::Import(string filename, vector<Vector3d> v)
{
	ifstream in(filename);
	string record, val;

	while (getline(in, record))
	{
		stringstream rec(record);
		Vector3d row;
		int i = 0;
		while (getline(rec, val, ','))
		{
			row[i] = stod(val);
			++i;
		}
		v.push_back(row);
	}
	return v;
}

Vector3d ImportData::Import(string filename, Vector3d v)
{
	ifstream in(filename);
	string record;

	int i = 0;
	while (getline(in, record, ','))
	{
		v[i] = stod(record);
		++i;
	}
	return v;
}

vector<double> ImportData::Import(string filename, vector<double> v)
{
	ifstream in(filename);
	string record, val;

	while (getline(in, record))
	{
		v.push_back(stod(record));
	}
	return v;
}
