#!/bin/bash
# Script Bash pour importer le CSV dans MongoDB
# Usage: ./import_mongodb.sh

CSV_FILE="yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv"
DB_NAME="bigdata_project"
COLLECTION="youtube_comments"
MONGO_URI="mongodb://admin:password@localhost:27017/$DB_NAME?authSource=admin"

echo "========================================"
echo "Importation CSV vers MongoDB"
echo "========================================"
echo ""

# Vérifier si le fichier existe
if [ ! -f "$CSV_FILE" ]; then
    echo "ERREUR: Le fichier $CSV_FILE n'existe pas!"
    exit 1
fi

echo "Fichier trouvé: $CSV_FILE"
echo "Base de données: $DB_NAME"
echo "Collection: $COLLECTION"
echo ""

# Vérifier si MongoDB est accessible
echo "Vérification de la connexion MongoDB..."
if ! docker exec mongodb mongosh -u admin -p password --eval "db.version()" --quiet > /dev/null 2>&1; then
    echo "ERREUR: MongoDB n'est pas accessible!"
    echo "Assurez-vous que Docker est démarré et que MongoDB fonctionne."
    echo "Lancez: docker compose up -d"
    exit 1
fi

echo "MongoDB est accessible ✓"
echo ""

# Copier le fichier dans le conteneur
echo "Copie du fichier dans le conteneur Docker..."
if ! docker cp "$CSV_FILE" mongodb:/tmp/comments.csv; then
    echo "ERREUR lors de la copie du fichier!"
    exit 1
fi

echo "Fichier copié ✓"
echo ""

# Importer dans MongoDB
echo "Importation en cours..."
if docker exec mongodb mongoimport --uri "$MONGO_URI" \
  --collection "$COLLECTION" \
  --type csv \
  --headerline \
  --ignoreBlanks \
  --file /tmp/comments.csv \
  --drop; then
    echo ""
    echo "========================================"
    echo "Importation réussie! ✓"
    echo "========================================"
    echo ""
    echo "Pour vous connecter à MongoDB:"
    echo "docker exec -it mongodb mongosh -u admin -p password"
    echo ""
    echo "Pour utiliser la base de données:"
    echo "use $DB_NAME"
    echo "db.$COLLECTION.countDocuments()"
else
    echo ""
    echo "ERREUR lors de l'importation!"
    exit 1
fi

