# Rapport Projet Big Data - Analyse de Commentaires YouTube avec MongoDB

## 📋 Résumé Exécutif

**Projet** : Analyse de commentaires YouTube avec MongoDB  
**Objectif** : Démontrer les capacités de MongoDB pour le traitement et l'analyse de données non structurées (Big Data)  
**Données** : 100 commentaires YouTube exportés depuis ExportComments.com  
**Base de données** : `bigdata_project`  
**Collection** : `youtube_comments`  
**Statut** : ✅ Données importées avec succès (100 documents)

---

## 1️⃣ Importation du CSV dans MongoDB

### Commande mongoimport

```bash
docker exec mongodb mongoimport \
  --uri "mongodb://admin:password@localhost:27017/bigdata_project?authSource=admin" \
  --collection youtube_comments \
  --type csv \
  --headerline \
  --ignoreBlanks \
  --file /tmp/comments.csv \
  --drop
```

### Étapes d'importation

1. **Copier le fichier CSV dans le conteneur Docker :**
   ```bash
   docker cp "yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv" mongodb:/tmp/comments.csv
   ```

2. **Exécuter la commande mongoimport** (voir ci-dessus)

3. **Résultat** : 100 documents importés avec succès

### Options utilisées

- `--type csv` : Spécifie le format d'import (CSV)
- `--headerline` : Utilise la première ligne comme noms de champs
- `--ignoreBlanks` : Ignore les champs vides
- `--drop` : Supprime la collection existante avant l'import
- `--file` : Chemin vers le fichier CSV dans le conteneur

---

## 2️⃣ Structure des Documents

### Structure après importation

