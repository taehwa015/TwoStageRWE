##############################################################################
# Sample code for "Incorporating real-world evidence for Bayesian two-stage  # 
#                  Phase-II single-arm trial for rare diseases"              #
# Maintainer: Taehwa Choi                                                    #
# Update: 01/01/2024                                                         #
##############################################################################
library(jagsUI)

# MCMC sampler
sampler <- function(response, stage.size, model.file, niter, nburn, nchain = 2, nthin = 1) {
  idst <- stage.size != 0
  jags_data <- list( "y" = response[idst], 
                     "N" = length(response[idst]), 
                     "n" = stage.size[idst] ) 
  jags_inits <- function() list("mu" = 1, "tau21" = 1)
  params <- c("prob", "mu", "tau21")
  jags_fit <- jags(data = jags_data, inits = jags_inits, 
                   parameters.to.save = params, 
                   model.file = model.file, 
                   n.chains = nchain, n.iter = niter, verbose = FALSE,
                   n.burnin = nburn, n.thin = nthin)
  
  list(post.p = plogis(jags_fit$sims.list$mu), 
       max.rhat = max(unlist(jags_fit$Rhat)),
       jags_fit = jags_fit)
}

sampler_ext <- function(response, stage.size, model.file, niter, nburn, nchain = 2, nthin = 1) {
  idst <- stage.size != 0
  jags_data <- list( "y" = response[idst], 
                     "N" = length(response[idst]), 
                     "n" = stage.size[idst] ) 
  jags_inits <- function() list("mu" = 1, "tau21" = 1, "tau22" = 1)
  params <- c("prob", "mu", "tau21", "tau22")
  jags_fit <- jags(data = jags_data, inits = jags_inits, 
                   parameters.to.save = params, 
                   model.file = model.file, 
                   n.chains = nchain, n.iter = niter, verbose = FALSE,
                   n.burnin = nburn, n.thin = nthin)
  
  list(post.p = plogis(jags_fit$sims.list$mu), 
       max.rhat = max(unlist(jags_fit$Rhat)),
       jags_fit = jags_fit)
}

# Summary function
resfun <- function(fit, h0, delta) {
  Gelman.Rubin <- fit$max.rhat
  Pooled.p <- mean(fit$post.p)
  PET <- mean(fit$post.p < 0.1)
  Decision <- ifelse(mean(fit$post.p > 0.1) < 0.15, "No-go", "Go")
  
  data.frame(Pooled.p, Gelman.Rubin, PET, Decision)
}

# Example 1
set.seed(1)
niter <- 40000; nburn <- 20000
response1 <- c(1, 0, 0)
stage.size1 <- c(2, 3, 3)
jags <- sampler(response = response1, 
                stage.size = stage.size1, 
                model.file = "model.jags",
                niter = niter, 
                nburn = nburn)
resfun(fit = jags, h0 = 0.1, delta = 0.15)

# Example 2
set.seed(1)
response2 <- c(6, 1, 2)
stage.size2 <- c(6, 7, 5)
jags <- sampler(response = response2, 
                stage.size = stage.size2, 
                model.file = "model.jags",
                niter = niter, 
                nburn = nburn)
resfun(fit = jags, h0 = 0.1, delta = 0.15)

# Example 3
set.seed(1)
response3 <- c(5, 1, 2, 0, 1)
stage.size3 <- c(6, 7, 5, 2, 4)
jags <- sampler_ext(response = response3, 
                    stage.size = stage.size3, 
                    model.file = "model_ext.jags",
                    niter = niter, 
                    nburn = nburn)
resfun(fit = jags, h0 = 0.1, delta = 0.15)