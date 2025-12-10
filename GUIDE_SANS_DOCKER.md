# 🖥️ Guide d'Utilisation Sans Docker

Ce guide explique comment utiliser le projet avec MongoDB Compass ou une installation MongoDB locale (sans Docker).

---

## 📋 Prérequis

- ✅ MongoDB installé localement OU
- ✅ MongoDB Compass installé
- ✅ MongoDB Tools (`mongoimport`, `mongosh`) installés (optionnel, pour la ligne de commande)

---

## 🎯 Option 1 : Utiliser MongoDB Compass (Recommandé - Interface Graphique)

### 1. Installer MongoDB Compass

Téléchargez depuis : https://www.mongodb.com/try/download/compass

### 2. Se connecter à MongoDB

**Si MongoDB est installé localement :**
- **Connection String** : `mongodb://localhost:27017`
- Cliquez sur "Connect"

**Si MongoDB nécessite une authentification :**
- **Connection String** : `mongodb://admin:password@localhost:27017/?authSource=admin`
- Ou utilisez l'interface pour entrer :
  - Host: `localhost`
  - Port: `27017`
  - Username: `admin`
  - Password: `password`
  - Authentication Database: `admin`

### 3. Créer la base de données

1. Dans MongoDB Compass, cliquez sur "Create Database"
2. **Database Name** : `bigdata_project`
3. **Collection Name** : `youtube_comments`
4. Cliquez sur "Create Database"

### 4. Importer le CSV

**Méthode A - Import direct dans Compass :**

1. Sélectionnez la collection `youtube_comments`
2. Cliquez sur "Add Data" → "Import File"
3. Sélectionnez le fichier : `yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv`
4. Choisissez le format : **CSV**
5. Vérifiez que "Header row" est coché
6. Cliquez sur "Import"

**Méthode B - Via mongoimport (ligne de commande) :**

**Linux/macOS :**
```bash
mongoimport --uri "mongodb://localhost:27017/bigdata_project" \
  --collection youtube_comments \
  --type csv \
  --headerline \
  --ignoreBlanks \
  --file "yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv" \
  --drop
```

**Windows PowerShell :**
```powershell
mongoimport --uri "mongodb://localhost:27017/bigdata_project" `
  --collection youtube_comments `
  --type csv `
  --headerline `
  --ignoreBlanks `
  --file "yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv" `
  --drop
```

**Avec authentification :**
```bash
mongoimport --uri "mongodb://admin:password@localhost:27017/bigdata_project?authSource=admin" \
  --collection youtube_comments \
  --type csv \
  --headerline \
  --ignoreBlanks \
  --file "yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv" \
  --drop
```

### 5. Vérifier l'import

Dans MongoDB Compass :
- Sélectionnez la collection `youtube_comments`
- Vous devriez voir 100 documents
- Cliquez sur un document pour voir son contenu

---

## 🖥️ Option 2 : Utiliser MongoDB Local (Ligne de Commande)

### 1. Vérifier que MongoDB est démarré

**Linux/macOS :**
```bash
sudo systemctl status mongod
# ou
brew services list  # sur macOS avec Homebrew
```

**Windows :**
Vérifiez dans les Services Windows que MongoDB est en cours d'exécution.

### 2. Se connecter à MongoDB

**Sans authentification :**
```bash
mongosh
```

**Avec authentification :**
```bash
mongosh -u admin -p password --authenticationDatabase admin
```

**Ou avec URI :**
```bash
mongosh "mongodb://admin:password@localhost:27017/?authSource=admin"
```

### 3. Créer la base de données

Dans le shell MongoDB :
```javascript
use bigdata_project
```

### 4. Importer le CSV

**Linux/macOS :**
```bash
mongoimport --uri "mongodb://localhost:27017/bigdata_project" \
  --collection youtube_comments \
  --type csv \
  --headerline \
  --ignoreBlanks \
  --file "yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv" \
  --drop
```

