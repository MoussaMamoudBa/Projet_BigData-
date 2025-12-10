# Projet Big Data - Analyse de Commentaires YouTube avec MongoDB

## 📋 Résumé du Projet

Ce projet consiste à analyser des commentaires YouTube exportés depuis ExportComments.com en utilisant MongoDB comme base de données NoSQL. L'objectif est de démontrer les capacités de MongoDB pour le traitement et l'analyse de données non structurées (Big Data).

**Données** : 100 commentaires YouTube au format CSV  
**Base de données** : `bigdata_project`  
**Collection** : `youtube_comments`  
**Objectif** : Analyse textuelle, statistiques et agrégations sur les commentaires

---

## 1️⃣ Importation du CSV dans MongoDB

### Commande mongoimport

```bash
mongoimport --uri "mongodb://admin:password@localhost:27017/bigdata_project?authSource=admin" \
  --collection youtube_comments \
  --type csv \
  --headerline \
  --ignoreBlanks \
  --file "yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv" \
  --drop
```

### Explication des options

- `--uri` : Chaîne de connexion avec authentification
- `--collection youtube_comments` : Nom de la collection cible
- `--type csv` : Format d'import (CSV)
- `--headerline` : Utilise la première ligne comme noms de champs
- `--ignoreBlanks` : Ignore les champs vides
- `--file` : Chemin vers le fichier CSV
- `--drop` : Supprime la collection existante avant l'import (optionnel)

### Alternative avec Docker

Si MongoDB est dans Docker :

```bash
docker exec -i mongodb mongoimport --uri "mongodb://admin:password@localhost:27017/bigdata_project?authSource=admin" \
  --collection youtube_comments \
  --type csv \
  --headerline \
  --ignoreBlanks \
  --file /dev/stdin < "yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv"
```

Ou copier le fichier dans le conteneur :

```bash
docker cp "yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv" mongodb:/tmp/comments.csv
docker exec mongodb mongoimport --uri "mongodb://admin:password@localhost:27017/bigdata_project?authSource=admin" \
  --collection youtube_comments \
  --type csv \
  --headerline \
  --ignoreBlanks \
  --file /tmp/comments.csv
```

---

## 2️⃣ Structure des Documents

### Exemple de document après importation

```json
{
  "_id": ObjectId("..."),
  "id": "1",
  "Name": "@kevinricardogustanlopez-b5u",
  "Date": "03/12/25 06:24:13",
  "Likes": "3",
  "isHearted": "yes",
  "isPinned": "no",
  "Comment": "Quien en 2025?",
  "(view source)": "view comment"
}
```

### Structure optimisée (après transformation)

```json
{
  "_id": ObjectId("..."),
  "commentId": 1,
  "authorName": "@kevinricardogustanlopez-b5u",
  "publishedAt": ISODate("2025-12-03T06:24:13Z"),
  "likeCount": 3,
  "isHearted": true,
  "isPinned": false,
  "text": "Quien en 2025?",
  "textLength": 14,
  "sentiment": "neutral"
}
```

---

## 3️⃣ Commandes MongoDB - Analyse Complète

### 🔍 Affichage & Recherche

#### Afficher les 5 premiers documents

```javascript
db.youtube_comments.find().limit(5).pretty()
```

#### Chercher un mot-clé dans le texte

```javascript
// Recherche simple (insensible à la casse)
db.youtube_comments.find({ "Comment": /2025/i }).pretty()

// Recherche avec regex
db.youtube_comments.find({ 
  "Comment": { $regex: "2025", $options: "i" } 
}).count()

// Recherche multiple mots-clés
db.youtube_comments.find({
  $or: [
    { "Comment": /2025/i },
    { "Comment": /december/i },
    { "Comment": /décembre/i }
  ]
}).pretty()
```

#### Filtrer par auteur

```javascript
// Commentaires d'un auteur spécifique
db.youtube_comments.find({ 
  "Name": "@kevinricardogustanlopez-b5u" 
}).pretty()

// Recherche partielle d'auteur
db.youtube_comments.find({ 
  "Name": /kevin/i 
}).pretty()
```

#### Récupérer les commentaires les plus likés

```javascript
// Top 10 commentaires les plus likés
db.youtube_comments.find()
  .sort({ "Likes": -1 })
  .limit(10)
  .pretty()

// Avec conversion en nombre (si Likes est string)
db.youtube_comments.aggregate([
  { $addFields: { likeCount: { $toInt: "$Likes" } } },
  { $sort: { likeCount: -1 } },
  { $limit: 10 },
  { $project: { Name: 1, Comment: 1, likeCount: 1 } }
])
```

#### Commentaires avec plus de X likes

```javascript
db.youtube_comments.find({ 
  $expr: { $gt: [{ $toInt: "$Likes" }, 4] } 
}).pretty()
```

