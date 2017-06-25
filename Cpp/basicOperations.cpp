/*
* basicOperations.cpp
*
*  Updated on: 05.06.2017
*      Author: Jannik Altevogt, Marcel Brusius
*			   University of Kaiserslautern
*/

#include <iostream>
#include <vector>

using namespace std; // vermeidet Doppelbenennung von Variablen

#include "basicOperations.h"

void printVector( vector<double>& a ) {
	cout << "[";
	for (int i=0; i<a.size(); i++) {
		if (i+1<a.size()) {
		    cout << a[i] << ",";
		}else{
			cout << a[i];
		}
	}
	cout << "]";
}

void printVector(vector<int>& a) {
	cout << "[";
	for (int i = 0; i<a.size(); i++) {
		if (i + 1<a.size()) {
			cout << a[i] << ",";
		}
		else {
			cout << a[i];
		}
	}
	cout << "]";
}

double sumVector( vector<double>& a ) 
{
	if( a.size()==0 ) {
		cerr << "Error: Empty vector.\n";
	}
	double s=0;
	for(int i=0; i<a.size(); i++ ) {
		s+=a[i];
	}
	return s;
}

double sumVector(vector<int>& a) 
{
	if (a.size() == 0) {
		cerr << "Error: Empty vector.\n";
	}
	double s = 0;
	for (int i = 0; i<a.size(); i++) {
		s += (double)a[i];
	}
	return s;
}
