%SA_SLP
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
no_of_interation = 0;
%======================set SA parameters===================================
T0=1000; %set the initial temperature (T0)
Tf=1; %set the final temperature (Tf)
T=T0; %set the current temperature equal to T0
it=[];
storetemp=[];
solutioneveryinteration=[];
work_station_periteration=[];
reset_threshold = 1e-100;
reset_value_tau = 0.05;
tau = reset_value_tau ;
%=========================initial solution generation======================
sol=zeros(1,W+3); %sol is the solution representation vector;
%columns 1-W represent the random key assigned to each worstation index
%columns W+1 represent the shipment cost
%column  W+2 represent the installation cost
%column  W+3 represent the total cost
%set the initial solution
sol(1:W)=rand(1,W);

%Decoding the generated intitial soution:
supc=1; %initialize supermarket counter (supc)
aswstosup=zeros(1,W);%initialize the vector for assignment of workstations to supermarket (aswstosup)
aswstosup(1,1)=1;%assign the first workstation to the first supermarket
td=zeros(1,S);%initialize total demand of each supermarket (td)
td(1,1)=dw(1);%set the current td in supermarket 1 equal to the demand of workstation 1
for i=2:W %for each workstation
    if supc<S %if the supc is less than S
        if (sol(i)<=0.65) && (td(supc)+dw(i)<=SC) % if (random key of current workstation is less than preset value of 0.5) and (the td of current supermarket + the demand of considered workstation (dw(i)) are less than SC)
            td(supc)=td(supc)+dw(i);% update the td of current supermarket  
            aswstosup(1,i)=supc; %set the current place in aswstosup(1,i) vector as supc
        else % else if either of the above conditions are not satisfied 
            supc=supc+1; % add to the supc
            td(supc)=td(supc)+dw(i); % update the td of new supermarket
            aswstosup(1,i)=supc; %set the current place in aswstosup(1,i) vector as supc
        end
    else % if this is the last supermarket considering supc
        td(supc)=td(supc)+dw(i); % update the td of current supermarket 
        aswstosup(1,i)=supc; %set the current place in aswstosup(1,i) vector as supc
    end
end

%=====================fitness function evaluation==========================
%1)calculate the shipment cost:
shipc=zeros(1,S); %initialize the shipment cost (shipc) vector for the potential supermarket (S)
for i=1:S % for each supermarket 
    for j=1:W % for each workstation 
        if aswstosup(1,j)==i % check if the current workstation is assigned to the considered supermarket
            shipc(i)=shipc(i)+SUC*dw(j)*2*(abs(Xs(i)-xw(j))+abs(Ys(i)-yw(j))); % calculate the shipment cost for current supermarket 
        end
    end
end
sol(1,W+1)=sum(shipc); % update the column sol(1,W+1) as the total shipment costs 
%2)calculate the installation cost:
instc=SIC*max(aswstosup(1,:)); %calculate the total installation costs considering the maximum number of established supermarkets
sol(1,W+2)=instc; % update the column sol(1,W+2) as the total installation costs
%3)calculate the total cost:
sol(1,W+3)=sol(1,W+1)+sol(1,W+2);%update the total cost (TC) in sol(1,W+3)

%5)Allow a penalty function of "inf" in total cost column if the total demand (td) of the last supermarket exceeds the supermarket capacity (SC)
if td(S)>SC %check if the td(S) exceeds the SC
    sol(1,W+3)=inf; % if so, set the column W+3 of sol eqaul to "inf"
end