---

### 📊 Statistiques & Agrégations

#### Compter le nombre total de commentaires

```javascript
db.youtube_comments.countDocuments()

// Ou
db.youtube_comments.find().count()
```

#### Nombre de commentaires par auteur

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

#### Top 10 des auteurs les plus actifs

```javascript
db.youtube_comments.aggregate([
  {
    $group: {
      _id: "$Name",
      commentCount: { $sum: 1 },
      avgLikes: { $avg: { $toInt: "$Likes" } },
      totalLikes: { $sum: { $toInt: "$Likes" } }
    }
  },
  { $sort: { commentCount: -1 } },
  { $limit: 10 }
])
```

#### Top mots-clés (split basique sur les espaces)

```javascript
db.youtube_comments.aggregate([
  { $project: { words: { $split: ["$Comment", " "] } } },
  { $unwind: "$words" },
  { 
    $match: { 
      words: { 
        $not: { $regex: /^[.,!?;:()@#]+$/ },
        $ne: "",
        $exists: true
      }
    }
  },
  { $group: { _id: { $toLower: "$words" }, count: { $sum: 1 } } },
  { $sort: { count: -1 } },
  { $limit: 20 }
])
```

#### Filtrer les commentaires récents par date

```javascript
// Après conversion de Date en ISODate
db.youtube_comments.aggregate([
  {
    $addFields: {
      publishedDate: {
        $dateFromString: {
          dateString: {
            $concat: [
              { $substr: ["$Date", 6, 2] }, "/",  // jour
              { $substr: ["$Date", 3, 2] }, "/",  // mois
              "20", { $substr: ["$Date", 0, 2] }, // année
              " ",
              { $substr: ["$Date", 9, 8] }        // heure
            ]
          },
          format: "%d/%m/%Y %H:%M:%S"
        }
      }
    }
  },
  {
    $match: {
      publishedDate: {
        $gte: ISODate("2025-12-03T00:00:00Z"),
        $lte: ISODate("2025-12-03T23:59:59Z")
      }
    }
  },
  { $sort: { publishedDate: -1 } }
])
```

#### Détecter des sentiments simples avec des mots-clés

```javascript
db.youtube_comments.aggregate([
  {
    $addFields: {
      sentiment: {
        $cond: {
          if: { $regexMatch: { input: "$Comment", regex: /love|❤|amazing|great|best|good|beautiful|perfect/i } },
          then: "positive",
          else: {
            $cond: {
              if: { $regexMatch: { input: "$Comment", regex: /bad|hate|worst|terrible|sad|angry/i } },
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
      count: { $sum: 1 },
      avgLikes: { $avg: { $toInt: "$Likes" } }
    }
  }
])
```

#### Statistiques globales

```javascript
db.youtube_comments.aggregate([
  {
    $group: {
      _id: null,
      totalComments: { $sum: 1 },
      totalLikes: { $sum: { $toInt: "$Likes" } },
      avgLikes: { $avg: { $toInt: "$Likes" } },
      maxLikes: { $max: { $toInt: "$Likes" } },
      minLikes: { $min: { $toInt: "$Likes" } },
      uniqueAuthors: { $addToSet: "$Name" }
    }
  },
  {
    $project: {
      totalComments: 1,
      totalLikes: 1,
      avgLikes: { $round: ["$avgLikes", 2] },
      maxLikes: 1,
      minLikes: 1,
      uniqueAuthorsCount: { $size: "$uniqueAuthors" }
    }
  }
])
```

---

### 🧹 Nettoyage / Transformation

#### Supprimer les documents dont le texte est vide

```javascript
// Vérifier d'abord
db.youtube_comments.find({ 
  $or: [
    { "Comment": "" },
    { "Comment": { $exists: false } },
    { "Comment": null }
  ]
}).count()

// Supprimer
db.youtube_comments.deleteMany({
  $or: [
    { "Comment": "" },
    { "Comment": { $exists: false } },
    { "Comment": null }
  ]
})
```

#### Convertir le champ Date en type Date

```javascript
db.youtube_comments.updateMany(
  {},
  [
    {
      $set: {
        publishedAt: {
          $dateFromString: {
            dateString: {
              $concat: [
                { $substr: ["$Date", 6, 2] }, "/",
                { $substr: ["$Date", 3, 2] }, "/",
                "20", { $substr: ["$Date", 0, 2] },
                " ",
                { $substr: ["$Date", 9, 8] }
              ]
            },
            format: "%d/%m/%Y %H:%M:%S",
            onError: null
          }
        }
      }
    }
  ]
)
```

#### Convertir Likes en nombre

```javascript
db.youtube_comments.updateMany(
  {},
  [
    {
      $set: {
        likeCount: { $toInt: "$Likes" }
      }
    }
  ]
)
```

