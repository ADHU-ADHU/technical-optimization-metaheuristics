%=====================solving Example2 by Linprog function=================
clc%clear the command window
clear%remove memory in Workspace


%vector f= coefficient of objective function; operational costs of machines A, B, and C amount to $30, $50, and $80 per hour 
f=[30 50 80 30 50 80 30 50 80 30 50 80]


%matrix A= coefficient of <= constraints

A=[-300 -600 -800 0 0 0 0 0 0 0 0 0   % Size small
    0 0 0 -250 -400 -800 0 0 0 0 0 0  % size medium
    0 0 0 0 0 0 -200 -350 -600 0 0 0  % size large
    0 0 0 0 0 0 0 0 0 -100 -200 -300  % size Extra-large
    1 0 0 1 0 0 1 0 0 1 0 0             % time for machine A
    0 1 0 0 1 0 0 1 0 0 1 0           % time for machine B
    0 0 1 0 0 1 0 0 1 0 0 1]          % time for machine C

%vector b= coefficient of RHS (righ hand side) of <= constraints; note for >= constraints both sides are multiplied by -1
b=[ -12000
-8000
-6000
-6000
 50
 30
 20]
%matrix Aeq= coefficient of = constraints
Aeq = []
beq = []
%vector beq= coefficient of RHS (righ hand side) of = constraints

%vector lb= lb of decision variables
lb=[0	0	0	0	0	0	0	0	0	0	0	0]
%vector ub= ub of decision variables
ub=[]

%calls function by [x,fval] = linprog(f,A,b,Aeq,beq,lb,ub) 
[x,fval]=linprog(f,A,b,Aeq,beq,lb,ub)
hours = transpose(x)
fval
