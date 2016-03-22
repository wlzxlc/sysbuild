#include <iostream>
using namespace std;

//its defiend in libtest.so or libtest.a
extern "C"{
extern int testc();
}
extern int testcc();
int main(){
  testc();
  testcc();
}
