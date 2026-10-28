clc;
clear;
format shortG
%==========================Read SLP inputs=================================
%problem 1
%1) Workstations inputs:
W=30; %set the number of workstations (W)
dw=[7 7 10 1 7 9 4 5 4 6 6 3 9 1 5 3 5 9 6 3 5 9 9 9 9 3 9 5 8 10]; %demand of workstations (dw)
sumd=sum(dw); %calculate the sum of all demands (sumd)
xw=[0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 56 58]; %set the x-cordinate of workstations (xw)
yw=[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]; %set the y-cordinate of workstations (yw)
%2) Supermarkets inputs:
S=5; %set the potential number of supermarkets (S)
SIC=1000; %set the supermarket installation cost (SIC)
SUC=1; %set the shipment unit cost (SUC)
SC=60; %set the supermarket capacity (SC)
Xs=[5.8 17.4 29 40.6 52.2]; %set the x-cordinate of supermarkets (Xs)
Ys=[5 5 5 5 5]; %set the y-cordinate of supermarkets (Ys)
it=0;
c1=1;
c2 = 1;
cost_every_iteration = []
particles=100;
g_best = zeros(1,W+1);
g_best(1,W+1)= inf;
particles_best = zeros(particles,W+1);
particles_best(1:particles,W+1)=inf;
velocity = rand(particles, W);
initialWeight = 0.9;
finalWeight = 0.4 ; 
maxit = 200;
weight = 0.5;
TP=zeros(particles,W+1); % Initilaize the task priority (TP) matrix with size : popsize*n+1, where column n+1 will be updated as the fitness function later
for i=1:particles 
    TP(i,1:W)=rand(1,W); % each row of TP is a random-key number between (0,1) 
end
particles_best(1:particles,1:W)=TP(1:particles,1:W);


aswstosup=zeros(particles,W);%initialize the vector for assignment of workstations to supermarket (aswstosup)
aswstosup(1:particles,1)=1;%assign the first workstation to the first supermarket
td=zeros(particles,S);%initialize total demand of each supermarket (td)
td(1:particles,1)=dw(1);%set the current td in supermarket 1 equal to the demand of workstation 1
for p = 1: particles
   
    supc=1; %initialize supermarket counter (supc)
    for i=2:W %for each workstation
     
    if supc<S %if the supc is less than S
        if (TP(p,i)<=0.5) && (td(p,supc)+dw(i)<=SC) % if (random key of current workstation is less than preset value of 0.5) and (the td of current supermarket + the demand of considered workstation (dw(i)) are less than SC)
            td(p,supc)=td(p,supc)+dw(i);% update the td of current supermarket  
            aswstosup(p,i)=supc; %set the current place in aswstosup(1,i) vector as supc
        else % else if either of the above conditions are not satisfied 
            supc=supc+1; % add to the supc
            td(p,supc)=td(p,supc)+dw(i); % update the td of new supermarket
            aswstosup(p,i)=supc; %set the current place in aswstosup(1,i) vector as supc
        end
    else % if this is the last supermarket considering supc
        td(p,supc)=td(p,supc)+dw(i); % update the td of current supermarket 
        aswstosup(p,i)=supc; %set the current place in aswstosup(1,i) vector as supc
    end
    end
end

%=====================fitness function evaluation==========================
%1)calculate the shipment cost:

for j = 1:particles
final_cost= 0;
for i = 1:W
    final_cost = final_cost + 2*(abs(Xs(aswstosup(j,i))-xw(i)) + abs(Ys(aswstosup(j,i))-yw(i))) * dw(i);
    
end

final_cost=final_cost + 1000*max(aswstosup(j,W));
TP(j,W+1)=final_cost;
end

for p = 1:particles
if td(p,S)>SC %check if the td(S) exceeds the SC
        TP(p,W+1)=inf; % if so, set the column W+3 of n_sol eqaul to "inf"
end
end

for p = 1:particles
 if TP(p,1:W+1) < g_best(1,W+1)
     g_best(1,1:W+1)= TP(p,1:W+1);
 end
  if TP(p,1:W+1) < particles_best(p,W+1)
     particles_best(p,1:W+1)= TP(p,1:W+1);
 end
end

%----------------------------------------------------------------------------------------------------
% main part of Swarm optimization
while it < maxit 
    it = it + 1;
    weight = initialWeight - (initialWeight - finalWeight) * (it / maxit);

