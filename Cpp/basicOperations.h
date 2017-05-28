/*
 * basicOperations.h
 *
 *  Updated on: 28.05.2017
 *      Author: Jannik, Marcel
 */

#ifndef BASICOPERATIONS_H_
#define BASICOPERATIONS_H_

#include <vector> // ermöglicht die Initialisierung von Vektoren zusammen mit einigen Vektorenoperationen z.B. size

void printVector(vector<double>& a);

void printVector(vector<int>& a);

// normiere Vektor in euklidischer Norm
vector<double> normVector(vector<double>& a);

vector<double> normVector(vector<int>& a);

double sumVector(vector<double>& a);

double sumVector(vector<int>& a);

vector<double> addVectors(vector<double>& a, vector<double>& b);

vector<double> addVectors(vector<int>& a, vector<int>& b);

vector<double> addVectors(vector<double>& a, vector<int>& b);

vector<double> addVectors(vector<int>& a, vector<double>& b);

vector<double> addVectorScalar(vector<double>& a, double& b);

vector<double> addVectorScalar(vector<int>& a, double& b);

vector<double> addVectorScalar(vector<double>& a, int& b);

vector<double> addVectorScalar(vector<int>& a, int& b);

// Elementweises multiplizieren
vector<double> multVectors(vector<double>& a, vector<double>& b);

vector<double> multVectors(vector<int>& a, vector<double>& b);

vector<double> multVectors(vector<double>& a, vector<int>& b);

vector<double> multVectorScalar(vector<double>& a, double& b);

vector<double> multVectorScalar(vector<int>& a, double& b);

vector<double> multVectorScalar(vector<double>& a, int& b);

#endif /* BASICOPERATIONS_H_ */