# 🚀 Guide de Démarrage Rapide - Linux

## Prérequis

- ✅ Docker installé
- ✅ Docker Compose installé
- ✅ Fichier CSV présent dans le projet

## 📋 Étapes pour Démarrer

### 1. Démarrer MongoDB avec Docker Compose

```bash
cd /home/ahmed/Desktop/Projet_BigData-
docker compose up -d
```

**Note:** Utilisez `docker compose` (v2) et non `docker-compose` (v1)

Vérifier que MongoDB est démarré :
```bash
docker ps
```

Vous devriez voir le conteneur `mongodb` en cours d'exécution.

### 2. Importer les données CSV

**Option A - Script automatique (Recommandé) :**
```bash
./import_mongodb.sh
```

**Option B - Commande manuelle :**
```bash
docker cp "yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv" mongodb:/tmp/comments.csv

docker exec mongodb mongoimport --uri "mongodb://admin:password@localhost:27017/bigdata_project?authSource=admin" \
  --collection youtube_comments \
  --type csv \
  --headerline \
  --ignoreBlanks \
  --file /tmp/comments.csv \
  --drop
```

### 3. Se connecter à MongoDB

```bash
docker exec -it mongodb mongosh -u admin -p password
```

Dans le shell MongoDB, exécutez :
```javascript
use bigdata_project
db.youtube_comments.countDocuments()
```

## 🔧 Commandes Utiles

### Arrêter MongoDB
```bash
docker compose down
```

### Voir les logs MongoDB
```bash
docker compose logs mongodb
```

### Redémarrer MongoDB
```bash
docker compose restart
```

### Vérifier l'état
```bash
docker ps -a
```

## 📊 Premières Requêtes

Une fois connecté à MongoDB (`mongosh`), essayez :

```javascript
// Compter les commentaires
db.youtube_comments.countDocuments()

// Afficher 5 commentaires
db.youtube_comments.find().limit(5).pretty()

// Top 10 commentaires les plus likés
db.youtube_comments.aggregate([
  { $addFields: { likeCount: { $toInt: "$Likes" } } },
  { $sort: { likeCount: -1 } },
  { $limit: 10 }
])
```

## 📚 Documentation Complète

- `README.md` - Vue d'ensemble du projet
- `PROJET_BIGDATA_MONGODB.md` - Toutes les commandes détaillées
- `COMMANDES_ESSENTIELLES.md` - Récapitulatif des commandes principales

## ⚙️ Configuration

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

