#include <TMB.hpp>
template<class Type>
Type objective_function<Type>::operator() ()
{
  // Data
 
  DATA_VECTOR( y );  // observations
  DATA_VECTOR( X );  // covariates
  DATA_FACTOR( R );  // factor for grouping the random effects
  DATA_INTEGER( n_g); // number of groups
  int n_y = y.size(); 
  
  // Parameters
  PARAMETER ( beta0 );
  PARAMETER ( beta1 );
  PARAMETER ( logsigma );  // log sd of measurement error
  PARAMETER_VECTOR (eps); // random effects
  PARAMETER ( logsd );  // log sd of random effects
  
  Type sigma = exp(logsigma);
  Type sd = exp(logsd);

  // Objective function
  Type jnll = 0;
  
  // Probability of data
  vector<Type> ypred(n_y);
  for( int i=0; i<n_y; i++){
    ypred(i) = exp( beta0 + beta1*X(i) ) + eps(R(i));
    jnll -= dnorm( y(i), ypred(i), sigma, true );
  }
  // Probability of the random effect
  for( int i=0; i<n_g; i++){
    jnll -= dnorm( eps(i), Type(0.0), sd, true );
  }
  
  
  REPORT(beta0);
  REPORT(beta1);
  REPORT(sigma);
  REPORT(sd);
  
  return jnll;
}
