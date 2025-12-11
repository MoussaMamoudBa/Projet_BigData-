# 🔄 Transformation vers Structure Propre (Modèle Recommandé)

Ce guide explique comment transformer vos données vers la structure propre et standardisée recommandée pour MongoDB.

---

## 📋 Structures de Documents

### Structure Initiale (Après Import CSV)

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

**Caractéristiques de cette structure :**
- ⚠️ Noms de champs longs (`Name`, `Comment`, `isHearted`)
- ⚠️ Types inappropriés : `Likes` peut être String ou Number selon l'import
- ⚠️ Dates en format String (`Date`: "03/12/25 07:24:13")
- ⚠️ Booléens en String (`isHearted`: "yes"/"no" au lieu de true/false)
- ⚠️ Métadonnées dispersées (pas regroupées)
- ⚠️ Champ avec caractères spéciaux `(view source)`

**Cette structure est fonctionnelle mais pas optimale pour les requêtes et agrégations.**

---

### Structure Propre (Modèle Recommandé) ⭐

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

### Comparaison : Structure Initiale vs Structure Propre

| Aspect | Structure Initiale | Structure Propre (Recommandée) |
|--------|-------------------|-------------------------------|
| **ID Commentaire** | `id` (Number) | `comment_id` (Number) |
| **Auteur** | `Name` (String) | `author` (String) |
| **Texte** | `Comment` (String) | `text` (String) |
| **Date** | `Date` (String: "03/12/25 07:24:13") | `timestamp` (ISODate) |
| **Likes** | `Likes` (Number/String) | `metadata.likes` (Number) |
| **Hearted** | `isHearted` (String: "yes"/"no") | `metadata.hearted` (Boolean) |
| **Pinned** | `isPinned` (String: "yes"/"no") | `metadata.pinned` (Boolean) |
| **Source** | - | `metadata.source` (String) |
| **Champ spécial** | `(view source)` (String) | - (supprimé) |

### Avantages de la Structure Propre

✅ **Noms de champs courts et clairs**
- `comment_id` au lieu de `id`
- `author` au lieu de `Name`
- `text` au lieu de `Comment`
- `timestamp` au lieu de `Date`

✅ **Métadonnées regroupées**
- Toutes les métadonnées dans un objet `metadata`
- Meilleure organisation et lisibilité
- Facilite les requêtes sur les métadonnées

✅ **Types de données appropriés**
- `ISODate` pour les dates (au lieu de String)
- `Number` pour les likes (garanti)
- `Boolean` pour hearted/pinned (au lieu de "yes"/"no")

✅ **Source documentée**
- Le champ `metadata.source` indique l'origine des données

✅ **Champs problématiques supprimés**
- Le champ `(view source)` avec caractères spéciaux est supprimé

---

## ⚠️ Important : La Collection "Clean" n'est pas dans Git

**Les collections MongoDB ne sont pas versionnées dans Git !**

Quand quelqu'un fait un `git pull` de votre projet :
- ✅ Il obtiendra les scripts et la documentation
- ❌ Il n'aura **PAS** la collection `youtube_comments_clean` automatiquement
- ✅ Il devra exécuter la transformation lui-même

**Solution :** Utilisez les scripts automatisés fournis :
- **Linux/macOS** : `./transform_to_clean_structure.sh`
- **Windows** : `.\transform_to_clean_structure.ps1`

Ces scripts créent automatiquement la collection `youtube_comments_clean` à partir de `youtube_comments`.

---

## 🔄 Transformation Complète

### Option 1 : Script Automatisé (Recommandé) ⭐

**Linux/macOS :**
```bash
./transform_to_clean_structure.sh
```

**Windows PowerShell :**
```powershell
.\transform_to_clean_structure.ps1
```

Ces scripts :
- ✅ Vérifient que la collection source existe
- ✅ Transforment automatiquement vers la structure propre
- ✅ Créent les index recommandés
- ✅ Affichent un exemple de document transformé

### Option 2 : Créer une Nouvelle Collection Manuellement

**Créer une collection `youtube_comments_clean` avec la structure propre :**

```javascript
use bigdata_project

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

**Vérifier la transformation :**

```javascript
// Voir un exemple
db.youtube_comments_clean.findOne().pretty()

// Compter les documents
db.youtube_comments_clean.countDocuments()

// Voir quelques exemples
db.youtube_comments_clean.find().limit(5).pretty()
```

### Option 2 : Mettre à Jour la Collection Existante

**Remplacer les documents existants :**

```javascript
use bigdata_project

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
    $merge: {
      into: "youtube_comments",
      whenMatched: "replace"
    }
  }
])
```

**⚠️ Attention :** Cette option remplace les documents existants. Assurez-vous d'avoir une sauvegarde si nécessaire.

---

## 📊 Exemples de Requêtes avec la Structure Propre

### Recherche Simple

```javascript
// Rechercher un mot-clé dans le texte
db.youtube_comments_clean.find({ 
  "text": /2025/i 
}).pretty()

// Rechercher par auteur
db.youtube_comments_clean.find({ 
  "author": "@AmalRoy-q2h" 
}).pretty()
```

### Requêtes sur les Métadonnées

```javascript
// Commentaires avec plus de 3 likes
db.youtube_comments_clean.find({ 
  "metadata.likes": { $gt: 3 } 
}).pretty()

// Commentaires hearted par le créateur
db.youtube_comments_clean.find({ 
  "metadata.hearted": true 
}).pretty()