%     update velocity
    for p = 1:particles
        velocity(p,1:W) = weight*velocity(p,1:W)+c1*rand(1,W).*(particles_best(p,1:W)-TP(p,1:W))+ c2*rand(1,W).*(g_best(1:W)-TP(p,1:W));
        TP(p,1:W) = TP(p,1:W) + velocity(p,1:W);
    end

 %------------------------------
%_________________________---Assigning supermarket
aswstosup=zeros(particles,W);%initialize the vector for assignment of workstations to supermarket (aswstosup)
aswstosup(1:particles,1)=1;%assign the first workstation to the first supermarket
td=zeros(particles,S);%initialize total demand of each supermarket (td)
td(1:particles,1)=dw(1);%set the current td in supermarket 1 equal to the demand of workstation 1
for p = 1: particles
   
    supc=1; %initialize supermarket counter (supc)
    for i=2:W %for each workstation
     
    if supc<S %if the supc is less than S
        if (TP(p,i)<=0.5) && (td(p,supc)+dw(i)<=SC) % if (random key of current workstation is less than preset value of 0.5) and (the td of current supermarket + the demand of considered workstation (dw(i)) are less than SC)
            td(p,supc)=td(p,supc)+dw(i);% update the td of current supermarket  
            aswstosup(p,i)=supc; %set the current place in aswstosup(1,i) vector as supc
        else % else if either of the above conditions are not satisfied 
            supc=supc+1; % add to the supc
            td(p,supc)=td(p,supc)+dw(i); % update the td of new supermarket
            aswstosup(p,i)=supc; %set the current place in aswstosup(1,i) vector as supc
        end
    else % if this is the last supermarket considering supc
        td(p,supc)=td(p,supc)+dw(i); % update the td of current supermarket 
        aswstosup(p,i)=supc; %set the current place in aswstosup(1,i) vector as supc
    end
    end
end

%=====================fitness function evaluation==========================
%1)calculate the shipment cost:

for j = 1:particles
final_cost= 0;
for i = 1:W
    final_cost = final_cost + 2*(abs(Xs(aswstosup(j,i))-xw(i)) + abs(Ys(aswstosup(j,i))-yw(i))) * dw(i);
    
end

final_cost=final_cost + 1000*max(aswstosup(j,W));
TP(j,W+1)=final_cost;
end

for p = 1:particles
if td(p,S)>SC %check if the td(S) exceeds the SC
        TP(p,W+1)=inf; % if so, set the column W+3 of n_sol eqaul to "inf"
end
end

for p = 1:particles
 if TP(p,1:W+1) < g_best(1,W+1)
     g_best(1,1:W+1)= TP(p,1:W+1);
 end
  if TP(p,1:W+1) < particles_best(p,W+1)
     particles_best(p,1:W+1)= TP(p,1:W+1);
 end
end
cost_every_iteration=[cost_every_iteration,g_best(1,W+1)];
end

supc=1;
g_aswstosup=zeros(1,W);%initialize the vector for assignment of workstations to supermarket (aswstosup)
g_aswstosup(1,1)=1;%assign the first workstation to the first supermarket
g_td=zeros(1,S);%initialize total demand of each supermarket (td)
g_td(1,1)=dw(1);%set the current td in supermarket 1 equal to the demand of workstation 1
for i=2:W %for each workstation
    if supc<S %if the supc is less than S
        if (g_best(i)<=0.5) && (g_td(supc)+dw(i)<=SC) % if (random key of current workstation is less than preset value of 0.5) and (the td of current supermarket + the demand of considered workstation (dw(i)) are less than SC)
            g_td(supc)=g_td(supc)+dw(i);% update the td of current supermarket  
            g_aswstosup(1,i)=supc; %set the current place in aswstosup(1,i) vector as supc
        else % else if either of the above conditions are not satisfied 
            supc=supc+1; % add to the supc
            g_td(supc)=g_td(supc)+dw(i); % update the td of new supermarket
            g_aswstosup(1,i)=supc; %set the current place in aswstosup(1,i) vector as supc
        end
    else % if this is the last supermarket considering supc
        g_td(supc)=g_td(supc)+dw(i); % update the td of current supermarket 
        g_aswstosup(1,i)=supc; %set the current place in aswstosup(1,i) vector as supc
    end
end


g_best(1,W+1)  % Final cost

g_aswstosup     %assignment

g_td       %supermarket

plot(cost_every_iteration)
xlabel('Iteration')
ylabel('cost')
title('Cost vs Iteration')

