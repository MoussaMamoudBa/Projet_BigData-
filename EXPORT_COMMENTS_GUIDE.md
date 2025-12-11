# 📥 Guide d'Export des Commentaires YouTube

Ce guide explique comment exporter des commentaires YouTube en utilisant ExportComments.com pour les analyser dans MongoDB.

---

## 🎯 À Propos d'ExportComments.com

**ExportComments.com** est un service en ligne gratuit qui permet d'extraire et d'exporter les commentaires YouTube au format CSV. C'est un outil pratique pour l'analyse de données et les projets Big Data.

**Site web** : https://exportcomments.com/

---

## 📹 Données du Projet Actuel

### Vidéo Source

Les commentaires analysés dans ce projet proviennent de :

- **Titre** : Enrique Iglesias - Bailando (Español) ft. Descemer Bueno, Gente De Zona
- **Artiste** : Enrique Iglesias
- **URL YouTube** : https://www.youtube.com/watch?v=NUsoVlDFqZg
- **Vues** : 3 763 899 492+ vues (au moment de l'export)
- **Date de publication** : 11 avril 2014
- **Hashtags** : #EnriqueIglesias #Bailando

### Fichier Exporté

- **Nom du fichier** : `yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv`
- **Nombre de commentaires** : 100
- **Format** : CSV (Comma-Separated Values)
- **Date d'export** : Décembre 2025

---

## 📋 Comment Exporter des Commentaires YouTube

### Étape 1 : Préparer l'URL de la Vidéo

1. Ouvrez YouTube et trouvez la vidéo dont vous voulez exporter les commentaires
2. Copiez l'URL complète de la vidéo
   - Format : `https://www.youtube.com/watch?v=VIDEO_ID`
   - Exemple : `https://www.youtube.com/watch?v=NUsoVlDFqZg`

### Étape 2 : Utiliser ExportComments.com

1. **Accédez au site** : https://exportcomments.com/
2. **Collez l'URL YouTube** dans le champ prévu à cet effet
3. **Configurez les options d'export** :
   - Nombre de commentaires à exporter (100, 500, 1000, etc.)
   - Format de sortie (CSV recommandé pour MongoDB)
   - Options supplémentaires selon vos besoins
4. **Cliquez sur "Export"** ou "Download"
5. **Attendez le traitement** (peut prendre quelques minutes selon le nombre de commentaires)
6. **Téléchargez le fichier CSV** généré

### Étape 3 : Organiser le Fichier

Le fichier CSV exporté contiendra généralement :
- Un nom de fichier avec l'ID de la vidéo et le service d'export
- Format : `yt-comments_VIDEO_ID_ExportComments.com.csv`

**Exemple** : `yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv`

---

## 📊 Structure du Fichier CSV Exporté

Le fichier CSV contient les colonnes suivantes :

| Colonne | Description | Exemple |
|---------|-------------|---------|
| `id` | Identifiant unique du commentaire | `1`, `2`, `3` |
| `Name` | Nom d'utilisateur YouTube | `@kevinricardogustanlopez-b5u` |
| `Date` | Date et heure du commentaire | `03/12/25 06:24:13` |
| `Likes` | Nombre de likes reçus | `3`, `5`, `10` |
| `isHearted` | Si le créateur a "liké" le commentaire | `yes`, `no` |
| `isPinned` | Si le commentaire est épinglé | `yes`, `no` |
| `Comment` | Texte du commentaire | `"Quien en 2025?"` |
| `(view source)` | Lien vers le commentaire original | `view comment` |

### Exemple de Ligne CSV

```csv
id,Name,Date,Likes,isHearted,isPinned,Comment,(view source)
1,@kevinricardogustanlopez-b5u,03/12/25 06:24:13,3,yes,no,Quien en 2025?,view comment
2,@kevinricardogustanlopez-b5u,03/12/25 06:24:13,2,yes,no,Quien escuchandola en diciembre del 2025?,view comment
```

---

## 🔄 Réexporter des Données

Si vous voulez mettre à jour vos données ou exporter d'autres vidéos :

1. Suivez les étapes ci-dessus avec une nouvelle URL YouTube
2. Remplacez l'ancien fichier CSV par le nouveau
3. Réimportez dans MongoDB en utilisant les scripts fournis :
   ```bash
   ./import_mongodb.sh  # Avec Docker
   # ou
   ./import_mongodb_local.sh  # Sans Docker
   ```

---

## 💡 Conseils pour l'Export

### Choisir le Nombre de Commentaires

- **100 commentaires** : Idéal pour les tests et projets académiques
- **500-1000 commentaires** : Pour des analyses plus approfondies
- **Plus de 1000** : Pour des analyses Big Data complètes (peut prendre plus de temps)

### Format Recommandé

- **CSV** : Format recommandé pour MongoDB (facile à importer avec `mongoimport`)
- **JSON** : Alternative possible, mais nécessite une transformation avant l'import

### Gestion des Fichiers

- Gardez une copie du fichier CSV original
- Nommez clairement vos fichiers pour identifier la source
- Documentez la date d'export et la vidéo source

---

## 🎯 Cas d'Usage

### Analyse de Sentiment

Exporter les commentaires permet d'analyser :
- Les sentiments des utilisateurs (positif, négatif, neutre)
- Les mots-clés les plus fréquents
- L'engagement (likes, réponses)

### Analyse Temporelle

Avec les dates d'export, vous pouvez :
- Analyser les tendances dans le temps
- Identifier les pics d'activité
- Comparer différents exports de la même vidéo

### Analyse Multilingue

Les commentaires peuvent contenir plusieurs langues :
- Identifier les langues principales
- Analyser les commentaires par langue
- Détecter les communautés linguistiques

---

## ⚠️ Limitations et Considérations

1. **Limites d'ExportComments.com** :
   - Peut avoir des limites sur le nombre de commentaires gratuits
   - Le traitement peut prendre du temps pour les grandes vidéos

2. **Données Dynamiques** :
   - Les commentaires YouTube changent constamment
   - Un export à une date donnée capture un instantané

3. **Respect de la Vie Privée** :
   - Utilisez les données de manière éthique
   - Respectez les conditions d'utilisation de YouTube

---

## 📚 Ressources

- **ExportComments.com** : https://exportcomments.com/
- **Documentation MongoDB** : https://docs.mongodb.com/
- **Guide d'import MongoDB** : Voir `PROJET_BIGDATA_MONGODB.md`

---

## 🔗 Liens Utiles

- **Vidéo source du projet** : https://www.youtube.com/watch?v=NUsoVlDFqZg
- **Enrique Iglesias - Bailando** : Vidéo officielle sur YouTube
- **ExportComments.com** : Service d'export de commentaires

---

**Note** : Ce guide est basé sur l'utilisation d'ExportComments.com pour exporter les commentaires de la vidéo "Enrique Iglesias - Bailando" utilisée dans ce projet Big Data.

