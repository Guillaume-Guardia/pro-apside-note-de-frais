# APSIDE Python NDF

[![CI](https://github.com/Guillaume-Guardia/pro-apside-note-de-frais/actions/workflows/ci.yml/badge.svg)](https://github.com/Guillaume-Guardia/pro-apside-note-de-frais/actions/workflows/ci.yml)

Application Windows pour analyser des fichiers Excel et CSV de notes de frais et générer des PDF.

## Prérequis

- Windows
- Python 3.14 ou plus récent
- Git
- Une clé Google Maps API pour les calculs de distance qui ne sont pas déjà en cache (facultatif pour lancer l'application et les tests sans appels API)

## Installation et lancement

Depuis PowerShell ou `cmd` :

```powershell
git clone https://github.com/Guillaume-Guardia/pro-apside-note-de-frais.git
cd pro-apside-note-de-frais
.\dev.bat install
.\dev.bat run
```

`dev.bat install` crée `.venv` si nécessaire, installe le projet en mode éditable et installe les dépendances de développement. Aucun environnement virtuel ni fichier de configuration local n'est à copier depuis un autre clone.

Pour lancer l'application directement avec Python :

```powershell
.\.venv\Scripts\python.exe src\pyndf\main.py
```

## Fonctionnement

Dans l'onglet *Processus*, sélectionner les fichiers Excel et CSV à traiter ainsi qu'un dossier de sortie, puis lancer la génération :

1. Le lecteur Excel repère les lignes de déplacement et les informations de mission.
2. Le lecteur CSV récupère les indemnités non nulles.
3. Pour chaque trajet, l'application cherche la distance dans son cache mémoire puis dans la base SQLite. Si elle n'y figure pas, elle peut interroger Google Maps Distance Matrix.
4. Les données sont regroupées par salarié et des notes de frais PDF sont générées dans le dossier choisi.

Les onglets d'analyse permettent de consulter les résultats et les statuts du traitement. Une clé Google Maps est nécessaire uniquement pour les trajets qui ne sont pas déjà disponibles dans le cache ou la base.

## Options avancées

Le menu *Options* contient des réglages supplémentaires. Le raccourci `Ctrl+D` active le *mode développeur*, qui affiche notamment les vues d'analyse et les onglets des tables de la base de données. Les options de développement comprennent :

- **Save tmp file** : enregistre les fichiers temporaires après les modifications faites dans les tableaux CSV ou Excel.
- **Use multithreading** : génère les PDF en parallèle plutôt que séquentiellement.
- **Overwrite PDF** : autorise le remplacement d'un PDF existant ; désactivé, le fichier existant n'est pas remplacé.
- **Use DB** et **Use CACHE** : activent ou désactivent la recherche des distances déjà enregistrées.
- **Use API** : active ou désactive les appels à Google Maps.
- **Vues d'analyse et DB** : affichent les résultats par étape et le contenu des tables clients, salariés et mesures.

Les préférences de l'application peuvent être mémorisées par Qt dans les paramètres de l'utilisateur Windows.

## Développement

Les commandes suivantes s'exécutent depuis la racine du dépôt :

| Commande | Action |
| --- | --- |
| `.\dev.bat install` | Crée/met à jour `.venv` et installe les dépendances |
| `.\dev.bat test` | Vérifie les dépendances et exécute les tests |
| `.\dev.bat run [arguments]` | Lance l'application et transmet ses arguments |
| `.\dev.bat exe` | Génère `ndf.exe` (nécessite Bat To Exe Converter) |
| `.\dev.bat` | Installe les dépendances, puis exécute les tests |

Exemple pour afficher l'aide de l'application : `.\dev.bat run --help`. Le même script `dev.bat` sert de lanceur, de script de développement et de source pour générer `ndf.exe`.

Les tests Qt s'exécutent en mode sans affichage. Les tests qui appellent Google Maps sont ignorés si `GOOGLE_API_KEY` n'est pas définie. Pour les exécuter, définir la variable dans le terminal avant de lancer les tests :

```powershell
$env:GOOGLE_API_KEY = "votre-cle"
.\dev.bat test
```

La CI GitHub Actions utilise Windows et Python 3.14. Elle ne reçoit pas de clé Google par défaut ; seuls les tests sans appel API sont alors exécutés.

## Configuration et données locales

- La configuration fonctionnelle est dans `src/pyndf/conf/conf.yaml`.
- La clé Google Maps API est lue depuis `GOOGLE_API_KEY`. Ne jamais la mettre dans le code, la configuration suivie par Git ou les tests.
- La base SQLite de l'application est créée localement dans `src/pyndf/db/pydb.db`. Elle est ignorée par Git. Les tests utilisent une base temporaire.
- Les fichiers produits sont enregistrés dans le dossier choisi dans l'application ; `output/` est ignoré par Git.
- Ne pas ajouter de données personnelles ou de fichiers métier réels au dépôt. Utiliser des exemples anonymisés pour les tests.

## Organisation du code

- `src/pyndf/app.py`, `gui/` : démarrage et interface PyQt
- `src/pyndf/process/` : lecture, traitement et génération des fichiers
- `src/pyndf/db/` : modèles et accès SQLite
- `src/pyndf/conf/` : configuration de l'application
- `src/pyndf/data/` : ressources de l'interface et traductions
- `tests/` : tests automatisés
- `dev.bat` : commandes de développement, lancement Windows et génération de l'exécutable

## Générer l'exécutable Windows

La génération de `ndf.exe` est facultative et ne fait pas partie de l'installation ou des tests. Installer [Bat To Exe Converter](https://www.f2ko.de/en/b2e.php), puis lancer `.\dev.bat exe`. Le convertisseur utilise `dev.bat` comme lanceur. Son chemin peut être fourni dans la variable d'environnement `B2E`.

L'exécutable n'est pas autonome : il s'appuie sur le dépôt et son environnement `.venv`, qui doivent rester à côté de lui. `ndf.exe` est ignoré par Git.
