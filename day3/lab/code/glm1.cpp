#include <TMB.hpp>
template<class Type>
Type objective_function<Type>::operator() ()
{
  // Data
  DATA_VECTOR( y );  // observations
  DATA_VECTOR( X );  // covariates
  int n_y = y.size(); 
  
  // Parameters
  PARAMETER ( beta0 );
  PARAMETER ( beta1 );
  

  // Objective funcction
  Type jnll = 0;
  
  // Probability of data
  vector<Type> ypred(n_y);
  for( int i=0; i<n_y; i++){
    ypred(i) = exp( beta0 + beta1*X(i) );
    jnll -= dpois( y(i), ypred(i), true );
  }
  
  
  ADREPORT(beta0);
  ADREPORT(beta1);
  
  return jnll;
}
