# AG 1/27/17 Simple 5-queue network simulation

# TODO: Collect statistics for total time in system a customer spends





# Acknowledgement that this is DRY violation,
# and not an efficient coding solution.

# Code could be a lot cleaner and easier to n-queue network
# generalize if we maybe represent all the Queues as rows in
# a matrix, or utilize list data structures in a oo language like
# C# or Java.

# However, I don't like the idea of adding columns to a matrix as needed,
# where Queue2 may need 200 columns, but Queue5 only needs 3.
# and this code is meant to be more illustrative of how you might go about
# writing a queue simulation in R, rather than an efficient and already generalized 
# solution.

# initial time time begins from 0
t = 0

# time step in simulation
dt = 0.01

# lets say a time unit 0.01 is 1 day

# exponential service times

service_rate = 6

# > tmp <- rexp(100, service_rate)
# > tmp
#   [1] 2.493666e-01 4.967563e-02 3.238861e-01 1.761265e-01 1.556911e-01 7.048230e-02 6.756533e-01 9.303652e-02 1.179527e-01
#  [10] 1.391551e-01 3.935893e-02 4.436938e-01 5.211235e-01 2.323992e-02 4.586751e-02 2.414990e-01 8.398425e-02 2.758091e-02
#  [19] 3.718483e-01 3.809367e-02 4.563127e-01 1.753753e-01 1.276340e-01 3.122147e-02 3.420102e-02 5.196695e-03 1.883411e-01
#  [28] 1.467518e-01 1.006913e-01 8.151058e-02 3.967947e-01 3.591404e-02 2.555494e-02 3.436846e-02 3.201478e-01 2.108188e-01
#  [37] 2.278551e-01 1.662969e-01 6.090101e-02 1.045153e-01 1.424147e-02 1.638483e-02 1.418287e-03 5.853502e-02 5.224640e-02
#  [46] 8.351761e-02 7.757083e-03 6.828762e-02 5.362528e-01 9.214029e-02 1.141244e-02 1.347589e-01 1.147410e-01 5.500227e-02
#  [55] 1.430173e-01 6.558961e-01 2.109010e-02 1.284365e-02 2.010863e-01 1.844378e-02 8.783629e-02 8.744533e-02 2.971614e-01
#  [64] 1.235091e-02 9.923190e-02 3.949298e-02 9.668033e-02 1.405050e-01 4.324115e-02 4.059856e-01 2.297589e-05 8.814034e-02
#  [73] 8.509047e-02 1.087792e-02 3.033504e-02 1.772898e-02 3.320641e-01 2.309249e-01 4.359491e-02 1.867392e-01 1.203455e-01
#  [82] 2.356741e-02 6.132288e-02 9.122251e-02 4.281527e-02 1.555557e-02 9.893810e-02 1.972662e-01 6.066410e-02 3.670190e-01
#  [91] 2.639242e-01 1.307038e-01 3.757971e-02 1.157248e-01 8.209801e-02 7.681805e-02 3.012348e-04 7.982147e-02 3.112245e-01
# [100] 1.811910e-01
# > summary(tmp)
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# 0.000023 0.037970 0.087990 0.138100 0.182600 0.675700 

# mean = 1/6 ~= 16.67 days


# > tmp <- rpois(100,1)
# > tmp
#   [1] 3 0 1 0 0 2 0 2 0 0 3 2 1 1 1 0 1 0 1 0 1 4 3 0 0 2 0 1 2 0 0 1 2 1 1 1 1 1 0 0 1 0 3 0 2 2 0 0 0 0 0 3 1 0 1 2 0 1 1
#  [60] 2 3 1 0 1 2 2 0 2 0 0 0 4 1 1 0 3 2 0 1 1 0 0 0 1 1 1 0 0 1 0 0 1 2 0 0 1 0 1 3 2
# > summary(tmp)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#    0.00    0.00    1.00    0.96    2.00    4.00 

# mean = 1 person a day





# last_customer - These are sequential integers that act as customer
# id.  They are used in last_customer to keep track of current id to
# handle intake and generation of id's for new arrivals.
last_customer = 0


