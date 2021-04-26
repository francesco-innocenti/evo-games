%% Spatial Game with Evolutionary Algorithm
% this script is due to Mark (2013) - Evolutionary Pressures on Veridical Perception: When does natural selection favor truth?
% simulates the evolution of actions and perceptions in an foraging game
% with an evolutionary algorithm

%% Set simulation parameters

tic
N_indiv = 200;              % number of individuals or agents per generation
N_moves = 200;              % number of ations/moves per game
N_games = 100;              % number of games played by each agent
N_gen = 600;                % number of generations
N_res = 10;                 % number of resources

Indiv = 1:N_indiv;          % vector with all individuals listed

% create all the possible situations an agent could find itself in
Situations = combinator(3, 5,'p','r')-2;      % each patch has 3 possible states (0=red, 1=green, -1=wall) and ...
                                              % ... each agent "perceives" 5 squares or sites (North, South, East, West, & current site)
                                              % so, all the possible combinations are 3^5 = 243
                                              % note that some of these combinations are impossible (eg all walls)
                                          
                                          
%% Initialise action and perceptual strategies
% 6 possible actions and 2 possible perceptions

% create random actions for every agent
initial_actions = rand(N_indiv,length(Situations));     
initial_actions(initial_actions < 1/7) = 1;             % move North
initial_actions(initial_actions < 2/7) = 2;             % move East
initial_actions(initial_actions < 3/7) = 3;             % move South
initial_actions(initial_actions < 4/7) = 4;             % move West
initial_actions(initial_actions < 6/7) = 5;             % move random
initial_actions(initial_actions < 7/7) = 6;             % pick up something
    
loci = 1:length(Action_genomes);                        % vector with all "genetic loci" listed

% create random two-category (0=red, 1=green) perceptual strategies for all agents
initial_percepts = round(rand(N_indiv,N_res+1)); 


%% Start generation

% pre-allocate fitness across agents and generations
Avg_fitness = zeros(N_gen,1);
Max_fitness = zeros(N_gen,1);                 
fitness = zeros(N_indiv,N_gen);

