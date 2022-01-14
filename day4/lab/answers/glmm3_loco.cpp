#include <TMB.hpp>
template<class Type>
Type objective_function<Type>::operator() ()
{
  // Data
  DATA_INTEGER( n_y );  // number of years
  DATA_INTEGER( n_s); // number of sites
  DATA_MATRIX( y );  // observations
  DATA_MATRIX( X1 );  // covars n_y by n_s
  DATA_MATRIX( X2 );
  DATA_MATRIX( E );  //effort
  
  // Parameters
  PARAMETER ( beta0 );
  PARAMETER ( beta1 );
  PARAMETER ( beta2 );
  PARAMETER( log_sdz_s );
  PARAMETER( log_sdz_y );
  PARAMETER_VECTOR( eps_s );
  PARAMETER_VECTOR( eps_y );

  
  // Objective function
  Type jnll = 0;
  
  // transform log_sdz
  Type sdz_s = exp(log_sdz_s);
  Type sdz_y = exp(log_sdz_y);
  
  // Probability of data
  matrix<Type> ypred(n_y, n_s);
  for( int i=0; i<n_y; i++){
    for( int j=0; j<n_s; j++){
  //fixed effects component  
      ypred(i,j) = exp( beta0 + beta1*X1(i,j) + beta2*X2(i,j) + log(E(i,j)) + eps_s(j) + eps_y(i));
      jnll -= dpois( y(i,j), ypred(i,j), true );
    }
  }
  //random effects for site
  for( int i=0; i<n_s; i++){
    jnll -= dnorm( eps_s(i), Type(0.0), sdz_s, true );
  }
  //random effects for year
  for( int j=0; j<n_y; j++){
    jnll -= dnorm( eps_y(j), Type(0.0), sdz_y, true );
  }
  
  // Reporting
  REPORT( sdz_y );
  REPORT( sdz_s );
  REPORT( eps_y );
  REPORT( eps_s );
  REPORT( beta0 );
  REPORT( beta1 );
  REPORT( beta2 );
 
  return jnll;
}
