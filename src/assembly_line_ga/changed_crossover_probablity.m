%GA code for Solving SALBP-1
clc
clear
%=================================Problem input============================

%Problem 1:
CT=61;
n=35;
PR=[0	1	0	0	1	0	1	0	0	1	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	1	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	1	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	1	0	0	0	0	1	0	1	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	1	1	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
];
t= [29
3
5
22
8
14
2
5
22
30
23
30
23
2
19
29
2
2
19
29
6
10
16
23
5
5
5
40
2
5
5
1
40
2
2];

%=================================GA parameters============================
popsize=100; % population size
r_cr=0.5; % crossover rate
n_cr=popsize*r_cr; % number of solutions/chromosomes selected for crossover 
r_mu=0.1; % mutation rate
n_mu=popsize*r_mu; % number of solutions/chromosomes selected for mutation
r_el=0.1; % Elitism rate
n_el=popsize*r_el; % Number of solutions/chromosomes copied to the next generation as Elites
G=0; % initialize the generation counter (G)
Max_G=500; % set the maximum generation (Max_G) as the stopping condition/criteria 

%===================generate a random population===========================
TP=zeros(popsize,n+1); % Initilaize the task priority (TP) matrix with size : popsize*n+1, where column n+1 will be updated as the fitness function later
for i=1:popsize 
    TP(i,1:n)=rand(1,n); % each row of TP is a random-key number between (0,1) 
end

%=================================Encoding=================================
TS=zeros(popsize,n+1); % initialize the task sequence (TS) matrix with size : popsize*n+1, where column n+1 will be updated as the fitness function later 
for i=1:popsize % for each row of TP do:
    PR2=PR; % make  a copy of prededence relationships (PR) matrix since we want to update it for selecting tasks
    tac=1; % initialize the task counter (tac)
    while tac<=n % while tac <= nunber of tasks (n)
        %==============find a candidate list of tasks (clt)===================
        prsum=sum(PR2,1); % sum the PR2 in columns
        clt=find(prsum==0); % find clt as those tasks with zero prsum 
        %============select task with the highest priority=================
        maxup=0; % initialize the maximum update scalar (maxup)  
        for j=1:size(clt,2) % for the size of clt 
            if TP(i,clt(j))>maxup % if TP related to j-th elemet of clt is greater than maxup 
                maxup=TP(i,clt(j)); % update maxup
                slt=clt(j); % set selected task (slt) in clt with the highest priority
            end
        end
        TS(i,tac)=slt; % insert slt in tac-th position of TS 
        tac=tac+1; % update tac (go to the next task)
        PR2(slt,:)=0; % update PR2 for successor tasks (put zeros on all rows of slt)
        PR2(:,slt)=1; % update PR2 for the current task not to be selected again (put ones on all columns of slt)
    end
end

%=================================Decoding=================================
AsTaSt=zeros(popsize,n+1); % assignment of tasks to stations by determining the station index where each task has been assigned
for i=1:popsize
    stc=1; % initizlize station counter (stc)
    tac=1; % initialize task counter (tac)
    tt=0; % initialize the totol time (tt) of each station
    while tac<=n % repeat while loop until tac is less than equal to number of tasks (n)
        if tt+t(TS(i,tac))<=CT % if total time (tt) of current station + plus the time (t) of task in index tac of TS is less than the cycle time 
            AsTaSt(i,tac)=stc; % update the assignment of task to station (AsTaSt) matrix by setting its tac th element equal to stc    
            tt=tt+t(TS(i,tac)); % update the tt 
            tac=tac+1; % update tac
        else
            stc=stc+1; % open a new station
            tt=0; % initialize tt 
           
        end
    end
end

%===========================fitness function===============================
%set the fitness function (ff) of each solution equal to the last column of AsTaSt
for i=1:popsize
    TP(i,n+1)=AsTaSt(i,n); % set TP in cloumn n+1 equal to the last column of AsTaSt
    TS(i,n+1)=AsTaSt(i,n); % set TS in cloumn n+1 equal to the last column of AsTaSt
    AsTaSt(i,n+1)=AsTaSt(i,n); % set AsTaSt in cloumn n+1 equal to the last column of AsTaSt
end

%==============================main body of GA=============================
n_TP=zeros(popsize,n+1);%n_TP = next population of TP

