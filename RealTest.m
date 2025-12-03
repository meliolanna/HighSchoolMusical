% Loading the 5 files with the impedances, one file for each freqency
Z_F2 = readmatrix('Z_F2_349_Hz_13x9.csv');
Z_A4 = readmatrix('Z_A4_440_Hz_13x9.csv');
Z_C5 = readmatrix('Z_C5_523_Hz_13x9.csv');
Z_E5 = readmatrix('Z_E5_659_Hz_13x9.csv');
Z_G5 = readmatrix('Z_G5_784_Hz_13x9.csv');

% Assembling the Cell Array in the order[F2, A4, C5, E5, G5]
ImpedanceData = {Z_F2, Z_A4, Z_C5, Z_E5, Z_G5};

%%
% Function to find the best solution
[best_solution, min_total_cost]  = find_best_path_greedy(ImpedanceData);

% Plot of the bridge best solution
figure;
title('Percorso Greedy Ottimale');
xlabel('X (0.0 a 1.0)');
ylabel('Y (0.0 a 1.4)');
hold on;

% For each freq, grid
for f = 1:num_freqs
    % Immagine della griglia (richiede l'uso delle coordinate reali)
    X_plot = linspace(0.0, 1.0, num_x);
    Y_plot = linspace(0.0, 1.4, num_y);
    surf(X_plot, Y_plot, ImpedanceData{f}, 'EdgeColor', 'none', 'FaceAlpha', 0.2);
end

plot(best_solution(:, 1), best_solution(:, 2), 'r-o', ...
    'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'r');

scatter(best_solution(1, 1), best_solution(1, 2), 100, 'g', 'filled', 'DisplayName', 'Start');
scatter(best_solution(end, 1), best_solution(end, 2), 100, 'b', 'filled', 'DisplayName', 'End');

view(2); % View 2D
colormap('jet');
colorbar;
hold off;


disp(' ');
disp('========================================');
disp('Optimal path (Coordinates [X, Y]):');
disp('----------------------------------------');
disp('  Frequency |     X (m) |     Y (m) ');
disp('----------------------------------------');

freq_labels = {'F2'; 'A4'; 'C5'; 'E5'; 'G5'};

for i = 1:size(best_solution, 1)
    fprintf('%-10s | %10.6f | %10.6f \n', freq_labels{i}, best_solution(i, 1), best_solution(i, 2));
end

disp('----------------------------------------');
disp(['Costo Totale (Variazione Minima Z): ', num2str(min_cost)]);

% ========================================
%%
% Colleting all the solutions in the order from the best to the worst 
all_solutions = find_all_paths_greedy(ImpedanceData);

if isempty(all_solutions)
    disp('No solution found.');
    return;
end

% Visualization of the best path (minimum cost)
disp(' ');
disp('==================================================');
disp('Percorso Migliore (Costo Minimo):');
disp(['Costo Totale (Variazione Minima): ', num2str(all_solutions(1).cost)]);
disp('Coordinate del percorso [X, Y] per le 5 frequenze:');

% Print matrix 5x2 of the coordinates from the first to the last point
disp(all_solutions(1).solution); 
disp('==================================================');


% 2. Visualizing the first 3 paths of the list, so other that can be good
disp(' ');
disp('Lista dei primi 3 percorsi (dal migliore al peggiore):');
for i = 1:min(3, length(all_solutions))
    disp(['#', num2str(i), ' - Costo: ', num2str(all_solutions(i).cost)]);
    % Non stampiamo la matrice intera qui, solo un'indicazione:
    disp(['  Punto di Partenza (F2): [', num2str(all_solutions(i).solution(1, :)), ']']);
    % 1. Visualizza il percorso migliore (Soluzione con costo minimo)
    disp(' ');
    disp('==================================================');
    disp('Percorso Migliore (Costo Minimo):');
    disp(['Costo Totale (Variazione Minima): ', num2str(all_solutions(i).cost)]);
    disp('Coordinate del percorso [X, Y] per le 5 frequenze:');
    
    % Stampa la matrice 5x2 delle coordinate
    disp(all_solutions(i).solution); 
    disp('==================================================');
end

%%
% doesnt work
figure;
title('Percorso Greedy Ottimale');
xlabel('X (0.0 a 1.0)');
ylabel('Y (0.0 a 1.4)');
hold on;
% Per ogni frequenza, plottiamo la griglia (opzionale)
for f = 1:num_freqs
    % Immagine della griglia (richiede l'uso delle coordinate reali)
    X_plot = linspace(0.0, 1.0, num_x);
    Y_plot = linspace(0.0, 1.4, num_y);
    surf(X_plot, Y_plot, ImpedanceData{f}, 'EdgeColor', 'none', 'FaceAlpha', 0.2);
end

sol = all_solutions(2);
% Plotta il percorso migliore (i punti della soluzione)
plot(sol(:, 1), sol(:, 2), 'r-o', ...
    'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'r');

scatter(sol(1, 1), sol(1, 2), 100, 'g', 'filled', 'DisplayName', 'Start');
scatter(sol(end, 1), sol(end, 2), 100, 'b', 'filled', 'DisplayName', 'End');

view(2); % Vista 2D
colormap('jet');
colorbar;
hold off;