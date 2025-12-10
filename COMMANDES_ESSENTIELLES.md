# Commandes MongoDB Essentielles - Projet Big Data

## 🚀 Importation

### Commande principale

```bash
docker exec mongodb mongoimport --uri "mongodb://admin:password@localhost:27017/bigdata_project?authSource=admin" --collection youtube_comments --type csv --headerline --ignoreBlanks --file /tmp/comments.csv --drop
```

### Avec script PowerShell

```powershell
.\import_mongodb.ps1
```

---

## 📊 Commandes de Base

### Connexion à MongoDB

```bash
docker exec -it mongodb mongosh -u admin -p password
```

### Sélectionner la base de données

```javascript
use bigdata_project
```

### Compter les documents

```javascript
db.youtube_comments.countDocuments()
```

### Afficher 5 premiers documents

```javascript
db.youtube_comments.find().limit(5).pretty()
```

---

## 🔍 Recherche

### Rechercher un mot-clé

```javascript
db.youtube_comments.find({ "Comment": /2025/i }).pretty()
```

### Filtrer par auteur

```javascript
db.youtube_comments.find({ "Name": "@kevinricardogustanlopez-b5u" }).pretty()
```

### Top 10 commentaires les plus likés

```javascript
db.youtube_comments.aggregate([
  { $addFields: { likeCount: { $toInt: "$Likes" } } },
  { $sort: { likeCount: -1 } },
  { $limit: 10 }
])
```

---

## 📈 Statistiques

### Nombre total de commentaires

```javascript
db.youtube_comments.countDocuments()
```

### Commentaires par auteur

```javascript
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

### Top 10 auteurs les plus actifs

```javascript
db.youtube_comments.aggregate([
  {
    $group: {
      _id: "$Name",
      commentCount: { $sum: 1 }
    }
  },
  { $sort: { commentCount: -1 } },
  { $limit: 10 }
])
```

### Top 20 mots-clés

```javascript
db.youtube_comments.aggregate([
  { $project: { words: { $split: ["$Comment", " "] } } },
  { $unwind: "$words" },
  { $match: { words: { $ne: "", $exists: true } } },
  { $group: { _id: { $toLower: "$words" }, count: { $sum: 1 } } },
  { $sort: { count: -1 } },
  { $limit: 20 }
])
```

### Analyse de sentiment

```javascript
db.youtube_comments.aggregate([
  {
    $addFields: {
      sentiment: {
        $cond: {
          if: { $regexMatch: { input: "$Comment", regex: /love|❤|amazing|great|best|good/i } },
          then: "positive",
          else: {
            $cond: {
              if: { $regexMatch: { input: "$Comment", regex: /bad|hate|worst|terrible/i } },
              then: "negative",
              else: "neutral"
            }
          }
        }
      }
    }
  },
  {
    $group: {
      _id: "$sentiment",
      count: { $sum: 1 }
    }
  }
])
```

---

## 🧹 Nettoyage

### Supprimer commentaires vides

```javascript
db.youtube_comments.deleteMany({
  $or: [
    { "Comment": "" },
    { "Comment": { $exists: false } }
  ]
})
```

### Convertir Likes en nombre

```javascript
db.youtube_comments.updateMany(
  {},
  [{ $set: { likeCount: { $toInt: "$Likes" } } }]
)
```

### Ajouter longueur du texte

```javascript
db.youtube_comments.updateMany(
  {},
  [{ $set: { textLength: { $strLenCP: "$Comment" } } }]
)
```

---

## 📚 Documentation Complète

Pour toutes les commandes détaillées, consultez : **PROJET_BIGDATA_MONGODB.md**


