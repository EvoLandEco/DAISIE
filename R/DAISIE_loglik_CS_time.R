island_area <- function(t, Apars, island_ontogeny)
{
  Amax <- Apars[1] #max_area
  Topt <- Apars[2] #proportional_peak_t
  peak <- Apars[3] #peak_sharpness
  Tmax <- Apars[4] #total_island_age
  proptime <- t/Tmax	
  # Constant
  if(island_ontogeny == 0)
  {
    if(Amax != 1)
    {
      warning('Constant ontogeny requires a maximum area of 1.')
    }
    return(1)
  }	
  if(island_ontogeny == 2) {
    
    f <- Topt / (1 - Topt)
    a <- f * peak / (1 + f)
    b <- peak / (1 + f) 
    At <- Amax * proptime ^ a * (1 - proptime) ^ b / ((a / (a + b)) ^ a * (b / (a + b)) ^ b)
    return(At)}
}

#parsvec[1:4] = Apars
#parsvec[5] = lac0
#parsvec[6:7] = mupars
#parsvec[8] = K0
#parsvec[9] = gam0
#parsvec[10] = laa0
#parsvec[11] = island_ontogeny
#parsvec[12] = kk
#parsvec[13] = ddep

DAISIE_loglik_rhs_time = function(t,x,parsvec)
{
  kk <- parsvec[length(parsvec) - 1]
  lx <- (length(x) - 1)/2
  lnn <- lx + 4 + 2 * kk
  nn <- -2:(lx+2*kk+1)
  nn = pmax(rep(0,lnn),nn) # Added this
  
  Apars <- parsvec[1:4]
  island_ontogeny <- parsvec[11]
  time_for_area_calc <- abs(t)
  area <- island_area(t = time_for_area_calc,
                      Apars = Apars,
                      island_ontogeny = island_ontogeny)
  lacvec <- pmax(rep(0,lnn),parsvec[5] * (1 - nn/(area * parsvec[8])))
  X <- log(parsvec[6] / parsvec[7]) / log(0.1)
  mu <- parsvec[6] / ((area / parsvec[2])^X)
  muvec <- mu * rep(1,lnn)
  gamvec <- pmax(rep(0,lnn),parsvec[9] * (1 - nn/(area * parsvec[8])))
  laavec <- parsvec[10] * rep(1,lnn)

  xx1 = c(0,0,x[1:lx],0)
  xx2 = c(0,0,x[(lx + 1):(2 * lx)],0)
  xx3 = x[2 * lx + 1]
  
  nil2lx = 3:(lx + 2)
  
  il1 = nil2lx+kk-1
  il2 = nil2lx+kk+1
  il3 = nil2lx+kk
  il4 = nil2lx+kk-2
  
  in1 = nil2lx+2*kk-1
  in2 = nil2lx+1
  in3 = nil2lx+kk
  
  ix1 = nil2lx-1
  ix2 = nil2lx+1
  ix3 = nil2lx
  ix4 = nil2lx-2
  
  dx1 = laavec[il1 + 1] * xx2[ix1] + lacvec[il4 + 1] * xx2[ix4] + muvec[il2 + 1] * xx2[ix3] +
    lacvec[il1] * nn[in1] * xx1[ix1] + muvec[il2] * nn[in2] * xx1[ix2] +
    -(muvec[il3] + lacvec[il3]) * nn[in3] * xx1[ix3] +
    -gamvec[il3] * xx1[ix3]
  dx1[1] = dx1[1] + laavec[il3[1]] * xx3 * (kk == 1)
  dx1[2] = dx1[2] + 2 * lacvec[il3[1]] * xx3 * (kk == 1)
  
  dx2 = gamvec[il3] * xx1[ix3] +
    lacvec[il1 + 1] * nn[in1] * xx2[ix1] + muvec[il2 + 1] * nn[in2] * xx2[ix2] +
    -(muvec[il3 + 1] + lacvec[il3 + 1]) * nn[in3 + 1] * xx2[ix3] +
    -laavec[il3 + 1] * xx2[ix3]
  
  dx3 = -(laavec[il3[1]] + lacvec[il3[1]] + gamvec[il3[1]] + muvec[il3[1]]) * xx3
  return(list(c(dx1,dx2,dx3)))
}

