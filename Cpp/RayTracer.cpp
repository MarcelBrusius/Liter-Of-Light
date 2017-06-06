/*
* RayTracer.cpp
*
*  Updated on: 05.06.2017
*      Author: Marcel Brusius
*			   University of Kaiserslautern
*/

#include <numeric>
#include <cmath>
#include <vector> // vector<class> template
#include <fstream> // file interactions
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

#define EPS 0.001
#define INF 1000000

// ------------------------ functions --------------------------------

void Fresnel(double n1, double n2, double c1, double c2, Light *Reflection, Light *Refraction, Light *light, int raynumber ) 
{
	//FRESNEL computes the rate of reflection R and the rate of transmission T when light moves
	//        from medium M1 into medium M2, using the fresnel equations.
	//	Input:	- n1 refractive index from medium M1
	//			- n2 refractive index from medium M2
	//			- c1 cosine value of incidence angle
	//			- c2 cosine value of refraction angle.
	//
	//	Output: - Reflectance R and transmittance T gathered in "fresnelOutput" class

	double nrel = n2 / n1;
	double frel = c2 / c1;

	//s-polarized light
	double rs = pow(abs(n1*c1 - n2*c2) / abs(n1*c1 + n2*c2), 2);
	//p-polarized light
	double rp = pow(abs(n1*c2 - n2*c1) / abs(n1*c2 + n2*c1), 2);
	//assume unpolarised light
	double Reflectance = 0.5*(rs + rp);
	Reflection->Intensity[raynumber] = Reflectance * light->Intensity[raynumber];
	//conservation of energy
	Refraction->Intensity[raynumber] = (1 - Reflectance) * light->Intensity[raynumber];

	return;
}

void snellsLaw(Vector3d normal, Light *Reflection, Light *Refraction, Light *light, double n1, double n2, int raynumber)
{
	//REFLECTLIGHT	Calculate reflection and refraction of a light ray at the bottle surface
	//				http://www.thefullwiki.org/Snells_law
	// Input:	- normal: Normal vector of the interaction triangle
	//			- direction: Direction of the incident light ray
	//			- *reflection: pointer to data holding reflection -> Output
	//						   - Direction
	//						   - Origin
	//						   - Intensity
	//			- *refraction: pointer to data holding refraction -> Output
	//						   - Direction
	//						   - Origin
	//						   - Intensity
	//			- intensity: Intensity of incident light ray
	//			- n1: Refractive index of the medium, where the light ray is coming from
	//			- n2: Refractive index of the medium, where the light ray is transmitted to
	//			- raynumber: current raynumber

	normal.normalize();
	light->Direction[raynumber].normalize();
	
	double cos_theta_1 = normal.dot(-light->Direction[raynumber]);
	double tmp = 1 - pow((n1 / n2), 2) * (1 - pow(cos_theta_1, 2));
	// check for total reflection
	if (tmp >= 0)
	{
		double cos_theta_2 = sqrt(tmp);
		// Methode 1: Assume plastic doesn't change intensities

		Fresnel(n1, n2, cos_theta_1, cos_theta_2, Reflection, Refraction, light, raynumber);
		if (cos_theta_1 >= 0)
		{
			Refraction->Direction[raynumber] = (n1 / n2) * light->Direction[raynumber] + ((n1 / n2) * cos_theta_1 - cos_theta_2) * normal;
		}
		else
		{
			Refraction->Direction[raynumber] = (n1 / n2) * light->Direction[raynumber] + ((n1 / n2) * cos_theta_1 + cos_theta_2) * normal;
		}

		Refraction->Direction[raynumber].normalize();
	}
	else
	{
		Refraction->Direction[raynumber] = { 0,0,0 };
		Refraction->Intensity[raynumber] = 0;

		Reflection->Intensity[raynumber] = light->Intensity[raynumber];
	}

	Reflection->Direction[raynumber] = light->Direction[raynumber] + 2 * cos_theta_1 * normal;
	Reflection->Direction[raynumber].normalize();

	return;
}

void RayTracer(Light *light, Light *Reflection, Light *Refraction, Surface *surface, bool inside)
{
	// TAYTRANCE	Compute interactions of rays on the surface of an object
	//
	//	Input:	- *light: pointer to data holding light information
	//					  - direction
	//					  - origin
	//					  - intensity
	//			- *Reflection: pointer to data holding the reflection information
	//					       - direction
	//						   - origin
	//						   - intensity
	//			- *Refraction: pointer to data holding the refraction information
	//					       - direction
	//						   - origin
	//						   - intensity
	//			- *surface: pointer to data holding surface information
	//			- inside: boolean specifying if the ray originated from inside the object or not

	Contact contact;
	contact.RayNumber = vector<double>(surface->NumFacets);
	contact.Vertices = vector<Vector3d>(surface->NumFacets);
	//contact.BoundaryFacet = vector<Vector3d>(light.RayNumber);
	contact.Facets = vector<double>(surface->NumFacets, -1);
	contact.Distance = vector<double>(light->RayNumber, INF);

	for (int ray = 0; ray < light->RayNumber; ++ray)
	{
		light->Direction[ray].normalize();
		//vector<bool> possiblerays = PreProcessing(light->Direction[ray], surface, inside);
		for (int j = 0; j < surface->NumFacets; ++j)
		{
			// better "preprocessing" than actual preprocessing (no additional loop):
			surface->Normal[j].normalize();
			if ((light->Direction[ray].dot(surface->Normal[j]) > 0) && (inside))
				continue;
			if ((light->Direction[ray].dot(surface->Normal[j]) < 0) && (!inside))
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
				if (contact.Distance[ray] > t)
				{
					contact.RayNumber[j] = ray;
					contact.Distance[ray] = t;
					contact.Facets[ray] = j;
				}
			}		
		}

		if (contact.Facets[ray] > -1)
		{
			Reflection->Origin[ray] = light->Origin[ray] + contact.Distance[ray] * light->Direction[ray];
			Refraction->Origin[ray] = light->Origin[ray] + contact.Distance[ray] * light->Direction[ray];

			if (inside) // check if light rays originate from within the bottle
			{
				snellsLaw(-surface->Normal[contact.Facets[ray]], Reflection, Refraction, light, 1.33, 1.0, ray);
			}
			else
			{
				snellsLaw(surface->Normal[contact.Facets[ray]], Reflection, Refraction, light, 1.0, 1.33, ray);
			}
		}
		/*else
		{
			Reflection->Origin[ray] = Vector3d(0, 0, 0);
			Refraction->Origin[ray] = Vector3d(0, 0, 0);

			Reflection->Direction[ray] = Vector3d(0, 0, 0);
			Refraction->Direction[ray] = Vector3d(0, 0, 0);

			Reflection->Intensity[ray] = 0;
			Refraction->Intensity[ray] = 0;
		}*/
	}
	return;
}