**Windows PowerShell :**
```powershell
mongoimport --uri "mongodb://localhost:27017/bigdata_project" `
  --collection youtube_comments `
  --type csv `
  --headerline `
  --ignoreBlanks `
  --file "yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv" `
  --drop
```

### 5. Vérifier l'import

Dans le shell MongoDB :
```javascript
use bigdata_project
db.youtube_comments.countDocuments()  // Devrait retourner 100
db.youtube_comments.find().limit(5).pretty()
```

---

## 🔧 Scripts pour MongoDB Local (Sans Docker)

### Script Bash (Linux/macOS)

Créez un fichier `import_mongodb_local.sh` :

```bash
#!/bin/bash
# Script pour importer CSV dans MongoDB local (sans Docker)

CSV_FILE="yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv"
DB_NAME="bigdata_project"
COLLECTION="youtube_comments"
MONGO_URI="mongodb://localhost:27017/$DB_NAME"

# Si vous avez besoin d'authentification, utilisez :
# MONGO_URI="mongodb://admin:password@localhost:27017/$DB_NAME?authSource=admin"

echo "========================================"
echo "Importation CSV vers MongoDB Local"
echo "========================================"
echo ""

if [ ! -f "$CSV_FILE" ]; then
    echo "ERREUR: Le fichier $CSV_FILE n'existe pas!"
    exit 1
fi

echo "Fichier trouvé: $CSV_FILE"
echo "Base de données: $DB_NAME"
echo "Collection: $COLLECTION"
echo ""

echo "Vérification de la connexion MongoDB..."
if ! mongosh "$MONGO_URI" --eval "db.version()" --quiet > /dev/null 2>&1; then
    echo "ERREUR: MongoDB n'est pas accessible!"
    echo "Assurez-vous que MongoDB est démarré."
    exit 1
fi

echo "MongoDB est accessible ✓"
echo ""

echo "Importation en cours..."
if mongoimport --uri "$MONGO_URI" \
  --collection "$COLLECTION" \
  --type csv \
  --headerline \
  --ignoreBlanks \
  --file "$CSV_FILE" \
  --drop; then
    echo ""
    echo "========================================"
    echo "Importation réussie! ✓"
    echo "========================================"
    echo ""
    echo "Pour vous connecter à MongoDB:"
    echo "mongosh \"$MONGO_URI\""
    echo ""
    echo "Ou dans MongoDB Compass, connectez-vous à:"
    echo "$MONGO_URI"
else
    echo ""
    echo "ERREUR lors de l'importation!"
    exit 1
fi
```

Rendez-le exécutable :
```bash
chmod +x import_mongodb_local.sh
```

### Script PowerShell (Windows)

Créez un fichier `import_mongodb_local.ps1` :

