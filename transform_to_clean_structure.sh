#!/bin/bash
# Script pour transformer les données vers la structure propre recommandée
# Usage: ./transform_to_clean_structure.sh

echo "========================================"
echo "Transformation vers Structure Propre"
echo "========================================"
echo ""

# Vérifier si MongoDB est accessible (avec Docker)
if docker ps | grep -q mongodb; then
    echo "MongoDB Docker détecté ✓"
    USE_DOCKER=true
    MONGO_CMD="docker exec mongodb mongosh"
    MONGO_URI="mongodb://admin:password@localhost:27017/bigdata_project?authSource=admin"
else
    echo "MongoDB local détecté"
    USE_DOCKER=false
    MONGO_CMD="mongosh"
    MONGO_URI="mongodb://localhost:27017/bigdata_project"
fi

echo ""
echo "Vérification de la collection source..."
if [ "$USE_DOCKER" = true ]; then
    COUNT=$(docker exec mongodb mongosh "$MONGO_URI" --eval "db.youtube_comments.countDocuments()" --quiet 2>/dev/null | grep -E '^[0-9]+$')
else
    COUNT=$(mongosh "$MONGO_URI" --eval "db.youtube_comments.countDocuments()" --quiet 2>/dev/null | grep -E '^[0-9]+$')
fi

if [ -z "$COUNT" ] || [ "$COUNT" -eq 0 ]; then
    echo "ERREUR: La collection youtube_comments n'existe pas ou est vide!"
    echo "Veuillez d'abord importer les données avec ./import_mongodb.sh"
    exit 1
fi

echo "Collection source trouvée: $COUNT documents"
echo ""

# Créer le script de transformation
TRANSFORM_SCRIPT=$(cat <<'EOF'
use bigdata_project

print("Début de la transformation...")
print("")

// Compter les documents avant transformation
var beforeCount = db.youtube_comments.countDocuments()
print("Documents à transformer: " + beforeCount)

// Transformation vers structure propre
print("Transformation en cours...")
var result = db.youtube_comments.aggregate([
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
]).toArray()

print("")
print("Transformation terminée!")
print("")

// Vérifier le résultat
var afterCount = db.youtube_comments_clean.countDocuments()
print("Documents transformés: " + afterCount)

if (afterCount === beforeCount) {
    print("✅ SUCCÈS: Tous les documents ont été transformés!")
} else {
    print("⚠️ ATTENTION: Nombre de documents différent!")
    print("Avant: " + beforeCount + ", Après: " + afterCount)
}

// Afficher un exemple
print("")
print("Exemple de document transformé:")
printjson(db.youtube_comments_clean.findOne())

// Créer les index recommandés
print("")
print("Création des index...")
db.youtube_comments_clean.createIndex({ "comment_id": 1 })
db.youtube_comments_clean.createIndex({ "author": 1 })
db.youtube_comments_clean.createIndex({ "metadata.likes": -1 })
db.youtube_comments_clean.createIndex({ "timestamp": -1 })
db.youtube_comments_clean.createIndex({ "text": "text" })
print("✅ Index créés!")

print("")
print("========================================")
print("Transformation terminée avec succès!")
print("========================================")
print("")
print("Collection créée: youtube_comments_clean")
print("Pour utiliser la nouvelle collection:")
print("  db.youtube_comments_clean.find().limit(5).pretty()")
EOF
)

# Exécuter la transformation
if [ "$USE_DOCKER" = true ]; then
    echo "$TRANSFORM_SCRIPT" | docker exec -i mongodb mongosh "$MONGO_URI" --quiet
else
    echo "$TRANSFORM_SCRIPT" | mongosh "$MONGO_URI" --quiet
fi

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Transformation réussie!"
    echo ""
    echo "La collection 'youtube_comments_clean' est maintenant disponible."
    echo "Vous pouvez l'utiliser avec toutes les requêtes de la structure propre."
else
    echo ""
    echo "❌ ERREUR lors de la transformation!"
    exit 1
fi

