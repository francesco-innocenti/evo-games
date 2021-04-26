%% Multipanel figure with worlds of varying spatial clustering of resources
% this script creates a figure with 5 different types of world
% to test in evolutionary game simulations
  % world with one cluster of high resources        (mean distance ~= 3)
  % world with two *close* clusters of resources    (md ~= 4)
  % world with four *close* resource clusters       (md ~= 5)
  % world with randomly distributed clusters        (md ~= 6)
  % world with four *distant* clusters              (md ~= 7)
  % world with two *distant* clusters               (md ~= 8)

 
%% Compute the adjancency matrix of a 10x10 square lattice 

% define number of lattice nodes (dimension)
n = 10;      

% initialise adjacency matrix of 10x10 lattice
adj_lattice = zeros(n^2, n^2);

% the adjacency matrix of this can be computed with 5 separate for loops
  % for (node) k = 1
    % then do conditions for k + 1 and k + n (don't do k - 1 and k - n)
  % for k == 2:10 
    % then do all conditions except k - n
  % for k == 91-99 
    % then do all conditions except k + n
  % for k == 100 
    % then do conditions k - 1 and k - n (don't do k + 1 and k + n)
  % for all other nodes k
    % do all the conditions

% for first node k
for k = 1
    % if k divided by n is an integer
    if floor(k/n) == k/n
        % then node k is *not* adjacent (= 0) to node k + 1
        adj_lattice(k, k + 1) = 0;
    else
        adj_lattice(k, k + 1) = 1;
    end
    % if k + n is greater than n squared
    if k + n > n^2 
        % then node k is *not* adjacent to node k + n
        adj_lattice(k, k + n) = 0;
    else
        adj_lattice(k, k + n) = 1;
    end
end

% for nodes 2 to 10
for k = 2:10
    % if k divided by n is an integer
    if floor(k/n) == k/n
        % then node k is *not* adjacent (= 0) to node k + 1
        adj_lattice(k, k + 1) = 0;
    else
        adj_lattice(k, k + 1) = 1;
    end
    % if k - 1 divided by n is an integer
    if floor((k - 1)/n) == (k - 1)/n
        % then node k is *not* adjacent to node k - 1
        adj_lattice(k, k - 1) = 0;
    else
        adj_lattice (k, k - 1) = 1;
    end
    % if k + n is greater than n squared
    if k + n > n^2 
        % then node k is *not* adjacent to node k + n
        adj_lattice(k, k + n) = 0;
    else
        adj_lattice(k, k + n) = 1;
    end
end
    
% for nodes 91 to 99
for k = 91:99
    % if k divided by n is an integer
    if floor(k/n) == k/n
        % then node k is *not* adjacent (= 0) to node k + 1
        adj_lattice(k, k + 1) = 0;
    else
        adj_lattice(k, k + 1) = 1;
    end
    % if k - 1 divided by n is an integer
    if floor((k - 1)/n) == (k - 1)/n
        % then node k is *not* adjacent to node k - 1
        adj_lattice(k, k - 1) = 0;
    else
        adj_lattice (k, k - 1) = 1;
    end
    % if k - n is less than or equal to 0
    if k - n <= 0
        % then node k is *not* adjacent to node k - n
        adj_lattice(k, k - n) = 0;
    else
        adj_lattice(k, k - n) = 1;
    end
end

% for node 100
for k = 100
    % if k - 1 divided by n is an integer
    if floor((k - 1)/n) == (k - 1)/n
        % then node k is *not* adjacent to node k - 1
        adj_lattice(k, k - 1) = 0;
    else
        adj_lattice (k, k - 1) = 1;
    end
    % if k - n is less than or equal to 0
    if k - n <= 0
        % then node k is *not* adjacent to node k - n
        adj_lattice(k, k - n) = 0;
    else
        adj_lattice(k, k - n) = 1;
    end  
end

% for nodes 11 to 90
for k = 11:90
    % if k divided by n is an integer
    if floor(k/n) == k/n
        % then node k is *not* adjacent (= 0) to node k + 1
        adj_lattice(k, k + 1) = 0;
    else
        adj_lattice(k, k + 1) = 1;
    end
    % if k - 1 divided by n is an integer
    if floor((k - 1)/n) == (k - 1)/n
        % then node k is *not* adjacent to node k - 1
        adj_lattice(k, k - 1) = 0;
    else
        adj_lattice (k, k - 1) = 1;
    end
    % if k + n is greater than n squared
    if k + n > n^2 
        % then node k is *not* adjacent to node k + n
        adj_lattice(k, k + n) = 0;
    else
        adj_lattice(k, k + n) = 1;
    end
    % if k - n is less than or equal to 0
    if k - n <= 0
        % then node k is *not* adjacent to node k - n
        adj_lattice(k, k - n) = 0;
    else
        adj_lattice(k, k - n) = 1;
    end
end


%% World with one resource cluster
% mean distance ~=3

% define low and high resource values (for other worlds too)
low_res = 6;
high_res = [7, 8, 9, 10];

% create random world without walls
one_cluster_world = floor((low_res+1) * rand(10,10));

% assign high resource values (7-10) to specific spots at random
for i = 3:7
    for j = 3:7
    one_cluster_world(i,j) = randsample(high_res,1);
    end
end

world_as_vector1 = one_cluster_world(:);   % to feed to nodes' size
    
% create graph/network from adjacency matrix
network1 = graph(adj_lattice,'omitselfloops');

% code resource quantity as size of nodes
network1.Nodes.Size = [world_as_vector1];
    
% find indices of nodes with resource values 7-10 
high_res_nodes = find(network1.Nodes.Size == 7 | network1.Nodes.Size == 8 | network1.Nodes.Size == 9| network1.Nodes.Size == 10);

% compute mean shortest path distance of all these node pairs (serving both
% as sources and targets)
shortest_paths1 = distances(network1, high_res_nodes, high_res_nodes);
mean_distance1 = mean(shortest_paths1, 'all');

% create subplot heatmap of resources on this world
subplot(2,3,1)
onecluster_heatmap = heatmap(one_cluster_world, 'Title', '{\it D} \approx 3', 'FontSize', 12,'CellLabelColor','none');
onecluster_heatmap.GridVisible = 'off';                               % get rid of grid lines
onecluster_heatmap.XDisplayLabels = {'','','','','','','','','',''};  % remove number x ticks
onecluster_heatmap.YDisplayLabels = {'','','','','','','','','',''};  % remove number y ticks


%% World with 2 close resource clusters
% mean distance ~=4

% create two-resource-cluster world without walls
twocluster_world = floor((low_res+1) * rand(10,10));

for i = [3:5, 6:8]
    for j = [2:4, 6:8]
    twocluster_world(i,j) = randsample(high_res,1);
    end
end

world_as_vector2 = twocluster_world(:);   % to feed to nodes' size
    
% create graph/network from adjacency matrix
network2 = graph(adj_lattice,'omitselfloops');

% code resource quantity as size of nodes
network2.Nodes.Size = [world_as_vector2];
    
% find indices of nodes with resource values 8-10 
high_res_nodes = find(network2.Nodes.Size == 7 | network2.Nodes.Size == 8 | network2.Nodes.Size == 9| network2.Nodes.Size == 10);

% compute mean shortest path distance of all these node pairs (serving both
% as sources and targets)
shortest_paths2 = distances(network2, high_res_nodes, high_res_nodes);
mean_distance2 = mean(shortest_paths2, 'all');

% create subplot heatmap of resources on this world
subplot(2,3,2)
twocluster_heatmap = heatmap(twocluster_world, 'Title', '{\it D} \approx 4','FontSize', 12,'CellLabelColor','none');
twocluster_heatmap.GridVisible = 'off';                               % get rid of grid lines
twocluster_heatmap.XDisplayLabels = {'','','','','','','','','',''};  % remove number x ticks
twocluster_heatmap.YDisplayLabels = {'','','','','','','','','',''};  % remove number y ticks


%% World with 4 close resource clusters
% mean distance ~=5

% create example world without walls
fourcluster_world = floor((low_res+1)*rand(10,10));

% assign high resource values (8-10) from specific spots at random
high_res = [7, 8, 9, 10];

for i = [3:5, 7:9]
    for j = [2:4, 7:9]
    fourcluster_world(i,j) = randsample(high_res,1);
    end
end

world_as_vector3 = fourcluster_world(:);   % to feed to nodes' size

% create graph/network from adjacency matrix
network3 = graph(adj_lattice,'omitselfloops');

% code resource quantity as size of nodes
network3.Nodes.Size = [world_as_vector3];

% find indices of nodes with resource values 8-10 
high_res_nodes = find(network3.Nodes.Size == 7 | network3.Nodes.Size == 8 | network3.Nodes.Size == 9| network3.Nodes.Size == 10);

% compute mean shortest path distance of all these node pairs (serving both as
% sources and targets)
shortest_paths3 = distances(network3, high_res_nodes, high_res_nodes);
mean_distance3 = mean(shortest_paths3, 'all');

% create heatmap
subplot(2,3,3)
fourcluster_heatmap = heatmap(fourcluster_world, 'Title', '{\it D} \approx 5','FontSize', 12,'CellLabelColor','none');
fourcluster_heatmap.GridVisible = 'off';                               % get rid of grid lines
fourcluster_heatmap.XDisplayLabels = {'','','','','','','','','',''};  % remove number x ticks
fourcluster_heatmap.YDisplayLabels = {'','','','','','','','','',''};  % remove number y ticks


%% World with randomly distributed resources
% mean distance ~=6

% define total number of resources for random world
N_res = 10;

% create random world without walls
random_world = floor((N_res+1) * rand(10,10));

% encode world resources in a vector to feed to nodes' size
world_as_vector4 = random_world(:);  

% create graph/network from adjacency matrix
network4 = graph(adj_lattice,'omitselfloops');

% code resource quantity as size of nodes
network4.Nodes.Size = [world_as_vector4];

% find indices of nodes with high resource values (ie 7-10) 
high_res_nodes = find(network4.Nodes.Size == 7 | network4.Nodes.Size == 8 | network4.Nodes.Size == 9 | network4.Nodes.Size == 10);

% compute mean shortest path distances of all these node pairs (serving both as
% sources and targets)
shortest_paths4 = distances(network4, high_res_nodes, high_res_nodes);
mean_distance4 = mean(shortest_paths4, 'all');

% create subplot heatmap of resources on this world
subplot(2,3,4)
random_heatmap = heatmap(random_world, 'Title', '{\it D} \approx 6','FontSize', 12,'CellLabelColor','none');
random_heatmap.GridVisible = 'off';                               % get rid of grid lines
random_heatmap.XDisplayLabels = {'','','','','','','','','',''};  % remove number x ticks
random_heatmap.YDisplayLabels = {'','','','','','','','','',''};  % remove number y ticks


%% World with 4 distant resource clusters
% mean distance ~=7

% create example world without walls
four_dcluster_world = floor((low_res+1) * rand(10,10));

for i = [2:4, 8:10]
    for j = [1:3, 8:10]
    four_dcluster_world(i,j) = randsample(high_res,1);
    end
end

world_as_vector5 = four_dcluster_world(:);   % to feed to nodes' size
    
% create graph/network from adjacency matrix
network5 = graph(adj_lattice,'omitselfloops');

% code resource quantity as size of nodes
network5.Nodes.Size = [world_as_vector5];
    
% find indices of nodes with resource values 8-10 
high_res_nodes = find(network5.Nodes.Size == 7 | network5.Nodes.Size == 8 | network5.Nodes.Size == 9| network5.Nodes.Size == 10);

% compute mean shortest path distance of all these node pairs (serving both as
% sources and targets)
shortest_paths5 = distances(network5, high_res_nodes, high_res_nodes);
mean_distance5 = mean(shortest_paths5, 'all');

% create heatmap
subplot(2,3,5)
four_dcluster_heatmap = heatmap(four_dcluster_world, 'Title', '{\it D} \approx 7','FontSize', 12,'CellLabelColor','none');
four_dcluster_heatmap.GridVisible = 'off';                               % get rid of grid lines
four_dcluster_heatmap.XDisplayLabels = {'','','','','','','','','',''};  % remove number x ticks
four_dcluster_heatmap.YDisplayLabels = {'','','','','','','','','',''};  % remove number y ticks


%% World with 2 distant resource clusters
% mean distance ~=8

% create example world without walls
two_dcluster_world = floor((low_res+1) * rand(10,10));

for i = 6:10
    for j = 1
    two_dcluster_world(i,j) = randsample(high_res,1);
    end
end

for i = 7:10
    for j = 2
    two_dcluster_world(i,j) = randsample(high_res,1);
    end
end

for i = 8:10
    for j = 3
    two_dcluster_world(i,j) = randsample(high_res,1);
    end
end

for i = 9:10
    for j = 4
    two_dcluster_world(i,j) = randsample(high_res,1);
    end
end

for i = 10
    for j = 5
    two_dcluster_world(i,j) = randsample(high_res,1);
    end
end

for i = 1
    for j = 6:10
    two_dcluster_world(i,j) = randsample(high_res,1);
    end
end

for i = 2
    for j = 7:10
    two_dcluster_world(i,j) = randsample(high_res,1);
    end
end

for i = 3
    for j = 8:10
    two_dcluster_world(i,j) = randsample(high_res,1);
    end
end

for i = 4
    for j = 9:10
    two_dcluster_world(i,j) = randsample(high_res,1);
    end
end

for i = 5
    for j = 10
    two_dcluster_world(i,j) = randsample(high_res,1);
    end
end

world_as_vector6 = two_dcluster_world(:);   % to feed to nodes' size
    
% create graph/network from adjacency matrix
network6 = graph(adj_lattice,'omitselfloops');

% code resource quantity as size of nodes
network6.Nodes.Size = [world_as_vector6];
    
% find indices of nodes with resource values 8-10 
high_res_nodes = find(network6.Nodes.Size == 7 | network6.Nodes.Size == 8 | network6.Nodes.Size == 9| network6.Nodes.Size == 10);

% compute mean shortest path distance of all these node pairs (serving both as
% sources and targets)
shortest_paths6 = distances(network6, high_res_nodes, high_res_nodes);
mean_distance6 = mean(shortest_paths6, 'all');

% create heatmap
subplot(2,3,6)
two_dcluster_heatmap = heatmap(two_dcluster_world, 'Title', '{\it D} \approx 8','FontSize', 12,'CellLabelColor','none');
two_dcluster_heatmap.GridVisible = 'off';                               % get rid of grid lines
two_dcluster_heatmap.XDisplayLabels = {'','','','','','','','','',''};  % remove number x ticks
two_dcluster_heatmap.YDisplayLabels = {'','','','','','','','','',''};  % remove number y ticks

% save figure as pdf
%print('Worlds','-dpdf', '-bestfit');

