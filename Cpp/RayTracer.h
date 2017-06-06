/*
* RayTracer.h
*
*  Updated on: 05.06.2017
*      Author: Marcel Brusius
*			   University of Kaiserslautern
*/

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

#include "ImportData.h"
#include "Structures.h"

using namespace std;
using namespace Eigen;

// ---------------------------- declaration ----------------------------------

void Fresnel(double n1, double n2, double c1, double c2, Light *Reflection, Light *Refraction, Light *light, int raynumber);

void snellsLaw(Vector3d normal, Light *Reflection, Light *Refraction, Light *light, double n1, double n2, int raynumber);

void RayTracer(Light *light, Light *Reflection, Light *Refraction, Surface *surface, bool inside);

#endif // !RAYTRACER_H