// Commentaires épinglés
db.youtube_comments_clean.find({ 
  "metadata.pinned": true 
}).pretty()
```

### Tri et Limitation

```javascript
// Top 10 commentaires les plus likés
db.youtube_comments_clean.find()
  .sort({ "metadata.likes": -1 })
  .limit(10)
  .pretty()

// Commentaires les plus récents
db.youtube_comments_clean.find()
  .sort({ "timestamp": -1 })
  .limit(10)
  .pretty()
```

### Agrégations

```javascript
// Statistiques par auteur
db.youtube_comments_clean.aggregate([
  {
    $group: {
      _id: "$author",
      totalComments: { $sum: 1 },
      totalLikes: { $sum: "$metadata.likes" },
      avgLikes: { $avg: "$metadata.likes" }
    }
  },
  { $sort: { totalComments: -1 } }
])

// Statistiques globales
db.youtube_comments_clean.aggregate([
  {
    $group: {
      _id: null,
      totalComments: { $sum: 1 },
      totalLikes: { $sum: "$metadata.likes" },
      avgLikes: { $avg: "$metadata.likes" },
      maxLikes: { $max: "$metadata.likes" },
      heartedCount: {
        $sum: { $cond: ["$metadata.hearted", 1, 0] }
      },
      pinnedCount: {
        $sum: { $cond: ["$metadata.pinned", 1, 0] }
      }
    }
  }
])
```

### Recherche par Date

```javascript
// Commentaires d'une date spécifique
db.youtube_comments_clean.find({
  timestamp: {
    $gte: ISODate("2025-12-03T00:00:00Z"),
    $lte: ISODate("2025-12-03T23:59:59Z")
  }
}).pretty()

// Commentaires des 7 derniers jours
db.youtube_comments_clean.find({
  timestamp: {
    $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
  }
}).pretty()
```

---

## 🔍 Comparaison des Requêtes

### Avant (Structure Initiale)

```javascript
// Recherche avec conversion
db.youtube_comments.aggregate([
  { $addFields: { likeCount: { $toInt: "$Likes" } } },
  { $match: { likeCount: { $gt: 3 } } }
])
```

### Après (Structure Propre)

```javascript
// Recherche directe
db.youtube_comments_clean.find({ 
  "metadata.likes": { $gt: 3 } 
})
```

**Avantage** : Plus simple, plus rapide, pas besoin de conversion à chaque requête.

---

## 📈 Indexation Recommandée

Créer des index pour améliorer les performances :

```javascript
// Index sur comment_id
db.youtube_comments_clean.createIndex({ "comment_id": 1 })

// Index sur author
db.youtube_comments_clean.createIndex({ "author": 1 })

// Index sur metadata.likes (pour tri rapide)
db.youtube_comments_clean.createIndex({ "metadata.likes": -1 })

// Index sur timestamp (pour recherche par date)
db.youtube_comments_clean.createIndex({ "timestamp": -1 })

// Index textuel pour recherche full-text
db.youtube_comments_clean.createIndex({ "text": "text" })

// Index composé (author + metadata.likes)
db.youtube_comments_clean.createIndex({ 
  "author": 1, 
  "metadata.likes": -1 
})
```

---

## ✅ Vérification de la Transformation

### Script de Vérification

```javascript
use bigdata_project

// Vérifier le nombre de documents
print("Nombre de documents transformés: " + 
  db.youtube_comments_clean.countDocuments())

// Vérifier la structure d'un document
print("\nExemple de document transformé:")
printjson(db.youtube_comments_clean.findOne())

// Vérifier les types de données
print("\nVérification des types:")
var sample = db.youtube_comments_clean.findOne()
print("comment_id type: " + typeof sample.comment_id)
print("metadata.likes type: " + typeof sample.metadata.likes)
print("metadata.hearted type: " + typeof sample.metadata.hearted)
print("timestamp type: " + sample.timestamp.constructor.name)

// Statistiques rapides
print("\nStatistiques:")
var stats = db.youtube_comments_clean.aggregate([
  {
    $group: {
      _id: null,
      total: { $sum: 1 },
      totalLikes: { $sum: "$metadata.likes" },
      avgLikes: { $avg: "$metadata.likes" },
      hearted: { $sum: { $cond: ["$metadata.hearted", 1, 0] } },
      pinned: { $sum: { $cond: ["$metadata.pinned", 1, 0] } }
    }
  }
]).toArray()[0]

print("Total commentaires: " + stats.total)
print("Total likes: " + stats.totalLikes)
print("Moyenne likes: " + stats.avgLikes.toFixed(2))
print("Commentaires hearted: " + stats.hearted)
print("Commentaires épinglés: " + stats.pinned)
```

---

## 🎯 Résumé

### Avant Transformation
- Champs avec noms longs (`Name`, `Comment`, `isHearted`)
- Types inappropriés (String pour nombres, dates)
- Métadonnées dispersées

### Après Transformation
- ✅ Champs courts et clairs (`author`, `text`, `comment_id`)
- ✅ Types appropriés (Number, Boolean, ISODate)
- ✅ Métadonnées regroupées dans `metadata`
- ✅ Structure standardisée et exploitable
- ✅ Requêtes plus simples et performantes

---

**Note** : La structure propre est recommandée pour tous les nouveaux projets MongoDB. Elle facilite la maintenance, les requêtes et les agrégations.