#### Ajouter un champ calculé (longueur du commentaire)

```javascript
db.youtube_comments.updateMany(
  {},
  [
    {
      $set: {
        textLength: { $strLenCP: "$Comment" }
      }
    }
  ]
)
```

#### Transformation complète (restructuration)

```javascript
db.youtube_comments.aggregate([
  {
    $project: {
      commentId: { $toInt: "$id" },
      authorName: "$Name",
      publishedAt: {
        $dateFromString: {
          dateString: {
            $concat: [
              { $substr: ["$Date", 6, 2] }, "/",
              { $substr: ["$Date", 3, 2] }, "/",
              "20", { $substr: ["$Date", 0, 2] },
              " ",
              { $substr: ["$Date", 9, 8] }
            ]
          },
          format: "%d/%m/%Y %H:%M:%S"
        }
      },
      likeCount: { $toInt: "$Likes" },
      isHearted: { $eq: ["$isHearted", "yes"] },
      isPinned: { $eq: ["$isPinned", "yes"] },
      text: "$Comment",
      textLength: { $strLenCP: "$Comment" }
    }
  },
  {
    $out: "youtube_comments_clean"
  }
])
```

#### Ajouter un champ sentiment

```javascript
db.youtube_comments.updateMany(
  {},
  [
    {
      $set: {
        sentiment: {
          $cond: {
            if: { $regexMatch: { input: "$Comment", regex: /love|❤|amazing|great|best|good|beautiful|perfect|excellent|wonderful/i } },
            then: "positive",
            else: {
              $cond: {
                if: { $regexMatch: { input: "$Comment", regex: /bad|hate|worst|terrible|sad|angry|disappointed/i } },
                then: "negative",
                else: "neutral"
              }
            }
          }
        }
      }
    }
  ]
)
```

---

## 4️⃣ Commandes Utiles Supplémentaires

### Indexation pour améliorer les performances

```javascript
// Index sur le nom d'auteur
db.youtube_comments.createIndex({ "Name": 1 })

// Index sur les likes (après conversion)
db.youtube_comments.createIndex({ "likeCount": -1 })

// Index sur la date (après conversion)
db.youtube_comments.createIndex({ "publishedAt": -1 })

// Index textuel pour recherche full-text
db.youtube_comments.createIndex({ "Comment": "text" })

// Recherche avec index textuel
db.youtube_comments.find({ $text: { $search: "2025 december" } })
```

### Export des résultats

```javascript
// Exporter vers JSON
mongoexport --uri "mongodb://admin:password@localhost:27017/bigdata_project?authSource=admin" \
  --collection youtube_comments \
  --out comments_export.json

// Exporter vers CSV
mongoexport --uri "mongodb://admin:password@localhost:27017/bigdata_project?authSource=admin" \
  --collection youtube_comments \
  --type csv \
  --fields id,Name,Date,Likes,Comment \
  --out comments_export.csv
```

### Requêtes complexes combinées

```javascript
// Commentaires positifs avec plus de 3 likes, triés par date
db.youtube_comments.aggregate([
  { $match: { sentiment: "positive", likeCount: { $gt: 3 } } },
  { $sort: { publishedAt: -1 } },
  { $project: { authorName: 1, text: 1, likeCount: 1, publishedAt: 1 } }
])

// Auteurs avec le meilleur ratio likes/commentaires
db.youtube_comments.aggregate([
  {
    $group: {
      _id: "$Name",
      totalComments: { $sum: 1 },
      totalLikes: { $sum: { $toInt: "$Likes" } }
    }
  },
  {
    $project: {
      authorName: "$_id",
      totalComments: 1,
      totalLikes: 1,
      avgLikesPerComment: { $divide: ["$totalLikes", "$totalComments"] }
    }
  },
  { $match: { totalComments: { $gt: 1 } } },
  { $sort: { avgLikesPerComment: -1 } },
  { $limit: 10 }
])
```

---

## 📝 Notes Importantes

1. **Authentification** : Utilisez `--authenticationDatabase admin` si nécessaire
2. **Types de données** : Les champs numériques peuvent être des strings après import CSV
3. **Dates** : Le format de date doit être converti pour les opérations de comparaison
4. **Performance** : Créez des index sur les champs fréquemment utilisés
5. **Nettoyage** : Effectuez les transformations de données avant les analyses complexes

---

## 🎯 Conclusion

Ce projet démontre l'utilisation de MongoDB pour :
- ✅ Import de données CSV
- ✅ Requêtes et filtres complexes
- ✅ Agrégations et statistiques
- ✅ Transformation et nettoyage de données
- ✅ Analyse textuelle basique
- ✅ Gestion de données non structurées (Big Data)


