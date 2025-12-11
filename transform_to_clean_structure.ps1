# Script PowerShell pour transformer les données vers la structure propre recommandée
# Usage: .\transform_to_clean_structure.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Transformation vers Structure Propre" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier si MongoDB est accessible (avec Docker)
$dockerRunning = docker ps 2>&1 | Select-String -Pattern "mongodb" -Quiet

if ($dockerRunning) {
    Write-Host "MongoDB Docker détecté ✓" -ForegroundColor Green
    $USE_DOCKER = $true
    $MONGO_URI = "mongodb://admin:password@localhost:27017/bigdata_project?authSource=admin"
} else {
    Write-Host "MongoDB local détecté" -ForegroundColor Yellow
    $USE_DOCKER = $false
    $MONGO_URI = "mongodb://localhost:27017/bigdata_project"
}

Write-Host ""
Write-Host "Vérification de la collection source..." -ForegroundColor Yellow

if ($USE_DOCKER) {
    $countOutput = docker exec mongodb mongosh "$MONGO_URI" --eval "db.youtube_comments.countDocuments()" --quiet 2>&1
    $COUNT = ($countOutput | Select-String -Pattern '^\d+$').Matches.Value
} else {
    $countOutput = mongosh "$MONGO_URI" --eval "db.youtube_comments.countDocuments()" --quiet 2>&1
    $COUNT = ($countOutput | Select-String -Pattern '^\d+$').Matches.Value
}

if (-not $COUNT -or $COUNT -eq "0") {
    Write-Host "ERREUR: La collection youtube_comments n'existe pas ou est vide!" -ForegroundColor Red
    Write-Host "Veuillez d'abord importer les données avec .\import_mongodb.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "Collection source trouvée: $COUNT documents" -ForegroundColor Green
Write-Host ""

# Script de transformation
$transformScript = @"
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
    `$project: {
      comment_id: { `$toInt: "`$id" },
      author: "`$Name",
      text: "`$Comment",
      metadata: {
        likes: { `$toInt: "`$Likes" },
        hearted: { `$eq: ["`$isHearted", "yes"] },
        pinned: { `$eq: ["`$isPinned", "yes"] },
        source: "youtube"
      },
      timestamp: {
        `$dateFromString: {
          dateString: {
            `$concat: [
              { `$substr: ["`$Date", 6, 2] }, "/",
              { `$substr: ["`$Date", 3, 2] }, "/",
              "20", { `$substr: ["`$Date", 0, 2] },
              " ",
              { `$substr: ["`$Date", 9, 8] }
            ]
          },
          format: "%d/%m/%Y %H:%M:%S",
          onError: null
        }
      }
    }
  },
  {
    `$out: "youtube_comments_clean"
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
"@

# Exécuter la transformation
Write-Host "Exécution de la transformation..." -ForegroundColor Yellow
Write-Host ""

if ($USE_DOCKER) {
    $transformScript | docker exec -i mongodb mongosh "$MONGO_URI" --quiet
} else {
    $transformScript | mongosh "$MONGO_URI" --quiet
}

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Transformation réussie!" -ForegroundColor Green
    Write-Host ""
    Write-Host "La collection 'youtube_comments_clean' est maintenant disponible." -ForegroundColor Cyan
    Write-Host "Vous pouvez l'utiliser avec toutes les requêtes de la structure propre." -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "❌ ERREUR lors de la transformation!" -ForegroundColor Red
    exit 1
}

