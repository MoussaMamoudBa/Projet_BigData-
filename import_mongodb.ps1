# Script PowerShell pour importer le CSV dans MongoDB
# Usage: .\import_mongodb.ps1

$CSV_FILE = "yt-comments_kJQP7kiw5Fk_22182891 - ExportComments.com.csv"
$DB_NAME = "bigdata_project"
$COLLECTION = "youtube_comments"
$MONGO_URI = "mongodb://admin:password@localhost:27017/$DB_NAME?authSource=admin"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Importation CSV vers MongoDB" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier si le fichier existe
if (-Not (Test-Path $CSV_FILE)) {
    Write-Host "ERREUR: Le fichier $CSV_FILE n'existe pas!" -ForegroundColor Red
    exit 1
}

Write-Host "Fichier trouvé: $CSV_FILE" -ForegroundColor Green
Write-Host "Base de données: $DB_NAME" -ForegroundColor Green
Write-Host "Collection: $COLLECTION" -ForegroundColor Green
Write-Host ""

# Vérifier si MongoDB est accessible
Write-Host "Vérification de la connexion MongoDB..." -ForegroundColor Yellow
$mongoCheck = docker exec mongodb mongosh --eval "db.version()" --quiet 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR: MongoDB n'est pas accessible!" -ForegroundColor Red
    Write-Host "Assurez-vous que Docker est démarré et que MongoDB fonctionne." -ForegroundColor Yellow
    exit 1
}

Write-Host "MongoDB est accessible ✓" -ForegroundColor Green
Write-Host ""

# Copier le fichier dans le conteneur
Write-Host "Copie du fichier dans le conteneur Docker..." -ForegroundColor Yellow
docker cp $CSV_FILE mongodb:/tmp/comments.csv

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR lors de la copie du fichier!" -ForegroundColor Red
    exit 1
}

Write-Host "Fichier copié ✓" -ForegroundColor Green
Write-Host ""

# Importer dans MongoDB
Write-Host "Importation en cours..." -ForegroundColor Yellow
docker exec mongodb mongoimport --uri $MONGO_URI `
  --collection $COLLECTION `
  --type csv `
  --headerline `
  --ignoreBlanks `
  --file /tmp/comments.csv `
  --drop

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Importation réussie! ✓" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Pour vous connecter à MongoDB:" -ForegroundColor Cyan
    Write-Host "docker exec -it mongodb mongosh -u admin -p password" -ForegroundColor White
    Write-Host ""
    Write-Host "Pour utiliser la base de données:" -ForegroundColor Cyan
    Write-Host "use $DB_NAME" -ForegroundColor White
    Write-Host "db.$COLLECTION.countDocuments()" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "ERREUR lors de l'importation!" -ForegroundColor Red
    exit 1
}