# initialize queues and servers
Queue1 = c()
server1.occupied = FALSE
server1.processtime = 0
server1.begintime = 0

Queue2 = c()
server2.occupied = FALSE
server2.processtime = 0
server2.begintime = 0

Queue3 = c()
server3.occupied = FALSE
server3.processtime = 0
server3.begintime = 0

# Yeah, yeah, yeah, DRY...

Queue4 = c()
server4.occupied = FALSE
server4.processtime = 0
server4.begintime = 0

Queue5 = c()
server5.occupied = FALSE
server5.processtime = 0
server5.begintime = 0

processed_customers = c()

#new code
process_times <- data.frame(0,0,0,0,0,0)
colnames(process_times) = c("server1","server2","server3","server4","server5","total_time")

# Adding customers to the queue is different for Queue1
# than the others because this is the only input to the system.
# The other queues are merely getting customers from the other
# queues, but entry in Queue1 will manage customer id'ing.

# n - number of people to add
AddToQueue1 <- function(n) {
  n_local = n
  
  # last_customer - what I use to keep track and generate
  #                 id's of the entering customers
  
  if (is.null(Queue1)) {  # initialize Queue1
    Queue1 <<- c(last_customer + 1)
    last_customer <<- last_customer + 1
    n_local = n_local - 1 # Queue1 has been initialized, decrement n_local for for loop
  }
  
  # input to function was number of new people to add,
  # they will be appended in order to the Queue with the id's
  # generated from last_customer
  for (i in 1:n_local) {
    Queue1 <<- append(Queue1, last_customer + 1)
	
	#new code
	if (last_customer + 1 > 1) {
		process_times[last_customer + 1,] <<- c(0,0,0,0,0,0)
	}
	
    last_customer <<- last_customer + 1
  }
}

Server1ProcessCustomer <- function() {
  server1.processtime <<- rexp(1, service_rate)
  server1.begintime <<- t
  server1.occupied <<- TRUE
  server1.customer <<- Queue1[1]
  
  #new code
  process_times$server1[server1.customer] <<- server1.processtime
  
  if (length(Queue1) == 1) {
    Queue1 <<- c()
  }
  else {
    Queue1 <<- Queue1[2:length(Queue1)]
  }
}

# Template of ServerProcessCustomer function
# function takes customer from respective server's
# queue and services that customer

Server2ProcessCustomer <- function() {
  server2.processtime <<- rexp(1, service_rate) # Generate a service time.
  
  server2.begintime <<- t  # Get this so we can keep track of how much time has elapsed
  # in the main while loop at the beginning where we check all the servers
  
  server2.occupied <<- TRUE  # Set flag so we can easily check whether or not the server is busy
  
  server2.customer <<- Queue2[1] # customer server is to process, FIFO.
  
  #new code
  process_times$server2[server2.customer] <<- server2.processtime
  
  if (length(Queue2) == 1) {
    Queue2 <<- c() # If that was the only person in line, empty queue
  }
  else {
    Queue2 <<- Queue2[2:length(Queue2)] # remove person from queue
  }
}

Server3ProcessCustomer <- function() {
  server3.processtime <<- rexp(1, service_rate)
  server3.begintime <<- t
  server3.occupied <<- TRUE
  server3.customer <<- Queue3[1]
  
  #new code
  process_times$server3[server3.customer] <<- server3.processtime
  
  
  if (length(Queue3) == 1) {
    Queue3 <<- c()
  }
  else {
    Queue3 <<- Queue3[2:length(Queue3)]
  }
}



Server4ProcessCustomer <- function() {
  server4.processtime <<- rexp(1, service_rate)
  server4.begintime <<- t
  server4.occupied <<- TRUE
  server4.customer <<- Queue4[1]
  
  #new code
  process_times$server4[server4.customer] <<- server4.processtime
  
  
  if (length(Queue4) == 1) {
    Queue4 <<- c()
  }
  else {
    Queue4 <<- Queue4[2:length(Queue4)]
  }
}