DAISIE_loglik_rhs_time2 = function(t,x,parsvec)
{
  kk <- parsvec[length(parsvec) - 1]
  lx <- (length(x))/3
  lnn <- lx + 4 + 2 * kk
  nn <- -2:(lx+2*kk+1)
  nn = pmax(rep(0,lnn),nn)
  
  Apars <- parsvec[1:4]
  island_ontogeny <- parsvec[11]
  
  time_for_area_calc <- abs(t)
  area <- island_area(t = time_for_area_calc,
                      Apars = Apars,
                      island_ontogeny = island_ontogeny)
  lacvec <- pmax(rep(0,lnn),parsvec[5] * (1 - nn/(area * parsvec[8])))
  X <- log(parsvec[6] / parsvec[7]) / log(0.1)
  mu <- parsvec[6] / ((area / Apars[2])^X)
  muvec <- mu * rep(1,lnn)
  gamvec <- pmax(rep(0,lnn),parsvec[9] * (1 - nn/(area * parsvec[8])))
  laavec <- parsvec[10] * rep(1,lnn)
  
  xx1 = c(0,0,x[1:lx],0)
  xx2 = c(0,0,x[(lx + 1):(2 * lx)],0)
  xx3 = c(0,0,x[(2 * lx + 1):(3 * lx)],0)
  
  nil2lx = 3:(lx + 2)
  
  il1 = nil2lx+kk-1
  il2 = nil2lx+kk+1
  il3 = nil2lx+kk
  il4 = nil2lx+kk-2
  
  in1 = nil2lx+2*kk-1
  in2 = nil2lx+1
  in3 = nil2lx+kk
  in4 = nil2lx-1
  
  ix1 = nil2lx-1
  ix2 = nil2lx+1
  ix3 = nil2lx
  ix4 = nil2lx-2
  
  # inflow:
  # anagenesis in colonist when k = 1: Q_M,n -> Q^1_n; n+k species present
  # cladogenesis in colonist when k = 1: Q_M,n-1 -> Q^1_n; n+k-1 species present; rate twice
  # anagenesis of reimmigrant: Q^M,k_n-1 -> Q^k,n; n+k-1+1 species present
  # cladogenesis of reimmigrant: Q^M,k_n-2 -> Q^k,n; n+k-2+1 species present; rate once
  # extinction of reimmigrant: Q^M,k_n -> Q^k,n; n+k+1 species present
  # cladogenesis in one of the n+k-1 species: Q^k_n-1 -> Q^k_n; n+k-1 species present; rate twice for k species
  # extinction in one of the n+1 species: Q^k_n+1 -> Q^k_n; n+k+1 species present
  # outflow:
  # all events with n+k species present
  dx1 = (laavec[il3] * xx3[ix3] + 2 * lacvec[il1] * xx3[ix1]) * (kk == 1) + 
    laavec[il1 + 1] * xx2[ix1] + lacvec[il4 + 1] * xx2[ix4] + muvec[il2 + 1] * xx2[ix3] +
    lacvec[il1] * nn[in1] * xx1[ix1] + muvec[il2] * nn[in2] * xx1[ix2] +
    -(muvec[il3] + lacvec[il3]) * nn[in3] * xx1[ix3] - gamvec[il3] * xx1[ix3]
  
  # inflow:
  # immigration when there are n+k species: Q^k,n -> Q^M,k_n; n+k species present
  # cladogenesis in n+k-1 species: Q^M,k_n-1 -> Q^M,k_n; n+k-1+1 species present; rate twice for k species
  # extinction in n+1 species: Q^M,k_n+1 -> Q^M,k_n; n+k+1+1 species present
  # outflow:
  # all events with n+k+1 species present
  dx2 = gamvec[il3] * xx1[ix3] +
    lacvec[il1 + 1] * nn[in1] * xx2[ix1] + muvec[il2 + 1] * nn[in2] * xx2[ix2] +
    -(muvec[il3 + 1] + lacvec[il3 + 1]) * nn[in3 + 1] * xx2[ix3] +
    -laavec[il3 + 1] * xx2[ix3]
  
  # only when k = 1         
  # inflow:
  # cladogenesis in one of the n-1 species: Q_M,n-1 -> Q_M,n; n+k-1 species present; rate once
  # extinction in one of the n+1 species: Q_M,n+1 -> Q_M,n; n+k+1 species present
  # outflow:
  # all events with n+k species present
  dx3 = lacvec[il1] * nn[in4] * xx3[ix1] + muvec[il2] * nn[in2] * xx3[ix2] +
    -(lacvec[il3] + muvec[il3]) * nn[in3] * xx3[ix3] +
    -(laavec[il3] + gamvec[il3]) * xx3[ix3]
  
  return(list(c(dx1,dx2,dx3)))
}

divdepvec_time <- function(lacgam,pars1,lx,k1,ddep,island_ontogeny)
{
  #pars1[1:4] = Apars
  #pars1[5] = lac0
  #pars1[6:7] = mupars
  #pars1[8] = K0
  #pars1[9] = gam0
  #pars1[10] = laa0
  #pars1[11] = island_ontogeny
  #pars1[12] = t
  #pars1[13] = 0 (for gam) or 1 (for lac) 
  area <- island_area(t = pars1[12],Apars = pars1[1:4],island_ontogeny = island_ontogeny)
  lacA <- pars1[5]
  gamA <- pars1[9]
  KA <- area * pars1[8]
  lacgam <- (1 - pars1[13]) * gamA + pars1[13] * lacA
  K <- KA
  lacgamK <- c(lacgam,K)
  return(lacgamK)
}        

DAISIE_integrate_time <- function(initprobs,tvec,rhs_func,pars,rtol,atol,method)
{
  if(as.character(body(rhs_func)[3]) == "lx <- (length(x) - 1)/2")
  {
    y <- ode(initprobs,tvec,func = DAISIE_loglik_rhs_time,pars,atol = atol,rtol = rtol,method = method)
  } else if(as.character(body(rhs_func)[3]) == "lx <- (length(x))/3")
  {
    y <- ode(initprobs,tvec,func = DAISIE_loglik_rhs_time2,pars,atol = atol,rtol = rtol,method = method)
  } else
  {
    stop('The integrand function is written incorrectly.')
  }
  return(y)
}
