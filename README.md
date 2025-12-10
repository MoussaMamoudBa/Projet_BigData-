# Projet Big Data - Analyse de Commentaires YouTube avec MongoDB

## 📋 Description

Projet académique Big Data utilisant MongoDB pour analyser des commentaires YouTube exportés depuis ExportComments.com. Le projet démontre les capacités de MongoDB pour le traitement et l'analyse de données non structurées.

**Données** : 100 commentaires YouTube au format CSV  
**Technologie** : MongoDB (NoSQL)  
**Objectifs** : Import, transformation, analyse textuelle, statistiques et agrégations

---

## 🚀 Démarrage Rapide

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

- **`PROJET_BIGDATA_MONGODB.md`** : Documentation complète avec toutes les commandes
- **`COMMANDES_ESSENTIELLES.md`** : Récapitulatif des commandes principales
- **`QUICK_START_LINUX.md`** : Guide de démarrage rapide pour Linux/macOS
- **`import_mongodb.sh`** : Script Bash pour l'importation automatique (Linux/macOS)
- **`import_mongodb.ps1`** : Script PowerShell pour l'importation automatique (Windows)

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
├── docker-compose.yml              # Configuration Docker
├── import_mongodb.sh               # Script d'importation (Linux/macOS)
├── import_mongodb.ps1              # Script d'importation (Windows)
├── PROJET_BIGDATA_MONGODB.md       # Documentation complète
├── COMMANDES_ESSENTIELLES.md       # Commandes principales
├── QUICK_START_LINUX.md            # Guide Linux/macOS
├── README.md                        # Ce fichier
└── yt-comments_*.csv               # Données source
```

---

## 🎯 Fonctionnalités du Projet

- ✅ Import de données CSV vers MongoDB
- ✅ Requêtes et filtres complexes
- ✅ Agrégations et statistiques
- ✅ Analyse textuelle (mots-clés, sentiments)
- ✅ Transformation et nettoyage de données
- ✅ Gestion de données non structurées (Big Data)