%===========================Main body of SA================================
while T>=Tf %while the current T is geater than Tf

    no_of_interation= no_of_interation + 1;
    iter=0;
    
    while iter<50
    iter = iter+1;
    n_sol=sol; %initialize the new sol (n_sol) vector by setting it as sol
    %=========================Generate a new solution======================
    %Neighborhood search operator:
    %select a random position on current solution:
    pos=randi([2,W]);%select a random point between 2 to W
    %generate a new value for the selected postion
    n_sol(1,pos)=rand;% update the n_sol in the randomly selected position
  

    %Decoding the new generated intitial soution:
    supc=1; %initialize supermarket counter (supc)
    n_aswstosup=zeros(1,W);%initialize the new vector for assignment of workstations to supermarket (aswstosup)
    n_aswstosup(1,1)=1;%assign the first workstation to the first supermarket
    td=zeros(1,S);%initialize total demand of each supermarket (td)
    td(1,1)=dw(1);%set the current td in supermarket 1 equal to the demand of workstation 1
    %stc=0; %initialize station counter (stc)
    for i=2:W %for each workstation
        if supc<S %if the supc is less than S
            if (n_sol(i)<=0.6) && (td(supc)+dw(i)<=SC) % if (random key of current workstation is less than preset value of 0.5) and (the td of current supermarket + the demand of considered workstation (dw(i)) are less than SC)
                td(supc)=td(supc)+dw(i);% update the td of current supermarket 
                n_aswstosup(1,i)=supc; %set the current place in n_aswstosup(1,i) vector as supc
            else % else if either of the above conditions are not satisfied 
                supc=supc+1; % add to the supc
                td(supc)=td(supc)+dw(i); % update the td of new supermarket
                n_aswstosup(1,i)=supc; %set the current place in n_aswstosup(1,i) vector as supc
            end
        else % if this is the last supermarket considering supc
            td(supc)=td(supc)+dw(i); % update the td of current supermarket 
            n_aswstosup(1,i)=supc; %set the current place in aswstosup(1,i) vector as supc
        end
    end
               % Mutation operation (reverse)
        
               if rand() < 0.1
    % Select a random segment to reverse
    start_pos = randi(length(n_aswstosup));
    end_pos = randi(length(n_aswstosup));
    if end_pos < start_pos
        temp = start_pos;
        start_pos = end_pos;
        end_pos = temp;
    end

    % Reverse the selected segment
    n_aswstosup(start_pos:end_pos) = flip(n_aswstosup(start_pos:end_pos));
   % n_sol(start_pos:end_pos) = flip(n_sol(start_pos:end_pos));
        end


   


    %=====================fitness function evaluation==========================
    %1)calculate the shipment cost:
    shipc=zeros(1,S); %initialize the shipment cost (shipc) vector for the potential supermarket (S)
    for i=1:S % for each supermarket
        for j=1:W % for each workstation 
            if n_aswstosup(1,j)==i % check if the current workstation is assigned to the considered supermarket
                shipc(i)=shipc(i)+SUC*dw(j)*2*(abs(Xs(i)-xw(j))+abs(Ys(i)-yw(j))); % calculate the shipment cost for current supermarket 
            end
        end
    end
    n_sol(1,W+1)=sum(shipc); % update the column n_sol(1,W+1) as the total shipment costs 
    %2)calculate the installation cost:
    instc=SIC*max(n_aswstosup(1,:)); %calculate the total installation costs considering the maximum number of established supermarkets
    n_sol(1,W+2)=instc; % update the column n_sol(1,W+2) as the total installation costs
    %3)calculate the total cost:
    n_sol(1,W+3)=n_sol(1,W+1)+n_sol(1,W+2);%update the total cost (TC) in n_sol(1,W+3)

    %5)Allow a penalty function of "inf" in total cost column if the total demand (td) of the last supermarket exceeds the supermarket capacity (SC)
    if td(S)>SC %check if the td(S) exceeds the SC
        n_sol(1,W+3)=inf; % if so, set the column W+3 of n_sol eqaul to "inf"
    end

    %=============Check if n_sol is better than sol?=======================
    R=rand; % generate a random number R
    if n_sol(W+3) <= sol(W+3) % if fitness function of n_sol is better than sol
        sol=n_sol; % set the n_sol as the current solution
        aswstosup=n_aswstosup; % also set the n_aswstosu vector as for the current solution
    elseif max(n_aswstosup) < max(aswstosup)
         sol=n_sol; % set the n_sol as the current solution
        aswstosup=n_aswstosup; % also set the n_aswstosu vector as for the current solution


    elseif R < exp(-(n_sol(W+3)-sol(W+3))/T) % else investigate whether R < acceptance probability calculate by : exp(-(n_sol(W+3)-sol(W+3))/T)
        sol=n_sol; % if yes, accept n_sol as the current solution
        aswstosup=n_aswstosup; %also set the n_aswstosu vector as for the current solution
    end
    end
    cost_inter=0;
    for i = 1:length(aswstosup)
    cost_inter= cost_inter + 2*(abs(Xs(aswstosup(i))-xw(i)) + abs(Ys(aswstosup(i))-yw(i))) * dw(i);
    end
    tau = tau * tau;
    
    % Check if τ is very close to zero
    
   
    cost_inter=cost_inter+ 1000*max(aswstosup);
    solutioneveryinteration=[solutioneveryinteration,cost_inter]; 
    no_of_workstationattheineration = max(aswstosup);
    work_station_periteration=[work_station_periteration,no_of_workstationattheineration];
    %update temperature
    alpha=   0.99 ;
    beta = 3;
    t = no_of_interation;
    T = T0*alpha^no_of_interation; %Alpha=0.95
    it=[it,no_of_interation];
    storetemp = [storetemp,T];
      


end
% Add axis labels and title
plot(it,storetemp,'b-')
xlabel('Iteration');
ylabel('Temperature');
title('Temperature vs Iteration')

figure
plot(it,solutioneveryinteration,'r-')
xlabel('Iteration');
ylabel('Cost');
title('cost vs Iteration')

figure
plot(it,work_station_periteration,'r-')
xlabel('Iteration');
ylabel('SuperMarkets');
title('superMarkers vs Iteration')

sol %report the best found solution
aswstosup %report the best found solution's aswstosu matrix
final_cost= 0;
for i = 1:length(aswstosup)
    final_cost = final_cost + 2*(abs(Xs(aswstosup(i))-xw(i)) + abs(Ys(aswstosup(i))-yw(i))) * dw(i);
end
final_cost=final_cost + 1000*max(aswstosup)
no_of_workstation = max(aswstosup)
T
no_of_interation
no_of_workstation



































