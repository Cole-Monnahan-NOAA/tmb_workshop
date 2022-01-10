#include <TMB.hpp>
template<class Type>
Type objective_function<Type>::operator() ()
{
  // Data
  DATA_VECTOR( y );  // observations
  
  //*** 1. What kind of DATA object is X?
    ( X );   // n_y by n_b, including first column of 1's
  int n_y = y.size(); 
  
  // Parameters
  //***2. What kind of PARAMETER object is beta
   (beta);
  
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
  

  ADREPORT( beta );

  return jnll;
}
