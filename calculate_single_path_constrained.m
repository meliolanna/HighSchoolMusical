function [solution, cost_solution] = calculate_single_path_constrained(xs, ys, ImpedanceData, ...
    X_MIN, X_MAX, Y_MIN, Y_MAX, STEP_SEARCH, SEARCH_RADIUS)
% Implementa la logica greedy con vincoli di: 
% 1. NON-SOVRAPPOSIZIONE
% 2. BLOCCO DIREZIONALE
% 3. NO MOVIMENTO SOLO VERTICALE (Delta X deve essere non nullo)

num_freqs = length(ImpedanceData);
solution = zeros(num_freqs, 2);
cost_solution = 0;

% Definizioni di Griglia e Tolleranza
N_X = size(ImpedanceData{1}, 2);
N_Y = size(ImpedanceData{1}, 1);
X_grid = linspace(X_MIN, X_MAX, N_X);
Y_grid = linspace(Y_MIN, Y_MAX, N_Y);
TOL = 1e-6; % Tolleranza per confronti floating-point

% --- STATO BLOCCO DIREZIONALE ---
% 0: Sbloccato; 1: Bloccato Positivo; -1: Bloccato Negativo
Direction_Lock_X = 0;
Direction_Lock_Y = 0;
% ---------------------------------

% Inizializza il primo punto della soluzione (P1)
solution(1, :) = [xs, ys];

for k = 1:num_freqs
    current_table = ImpedanceData{k};
    Z_interp = griddedInterpolant({Y_grid, X_grid}, current_table, 'linear', 'none');
    
    % Punti di partenza per questa frequenza (P_k-1)
    xs_k = xs;
    ys_k = ys;
    
    abs_min_reference = min(min(ImpedanceData{k})); 
    
    min_imp_cost = Inf;
    xbest_local = xs_k;
    ybest_local = ys_k;
    
    % Ricerca nel vicinato 7x7 centrato su (xs_k, ys_k)
    for j = -SEARCH_RADIUS:SEARCH_RADIUS
        xk = xs_k + j * STEP_SEARCH;
        
        for i = -SEARCH_RADIUS:SEARCH_RADIUS
            yk = ys_k + i * STEP_SEARCH;
            
            % Calcolo del movimento potenziale
            dx_k = xk - xs_k;
            dy_k = yk - ys_k;
            
            % --- Vincolo 3: NO MOVIMENTO SOLO VERTICALE ---
            % Se dx_k è approssimativamente zero (movimento solo su Y o fermo)
            if abs(dx_k) < TOL 
                continue; % Salta: Movimento puramente verticale o nullo (non consentito)
            end
            
            % Controlli di Limite
            if (xk < X_MIN || xk > X_MAX || yk < Y_MIN || yk > Y_MAX)
                continue; 
            end
            
            % --- Vincolo 1: Nessuna Sovrapposizione (Non Coincidenza) ---
            is_overlap = false;
            if k > 1
                PreviousPoints = solution(1:k-1, :);
                DiffL1 = sum(abs(PreviousPoints - [xk, yk]), 2);
                if any(DiffL1 < TOL)
                    is_overlap = true;
                end
            end
            if is_overlap
                continue; % Salta punto sovrapposto
            end
            
            % --- Vincolo 2: Blocco Direzionale ---
            
            % Applicazione del blocco X
            if Direction_Lock_X == 1 && dx_k < -TOL
                continue; 
            elseif Direction_Lock_X == -1 && dx_k > TOL
                continue; 
            end
            
            % Applicazione del blocco Y
            if Direction_Lock_Y == 1 && dy_k < -TOL
                continue; 
            elseif Direction_Lock_Y == -1 && dy_k > TOL
                continue; 
            end
            
            % ---------------------------------------
            
            % Valutazione dell'Impedenza
            imp_here = Z_interp(yk, xk);
            if isnan(imp_here)
                continue;
            end
            
            imp_cost = imp_here - abs_min_reference;
            
            % Aggiornamento del Miglior Punto Trovato
            if (imp_cost < min_imp_cost)
                min_imp_cost = imp_cost;
                xbest_local = xk;
                ybest_local = yk;
            end
        end
    end
    
    % --- Aggiornamento Globale e STATO DEL BLOCCO ---
    
    % 1. Aggiornamento del costo
    cost_solution = cost_solution + min_imp_cost;
    
    % 2. Calcolo del movimento effettivo
    dx_best = xbest_local - xs_k;
    dy_best = ybest_local - ys_k;
    
    % 3. Aggiornamento dello Stato del Blocco (solo se era sbloccato)
    
    % Aggiorna Blocco X
    if Direction_Lock_X == 0
        if dx_best > TOL
            Direction_Lock_X = 1;  % Blocca a destra
        elseif dx_best < -TOL
            Direction_Lock_X = -1; % Blocca a sinistra
        end
    end
    
    % Aggiorna Blocco Y
    if Direction_Lock_Y == 0
        if dy_best > TOL
            Direction_Lock_Y = 1;  % Blocca in su
        elseif dy_best < -TOL
            Direction_Lock_Y = -1; % Blocca in giù
        end
    end
    
    % 4. Aggiornamento del punto di partenza per la prossima frequenza
    xs = xbest_local;
    ys = ybest_local;
    
    % 5. Aggiunge il punto migliore alla soluzione (P_k)
    solution(k, :) = [xs, ys];
    
end
end
