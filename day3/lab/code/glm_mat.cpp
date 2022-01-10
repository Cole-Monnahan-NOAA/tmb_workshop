#include <TMB.hpp>
template<class Type>
Type objective_function<Type>::operator() ()
{
  // Data
  //DATA_INTEGER( n_y );  // number of observations
  DATA_VECTOR( y );  // observations
  //DATA_INTEGER( n_b );  // number of covariates
  DATA_MATRIX( X );  // n_y by n_b, including first column of 1's
  int n_y = y.size(); 
  
  // Parameters
  //PARAMETER ( beta0 );
  PARAMETER_VECTOR ( beta );
  //PARAMETER( log_sdz );

  
  // Objective function
  Type jnll = 0;
  
  // Probability of data
  vector<Type> ypred(n_y);
  vector<Type> logypred(n_y);
  logypred = X * beta;  //matrix calc for predicted values 
  
  //for( int i=0; i<n_y; i++){
    ypred = exp( logypred );
    jnll = -sum(dpois( y, ypred, true ) );
  //}
  
  // Reporting
  ADREPORT( beta );

  return jnll;
}
