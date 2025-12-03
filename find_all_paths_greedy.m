function [all_solutions_sorted] = find_all_paths_greedy(ImpedanceData)
% Trova e ordina tutti i percorsi greedy trovati partendo da tutti i minimi
% della prima frequenza.

% --- Parametri di Griglia e Ricerca ---
X_MIN = 0.1; X_MAX = 0.9;
Y_MIN = 0.1; Y_MAX = 1.3;
N_X = 9; N_Y = 13;
STEP_SEARCH = 0.1; 
SEARCH_RADIUS = 3;

% Assumiamo che la prima griglia sia la prima frequenza
InitialZGrid = ImpedanceData{1};

% Calcolo delle coordinate della griglia (necessarie per trovare i minimi)
N_X_grid = size(InitialZGrid, 2);
N_Y_grid = size(InitialZGrid, 1);
[X_coords, Y_coords] = meshgrid(linspace(X_MIN, X_MAX, N_X_grid), linspace(Y_MIN, Y_MAX, N_Y_grid));

% 1. Trova i Punti di Partenza (Minimi Locali nella prima griglia)
IsLocalMin = islocalmin(InitialZGrid);
[start_y_indices, start_x_indices] = find(IsLocalMin);

% Estrai le coordinate dei minimi locali
start_points = [X_coords(sub2ind(size(X_coords), start_y_indices, start_x_indices)), ...
                Y_coords(sub2ind(size(Y_coords), start_y_indices, start_x_indices))];

% Inizializzazione della lista per salvare tutti i risultati
all_results = struct('cost', {}, 'solution', {});

disp(['Trovati ', num2str(size(start_points, 1)), ' potenziali punti di partenza.']);

% 2. Ciclo Esterno: Calcolo di tutti i percorsi
for p = 1:size(start_points, 1)
    xs = start_points(p, 1);
    ys = start_points(p, 2);
    
    % Chiama la funzione greedy per calcolare il percorso (la funzione ausiliaria NON CAMBIA)
    [current_solution, current_cost] = calculate_single_path_constrained(xs, ys, ImpedanceData, ...
        X_MIN, X_MAX, Y_MIN, Y_MAX, STEP_SEARCH, SEARCH_RADIUS);
    
    % Salva il risultato corrente nella lista
    all_results(p).cost = current_cost;
    all_results(p).solution = current_solution;
end

% 3. Ordinamento dei Risultati
% Estrae tutti i costi in un array
all_costs = [all_results.cost];

% Ottiene gli indici di ordinamento (dal costo minore al costo maggiore)
[~, sorted_indices] = sort(all_costs, 'ascend');

% Ordina la struttura dei risultati
all_solutions_sorted = all_results(sorted_indices);

disp('Calcolo completato. Le soluzioni sono state ordinate per costo crescente.');

end