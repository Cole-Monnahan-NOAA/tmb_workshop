#include <TMB.hpp>
template<class Type>
Type objective_function<Type>::operator() ()
{
  // Data
  DATA_VECTOR( y );  // observations
  
  // Parameters
  PARAMETER ( logmu );
  PARAMETER ( logtheta );
  Type mu;
  Type theta;
  
  //transform
  mu = exp(logmu);
  theta = exp(logtheta);

  // Objective funcction
  Type jnll = 0;
  
  // Probability of data
    jnll = -sum(dnbinom2( y, mu, theta, true ) );

  
  return jnll;
}
