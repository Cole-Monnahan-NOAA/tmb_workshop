// very basic function minimization
#include <TMB.hpp>
template<class Type>
Type objective_function<Type>::operator() ()
{
  PARAMETER(x);	
  Type f=2*x-4*log(x)-5*log(x);
  return f;
}