for generation = 1:N_gen
    
    if (generation == 1) 
        Actions = initial_actions;
        Percepts = initial_percepts;
    end
    
    % pre-allocate total fitness points (rewards & penalties) across all games for every agent
    Total_points = zeros(N_indiv,N_games);  

    for game = 1:N_games
    
    
        %% Create world

        % create random world without walls
        world = floor((N_res+1) * rand(12,12,N_indiv));

        % add walls
        world(1,:,:) = -1;                             
        world(12,:,:) = -1;
        world(:,1,:) = -1;
        world(:,12,:) = -1;

        % define utility function of the resources
        world_util = round(500*normpdf(world,5,2));  

        % dummy matrix for perceptions of the world
        C = zeros(12,12,N_indiv,11);                       

        % compute the perceptions of an agent across all resource values
        for p = 1:11
            C(:,:,:,p) = bsxfun(@times,(world == (p-1)),reshape(Percepts(:,p),1,1,N_indiv));
        end

        % sum across all perceptions to obtain complete world perceptions for each agent
        world_percepts = sum(C,4);                      

        % add walls to the perceptions of the agents
        world_percepts(1,:,:) = -1;                        
        world_percepts(12,:,:) = -1;
        world_percepts(:,1,:) = -1;
        world_percepts(:,12,:) = -1;

        % create copies of world, utility and percepts (to be used later in animations)
        world_copy = world;
        world_util_copy = world_util;
        world_percepts_copy = world_percepts;
    
    
        %% Play game

        situation = zeros(N_indiv,5);      % given situation for every agent
        points = zeros(N_indiv,N_moves);   % points for every move of each agent

        % top left corner as starting location
        start = [2 2];                         

        % starting coordinates for every agent
        location_x = start(1)*ones(N_indiv,1);     % horizontal (column) location of every agent
        location_y = start(2)*ones(N_indiv,1);     % vertical (row) location of every agent

        % position for every agent on every move
        location_x_track = zeros(N_indiv,N_moves); % horizontal location of every agent on every move
        location_y_track = zeros(N_indiv,N_moves); % vertical location of every agent on every move
        
        % record pick ups and actions of every agent
        pick_up_track = zeros(N_indiv,N_moves);
        action_track = zeros(N_indiv,N_moves);

        % action of every agent
        action = zeros(N_indiv,1);

        for move = 1:N_moves

            % track location of every agent for every move
            location_x_track(:,move) = location_x;
            location_y_track(:,move) = location_y;

            % points (reward or penalty) for a given action/move
            reward = zeros(N_indiv,1);             
            reward_1 = reward;                
            reward_2 = reward;                 

            % view world
            % what every agent "perceives" in any given situation
            situation(:,1) = world_percepts(sub2ind(size(world),location_y-1,location_x,Indiv'));   % North
            situation(:,2) = world_percepts(sub2ind(size(world),location_y,location_x+1,Indiv'));   % East
            situation(:,3) = world_percepts(sub2ind(size(world),location_y+1,location_x,Indiv'));   % South
            situation(:,4) = world_percepts(sub2ind(size(world),location_y,location_x-1,Indiv'));   % West
            situation(:,5) = world_percepts(sub2ind(size(world),location_y,location_x,Indiv'));     % current

            % look up action - consult action chromosome
            for i = 1:N_indiv
                 action(i) = find(all(bsxfun(@eq,Situations,situation(i,:))==1,2));
            end
            
            % choose action that matches the situation
            performed_action = Actions(sub2ind(size(Actions),Indiv',action));

            % outcome of moving randomly (performed action = 5)
            rnd_move = randsample(4,length(Indiv(performed_action == 5)),true);    % randomly sample with replacement from moves 1 - 4 (N,S,E,W)
            performed_action(performed_action == 5) = rnd_move;                    % if chromosome says action 5, then see random move (do above line)
            action_track(:,move) = performed_action;

            % outcome for picking up (performed action = 6)
            pickUp_ind = sub2ind(size(world),location_y(performed_action == 6),location_x(performed_action == 6),Indiv(performed_action == 6)');
            reward(performed_action == 6) = world_util(pickUp_ind) - 1;
            
            % update world, utility, and percepts
            world(pickUp_ind) = 0;
            world_util(pickUp_ind) = 0;
            world_percepts(pickUp_ind) = Percepts(sub2ind(size(Percepts),Indiv(performed_action==6)',ones(length(Indiv(performed_action==6)),1)));

            % update location of every agent
            location_y(performed_action == 1) = location_y(performed_action == 1) - 1;
            location_y(performed_action == 3) = location_y(performed_action == 3) + 1;
            location_x(performed_action == 2) = location_x(performed_action == 2) + 1;
            location_x(performed_action == 4) = location_x(performed_action == 4) - 1; 

            % apply penalty for running into a wall
            reward(location_y == 1 | location_y == 12) = -5;
            reward(location_x == 1 | location_x == 12) = -5;

            % remove agents from within walls
            location_y(location_y == 1) = 2;
            location_y(location_y == 12) = 11;
            location_x(location_x == 1) = 2;
            location_x(location_x == 12) = 11;

            % record pick ups
            pick_up_track(:,move) = (performed_action == 6);

            % points of every move of any agent
            points(:,move) = reward;
            
        end % concludes move
        
        % compute total points for every game across the moves of every agent
        Total_points(:,game) = sum(points,2);

    end % concludes game
    
    % compute fitness measures
    fitness(:,generation) = mean(Total_points,2);
    Avg_fitness(generation) = mean(fitness(:,generation));
    [Max_fitness(generation),id] = max(fitness(:,generation));
    Progress = [generation max(fitness(:,generation)) mean(fitness(:,generation))]
    
   
    %% Selection

    % ensure positive fitness weights for weighted sample
    if (min(fitness(:,generation)) < 0)
        weights = fitness(:,generation) - min(fitness(:,generation)) + 1;           
    elseif (min(fitness(:,generation)) == 0)
        weights = fitness(:,generation) + 1;
    else
        weights = fitness(:,generation);
    end
    
    % select parents (ie fit agents) for next generation
    if (rand > .9)
        possible_parents = Indiv';
        new_weights = weights;
    else
        possible_parents = Indiv(fitness(:,generation)>=mean(fitness(:,generation)))';
        new_weights = weights(fitness(:,generation)>=mean(fitness(:,generation)));
    end

    test = sortrows([possible_parents new_weights],2);
    parents_sample = randsample(length(possible_parents),N_indiv,true,test(:,2));
    parents = test(sub2ind(size(test),parents_sample,ones(N_indiv,1)));


%% Recombination (1-point crossover)
    
    % replication of actions   
    parent_1A = Actions(parents(1:(N_indiv/2)),:);              
    parent_2A = Actions(parents(1+(N_indiv/2):end),:);
    
    % cut action chromosome of each parent
    cut = randsample(length(Situations)-1,N_indiv/2,true);            
    cut_1 = bsxfun(@ge,loci,cut);
    cut_2 = bsxfun(@lt,loci,cut);
    
    child_1A = parent_1A.*cut_1 + parent_2A.*cut_2;
    child_2A = parent_1A.*cut_2 + parent_2A.*cut_1;
    
    Actions = [child_1A; child_2A];
    
    % replication of perceptions
    parent_1P = Percepts(parents(1:(N_indiv/2)),:);        
    parent_2P = Percepts(parents(1+(N_indiv/2):end),:);
    
    % cut perceptual chromosome of each parent
    cut_P = randsample(N_res,N_indiv/2,true);                 
    cut_1P = bsxfun(@ge,1:11,cut_P);
    cut_2P = bsxfun(@lt,1:11,cut_P);
    
    child_1P = parent_1P.*cut_1P + parent_2P.*cut_2P;
    child_2P = parent_1P.*cut_2P + parent_2P.*cut_1P;
    
    Percepts = [child_1P; child_2P];
    
    
%% Mutation
 
    % variation in child's actions
    num_genes = ceil(.01*length(Situations)*N_indiv*rand);     
    genes = randsample(length(Situations),num_genes,true);     
    mutants = randsample(N_indiv,num_genes,true);         
    new_genes = randsample(6,length(genes),true);        
    mut_ind = sub2ind(size(Actions),mutants,genes);     
    
    % replace current actions with new mutated actions
    Actions(mut_ind) = new_genes;                        
    
    % variation in child's perceptions
    num_genes_P = ceil(.01*N_res*N_indiv*rand);               
    genes_P = randsample(N_res+1,num_genes_P,true);            
    mutants_P = randsample(N_indiv,num_genes_P,true);           
    new_genes_P = round(rand(length(genes_P),1));              
    mut_ind_P = sub2ind(size(Percepts),mutants_P,genes_P);      
    
    % replace current perceptions with new mutated perceptions
    Percepts(mut_ind_P) = new_genes_P;                          
    
end


%% Create video animations

% get information for the best agent (maximum fitness) 
best_world = world_copy(:,:,id);
best_world_util = world_util_copy(:,:,id);
best_world_percept = world_percepts_copy(:,:,id);
best_loc_x = location_x_track(id,:);
best_loc_y = location_y_track(id,:);

locate = combinator(11, 2,'p','r'); 
locate(:,3) = best_world_util(sub2ind(size(best_world),locate(:,1),locate(:,2)));

% create movie of the best agent's game superimposed on the world's utility
v = VideoWriter('Best_Agent_Utility.avi');                         
open(v);
for j = 1:1:N_moves
    if (pick_up_track(id,j) == 1)
        best_world_util(best_loc_y(j),best_loc_x(j)) = 0;
        best_world_percept(best_loc_y(j),best_loc_x(j)) = 0;
         locate(:,3) = best_world_util(sub2ind(size(best_world),locate(:,1),locate(:,2)));
    end
    figure(1)
    title('Utility', 'FontSize', 20);
    axis([1 11 1 11])
    hold on
    colormap(flipud(summer))
    pcolor(1:11,1:11,best_world_util(2:12,2:12))
    plot(best_loc_x(1:j)-.5,best_loc_y(1:j)-.5,'LineWidth',2,'Color',[1 1 1])
    best_frame(j) = getframe;                       
    writeVideo(v,best_frame(j));           
end
hold off

% create movie of the best agent's game superimposed on its percepts
v = VideoWriter('Best_Agent_Percepts.avi');                        
open(v);
for j = 1:1:N_moves
    if (pick_up_track(id,j) == 1)
        best_world_util(best_loc_y(j),best_loc_x(j)) = 0;
        best_world_percept(best_loc_y(j),best_loc_x(j)) = 0;
         locate(:,3) = best_world_util(sub2ind(size(best_world),locate(:,1),locate(:,2)));
    end
    figure(1)
    title('Percepts', 'FontSize', 20);
    axis([1 11 1 11])
    hold on
    redgreen_cmap = [0.9 0.2 0.2;   
                     0.9 0.2 0.2;
                     0.2 0.9 0.2];
    colormap(redgreen_cmap)
    pcolor(1:11,1:11,best_world_percept(2:12,2:12))                                   
    plot(best_loc_x(1:j)-.5,best_loc_y(1:j)-.5,'LineWidth',2,'Color',[1 1 1]) 
    best_frame(j) = getframe;                   
    writeVideo(v,best_frame(j));                       
end
hold off

% movie without superimposed map
v = VideoWriter('Best_Agent_Game.avi');                      
open(v);                                            
hold on
axis([1 11 1 11])                                     
grid on                                              
for j = 1:1:N_moves                                
    plot(best_loc_x(1:j)-.5,best_loc_y(1:j)-.5,'LineWidth',2)      
    best_frame(j) = getframe;                         
    writeVideo(v,best_frame(j));                        
end
hold off

toc
time = toc/60