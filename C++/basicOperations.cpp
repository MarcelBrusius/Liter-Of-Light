#include <iostream>
#include <cmath>

using namespace std; // vermeidet Doppelbenennung von Variablen


#include "basicOperations.h"

void printVector( vector<double>& a ) {
	cout << "[";
	for (unsigned int i=0; i<a.size(); i++) {
		if (i+1<a.size()) {
		    cout << a[i] << ",";
		}else{
			cout << a[i];
		}
	}
	cout << "]";
}

// normiere Vektor in euklidischer Norm
vector<double> normVector( vector<double>& a ) {
	if( a.size()==0 ) {
		cout << "Fehler: 'normVector' mit leerem Vektor aufgerufen.\n";
	}
	double norm=0;
	for(unsigned int i=0; i<a.size(); i++ ) {
		norm += pow(a[i],2);
	}
	norm=sqrt(norm);
	for(unsigned int i=0; i<a.size(); i++ ) {
		a[i]=a[i]/norm;
	}
	return a;
}

double sumVector( vector<double>& a ) {
	if( a.size()==0 ) {
		cout << "Fehler: 'sumVector' mit leerem Vektor aufgerufen.\n";
	}
	double s=0;
	for(unsigned int i=0; i<a.size(); i++ ) {
		s+=a[i];
	}
	return s;
}


vector<double> addVectors( vector<double>& a , vector<double>& b ) {
	if( a.size()==0 || b.size()==0 ) {
			cout << "Fehler: 'addVector' mit leerem Vektor aufgerufen.\n";
	}
	if (a.size()!=b.size()) {
		cout << "Fehler: 'addVector' mit unterschiedlich langen Vektoren aufgerufen.\n";
	}
	vector<double> s(a.size(),0);
	for (unsigned int i=0; i<a.size(); i++) {
		s[i]=a[i]+b[i];
	}
	return s;
}

vector<double> addVectorScalar( vector<double>& a, double& b ) {
	if( a.size()==0 ) {
		cout << "Fehler: 'addVectorScalar' mit leerem Vektor aufgerufen.\n";
	}
	vector<double> s(a.size(),0);
	for (unsigned int i=0; i<a.size(); i++) {
		s[i]=a[i]+b;
	}
	return s;
}

// Elementweises multiplizieren
vector<double> multVectors( vector<double>& a, vector<double>& b ) {
	if( a.size()==0 || b.size()==0 ) {
		cout << "Fehler: 'multVector' mit leerem Vektor aufgerufen.\n";
	}
	if (a.size()!=b.size()) {
	cout << "Fehler: 'multVector' mit unterschiedlich langen Vektoren aufgerufen.\n";
	}
	vector<double> m(a.size(),0);
	for (unsigned int i=0; i<a.size(); i++) {
		m[i]=a[i]*b[i];
	}
	return m;
}

vector<double> multVectorScalar( vector<double>& a, double& b ) {
	if( a.size()==0 ) {
		cout << "Fehler: 'multVectorScalar' mit leerem Vektor aufgerufen.\n";
	}
	vector<double> m(a.size(),0);
	for (unsigned int i=0; i<a.size(); i++) {
		m[i]=a[i]*b;
	}
	return m;
}



