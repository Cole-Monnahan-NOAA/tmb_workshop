// very basic function minimization
#include <TMB.hpp>
template<class Type>
Type objective_function<Type>::operator() ()
{
  PARAMETER(x);	
  Type f=pow(x-0.113,2)+pow(x- -0.240,2)+pow(x-0.583,2);
  return f;
}