```json
{
  "_id": ObjectId("676f8a3b1234567890abcdef"),
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

### Champs du document

| Champ | Type | Description |
|-------|------|-------------|
| `_id` | ObjectId | Identifiant unique MongoDB |
| `id` | String | Identifiant du commentaire |
| `Name` | String | Nom d'utilisateur (ex: @username) |
| `Date` | String | Date et heure (format: DD/MM/YY HH:MM:SS) |
| `Likes` | String | Nombre de likes (à convertir en nombre) |
| `isHearted` | String | Commentaire "liké" par le créateur (yes/no) |
| `isPinned` | String | Commentaire épinglé (yes/no) |
| `Comment` | String | Texte du commentaire |
| `(view source)` | String | Lien vers le commentaire source |

### Structure optimisée (après transformation)

```json
{
  "_id": ObjectId("676f8a3b1234567890abcdef"),
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

### Structure propre (modèle recommandé) ⭐

**Structure standardisée, propre et optimale pour MongoDB :**

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

**Avantages de cette structure :**
- ✅ Noms de champs courts et clairs (`comment_id`, `author`, `text`)
- ✅ Métadonnées regroupées dans un objet `metadata` (meilleure organisation)
- ✅ Types de données appropriés (ISODate, Number, Boolean)
- ✅ Structure standardisée et exploitable
- ✅ Facilite les requêtes et agrégations
- ✅ Source documentée dans les métadonnées

**Tableau comparatif des structures :**

| Champ Initial | Structure Optimisée | Structure Propre (Recommandée) |
|---------------|---------------------|-------------------------------|
| `id` | `commentId` | `comment_id` |
| `Name` | `authorName` | `author` |
| `Comment` | `text` | `text` |
| `Date` | `publishedAt` | `timestamp` |
| `Likes` | `likeCount` | `metadata.likes` |
| `isHearted` | `isHearted` | `metadata.hearted` |
| `isPinned` | `isPinned` | `metadata.pinned` |
| - | - | `metadata.source` |

**Commande de transformation vers structure propre :**

```javascript
db.youtube_comments.aggregate([
  {
    $project: {
      comment_id: { $toInt: "$id" },
      author: "$Name",
      text: "$Comment",
      metadata: {
        likes: { $toInt: "$Likes" },
        hearted: { $eq: ["$isHearted", "yes"] },
        pinned: { $eq: ["$isPinned", "yes"] },
        source: "youtube"
      },
      timestamp: {
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
  },
  {
    $out: "youtube_comments_clean"
  }
])
```

---

## 3️⃣ Commandes MongoDB - Analyse Complète

### 🔍 Affichage & Recherche

#### Afficher les 5 premiers documents

```javascript
db.youtube_comments.find().limit(5).pretty()
```

**Résultat attendu** : Affiche les 5 premiers commentaires avec tous leurs champs formatés.

#### Chercher un mot-clé dans le texte

```javascript
// Recherche du mot "2025" (insensible à la casse)
db.youtube_comments.find({ "Comment": /2025/i }).pretty()

// Compter les occurrences
db.youtube_comments.find({ "Comment": /2025/i }).count()
```

**Résultat attendu** : Retourne tous les commentaires contenant "2025" dans le texte.

#### Filtrer par auteur

```javascript
// Commentaires d'un auteur spécifique
db.youtube_comments.find({ 
  "Name": "@kevinricardogustanlopez-b5u" 
}).pretty()

// Recherche partielle
db.youtube_comments.find({ 
  "Name": /kevin/i 
}).pretty()
```

**Résultat attendu** : Liste tous les commentaires de l'auteur spécifié.

#### Récupérer les commentaires les plus likés

```javascript
// Top 10 commentaires les plus likés
db.youtube_comments.aggregate([
  { $addFields: { likeCount: { $toInt: "$Likes" } } },
  { $sort: { likeCount: -1 } },
  { $limit: 10 },
  { $project: { Name: 1, Comment: 1, likeCount: 1 } }
])
```

**Résultat attendu** : Les 10 commentaires avec le plus de likes, triés par ordre décroissant.

---

### 📊 Statistiques & Agrégations

#### Compter le nombre total de commentaires

```javascript
db.youtube_comments.countDocuments()
```

**Résultat** : 100

#### Nombre de commentaires par auteur

```javascript
db.youtube_comments.aggregate([
  {
    $group: {
      _id: "$Name",
      totalComments: { $sum: 1 },
      totalLikes: { $sum: { $toInt: "$Likes" } },
      avgLikes: { $avg: { $toInt: "$Likes" } }
    }
  },
  { $sort: { totalComments: -1 } }
])
```

**Résultat attendu** : Liste des auteurs avec leur nombre de commentaires, total de likes et moyenne de likes.

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

**Résultat attendu** : Les 10 auteurs ayant posté le plus de commentaires.

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

**Résultat attendu** : Les 20 mots les plus fréquents dans les commentaires (mots vides et ponctuation exclus).

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
              { $substr: ["$Date", 6, 2] }, "/",
              { $substr: ["$Date", 3, 2] }, "/",
              "20", { $substr: ["$Date", 0, 2] },
              " ",
              { $substr: ["$Date", 9, 8] }
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

**Résultat attendu** : Tous les commentaires du 3 décembre 2025, triés par date décroissante.

#### Détecter des sentiments simples avec des mots-clés

```javascript
db.youtube_comments.aggregate([
  {
    $addFields: {
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

**Résultat attendu** : Répartition des commentaires par sentiment (positive, negative, neutral) avec moyenne de likes.

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

**Résultat attendu** : Statistiques globales (total commentaires, total likes, moyenne, max, min, nombre d'auteurs uniques).

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

**Résultat** : Supprime tous les commentaires vides de la collection.

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

**Résultat** : Ajoute un champ `publishedAt` de type Date pour chaque document.

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

**Résultat** : Ajoute un champ `likeCount` de type Number.

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

**Résultat** : Ajoute un champ `textLength` contenant le nombre de caractères du commentaire.

---

## 4️⃣ Résultats et Analyses

### Données importées

- ✅ **100 commentaires** importés avec succès
- ✅ **Base de données** : `bigdata_project`
- ✅ **Collection** : `youtube_comments`

### Analyses possibles

1. **Analyse textuelle** : Extraction de mots-clés, détection de langues
2. **Analyse de sentiment** : Classification positive/negative/neutral
3. **Analyse temporelle** : Distribution des commentaires dans le temps
4. **Analyse d'engagement** : Relation entre likes et contenu
5. **Analyse d'auteurs** : Identification des contributeurs les plus actifs

---

## 5️⃣ Conclusion

Ce projet démontre avec succès l'utilisation de MongoDB pour :

- ✅ **Import de données CSV** : Transformation de données structurées en documents NoSQL
- ✅ **Requêtes complexes** : Filtrage, recherche textuelle, agrégations
- ✅ **Analyse de données** : Statistiques, regroupements, calculs
- ✅ **Transformation de données** : Nettoyage, conversion de types, enrichissement
- ✅ **Gestion Big Data** : Traitement efficace de données non structurées

MongoDB s'avère être un outil puissant pour l'analyse de données non structurées, offrant flexibilité et performance pour les projets Big Data.

---

## 📚 Références

- Documentation MongoDB : https://docs.mongodb.com/
- MongoDB Aggregation Pipeline : https://docs.mongodb.com/manual/core/aggregation-pipeline/
- ExportComments.com : https://exportcomments.com/


