# Projet Big Data - Analyse de Commentaires YouTube avec MongoDB


## 📋 Description

Projet académique Big Data utilisant MongoDB pour analyser des commentaires YouTube exportés depuis ExportComments.com. Le projet démontre les capacités de MongoDB pour le traitement et l'analyse de données non structurées.

**Données** : 100 commentaires YouTube au format CSV  
**Technologie** : MongoDB (NoSQL)  
**Objectifs** : Import, transformation, analyse textuelle, statistiques et agrégations

---

## 📹 Source des Données

### Vidéo YouTube Source

Les commentaires analysés proviennent de la vidéo YouTube suivante :

- **Titre** : Enrique Iglesias - Bailando (Español) ft. Descemer Bueno, Gente De Zona
- **Artiste** : Enrique Iglesias
- **URL** : https://www.youtube.com/watch?v=NUsoVlDFqZg
- **Vues** : 3 763 899 492+ vues (au moment de l'export)
- **Date de publication** : 11 avril 2014
- **Hashtags** : #EnriqueIglesias #Bailando

### Export des Données

Les commentaires ont été exportés en utilisant **ExportComments.com**, un service en ligne qui permet d'extraire et d'organiser les commentaires YouTube au format CSV.

**Processus d'export :**
1. Accéder à ExportComments.com
2. Coller l'URL de la vidéo YouTube : `https://www.youtube.com/watch?v=NUsoVlDFqZg`
3. Sélectionner les options d'export (nombre de commentaires, format, etc.)
4. Télécharger le fichier CSV généré : `yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv`

**Structure du fichier CSV exporté :**
- `id` : Identifiant unique du commentaire
- `Name` : Nom d'utilisateur (ex: @kevinricardogustanlopez-b5u)
- `Date` : Date et heure du commentaire (format: DD/MM/YY HH:MM:SS)
- `Likes` : Nombre de likes
- `isHearted` : Si le commentaire a été "liké" par le créateur (yes/no)
- `isPinned` : Si le commentaire est épinglé (yes/no)
- `Comment` : Texte du commentaire
- `(view source)` : Lien vers le commentaire original

**Exemple de commentaires exportés :**
- Commentaires en espagnol, anglais et autres langues
- Dates récentes (décembre 2025) montrant l'activité continue sur cette vidéo classique
- Commentaires avec différents niveaux d'engagement (likes, hearted, pinned)

### Structure Initiale (Après Import)

**Structure brute après importation depuis le CSV :**

```json
{
  "_id": {
    "$oid": "693a03fa61c3c7f7efcdbbf4"
  },
  "id": 4,
  "Name": "@AmalRoy-q2h",
  "Date": "03/12/25 07:24:13",
  "Likes": 4,
  "isHearted": "yes",
  "isPinned": "no",
  "Comment": "8,800,00000 views 😮😮",
  "(view source)": "view comment"
}
```

### ⭐ Structure Propre Recommandée

Pour une meilleure organisation et exploitation des données, nous recommandons d'utiliser la **structure propre standardisée** :

```json
{
  "_id": ObjectId("693a03fa61c3c7f7efcdbbf4"),
  "comment_id": 4,
  "author": "@AmalRoy-q2h",
  "text": "8,800,00000 views 😮😮",
  "metadata": {
    "likes": 4,
    "hearted": true,
    "pinned": false,
    "source": "youtube"
  },
  "timestamp": ISODate("2025-12-03T07:24:13Z")
}
```

**Avantages :**
- ✅ Noms de champs courts et clairs
- ✅ Métadonnées regroupées dans un objet `metadata`
- ✅ Types de données appropriés (ISODate, Number, Boolean)
- ✅ Structure standardisée et exploitable

**Voir le guide complet :** [`TRANSFORMATION_STRUCTURE_PROPRE.md`](TRANSFORMATION_STRUCTURE_PROPRE.md)

**Créer la collection propre :**
```bash
# Linux/macOS
./transform_to_clean_structure.sh

# Windows PowerShell
.\transform_to_clean_structure.ps1
```

> **⚠️ Note :** La collection `youtube_comments_clean` n'est pas dans Git. Chaque personne doit exécuter le script de transformation après avoir importé les données.

---

## 🚀 Démarrage Rapide

> **💡 Vous n'avez pas Docker ?** Consultez **[`GUIDE_SANS_DOCKER.md`](GUIDE_SANS_DOCKER.md)** pour utiliser MongoDB Compass ou une installation MongoDB locale.

### 1. Démarrer MongoDB (Docker)

**Linux/macOS :**
```bash
docker compose up -d
```

**Windows PowerShell :**
```powershell
docker-compose up -d
```

**Note :** Sur Linux/macOS, utilisez `docker compose` (avec espace). Sur Windows, vous pouvez utiliser `docker-compose` ou `docker compose`.

### 2. Importer les données CSV

**Option A - Script automatique (Recommandé) :**

**Linux/macOS :**
```bash
./import_mongodb.sh
```

**Windows PowerShell :**
```powershell
.\import_mongodb.ps1
```

**Option B - Commande manuelle :**

**Linux/macOS :**
```bash
docker cp "yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv" mongodb:/tmp/comments.csv
docker exec mongodb mongoimport --uri "mongodb://admin:password@localhost:27017/bigdata_project?authSource=admin" --collection youtube_comments --type csv --headerline --ignoreBlanks --file /tmp/comments.csv --drop
```

**Windows PowerShell :**
```powershell
docker cp "yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv" mongodb:/tmp/comments.csv
docker exec mongodb mongoimport --uri "mongodb://admin:password@localhost:27017/bigdata_project?authSource=admin" --collection youtube_comments --type csv --headerline --ignoreBlanks --file /tmp/comments.csv --drop
```

### 3. Se connecter à MongoDB

**Linux/macOS/Windows :**
```bash
docker exec -it mongodb mongosh -u admin -p password
```

Puis dans le shell MongoDB :
```javascript
use bigdata_project
db.youtube_comments.countDocuments()
```

---

## 📚 Documentation

- **`SETUP_COMPLET.md`** : 🚀 Guide complet de setup pour nouveaux utilisateurs (après git clone/pull)
- **`SECURITY.md`** : 🔒 Guide de sécurité et bonnes pratiques pour les credentials
- **`EVALUATION_PROJET.md`** : ✅ Évaluation complète de la conformité du projet aux exigences
- **`PROJET_BIGDATA_MONGODB.md`** : Documentation complète avec toutes les commandes
- **`TRANSFORMATION_STRUCTURE_PROPRE.md`** : ⭐ Guide pour transformer vers la structure propre recommandée
- **`COMMANDES_ESSENTIELLES.md`** : Récapitulatif des commandes principales
- **`EXPORT_COMMENTS_GUIDE.md`** : Guide complet sur l'export de commentaires YouTube avec ExportComments.com
- **`GUIDE_SANS_DOCKER.md`** : Guide pour utiliser MongoDB Compass ou MongoDB local (sans Docker)
- **`QUICK_START_LINUX.md`** : Guide de démarrage rapide pour Linux/macOS avec Docker
- **`import_mongodb.sh`** : Script Bash pour l'importation avec Docker (Linux/macOS)
- **`import_mongodb.ps1`** : Script PowerShell pour l'importation avec Docker (Windows)
- **`import_mongodb_local.sh`** : Script Bash pour l'importation sans Docker (Linux/macOS)
- **`import_mongodb_local.ps1`** : Script PowerShell pour l'importation sans Docker (Windows)

---

## 🔧 Configuration MongoDB

- **Host** : `localhost`
- **Port** : `27017`
- **Username** : `admin`
- **Password** : `password`
- **Database** : `bigdata_project`
- **Collection** : `youtube_comments`

**Chaîne de connexion :**
```
mongodb://admin:password@localhost:27017/bigdata_project?authSource=admin
```

---

## 📊 Commandes Essentielles

### Statistiques de base
```javascript
// Compter les commentaires
db.youtube_comments.countDocuments()

// Top 10 commentaires les plus likés
db.youtube_comments.aggregate([
  { $addFields: { likeCount: { $toInt: "$Likes" } } },
  { $sort: { likeCount: -1 } },
  { $limit: 10 }
])
```

### Recherche
```javascript
// Rechercher un mot-clé
db.youtube_comments.find({ "Comment": /2025/i }).pretty()
```

### Agrégations
```javascript
// Commentaires par auteur
db.youtube_comments.aggregate([
  {
    $group: {
      _id: "$Name",
      totalComments: { $sum: 1 },
      totalLikes: { $sum: { $toInt: "$Likes" } }
    }
  },
  { $sort: { totalComments: -1 } }
])
```

**Voir `COMMANDES_ESSENTIELLES.md` pour plus d'exemples.**

---

## 🐳 Commandes Docker

**Linux/macOS :**
```bash
# Démarrer MongoDB
docker compose up -d

# Arrêter MongoDB
docker compose down

# Voir les logs
docker compose logs mongodb

# Voir les conteneurs
docker ps
```

**Windows PowerShell :**
```powershell
# Démarrer MongoDB
docker-compose up -d
# ou
docker compose up -d

# Arrêter MongoDB
docker-compose down
# ou
docker compose down

# Voir les logs
docker-compose logs mongodb
# ou
docker compose logs mongodb

# Voir les conteneurs
docker ps
```

---

## 📁 Structure du Projet

```
Projet_BigData/
├── docker-compose.yml                      # Configuration Docker
├── import_mongodb.sh                       # Script d'importation avec Docker (Linux/macOS)
├── import_mongodb.ps1                      # Script d'importation avec Docker (Windows)
├── import_mongodb_local.sh                 # Script d'importation sans Docker (Linux/macOS)
├── import_mongodb_local.ps1                # Script d'importation sans Docker (Windows)
├── transform_to_clean_structure.sh         # ⭐ Script de transformation vers structure propre (Linux/macOS)
├── transform_to_clean_structure.ps1        # ⭐ Script de transformation vers structure propre (Windows)
├── PROJET_BIGDATA_MONGODB.md               # Documentation complète
├── COMMANDES_ESSENTIELLES.md               # Commandes principales
├── TRANSFORMATION_STRUCTURE_PROPRE.md      # Guide de transformation vers structure propre
├── EXPORT_COMMENTS_GUIDE.md                # Guide d'export de commentaires YouTube
├── GUIDE_SANS_DOCKER.md                    # Guide pour MongoDB Compass/local
├── QUICK_START_LINUX.md                    # Guide Linux/macOS avec Docker
├── EVALUATION_PROJET.md                    # Évaluation de conformité du projet
├── README.md                                # Ce fichier
└── yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv  # Données source (100 commentaires)
```

**Fichier de données :**
- **Nom** : `yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv`
- **Source** : Commentaires YouTube de la vidéo "Enrique Iglesias - Bailando"
- **Format** : CSV avec en-têtes
- **Nombre de commentaires** : 100
- **Exporté via** : ExportComments.com

---

## 🎯 Fonctionnalités du Projet

- ✅ Import de données CSV vers MongoDB
- ✅ Requêtes et filtres complexes
- ✅ Agrégations et statistiques
- ✅ Analyse textuelle (mots-clés, sentiments)
- ✅ Transformation et nettoyage de données
- ✅ Gestion de données non structurées (Big Data)