```powershell
# Script pour importer CSV dans MongoDB local (sans Docker)

$CSV_FILE = "yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv"
$DB_NAME = "bigdata_project"
$COLLECTION = "youtube_comments"
$MONGO_URI = "mongodb://localhost:27017/$DB_NAME"

# Si vous avez besoin d'authentification, utilisez :
# $MONGO_URI = "mongodb://admin:password@localhost:27017/$DB_NAME?authSource=admin"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Importation CSV vers MongoDB Local" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (-Not (Test-Path $CSV_FILE)) {
    Write-Host "ERREUR: Le fichier $CSV_FILE n'existe pas!" -ForegroundColor Red
    exit 1
}

Write-Host "Fichier trouvé: $CSV_FILE" -ForegroundColor Green
Write-Host "Base de données: $DB_NAME" -ForegroundColor Green
Write-Host "Collection: $COLLECTION" -ForegroundColor Green
Write-Host ""

Write-Host "Vérification de la connexion MongoDB..." -ForegroundColor Yellow
$mongoCheck = mongosh "$MONGO_URI" --eval "db.version()" --quiet 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR: MongoDB n'est pas accessible!" -ForegroundColor Red
    Write-Host "Assurez-vous que MongoDB est démarré." -ForegroundColor Yellow
    exit 1
}

Write-Host "MongoDB est accessible ✓" -ForegroundColor Green
Write-Host ""

Write-Host "Importation en cours..." -ForegroundColor Yellow
mongoimport --uri $MONGO_URI `
  --collection $COLLECTION `
  --type csv `
  --headerline `
  --ignoreBlanks `
  --file $CSV_FILE `
  --drop

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Importation réussie! ✓" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Pour vous connecter à MongoDB:" -ForegroundColor Cyan
    Write-Host "mongosh `"$MONGO_URI`"" -ForegroundColor White
    Write-Host ""
    Write-Host "Ou dans MongoDB Compass, connectez-vous à:" -ForegroundColor Cyan
    Write-Host "$MONGO_URI" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "ERREUR lors de l'importation!" -ForegroundColor Red
    exit 1
}
```

---

## 📊 Utiliser les Données

### Dans MongoDB Compass

1. Sélectionnez la collection `youtube_comments`
2. Utilisez l'onglet "Documents" pour voir les données
3. Utilisez l'onglet "Aggregations" pour créer des pipelines d'agrégation
4. Utilisez l'onglet "Schema" pour analyser la structure des données

### Dans mongosh (Ligne de Commande)

Toutes les commandes MongoDB fonctionnent normalement :

```javascript
use bigdata_project

// Compter les documents
db.youtube_comments.countDocuments()

// Afficher 5 documents
db.youtube_comments.find().limit(5).pretty()

// Top 10 commentaires les plus likés
db.youtube_comments.aggregate([
  { $addFields: { likeCount: { $toInt: "$Likes" } } },
  { $sort: { likeCount: -1 } },
  { $limit: 10 }
])
```

---

## 🔍 Différences Clés : Docker vs Local

| Aspect | Docker | Local/Compass |
|--------|--------|---------------|
| **Connection String** | `mongodb://admin:password@localhost:27017/bigdata_project?authSource=admin` | `mongodb://localhost:27017/bigdata_project` |
| **Authentification** | Requise (admin/password) | Optionnelle (selon votre config) |
| **Import** | Via `docker exec` | Direct avec `mongoimport` ou Compass |
| **Connexion** | `docker exec -it mongodb mongosh -u admin -p password` | `mongosh` ou MongoDB Compass |

---

## ⚠️ Notes Importantes

1. **Port par défaut** : MongoDB utilise le port `27017` par défaut
2. **Authentification** : Si votre MongoDB local n'a pas d'authentification, supprimez les paramètres `-u admin -p password` et `?authSource=admin`
3. **MongoDB Tools** : Assurez-vous que `mongoimport` et `mongosh` sont dans votre PATH
4. **MongoDB Compass** : L'interface graphique est plus facile pour les débutants

---

## 🆘 Dépannage

### MongoDB n'est pas accessible

**Linux :**
```bash
sudo systemctl start mongod
sudo systemctl status mongod
```

**macOS (Homebrew) :**
```bash
brew services start mongodb-community
```

**Windows :**
Vérifiez les Services Windows et démarrez "MongoDB Server"

### mongoimport non trouvé

Installez MongoDB Database Tools :
- **Linux** : `sudo apt-get install mongodb-database-tools` (Ubuntu/Debian)
- **macOS** : `brew install mongodb-database-tools`
- **Windows** : Téléchargez depuis https://www.mongodb.com/try/download/database-tools

### Erreur d'authentification

Si vous obtenez une erreur d'authentification :
1. Vérifiez vos identifiants
2. Ou désactivez l'authentification dans votre configuration MongoDB locale
3. Ou créez un utilisateur avec les bons privilèges

---

## 📚 Documentation Complète

Pour toutes les commandes MongoDB, consultez :
- **`PROJET_BIGDATA_MONGODB.md`** : Toutes les commandes détaillées
- **`COMMANDES_ESSENTIELLES.md`** : Récapitulatif des commandes principales

