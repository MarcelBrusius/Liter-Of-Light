/*
* basicOperations.cpp
*
*  Updated on: 29.05.2017
*      Author: Jannik Altevogt, Marcel Brusius
*			   University of Kaiserslautern
*/

#include <iostream>
#include <cmath>

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

// normiere Vektor in euklidischer Norm
vector<double> normVector( vector<double>& a ) 
{
	if( a.size()==0 ) {
		cout << "Error: 'normVector' mit leerem Vektor aufgerufen.\n";
	}
	double norm=0;
	for(int i=0; i<a.size(); i++ ) {
		norm += pow(a[i],2);
	}
	norm=sqrt(norm);
	for(int i=0; i<a.size(); i++ ) {
		a[i]=a[i]/norm;
	}
	return a;
}

vector<double> normVector(vector<int>& a)
{
	vector<double> b(a.size());
	if (a.size() == 0) {
		cout << "Error: 'normVector' mit leerem Vektor aufgerufen.\n";
	}
	double norm = 0;
	for (int i = 0; i<a.size(); i++) {
		norm += pow((double)a[i], 2);
	}
	norm = sqrt(norm);
	for (int i = 0; i<a.size(); i++) {
		b[i] = (double)a[i] / norm;
	}
	return b;
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

vector<double> addVectors( vector<double>& a , vector<double>& b ) 
{
	if( a.size()==0 || b.size()==0 ) {
		cerr << "Error: Empty vector.\n";
	}
	if (a.size()!=b.size()) {
		cerr << "Error: Vectors of different size.\n";
	}
	vector<double> s(a.size(),0);
	for (int i=0; i<a.size(); i++) {
		s[i]=a[i]+b[i];
	}
	return s;
}

vector<double> addVectors(vector<int>& a, vector<int>& b) 
{
	if (a.size() == 0 || b.size() == 0) {
		cerr << "Error: Empty vector.\n";
	}
	if (a.size() != b.size()) {
		cerr << "Error: Vectors of different size.\n";
	}
	vector<double> s(a.size(), 0);
	for (int i = 0; i<a.size(); i++) {
		s[i] = (double)a[i] + (double)b[i];
	}
	return s;
}

vector<double> addVectors(vector<double>& a, vector<int>& b)
{
	if (a.size() == 0 || b.size() == 0) {
		cerr << "Error: Empty vector.\n";
	}
	if (a.size() != b.size()) {
		cerr << "Error: Vectors of different size.\n";
	}
	vector<double> s(a.size(), 0);
	for (int i = 0; i<a.size(); i++) {
		s[i] = a[i] + (double)b[i];
	}
	return s;
}

vector<double> addVectors(vector<int>& a, vector<double>& b)
{
	if (a.size() == 0 || b.size() == 0) {
		cerr << "Error: Empty vector.\n";
	}
	if (a.size() != b.size()) {
		cerr << "Error: Vectors of different size.\n";
	}
	vector<double> s(a.size(), 0);
	for (int i = 0; i<a.size(); i++) {
		s[i] = (double)a[i] + b[i];
	}
	return s;
}

vector<double> addVectorScalar( vector<double>& a, double& b ) 
{
	if( a.size()==0 ) {
		cerr << "Error: Empty vector.\n";
	}
	vector<double> s(a.size(),0);
	for (int i=0; i<a.size(); i++) {
		s[i]=a[i]+b;
	}
	return s;
}

vector<double> addVectorScalar(vector<int>& a, double& b)
{
	if (a.size() == 0) {
		cerr << "Error: Empty vector.\n";
	}
	vector<double> s(a.size(), 0);
	for (int i = 0; i<a.size(); i++) {
		s[i] = (double)a[i] + b;
	}
	return s;
}

vector<double> addVectorScalar(vector<double>& a, int& b)
{
	if (a.size() == 0) {
		cerr << "Error: Empty vector.\n";
	}
	vector<double> s(a.size(), 0);
	for (int i = 0; i<a.size(); i++) {
		s[i] = a[i] + (double)b;
	}
	return s;
}

vector<double> addVectorScalar(vector<int>& a, int& b)
{
	if (a.size() == 0) {
		cerr << "Error: Empty vector.\n";
	}
	vector<double> s(a.size(), 0);
	for (int i = 0; i<a.size(); i++) {
		s[i] = a[i] + b;
	}
	return s;
}

// Elementweises multiplizieren
vector<double> multVectors( vector<double>& a, vector<double>& b ) 
{
	if( a.size()==0 || b.size()==0 ) {
		cerr << "Error: Empty vector.\n";
	}
	if (a.size()!=b.size()) {
		cerr << "Error: Vectors of different size.\n";
	}
	vector<double> m(a.size(),0);
	for (int i=0; i<a.size(); i++) {
		m[i]=a[i]*b[i];
	}
	return m;
}

vector<double> multVectors(vector<int>& a, vector<double>& b) 
{
	if (a.size() == 0 || b.size() == 0) {
		cerr << "Error: Empty vector.\n";
	}
	if (a.size() != b.size()) {
		cerr << "Error: Vectors of different size.\n";
	}
	vector<double> m(a.size(), 0);
	for (int i = 0; i<a.size(); i++) {
		m[i] = (double)a[i] * b[i];
	}
	return m;
}

vector<double> multVectors(vector<double>& a, vector<int>& b) 
{
	if (a.size() == 0 || b.size() == 0) {
		cerr << "Error: Empty vector.\n";
	}
	if (a.size() != b.size()) {
		cerr << "Error: Vectors of different size.\n";
	}
	vector<double> m(a.size(), 0);
	for (int i = 0; i<a.size(); i++) {
		m[i] = a[i] * (double)b[i];
	}
	return m;
}

vector<double> multVectorScalar( vector<double>& a, double& b ) {
	if( a.size()==0 ) {
		cerr << "Error: Empty vector.\n";
	}
	vector<double> m(a.size(),0);
	for (int i=0; i<a.size(); i++) {
		m[i]=a[i]*b;
	}
	return m;
}

vector<double> multVectorScalar(vector<int>& a, double& b) {
	if (a.size() == 0) {
		cerr << "Error: Empty vector.\n";
	}
	vector<double> m(a.size(), 0);
	for (int i = 0; i<a.size(); i++) {
		m[i] = (double)a[i] * b;
	}
	return m;
}

vector<double> multVectorScalar(vector<double>& a, int& b) {
	if (a.size() == 0) {
		cerr << "Error: Empty vector.\n";
	}
	vector<double> m(a.size(), 0);
	for (int i = 0; i<a.size(); i++) {
		m[i] = a[i] * (double)b;
	}
	return m;
}


