#include <TMB.hpp>
template<class Type>
Type objective_function<Type>::operator() ()
{
  // Define data vectors x1,x2,y
  DATA_VECTOR(x1);
  DATA_VECTOR(x2);
  DATA_VECTOR(y);
  // Define parameters beta0,beta1, beta2
  PARAMETER(beta0);
  PARAMETER(beta1);
  PARAMETER(beta2);
  // predict y
  vector<Type> ypred= beta0 + x1*beta1 + x2*beta2;
  
  // calculate negative log likelihood
  Type nll= -dnorm(ypred, y, Type(0.5), true).sum();
  return nll;
}
