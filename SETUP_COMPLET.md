# 🚀 Guide de Setup Complet pour Nouveaux Utilisateurs

Ce guide explique comment configurer le projet depuis zéro après un `git clone` ou `git pull`.

---

## ⚠️ Important : Ce qui est dans Git vs Ce qui ne l'est pas

### ✅ Dans Git (Versionné)
- Scripts d'importation
- Scripts de transformation
- Documentation
- Fichier CSV source
- Configuration Docker

### ❌ Pas dans Git (Doit être créé localement)
- **Collections MongoDB** (youtube_comments, youtube_comments_clean)
- **Base de données MongoDB** (bigdata_project)
- **Données dans MongoDB** (doivent être importées)

---

## 📋 Étapes Complètes de Setup

### 1. Cloner/Pull le Projet

```bash
git clone <url-du-repo>
# ou
git pull
```

### 2. Démarrer MongoDB

**Avec Docker (Recommandé) :**
```bash
docker compose up -d
```

**Sans Docker :**
- Assurez-vous que MongoDB est installé et démarré localement
- Voir `GUIDE_SANS_DOCKER.md` pour plus de détails

### 3. Importer les Données Initiales

**Avec Docker :**
```bash
# Linux/macOS
./import_mongodb.sh

# Windows PowerShell
.\import_mongodb.ps1
```

**Sans Docker :**
```bash
# Linux/macOS
./import_mongodb_local.sh

# Windows PowerShell
.\import_mongodb_local.ps1
```

**Résultat :** Collection `youtube_comments` créée avec 100 documents

### 4. Créer la Collection "Clean" (Structure Propre) ⭐

**La collection `youtube_comments_clean` n'existe pas automatiquement !**

Vous devez exécuter le script de transformation :

```bash
# Linux/macOS
./transform_to_clean_structure.sh

# Windows PowerShell
.\transform_to_clean_structure.ps1
```

**Résultat :** Collection `youtube_comments_clean` créée avec la structure propre recommandée

### 5. Vérifier que Tout Fonctionne

```bash
# Se connecter à MongoDB
docker exec -it mongodb mongosh -u admin -p password
# ou sans Docker: mongosh
```

Dans MongoDB shell :
```javascript
use bigdata_project

// Vérifier la collection initiale
db.youtube_comments.countDocuments()  // Devrait retourner 100

// Vérifier la collection clean
db.youtube_comments_clean.countDocuments()  // Devrait retourner 100

// Voir un exemple de document clean
db.youtube_comments_clean.findOne().pretty()
```

---

## 🔄 Workflow Complet

```
1. git clone/pull
   ↓
2. docker compose up -d
   ↓
3. ./import_mongodb.sh
   ↓ (Collection youtube_comments créée)
   ↓
4. ./transform_to_clean_structure.sh
   ↓ (Collection youtube_comments_clean créée)
   ↓
5. Utiliser les collections pour les requêtes
```

---

## 📊 Collections Disponibles

Après le setup complet, vous aurez **2 collections** :

### 1. `youtube_comments` (Structure Initiale)
- Structure brute après import CSV
- Champs : `id`, `Name`, `Date`, `Likes`, `isHearted`, `isPinned`, `Comment`
- Types : Principalement des Strings

### 2. `youtube_comments_clean` (Structure Propre) ⭐
- Structure transformée et optimisée
- Champs : `comment_id`, `author`, `text`, `metadata`, `timestamp`
- Types : Number, Boolean, ISODate
- **Recommandée pour les requêtes et analyses**

---

## ❓ FAQ

### Q: Pourquoi la collection "clean" n'est pas dans Git ?

**R:** Les collections MongoDB sont stockées dans la base de données, pas dans les fichiers. Git ne peut pas versionner les données MongoDB. Chaque personne doit créer la collection localement.

### Q: Dois-je créer les deux collections ?

**R:** Non, c'est optionnel. Vous pouvez :
- Utiliser seulement `youtube_comments` (structure initiale)
- Utiliser seulement `youtube_comments_clean` (structure propre) - **Recommandé**
- Utiliser les deux pour comparer

### Q: Que se passe-t-il si je ne crée pas la collection "clean" ?

**R:** Vous pouvez toujours utiliser `youtube_comments` avec la structure initiale. Cependant, la structure propre est recommandée car elle est plus optimisée et facilite les requêtes.

### Q: Puis-je recréer la collection "clean" ?

**R:** Oui, vous pouvez exécuter `transform_to_clean_structure.sh` autant de fois que nécessaire. Le script remplace la collection existante.

### Q: Les scripts fonctionnent-ils avec MongoDB Atlas ?

**R:** Oui, mais vous devez modifier les scripts pour utiliser votre connection string Atlas au lieu de `localhost`.

---

## 🎯 Checklist de Setup

- [ ] Projet cloné/pullé
- [ ] MongoDB démarré (Docker ou local)
- [ ] Données importées (`youtube_comments` existe)
- [ ] Collection clean créée (`youtube_comments_clean` existe)
- [ ] Vérification réussie (100 documents dans chaque collection)

---

## 📚 Documentation Complète

- **`README.md`** - Vue d'ensemble
- **`QUICK_START_LINUX.md`** - Démarrage rapide avec Docker
- **`GUIDE_SANS_DOCKER.md`** - Utilisation sans Docker
- **`TRANSFORMATION_STRUCTURE_PROPRE.md`** - Guide de transformation
- **`PROJET_BIGDATA_MONGODB.md`** - Toutes les commandes

---

**Note :** Si vous avez des problèmes, vérifiez que MongoDB est bien démarré et que vous avez exécuté les scripts dans l'ordre.

