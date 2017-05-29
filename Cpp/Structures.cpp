/*
* Structures.cpp
*
*  Updated on: 29.05.2017
*      Author: Marcel Brusius
*			   University of Kaiserslautern
*/

#include <numeric>
#include <cmath>
#include <vector> // vector<class> template

#include <Eigen\Eigen> // matrix, vector classes for easy 

#include "Structures.h"

using namespace std;
using namespace Eigen;

struct Light light;

struct Surface surface;

struct Contact contact;

struct fresnelOutput fresneloutput;

struct snellsLawOutput snellslawoutput;

struct RayTrace raytrace;
