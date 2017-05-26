/*
 * basicOperations.h
 *
 *  Created on: 21.05.2017
 *      Author: Jannik
 */

#ifndef BASICOPERATIONS_H_
#define BASICOPERATIONS_H_


#include <vector> // ermöglicht die Initialisierung von Vektoren zusammen mit einigen Vektorenoperationen z.B. size

void printVector( vector<double>& a );

vector<double> normVector( vector<double>& a );

double sumVector( vector<double>& a );

vector<double> addVectors( vector<double>& a , vector<double>& b );

vector<double> addVectorScalar( vector<double>& a, double& b );

vector<double> multVectors( vector<double>& a, vector<double>& b );

vector<double> multVectorScalar( vector<double>& a, double& b );


#endif /* BASICOPERATIONS_H_ */
