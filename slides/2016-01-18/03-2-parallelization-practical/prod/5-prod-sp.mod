set PROD;  # products
param T > 0;  # number of weeks
set SCEN;     # set of scenarios

param rate {PROD} > 0;     # tons produced per hour
param avail {1..T} >= 0;   # hours available in week

param revenue {PROD, 1..T, SCEN}; # projected revenue/ton
param market {PROD, 1..T} >= 0;   # limit on tons sold in week

param prodcost {PROD} >= 0;       # cost per ton produced
param invcost {PROD} >= 0;        # carrying cost/ton of inventory

param inv0 {PROD} >= 0;  # initial inventory

param prob {SCEN} >= 0, <= 1;
   check: 0.99999 < sum {s in SCEN} prob[s] < 1.00001;

# First stage

var Make1 {PROD} >= 0;
var Inv1 {PROD} >= 0;
var Sell1 {p in PROD} >= 0, <= market[p,1];

subject to Time1:
   sum {p in PROD} (1/rate[p]) * Make1[p] <= avail[1];

subject to Balance1 {p in PROD}:
   Make1[p] + inv0[p] = Sell1[p] + Inv1[p];

# Second stage

var Make {PROD, 2..T, SCEN} >= 0;      # tons produced
var Inv {PROD, 2..T, SCEN} >= 0;       # tons inventoried
var Sell {p in PROD, t in 2..T, SCEN}  # tons sold
   >= 0, <= market[p,t];

maximize Total_Profit:
  sum {p in PROD, s in SCEN} prob[s] * (
    (revenue[p,1,s]*Sell1[p] -  prodcost[p]*Make1[p] - invcost[p]*Inv1[p]) +
    sum {t in 2..T} (revenue[p,t,s] * Sell[p,t,s] -
      prodcost[p]*Make[p,t,s] - invcost[p]*Inv[p,t,s]));
               # Objective: total profits from all products

subject to Time{t in 2..T, s in SCEN}:
  sum {p in PROD} (1/rate[p]) * Make[p, t, s] <= avail[t];

               # Constraint: total of hours used by all
               # products may not exceed hours available

subject to Balance2 {p in PROD, s in SCEN}:
   Make[p,2,s] + Inv1[p] = Sell[p,2,s] + Inv[p,2,s];

subject to Balance {p in PROD, t in 3..T, s in SCEN}:
   Make[p,t,s] + Inv[p,t-1,s] = Sell[p,t,s] + Inv[p,t,s];
