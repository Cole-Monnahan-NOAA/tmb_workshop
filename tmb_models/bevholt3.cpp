// Beverton-Hold stock recruit function. Modified from A. Nielson's
// lectures: http://www.nielsensweb.org/bergen/

#include <TMB.hpp>
template<class Type>
Type objective_function<Type>::operator() ()
{
  DATA_VECTOR(SSB);
  DATA_VECTOR(logR);

  PARAMETER(logA);
  PARAMETER(logB);
  PARAMETER(logsigma);

    // We use log transforms to keep parameters positive
  Type B=exp(logB);
  Type sigma=exp(logsigma);
  
  // Loop through each observed SSB and predict logR.
  int N=SSB.size();
  vector<Type> pred(N); // predictions for each row
  pred=logA+log(SSB)-log(Type(1)+B*SSB);
  

  // negative log-likelihood
  // Note: using vector calculations so need to sum them
  Type nll=-dnorm(logR,pred,sigma,true).sum();
  REPORT(pred);
  Type C=exp(logA)*B;
  REPORT(C);
  return nll;
}
