#pragma once
#ifndef RAYTRACER_H
#define RAYTRACER_H

#include <numeric>
#include <cmath>
#include <vector> // vector<class> template
#include <iostream> // input, output interaction via console

#include <fstream> // file interactions
#include <iterator>
#include <sstream>
#include <string>
#include <stdlib.h> // string to double conversion

#include <ctime> // ermöglicht timer

#include <Eigen\Eigen> // matrix, vector classes for easy computations

using namespace std;
using namespace Eigen;

#include "ImportData.h"
#include "Structures.h"

// ---------------------------- declaration ----------------------------------

fresnelOutput fresnel(double n1, double n2, double c1, double c2);

snellsLawOutput snellsLaw(Vector3d normal, Vector3d direction, double intensity, double n1, double n2);

RayTrace RayTracer(Light &light, RayTrace &Interaction, Surface &surface, bool inside);

#endif // !RAYTRACER_H
