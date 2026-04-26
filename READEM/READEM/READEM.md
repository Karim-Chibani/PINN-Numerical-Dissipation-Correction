# PINN-Numerical-Dissipation-Correction

Ce projet utilise les réseaux de neurones informés par la physique (**PINNs**) pour corriger la dissipation numérique induite par les schémas classiques (Upwind) lors de la résolution de l'équation d'advection 1D.

## 1. Fondement Mathématique : Méthode des Caractéristiques
Le projet repose sur le problème de Cauchy pour l'équation d'advection linéaire sur $\mathbb{R} \times [0, T[$ :

$$
\begin{cases} 
\dfrac{\partial u}{\partial t}(x,t) + c \dfrac{\partial u}{\partial x}(x,t) = 0 \\ 
u(x,0) = u_0(x) 
\end{cases}
$$

D'après la **méthode des caractéristiques**, en posant $\frac{dx}{dt} = c$, on démontre que la solution est constante le long des droites $x - ct = \text{constante}$. La solution exacte est donc :

$$u(x,t) = u_0(x - ct)$$

Théoriquement, le profil initial (une gaussienne d'amplitude **0.6**) doit être simplement translaté sans aucune déformation ni perte d'énergie.

## 2. Problématique : Dissipation Numérique
Malgré la théorie, l'utilisation de méthodes numériques classiques (MATLAB) introduit une erreur systématique appelée **dissipation artificielle**. Dans notre simulation, l'amplitude chute de **0.591** à **0.461**, représentant une perte de fidélité physique de plus de **21%**.

## 🎯 Objectifs du Projet
L'objectif principal est de démontrer la capacité des réseaux **PINNs** à agir comme un correcteur intelligent pour les simulateurs numériques classiques :

* **Restauration de l'Amplitude :** Compenser la perte d'énergie pour ramener le pic de l'onde de 0.46 à sa valeur physique réelle de 0.6.
* **Super-Résolution Spatiale :** Reconstruire une solution fine de 200 points à partir d'un maillage grossier de seulement 40 points.
* **Fusion de Données Multi-Fidélité :** Apprendre à combiner des données "dissipées" (MATLAB) avec des connaissances physiques (EDP) et des mesures exactes clairsemées.
* **Généralisation Physique :** Assurer que la solution reconstruite respecte la continuité imposée par l'équation de transport.

## 3. Solution : Approche Hybride PINN
Le modèle PINN restaure la solution exacte en fusionnant trois sources d'informations :
* **Données Basse Fidélité :** 40 points issus de la simulation MATLAB (dissipés).
* **Données Haute Fidélité :** Un échantillonnage sparse de seulement 20 points de vérité terrain.
* **Contrainte Physique :** Intégration du résidu de l'EDP directement dans la fonction de perte (Loss).

## 4. Résumé des Performances
| Métrique | Valeur |
| :--- | :--- |
| **Erreur Quadratique Moyenne (MSE)** | 0.00016371 |
| **Amplitude Réelle attendue** | 0.5907 |
| **Amplitude MATLAB (Dissipée)** | 0.4609 |
| **Amplitude reconstruite par l'IA** | **0.5638** |
| **Taux de correction de la dissipation** | **79.31%** |

## 🛠️ Installation et Technologies
* **Framework :** PyTorch
* **Langage :** Python 3.x
* **Bibliothèques :** NumPy, Pandas, Matplotlib
* **Génération de données :** MATLAB R2023b
