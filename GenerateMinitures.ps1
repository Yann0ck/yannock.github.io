# ===================================================================
# Script de génération automatique de miniatures pour galeries
# Usage: .\GenerateMiniatures.ps1
# ===================================================================

param(
    [string]$GaleriesPath = ".\galeries",
    [int]$ThumbnailWidth = 300,
    [int]$JpegQuality = 85
)

# Chargement de l'assembly pour manipulation d'images
Add-Type -AssemblyName System.Drawing

Write-Host "🎨 Démarrage de la génération des miniatures..." -ForegroundColor Cyan
Write-Host ""

# Vérifier si le dossier galeries existe
if (-not (Test-Path $GaleriesPath)) {
    Write-Host "❌ Le dossier '$GaleriesPath' n'existe pas!" -ForegroundColor Red
    Write-Host "Création du dossier..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $GaleriesPath | Out-Null
    Write-Host "✅ Dossier créé. Ajoutez-y vos galeries et relancez le script." -ForegroundColor Green
    exit
}

# Fonction pour créer une miniature
function Create-Thumbnail {
    param(
        [string]$SourcePath,
        [string]$DestPath,
        [int]$Width
    )
    
    try {
        $image = [System.Drawing.Image]::FromFile($SourcePath)
        
        # Calcul des dimensions en gardant le ratio
        $ratio = $image.Height / $image.Width
        $height = [int]($Width * $ratio)
        
        # Création de la miniature
        $thumbnail = New-Object System.Drawing.Bitmap($Width, $height)
        $graphics = [System.Drawing.Graphics]::FromImage($thumbnail)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.DrawImage($image, 0, 0, $Width, $height)
        
        # Encodeur JPEG avec qualité
        $encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | 
                   Where-Object { $_.MimeType -eq 'image/jpeg' }
        $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
        $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
            [System.Drawing.Imaging.Encoder]::Quality, $JpegQuality
        )
        
        # Sauvegarder
        $thumbnail.Save($DestPath, $encoder, $encoderParams)
        
        # Nettoyage
        $graphics.Dispose()
        $thumbnail.Dispose()
        $image.Dispose()
        
        return $true
    }
    catch {
        Write-Host "  ⚠️  Erreur avec $($SourcePath): $($_.Exception.Message)" -ForegroundColor Yellow
        return $false
    }
}

# Parcourir tous les sous-dossiers de galeries
$galerieFolders = Get-ChildItem -Path $GaleriesPath -Directory

if ($galerieFolders.Count -eq 0) {
    Write-Host "❌ Aucune galerie trouvée dans '$GaleriesPath'" -ForegroundColor Red
    Write-Host "Créez un dossier (ex: 'novembre2955') et ajoutez-y des images PNG" -ForegroundColor Yellow
    exit
}

$totalProcessed = 0

foreach ($folder in $galerieFolders) {
    Write-Host "📁 Traitement de la galerie: $($folder.Name)" -ForegroundColor Green
    
    # Créer le dossier thumbs s'il n'existe pas
    $thumbsPath = Join-Path $folder.FullName "thumbs"
    if (-not (Test-Path $thumbsPath)) {
        New-Item -ItemType Directory -Path $thumbsPath | Out-Null
    }
    
    # Récupérer toutes les images PNG
    $images = Get-ChildItem -Path $folder.FullName -Filter "*.png"
    
    if ($images.Count -eq 0) {
        Write-Host "  ⚠️  Aucune image PNG trouvée dans $($folder.Name)" -ForegroundColor Yellow
        continue
    }
    
    $imagesList = @()
    $processedCount = 0
    
    foreach ($image in $images) {
        $thumbName = [System.IO.Path]::GetFileNameWithoutExtension($image.Name) + "_thumb.jpg"
        $thumbPath = Join-Path $thumbsPath $thumbName
        
        # Générer la miniature si elle n'existe pas ou si l'image source est plus récente
        if (-not (Test-Path $thumbPath) -or $image.LastWriteTime -gt (Get-Item $thumbPath).LastWriteTime) {
            Write-Host "  🖼️  Génération: $($image.Name)..." -NoNewline
            
            if (Create-Thumbnail -SourcePath $image.FullName -DestPath $thumbPath -Width $ThumbnailWidth) {
                Write-Host " ✅" -ForegroundColor Green
                $processedCount++
            }
        }
        else {
            Write-Host "  ⏭️  Déjà à jour: $($image.Name)" -ForegroundColor Gray
        }
        
        # Ajouter à la liste pour le JSON
        $imagesList += @{
            original = $image.Name
            thumb = "thumbs/$thumbName"
        }
    }
    
    # Créer le fichier index.json
    $jsonPath = Join-Path $folder.FullName "index.json"
    $galerieData = @{
        nom = $folder.Name -replace '-', ' ' -replace '_', ' '
        date = Get-Date -Format "yyyy-MM-dd"
        images = $imagesList
    }
    
    $galerieData | ConvertTo-Json -Depth 3 | Set-Content -Path $jsonPath -Encoding UTF8
    
    Write-Host "  📝 index.json créé avec $($images.Count) images" -ForegroundColor Cyan
    Write-Host "  ✅ $processedCount nouvelle(s) miniature(s) générée(s)" -ForegroundColor Green
    Write-Host ""
    
    $totalProcessed += $processedCount
}

# Créer le fichier index global des galeries
$globalIndex = @()
foreach ($folder in $galerieFolders) {
    $jsonPath = Join-Path $folder.FullName "index.json"
    if (Test-Path $jsonPath) {
        $galerieData = Get-Content $jsonPath | ConvertFrom-Json
        $globalIndex += @{
            id = $folder.Name
            nom = $galerieData.nom
            date = $galerieData.date
            imageCount = $galerieData.images.Count
            coverImage = if ($galerieData.images.Count -gt 0) { 
                $galerieData.images[0].thumb 
            } else { 
                "" 
            }
        }
    }
}

$globalIndexPath = Join-Path $GaleriesPath "galleries-index.json"
$globalIndex | ConvertTo-Json -Depth 3 | Set-Content -Path $globalIndexPath -Encoding UTF8

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✨ Terminé!" -ForegroundColor Green
Write-Host "📊 Total: $totalProcessed miniature(s) générée(s)" -ForegroundColor Green
Write-Host "📄 Fichier index global créé: galleries-index.json" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Prochaines étapes:" -ForegroundColor Yellow
Write-Host "   1. git add ." -ForegroundColor White
Write-Host "   2. git commit -m 'Ajout nouvelles galeries'" -ForegroundColor White
Write-Host "   3. git push" -ForegroundColor White
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan