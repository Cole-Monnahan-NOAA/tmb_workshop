#include <TMB.hpp>
template<class Type>
Type objective_function<Type>::operator() ()
{
  // Data
  DATA_VECTOR( y ); 
  DATA_VECTOR( x ); 
  DATA_VECTOR( eggs );
  int n_y = y.size();
  int n_e = eggs.size();
  
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
  
  //Predictions
  vector<Type> newy(n_e);
  for( int i=0; i<n_e; i++){
    newy(i) = exp( lambda0 + lambda1 * eggs(i) );
  }
  // Reporting
  REPORT( lambda0 );
  REPORT( lambda1 );
  
  //Want to get SD on the predictions
  ADREPORT(newy);
  
  return jnll;
}
