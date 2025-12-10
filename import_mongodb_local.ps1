# Script pour importer CSV dans MongoDB local (sans Docker)

$CSV_FILE = "yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv"
$DB_NAME = "bigdata_project"
$COLLECTION = "youtube_comments"
$MONGO_URI = "mongodb://localhost:27017/$DB_NAME"

# Si vous avez besoin d'authentification, décommentez la ligne suivante :
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
    Write-Host ""
    Write-Host "Vérifiez les Services Windows pour MongoDB Server" -ForegroundColor Yellow
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
    Write-Host ""
    Write-Host "Pour vérifier les données:" -ForegroundColor Cyan
    Write-Host "mongosh `"$MONGO_URI`" --eval `"db.$COLLECTION.countDocuments()`"" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "ERREUR lors de l'importation!" -ForegroundColor Red
    exit 1
}

