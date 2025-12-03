function [best_solution, min_total_cost] = find_best_path_greedy(ImpedanceData)
% Trova il percorso a minima impedenza iterando su tutti i minimi
% della prima frequenza.
%
% ImpedanceData: Cell Array dove ogni cella ImpedanceData{k} contiene
%                la matrice 9x13 di impedenza per la frequenza k.

% --- Parametri di Griglia e Ricerca ---
X_MIN = 0.1; X_MAX = 0.9;
Y_MIN = 0.1; Y_MAX = 1.3;
N_X = 9; N_Y = 13;
STEP_SIZE_X = (X_MAX - X_MIN) / (N_X - 1); % ~ 0.125
STEP_SIZE_Y = (Y_MAX - Y_MIN) / (N_Y - 1); % ~ 0.116
STEP_SEARCH = 0.1; % Passo di ricerca per il vicinato (come da pseudocodice)
SEARCH_RADIUS = 3; % Vicinato 7x7

% Assumiamo che la prima griglia sia la prima frequenza
InitialZGrid = ImpedanceData{1};

% 1. Trova i Punti di Partenza (Minimi Locali nella prima griglia)
% Qui usiamo un approccio semplificato: tutti i punti che sono minori
% o uguali ai loro 8 vicini.
[X_coords, Y_coords] = meshgrid(linspace(X_MIN, X_MAX, N_X), linspace(Y_MIN, Y_MAX, N_Y));

% Trova i minimi locali
IsLocalMin = islocalmin(InitialZGrid);
[start_y_indices, start_x_indices] = find(IsLocalMin);

% Estrai le coordinate dei minimi locali
start_points = [X_coords(sub2ind(size(X_coords), start_y_indices, start_x_indices)), ...
                Y_coords(sub2ind(size(Y_coords), start_y_indices, start_x_indices))];

% Inizializzazione per il confronto
min_total_cost = Inf;
best_solution = [];

% 2. Ciclo Esterno: Iterazione su tutti i punti di partenza
disp(['Trovati ', num2str(size(start_points, 1)), ' potenziali punti di partenza.']);

for p = 1:size(start_points, 1)
    xs = start_points(p, 1);
    ys = start_points(p, 2);
    
    % Chiama la funzione greedy per calcolare il percorso
    [current_solution, current_cost] = calculate_single_path_constrained(xs, ys, ImpedanceData, ...
        X_MIN, X_MAX, Y_MIN, Y_MAX, STEP_SEARCH, SEARCH_RADIUS);
    
    % Aggiorna la soluzione migliore
    if current_cost < min_total_cost
        min_total_cost = current_cost;
        best_solution = current_solution;
    end
end

disp(['Percorso a minima impedenza trovato con costo totale: ', num2str(min_total_cost)]);

end