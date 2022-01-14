#include <TMB.hpp>
template<class Type>
Type objective_function<Type>::operator() ()
{
  // Data
  DATA_VECTOR( y ); 
  DATA_VECTOR( x ); 
  int n_y = y.size();
  
  // Parameters
  PARAMETER ( lambda0 );
  PARAMETER ( lambda1 );
    
  // Objective function
    Type jnll = 0;
  
  // Likelihood
  vector<Type> ypred(n_y);
  
  for( int i=0; i<n_y; i++){
  ypred(i) = exp( lambda0 + lambda1 * x(i) );
  jnll -= dpois( y(i), ypred(i), true );
  }
  
  // Reporting
  REPORT( lambda0 );
  REPORT( lambda1 );
  
  return jnll;
}
