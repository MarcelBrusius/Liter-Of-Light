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

#include "basicOperations.h"

double EPS = 0.0000001;

// ------------------------- ImportData class -----------------------------

class ImportData
{
public:
	vector<Vector3d> Import(string filename, vector<Vector3d> v)
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

	Vector3d Import(string filename, Vector3d v)
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

	vector<double> Import(string filename, vector<double> v)
	{
		ifstream in(filename);
		string record, val;

		while (getline(in, record))
		{
			v.push_back(stod(record));
		}
		return v;
	}
};

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
	double reflectionRate;
	double refractionRate;
};

struct snellsLawOutput 
{
	Vector3d reflectionDirection;
	Vector3d refractionDirection;
	double reflectionIntensity;
	double refractionIntensity;
};

struct RayTrace
{
	Light refraction;
	Light reflection;
};

// --------------------- global variables -------------------------

//Contact contact;
//Light light, reflection, refraction;
//Surface surface;

// ------------------------ functions --------------------------------

fresnelOutput fresnel(double n1, double n2, double c1, double c2) {

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
	double rs = pow(((-nrel*frel + 1) / (nrel*frel + 1)), 2);
	//p-polarized light
	double rp = pow(((nrel - frel) / (nrel + frel)), 2);
	//assume unpolarised light
	fresnelout.reflectionRate = 0.5*(rs + rp);
	//conservation of energy
	fresnelout.refractionRate = 1 - fresnelout.reflectionRate;
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
	double cos_theta_2 = sqrt(1 - pow((n1 / n2), 2)*(1 - pow(cos_theta_1, 2)));

	if (1 - pow((n1 / n2), 2)*(1 - pow(cos_theta_1, 2)) > 0) 
	{  // check for total reflection
		

		// Methode 1: Assume plastic doesn't change intensities
		fresnelOutput fresnelout = fresnel(n1, n2, cos_theta_1, cos_theta_2);
		
		snellsout.refractionDirection = (n1 / n2) * direction + ((n1 / n2)*cos_theta_1 - (cos_theta_2>0) - (cos_theta_1<0)*cos_theta_2)*normal;
		snellsout.refractionDirection.normalize();
		snellsout.refractionIntensity = intensity * fresnelout.refractionRate;
		
		snellsout.reflectionIntensity = intensity * fresnelout.reflectionRate;
	}
	else 
	{
		snellsout.refractionDirection = { 0,0,0 };
		snellsout.refractionIntensity = 0;
		snellsout.reflectionIntensity = intensity;
	}
	snellsout.reflectionDirection = direction + 2 * cos_theta_1*normal;
	snellsout.reflectionDirection.normalize();
	// what about the intensity?
	
	return snellsout;
}

RayTrace RayTracer(Light &light, RayTrace &Interaction, Surface &surface, bool inside)
{
	Contact contact;
	contact.RayNumber = vector<double>(surface.NumFacets,-1); // initialize with "-1"
	contact.Vertices = vector<Vector3d>(surface.NumFacets);
	//contact.BoundaryFacet = vector<Vector3d>(light.RayNumber);
	contact.Facets = vector<double>(surface.NumFacets, -1);
	contact.Distance = vector<double>(light.RayNumber);

	for (int ray = 0; ray < light.RayNumber; ++ray)
	{
		for (int j = 0; j < surface.NumFacets; ++j)
		{
			Vector3d rhs = light.Origin[ray] - surface.Vertices[surface.Facets[j][0] - 1]; // checked, works
			Matrix3d mat;
			mat << -light.Direction[ray], surface.Vertices[surface.Facets[j][1] - 1] - surface.Vertices[surface.Facets[j][0] - 1], surface.Vertices[surface.Facets[j][2] - 1] - surface.Vertices[surface.Facets[j][0] - 1];
			Vector3d res = mat.colPivHouseholderQr().solve(rhs);

			double t = res[0];
			double beta = res[1];
			double gamma = res[2];

			if ((t > 0) && (beta > 0) && (gamma > 0) && (beta < 1) && (gamma < 1) && (beta + gamma < 1))
			{
				if (contact.RayNumber[ray] == -1)
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
				//contact.BoundaryFacet[ray] = surface.Facets[j];
				// maybe add a mask like in the Matlab code

				Interaction.reflection.Origin[ray] = light.Origin[ray] + contact.Distance[ray] * light.Direction[ray];
				Interaction.refraction.Origin[ray] = light.Origin[ray] + contact.Distance[ray] * light.Direction[ray];

				snellsLawOutput out;
				if (inside) // check if light rays originate from within the bottle
				{
					out  = snellsLaw( -surface.Normal[contact.Facets[ray]], light.Direction[ray], light.Intensity[ray], 1.33, 1.0 );
				}
				else
				{
					out = snellsLaw(-surface.Normal[contact.Facets[ray]], light.Direction[ray], light.Intensity[ray], 1.0, 1.33);
				}
				Interaction.reflection.Direction[ray] = out.reflectionDirection;
				Interaction.reflection.Intensity[ray] = out.reflectionIntensity;

				Interaction.refraction.Direction[ray] = out.refractionDirection;
				Interaction.reflection.Intensity[ray] = out.refractionIntensity;
			}
			
		}
	}
	return Interaction;
}

int main()
{
	// initialize variables:
	Light light, reflection, refraction;
	Surface surface;

	ImportData im;
	light.Direction = im.Import("LightDirection.dat", light.Direction);
	light.Origin = im.Import("LightOrigin.dat", light.Origin);
	light.Intensity = im.Import("LightIntensity.dat", light.Intensity);
	light.RayNumber = light.Direction.size();

	
	surface.Vertices = im.Import("SurfaceVertex.dat", surface.Vertices);
	surface.Normal = im.Import("SurfaceNormal.dat", surface.Normal);
	surface.Facets = im.Import("SurfaceFacets.dat", surface.Facets);
	surface.NumFacets = surface.Facets.size();

	RayTrace Interaction;
	Interaction.reflection = light;
	Interaction.refraction = light;

	clock_t start = clock();
	Interaction = RayTracer(light, Interaction, surface, false);
	clock_t end = clock();

	cout << "Elapsed time is: " << (end - start) / (double)CLOCKS_PER_SEC;

}