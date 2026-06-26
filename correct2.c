#include <stdio.h>
#include <math.h>
#include "lambdalib.h"


double getBMI(double weight, double height) {
double bmi;
bmi = weight / (pow(height, 2));
return bmi;
}

void getBMIDetails(double bmi) {
write("BMI:\t%f\n", bmi);
writeStr("Grade:\t");

if(bmi < 18.5) {
writeStr("Under");
} else {

if(bmi < 25) {
writeStr("Normal");
} else {

if(bmi < 30) {
writeStr("Over");
} else {

if(bmi < 40) {
writeStr("Obese");
} else {
writeStr("Error");
}
}
}
}
}
int main(){
double weight, height;
weight = 57.4;
height = 1.73;
const double bmi = getBMI(weight, height);
getBMIDetails(bmi);
}

