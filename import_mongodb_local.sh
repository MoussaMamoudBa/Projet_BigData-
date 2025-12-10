#!/bin/bash
# Script pour importer CSV dans MongoDB local (sans Docker)

CSV_FILE="yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv"
DB_NAME="bigdata_project"
COLLECTION="youtube_comments"
MONGO_URI="mongodb://localhost:27017/$DB_NAME"

# Si vous avez besoin d'authentification, décommentez la ligne suivante :
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
    echo ""
    echo "Pour démarrer MongoDB:"
    echo "  Linux: sudo systemctl start mongod"
    echo "  macOS: brew services start mongodb-community"
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
    echo ""
    echo "Pour vérifier les données:"
    echo "mongosh \"$MONGO_URI\" --eval \"db.$COLLECTION.countDocuments()\""
else
    echo ""
    echo "ERREUR lors de l'importation!"
    exit 1
fi

