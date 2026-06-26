#include <stdio.h>
#include <math.h>
#include "lambdalib.h"


#define SELF struct ArrayList *self
typedef struct ArrayList {
int *data;
int numOfData;
int size;

void (*insert)(SELF, int elem);

void (*renewSize)(SELF, int newSize);

int (*getIndexOf)(SELF, int elem);

void (*delete)(SELF, int elem);
} ArrayList;

void insert(SELF, int elem) {

if(self->size == self->numOfData) {
self->size *= self->size;
self->renewSize(self, self->size);
}
self->data[self->numOfData] = elem;
self->numOfData += 1;
write("The element %d was inserted succesfully!\n", elem);
} 

void renewSize(SELF, int newSize) {
int* newData = (int*)malloc(newSize * sizeof(int));					
for(int data_i = 0; data_i < newSize; ++data_i)					
newData[data_i] = self->data[data_i];
self->data = newData;
write("The new array size is: %d\n", newSize);
} 

int getIndexOf(SELF, int elem) {
for(int i = 0; i < self->numOfData; i++) {

if(self->data[i] == elem) {
write("The element %d was found succesfully at %d!\n", elem, i);
return i;
}
}
write("The element %d was not found!\n", elem);
return -1;
} 

void delete(SELF, int elem) {
int index;
index = self->getIndexOf(self, elem);

if(index != -1) {
for(int i = index; i < self->numOfData - 1; i++) {
self->data[i] = self->data[i + 1];
}
self->data[self->numOfData - 1] = 0;
self->numOfData -= 1;
write("The element %d was deleted succesfully!\n", elem);
}
} 

const ArrayList ctor_ArrayList = { .insert=insert, .renewSize=renewSize, .getIndexOf=getIndexOf, .delete=delete };
#undef SELF


ArrayList createArrayList(int initialSize) {
ArrayList list = ctor_ArrayList;
list.size = initialSize;
int newData[initialSize];
list.data = newData;
list.numOfData = 0;
return list;
}
int main(){
ArrayList list = ctor_ArrayList;
list = createArrayList(10);
const int base = 2;
int max;
max = base * 10;
int *data = (int*)malloc(50 * sizeof(int));                    
for(int i = 0; i < 50; ++i)                    
data[i] = (base * i) % max;
for(int i = 1; i < 50; i++) {
list.insert(&list, data[i]);
}
list.delete(&list, 2 * 2);
list.delete(&list, 2 + 3);
}

