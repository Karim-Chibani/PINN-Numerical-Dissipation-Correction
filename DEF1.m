%% PFE : Reconstruction d'une onde d'advection par Interpolation Spectrale
% Auteur : Karim Chibani
% Master 2 : Mathématiques Appliquées

clear; clc; close all;

%% 1. Paramètres Physiques et Temporels
L       = 10;       % Longueur du domaine
a       = 1.0;      % Vitesse de transport
T_final = 2.0;      % Temps final de simulation
sigma   = 0.8;      % Largeur de la gaussienne
x0      = 3.0;      % Position initiale du pic

%% 2. Définition des Maillages
% Maillage Fin (Référence - Solution Approchée Fine)
Nx_f    = 200;
x_f     = linspace(0, L, Nx_f)';
dx_f    = L / (Nx_f - 1);
dt_f    = 0.8 * (dx_f / a); % Condition CFL

% Maillage Grossier (Données Coarse - 40 points)
Nx_c    = 40;
x_c     = linspace(0, L, Nx_c)';
dx_c    = L / (Nx_c - 1);
dt_c    = dt_f;             % On garde le même dt pour la comparaison

%% 3. Conditions Initiales (Profil Gaussien à t = 0)
u_f = 0.6 * exp(-0.5 * ((x_f - x0)/sigma).^2);
u_c = 0.6 * exp(-0.5 * ((x_c - x0)/sigma).^2);

%% 4. Résolution Numérique (Schéma Upwind)
% Simulation de la Solution Fine (Vérité terrain)
for t = 0:dt_f:T_final
    u_f(2:end) = u_f(2:end) - (a*dt_f/dx_f) * (u_f(2:end) - u_f(1:end-1));
end

% Simulation de la Solution Grossière (Souffrant de dissipation)
for t = 0:dt_c:T_final
    u_c(2:end) = u_c(2:end) - (a*dt_c/dx_c) * (u_c(2:end) - u_c(1:end-1));
end

%% 5. Reconstitution Spectrale (FFT Interpolation)
% Reconstruction du signal à partir de 40 points vers 200 points
u_recon = interpft(u_c, Nx_f);

%% 6. Visualisation des Résultats
figure('Color', 'w', 'Position', [100, 100, 900, 500]);
hold on;

% 1. Solution Fine (Référence)
plot(x_f, u_f, 'b-', 'LineWidth', 2, 'DisplayName', 'Solution Fine (Référence)');

% 2. Solution Reconstituée (Interpolation FFT)
plot(x_f, u_recon, 'r--', 'LineWidth', 1.8, 'DisplayName', 'Reconstitution Spectrale (FFT)');

% 3. Points Grossiers (Données initiales de reconstruction)
plot(x_c, u_c, 'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k', 'DisplayName', 'Points Coarse (40 pts)');

% Mise en forme professionnelle
grid on; box on;
xlabel('Position (x)', 'FontSize', 12);
ylabel('Amplitude u(x,T)', 'FontSize', 12);
title(['Comparaison : Solution Fine vs Reconstitution à T = ', num2str(T_final)], 'FontSize', 14);
legend('Location', 'northeast', 'FontSize', 10);

% Ajustement des axes
axis([0 L -0.1 0.7]);

%% 7. Exportation des données pour le PINN (Optionnel)
% data_pfe = [u_recon, u_f]; 
% csvwrite('data_reconstruction.csv', data_pfe);

fprintf('Simulation terminée. Pic Fine : %.3f | Pic Reconstruit : %.3f\n', max(u_f), max(u_recon));
%% 8. Analyse de l'Erreur (Indispensable pour le PFE)

% Calcul de l'erreur relative entre la vérité (u_f) et la reconstruction (u_recon)
erreur_L2 = norm(u_f - u_recon) / norm(u_f);

fprintf('--------------------------------------------------\n');
fprintf('ANALYSE DES RÉSULTATS :\n');
fprintf('Erreur relative (L2) après Reconstitution : %.2f%%\n', erreur_L2 * 100);
fprintf('Perte d''amplitude (Dissipation) : %.2f%%\n', (max(u_f) - max(u_recon))/max(u_f) * 100);
fprintf('--------------------------------------------------\n');
% 1. Les coordonnées (Positions x)
x_c = linspace(0, 10, 40)'; % Maillage Grossier
x_f = linspace(0, 10, 200)'; % Maillage Fin

% 2. Exportation des Features (40 points) et Labels (200 points)
writematrix(u_c, 'u_coarse_40.csv');  % Feature (Entrée dissipée)
writematrix(x_c, 'x_coarse_40.csv');  % Coordonnées de l'entrée
writematrix(u_f, 'u_fine_200.csv');    % Label (Cible précise)
writematrix(x_f, 'x_fine_200.csv');    % Coordonnées de la cible
%% =============================================================
%% 9. VISUALISATION AVANCÉE (À METTRE À LA FIN DU SCRIPT)
%% =============================================================

% Création d'une nouvelle figure professionnelle
figure('Color', 'w', 'Name', 'Analyse du Problème de Dissipation');

% --- Subplot 1 : Vue Globale ---
subplot(2,1,1);
hold on;
plot(x_f, u_f, 'b', 'LineWidth', 2, 'DisplayName', 'Solution Exacte (Cible)');
plot(x_f, u_recon, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Reconstitution Spectrale');
stem(x_c, u_c, 'k', 'MarkerSize', 3, 'DisplayName', 'Points Coarse (Entrée)');
title('Comparaison Globale : Vérité vs Reconstruction MATLAB');
ylabel('Amplitude');
legend('Location', 'northeast');
grid on;

% --- Subplot 2 : Zoom sur le Pic (Preuve de la dissipation) ---
subplot(2,1,2);
hold on;
plot(x_f, u_f, 'b', 'LineWidth', 2.5, 'DisplayName', 'Cible Fine');
plot(x_f, u_recon, 'r--', 'LineWidth', 2.5, 'DisplayName', 'Reconstruit (Dissipé)');
scatter(x_c, u_c, 60, 'k', 'filled', 'DisplayName', 'Points Coarse');

% Calcul automatique de la zone du pic pour le zoom
pic_pos = x0 + a*T_final;
xlim([pic_pos - 1.5, pic_pos + 1.5]); 
ylim([0.35, 0.65]);

title(['Zoom sur le Pic : Perte d''Amplitude de ', num2str((max(u_f)-max(u_recon))/max(u_f)*100, '%.1f'), '%']);
xlabel('Position (x)');
ylabel('Amplitude');
legend('Location', 'south');
grid on;

fprintf('✅ Visualisation générée. Le graphique montre la dissipation que le PINN doit corriger.\n');
% --- Sauvegarde automatique de l'image ---
% Cette ligne va créer un fichier PNG dans le dossier actuel
filename = 'Analyse_Dissipation_MATLAB.png';
exportgraphics(gcf, filename, 'Resolution', 300); 

fprintf('💾 Image sauvegardée avec succès sous le nom : %s\n', filename);