while G<=Max_G % while the stopping condition is met (G <= Max_G)
    G=G+1; % update G
    %========================crossover operator============================
    for i=1:2:n_cr % do crossover n_cr times with 2 incrementals or steps
        %========================select two parents========================
        par1=randi(popsize,1,1); % select parent 1 (par1) randomly  
        par2=randi(popsize,1,1); % select parent 2 (par2) randomly
        while par1==par2 % repeat while if par1 equals to par2 
            par1=randi(popsize,1,1);
            par2=randi(popsize,1,1);
        end
        %========================select two positions======================
        pos1=randi(n,1,1); % select the first position (pos1) randomly on both parent  
        pos2=randi(n,1,1); % select the second position (pos2) randomly on both parent  
        while pos1>=pos2 % repeat while if pos1 is >= pos2 
            pos1=randi(n,1,1);
            pos2=randi(n,1,1);
        end
        %=======================Reverse the orders in each sub-vector==============
        v1=flip(TP(par1,pos1:pos2),2); % reverse orders in parent one (row flip) 
        v2=flip(TP(par2,pos1:pos2),2); % reverse orders in parent two (row flip)
        
        %initiate the new tasks priorities (n_TP)
        n_TP(round(i),1:n)=TP(par1,1:n);
        n_TP(round(i+1),1:n)=TP(par2,1:n);
        
        %update the n_TP by the reverse order crossover operator 
        n_TP(round(i),pos1:pos2)=v1; % set offspring 1  
        n_TP(round(i+1),pos1:pos2)=v2; % set offspring 2
    end

    %========================mutation operator=============================
    for i=n_cr+1 : n_cr+n_mu% do mutation n_mu times 
        par1=randi(popsize,1,1); % select a parent (par1) randomly
        pos1=randi(n,1,1); % select a random position (pos1)
        pos2=randi(n,1,1); % select a random position (pos2)
        while pos1==pos2 % repeat while if pos1=pos2
            pos1=randi(n,1,1);
            pos2=randi(n,1,1);
        end
        v1=zeros(1,n);%initialize the set v1 to copy task proprities (TP) of par1  
        v1=TP(par1,:);% set v1 as TP related to par1
        sc=v1(pos1); % save the value in pos1 of v1 as a scalar (sc)
        v1(pos1)=v1(pos2); % change the value (priority) in pos1 to value in pos2
        v1(pos2)=sc; % change the priority in pos2 equal to sc
        n_TP(round(i),1:n)=v1(1:n); %update the n_TP by setting it to new solution found by mutation 
    end

    %==========================elitism operator============================
    sortTP=sortrows(TP,n+1);% sort the previous TP based on the column n+1 i.e., fitness functions  
    for i=n_cr+n_mu+1 : popsize % do elitism n_el times (popsize - n_cr - n_mu) 
        n_TP(i,1:n)=sortTP(i-n_cr-n_mu,1:n); % update the n_TP by copyong the best rows in sortTP
    end

    %=================================Encoding=============================
    n_TS=zeros(popsize,n+1); % initialize the new task sequence (n_TS) matrix with size : popsize*n+1, where column n+1 will be updated as the fitness function later
    for i=1:popsize % for each row of n_TP do:
        PR2=PR; % make  a copy of prededence relationships (PR) matrix since we want to update it for selecting tasks
        tac=1; % initialize the task counter (tac)
        while tac<=n % while tac <= nunber of tasks (n)
            %==============find a candid list of tasks (clt)===============
            prsum=sum(PR2,1); % sum the PR2 in columns
            clt=find(prsum==0); % find clt as those tasks with zero prsum 
            %============select task with the highest priority=============
            maxup=0; % initialize the maximum update scalar (maxup)  
            for j=1:size(clt,2) % for the size of clt
                if n_TP(i,clt(j))>maxup % if n_TP related to j-th elemet of clt is greater than maxup 
                    maxup=n_TP(i,clt(j)); % update maxup
                    slt=clt(j); % set selected task (slt) in clt with the highest priority
                end
            end
            n_TS(i,tac)=slt; % insert slt in tac-th position of n_TS 
            tac=tac+1; % update tac (go to the next task)
            PR2(slt,:)=0; % update PR2 for successor tasks (put zeros on all rows of slt)
            PR2(:,slt)=1; % update PR2 for the current task not to be selected again (put ones on all columns of slt)
        end
    end

    %=================================Decoding=============================
    n_AsTaSt=zeros(popsize,n+1); % assignment of tasks to stations by determining the station index where each task has been assigned
    for i=1:popsize
        stc=1; % initizlize station counter (stc)
        tac=1; % initialize task counter (tac)
        tt=0; % initialize the totol time (tt) of each station
        while tac<=n % repeat while loop until tac is less than equal to number of tasks (n)
            if tt+t(n_TS(i,tac),1)<=CT % if total time (tt) of current station + plus the time (t) of task in index tac of n_TS is less than the cycle time 
                n_AsTaSt(i,tac)=stc; % update the new assignment of task to station (n_AsTaSt) matrix by setting its tac th element equal to stc    
                tt=tt+t(n_TS(i,tac),1); % update the tt
                tac=tac+1;  % update tac
            else
                stc=stc+1; % open a new station
                tt=0; % initialize tt
            end
        end
    end

    %===========================fitness function===========================
    %set the fitness function (ff) of each solution equal to the last column of n_AsTaSt    
    for i=1:popsize
        n_TP(i,n+1)=n_AsTaSt(i,n); % set TP in cloumn n+1 equal to the last column of n_AsTaSt
        n_TS(i,n+1)=n_AsTaSt(i,n); % set TS in cloumn n+1 equal to the last column of n_AsTaSt
        n_AsTaSt(i,n+1)=n_AsTaSt(i,n); % set AsTaSt in cloumn n+1 equal to the last column of n_AsTaSt
    end
    
    %===============current generation=new generation======================
    TP=n_TP;% set the new TP as the current TP 

end

finalTP=sortrows(n_TP,n+1)%report the finalTP sorted by column n+1  
finalTS=sortrows(n_TS,n+1)%report the finalTS sorted by column n+1 
finalAsTaSt=sortrows(n_AsTaSt,n+1)%report the finalAsTaSt sorted by column n+1 































