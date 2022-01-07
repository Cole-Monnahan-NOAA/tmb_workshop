
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
  PARAMETER(logsigma);
  
  Type sigma=exp(logsigma);
  // predict y
  vector<Type> ypred=beta0+beta1*x1+beta2*x2;
  // calculate negative log likelihood
  Type nll= -dnorm(ypred,y,sigma,true).sum();
  REPORT(sigma);
  return nll;
}