Server5ProcessCustomer <- function() {
  server5.processtime <<- rexp(1, service_rate)
  server5.begintime <<- t
  server5.occupied <<- TRUE
  server5.customer <<- Queue5[1]
  
  #new code
  process_times$server5[server5.customer] <<- server5.processtime
  
  
  if (length(Queue5) == 1) {
    Queue5 <<- c()
  }
  else {
    Queue5 <<- Queue5[2:length(Queue5)]
  }
}


# FreeServer is different for the nth (last) queue,
# because this step is exit of system for customer. Not
# going to add to a queue for another server to serve,
# like FreeServer for the other ones.
FreeServer5 <- function() {
 process_times$total_time[server5.customer] <<- process_times$server1[server5.customer] + process_times$server2[server5.customer] + process_times$server3[server5.customer] + process_times$server4[server5.customer] + process_times$server5[server5.customer]
  processed_customers <<- append(processed_customers, server5.customer)
  server5.customer <<- NULL
  server5.occupied <<- FALSE
}

FreeServer4 <- function() {
  
  # Yes, I know this is trivial to simplify into an if without an else.
  
  if (server5.occupied) {                        # if server is occupied,
    Queue5 <<- append(Queue5, server4.customer)  # add into queue
  }
  else {
    Queue5 <<- append(Queue5, server4.customer) # otherwise, add anyway (will be removed in ServerProcessCustomer)
    Server5ProcessCustomer()                    # and serve them
  }
  
  # free server
  server4.customer <<- NULL
  server4.occupied <<- FALSE
  
}

FreeServer3 <- function() {
  if (server4.occupied) {
    Queue4 <<- append(Queue4, server3.customer)
  }
  else {
    Queue4 <<- append(Queue4, server3.customer)
    Server4ProcessCustomer()        
  }
  
  server3.customer <<- NULL
  server3.occupied <<- FALSE
  
}

FreeServer2 <- function() {
  
  if (server3.occupied) {
    Queue3 <<- append(Queue3, server2.customer)
  }
  else {
    Queue3 <<- append(Queue3, server2.customer)
    Server3ProcessCustomer()  # but also serve 1 customer since server1 is free        
  }
  
  server2.customer <<- NULL
  server2.occupied <<- FALSE
  
}

FreeServer1 <- function() {
  
  if (server2.occupied) {
    Queue2 <<- append(Queue2, server1.customer)
  }
  else {
    Queue2 <<- append(Queue2, server1.customer)
    Server2ProcessCustomer()  # but also serve 1 customer since server1 is free        
  }
  
  server1.customer <<- NULL
  server1.occupied <<- FALSE
  
}

# MAIN LOOP
while (t < 100) {
  
  # at a time step, r.v. of new arrivals arrive    
  number_of_new_arrivals=rpois(1,1)
  
  # check all the servers to see if processing time is up
  # if so, need to free server, and the FreeServer function
  
  if ((server5.occupied) & (server5.processtime <= (t - server5.begintime))) {
    FreeServer5()  
  }
  
  if ((server4.occupied) & (server4.processtime <= (t - server4.begintime))) {
    FreeServer4()  
  }
  
  if ((server3.occupied) & (server3.processtime <= (t - server3.begintime))) {
    FreeServer3()  
  }
  
  if ((server2.occupied) & (server2.processtime <= (t - server2.begintime))) {
    FreeServer2()  
  }
  
  if ((server1.occupied) & (server1.processtime <= (t - server1.begintime))) {
    FreeServer1()  
  }
  
  # Handle the entry into the system at Queue1
  if (server1.occupied) {
    AddToQueue1(number_of_new_arrivals)  # If so, add to queue
  } else {
    AddToQueue1(number_of_new_arrivals)  # Otherwise, still want to add to queue
    Server1ProcessCustomer()  # but also serve 1 customer since server1 is free        
  }
  
  # print time as it goes by
  print(t)
  t = t + dt
}

# END
print("END")

plot(process_times$total_time[1:100])