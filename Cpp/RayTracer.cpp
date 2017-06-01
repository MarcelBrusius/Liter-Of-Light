/*
* RayTracer.cpp
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
#include <sstream>
#include <string>
#include <stdlib.h> // string to double conversion
#include <ctime> // ermöglicht timer

#include <Eigen\Eigen> // matrix, vector classes for easy computations
#include <mex.h>

#include "ImportData.h"
#include "Structures.h"

using namespace std;
using namespace Eigen;

double EPS = 0.0000001;

// ------------------------ functions --------------------------------
int sign(double a)
{
	if (a > 0)
		return 1;
	else if (a < 0)
		return -1;
	else
		return 0;
}

int sign(int a)
{
	if (a > 0)
		return 1;
	else if (a < 0)
		return -1;
	else
		return 0;
}

vector<bool> PreProcessing(Vector3d direction, Surface *surface, bool inside)
{
	direction.normalize();
	vector<bool> possiblerays(surface->Normal.size()); // per default: vector of "false"
	for (int i = 0; i < surface->Normal.size(); ++i)
	{
		double d = direction.dot(surface->Normal[i]);
		if ((d > 0) && (inside))
			possiblerays[i] = true;
		else if ((d < 0) && (!inside))
			possiblerays[i] = true;
	}
	return possiblerays;
}

fresnelOutput fresnelEq(double n1, double n2, double c1, double c2) 
{
	//FRESNEL computes the rate of reflection R
	//and the rate of transmission T when light moves
	//from medium M1 into medium M2,
	//using the fresnel equations.
	//Input: - n1 refractive index from medium M1
	//       - n2 refractive index from medium M2
	//       - c1 cosine value of incidence angle
	//       - c2 cosine value of refraction angle.

	fresnelOutput fresnelout;
	double nrel = n2 / n1;
	double frel = c2 / c1;

	//s-polarized light
	double rs = pow(abs(n1*c1 - n2*c2) / abs(n1*c1 + n2*c2), 2);
	//p-polarized light
	double rp = pow(abs(n2*c2 - n1*c1) / abs(n2*c2 + n1*c1), 2);
	//assume unpolarised light
	fresnelout.ReflectionRate = 0.5*(rs + rp);
	//conservation of energy
	fresnelout.RefractionRate = 1 - fresnelout.ReflectionRate;
	return fresnelout;
}

snellsLawOutput snellsLaw(Vector3d normal, Vector3d direction, double intensity, double n1, double n2)
{
	//REFLECTLIGHT Calculate reflection and refraction of a light ray at the bottle surface
	//   http://www.thefullwiki.org/Snells_law
	//   Output:
	//   - reflection: Direction vector of reflected light ray
	//   - refraction: Direction vector of refracted light ray
	//   - reflectionIntensity: Calculate the intensity of light, that is reflected
	//   - refractionIntensity: Calculate the intensity of light, that is refracted
	//   Input:
	//   - normal: Normal vector of the penetrated triangle
	//   - direction: Direction of the incident light ray
	//   - intensity: Intensity of incident light ray
	//   - n1: Refractive index of the medium, where the light ray is coming from
	//   - n2: Refractive index of the medium of the transmitted light ray

	snellsLawOutput snellsout;

	normal.normalize();
	direction.normalize();
	
	double cos_theta_1 = normal.dot(-direction);
	double cos_theta_2 = sqrt(1 - pow((n1 / n2), 2) * (1 - pow(cos_theta_1, 2)));

	if (1 - pow((n1 / n2), 2) * (1 - pow(cos_theta_1, 2)) > 0)
	{  // check for total reflection
		// Methode 1: Assume plastic doesn't change intensities
		fresnelOutput fresnelout = fresnelEq(n1, n2, cos_theta_1, cos_theta_2);
		
		snellsout.RefractionDirection = (n1 / n2) * direction + ((n1 / n2) * cos_theta_1 - sign(cos_theta_1) * cos_theta_2) * normal;
		snellsout.RefractionDirection.normalize();
		snellsout.RefractionIntensity = intensity * fresnelout.RefractionRate;
		
		snellsout.ReflectionIntensity = intensity * fresnelout.ReflectionRate;
	}
	else 
	{
		snellsout.RefractionDirection = { 0,0,0 };
		snellsout.RefractionIntensity = 0;
		snellsout.ReflectionIntensity = intensity;
	}
	snellsout.ReflectionDirection = direction + 2 * cos_theta_1 * normal;
	snellsout.ReflectionDirection.normalize();
	// what about the intensity?
	
	return snellsout;
}

void RayTracer(Light *light, RayTrace *Interaction, Surface *surface, bool inside)
{
	time_t stop = 0;
	Contact contact;
	contact.RayNumber = vector<double>(surface->NumFacets,-1); // initialize with "-1"
	contact.Vertices = vector<Vector3d>(surface->NumFacets);
	//contact.BoundaryFacet = vector<Vector3d>(light.RayNumber);
	contact.Facets = vector<double>(surface->NumFacets, -1);
	contact.Distance = vector<double>(light->RayNumber);
	for (int i = 0; i < surface->Normal.size(); ++i)
		surface->Normal[i].normalize();

	for (int ray = 0; ray < light->RayNumber; ++ray)
	{
		light->Direction[ray].normalize();
		vector<bool> possiblerays = PreProcessing(light->Direction[ray], surface, inside);
		for (int j = 0; j < surface->NumFacets; ++j)
		{
			if (!possiblerays[j])
				continue;

			Vector3d rhs = light->Origin[ray] - surface->Vertices[surface->Facets[j][0] - 1];
			Matrix3d mat, matx, maty, matz;
			mat << -light->Direction[ray], surface->Vertices[surface->Facets[j][1] - 1] - surface->Vertices[surface->Facets[j][0] - 1], surface->Vertices[surface->Facets[j][2] - 1] - surface->Vertices[surface->Facets[j][0] - 1];

			// Use Cramer's Rule:
			matx << rhs, surface->Vertices[surface->Facets[j][1] - 1] - surface->Vertices[surface->Facets[j][0] - 1], surface->Vertices[surface->Facets[j][2] - 1] - surface->Vertices[surface->Facets[j][0] - 1];
			maty << -light->Direction[ray], rhs, surface->Vertices[surface->Facets[j][2] - 1] - surface->Vertices[surface->Facets[j][0] - 1];
			matz << -light->Direction[ray], surface->Vertices[surface->Facets[j][1] - 1] - surface->Vertices[surface->Facets[j][0] - 1], rhs;
			
			double det = mat.determinant();
			double detx = matx.determinant();
			double dety = maty.determinant();
			double detz = matz.determinant();

			if (det == 0)
			{
				continue;
			}

			double t = detx / det;
			double beta = dety / det;
			double gamma = detz / det;

			if ((t > 0) && (beta > 0) && (gamma > 0) && (beta < 1) && (gamma < 1) && (beta + gamma < 1))
			{
				
				if (contact.RayNumber[j] == -1)
				{
					contact.RayNumber[j] = ray;
					contact.Facets[ray] = j;
					contact.Distance[ray] = t;
				}
				else if ((contact.Distance[ray] > t) && (t > EPS))
				{
					contact.RayNumber[j] = ray;
					contact.Distance[ray] = t;
					contact.Facets[ray] = j;
				}
			}

			if (contact.Facets[ray] > -1)
			{
				//contact.BoundaryFacet[ray] = surface->Facets[j];
				// maybe add a mask like in the Matlab code

				Interaction->Reflection.Origin[ray] = light->Origin[ray] + contact.Distance[ray] * light->Direction[ray];
				Interaction->Refraction.Origin[ray] = light->Origin[ray] + contact.Distance[ray] * light->Direction[ray];

				snellsLawOutput out;
				if (inside) // check if light rays originate from within the bottle
				{
					out  = snellsLaw( -surface->Normal[contact.Facets[ray]], light->Direction[ray], light->Intensity[ray], 1.33, 1.0 );
				}
				else
				{
					out = snellsLaw(surface->Normal[contact.Facets[ray]], light->Direction[ray], light->Intensity[ray], 1.0, 1.33);
				}
				Interaction->Reflection.Direction[ray] = out.ReflectionDirection;
				Interaction->Reflection.Intensity[ray] = out.ReflectionIntensity;

				Interaction->Refraction.Direction[ray] = out.RefractionDirection;
				Interaction->Refraction.Intensity[ray] = out.RefractionIntensity;
			}
			
		}
	}
}
