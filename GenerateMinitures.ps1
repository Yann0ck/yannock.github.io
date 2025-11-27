# ===================================================================
# Script de generation automatique de miniatures pour galeries
# Usage: .\GenerateMiniatures.ps1
# ===================================================================

param(
    [string]$GaleriesPath = ".\galeries",
    [int]$ThumbnailWidth = 300,
    [int]$JpegQuality = 90
)

# Chargement de l'assembly pour manipulation d'images
Add-Type -AssemblyName System.Drawing

Write-Host "Demarrage de la generation des miniatures..." -ForegroundColor Cyan
Write-Host ""

# Verifier si le dossier galeries existe
if (-not (Test-Path $GaleriesPath)) {
    Write-Host "Le dossier '$GaleriesPath' n'existe pas!" -ForegroundColor Red
    Write-Host "Creation du dossier..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $GaleriesPath | Out-Null
    Write-Host "Dossier cree. Ajoutez-y vos galeries et relancez le script." -ForegroundColor Green
    exit
}

# ------------------------------------------------------------
# Chargement du watermark (watermark.png à côte du script)
# ------------------------------------------------------------

$watermarkBitmap = $null
$watermarkPath   = Join-Path $PSScriptRoot "watermark.png"

if (Test-Path $watermarkPath) {
    try {
        $wmOriginal = [System.Drawing.Image]::FromFile($watermarkPath)

        # Redimensionner à largeur max 200 px (en gardant le ratio)
        $maxWidth = 200
        $targetWidth  = $wmOriginal.Width
        $targetHeight = $wmOriginal.Height

        if ($wmOriginal.Width -gt $maxWidth) {
            $scale        = $maxWidth / $wmOriginal.Width
            $targetWidth  = [int]$maxWidth
            $targetHeight = [int]([double]$wmOriginal.Height * $scale)
        }

        $watermarkBitmap = New-Object System.Drawing.Bitmap($targetWidth, $targetHeight)
        $g = [System.Drawing.Graphics]::FromImage($watermarkBitmap)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.DrawImage($wmOriginal, 0, 0, $targetWidth, $targetHeight)
        $g.Dispose()
        $wmOriginal.Dispose()

        Write-Host "Watermark charge depuis $watermarkPath ( ${targetWidth}x${targetHeight} )" -ForegroundColor Green
    }
    catch {
        Write-Host "Impossible de charger le watermark : $($_.Exception.Message)" -ForegroundColor Yellow
        $watermarkBitmap = $null
    }
}
else {
    Write-Host "Aucun watermark trouve (watermark.png). Conversion sans watermark." -ForegroundColor Yellow
}

# ------------------------------------------------------------
# Fonctions utilitaires
# ------------------------------------------------------------

# Encodeur JPEG partage
$jpegEncoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
               Where-Object { $_.MimeType -eq 'image/jpeg' }

function New-JpegEncoderParameters([int]$Quality) {
    $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
        [System.Drawing.Imaging.Encoder]::Quality, $Quality
    )
    return $encoderParams
}

# Fonction pour creer une miniature
function Create-Thumbnail {
    param(
        [string]$SourcePath,
        [string]$DestPath,
        [int]$Width,
        [int]$Quality
    )
    
    try {
        $image = [System.Drawing.Image]::FromFile($SourcePath)
        
        # Calcul des dimensions en gardant le ratio
        $ratio  = $image.Height / $image.Width
        $height = [int]($Width * $ratio)
        
        # Creation de la miniature
        $thumbnail = New-Object System.Drawing.Bitmap($Width, $height)
        $graphics  = [System.Drawing.Graphics]::FromImage($thumbnail)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.DrawImage($image, 0, 0, $Width, $height)
        
        # Sauvegarder en JPEG
        $encoderParams = New-JpegEncoderParameters -Quality $Quality
        $thumbnail.Save($DestPath, $jpegEncoder, $encoderParams)
        
        # Nettoyage
        $graphics.Dispose()
        $thumbnail.Dispose()
        $image.Dispose()
        
        return $true
    }
    catch {
        Write-Host "Erreur miniature $($SourcePath): $($_.Exception.Message)" -ForegroundColor Yellow
        return $false
    }
}

# Fonction pour convertir PNG -> JPG avec watermark
function Convert-ToJpegWithWatermark {
    param(
        [string]$SourcePath,
        [string]$DestPath,
        [System.Drawing.Bitmap]$Watermark,
        [int]$Quality
    )

    try {
        $image = [System.Drawing.Image]::FromFile($SourcePath)

        # On travaille dans un Bitmap plein format
        $bitmap  = New-Object System.Drawing.Bitmap($image.Width, $image.Height)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.DrawImage($image, 0, 0, $image.Width, $image.Height)

        # Dessiner le watermark si dispo
        if ($Watermark -ne $null) {
            $margin = 10
            $wmW = $Watermark.Width
            $wmH = $Watermark.Height

            $x = $image.Width  - $wmW - $margin
            $y = $image.Height - $wmH - $margin

            if ($x -lt 0) { $x = 0 }
            if ($y -lt 0) { $y = 0 }

            $graphics.DrawImage(
                $Watermark,
                [System.Drawing.Rectangle]::new($x, $y, $wmW, $wmH)
            )
        }

        # Sauvegarder en JPEG
        $encoderParams = New-JpegEncoderParameters -Quality $Quality
        $bitmap.Save($DestPath, $jpegEncoder, $encoderParams)

        # Nettoyage
        $graphics.Dispose()
        $bitmap.Dispose()
        $image.Dispose()

        return $true
    }
    catch {
        Write-Host "Erreur conversion $($SourcePath): $($_.Exception.Message)" -ForegroundColor Yellow
        return $false
    }
}

# ------------------------------------------------------------
# Parcourir tous les sous-dossiers de galeries
# ------------------------------------------------------------

$galerieFolders = Get-ChildItem -Path $GaleriesPath -Directory

if ($galerieFolders.Count -eq 0) {
    Write-Host "Aucune galerie trouvee dans '$GaleriesPath'" -ForegroundColor Red
    Write-Host "Creez un dossier (ex: 'novembre2955') et ajoutez-y des images PNG" -ForegroundColor Yellow
    exit
}

$totalProcessed = 0

foreach ($folder in $galerieFolders) {
    Write-Host "Traitement de la galerie: $($folder.Name)" -ForegroundColor Green
    
    # 1) Conversion PNG -> JPG + watermark
    $pngImages = Get-ChildItem -Path $folder.FullName -Filter "*.png"

    foreach ($png in $pngImages) {
        $jpgName = [System.IO.Path]::GetFileNameWithoutExtension($png.Name) + ".jpg"
        $jpgPath = Join-Path $folder.FullName $jpgName

        if (-not (Test-Path $jpgPath) -or $png.LastWriteTime -gt (Get-Item $jpgPath).LastWriteTime) {
            Write-Host "Conversion PNG -> JPG + watermark : $($png.Name)..." -NoNewline
            if (Convert-ToJpegWithWatermark -SourcePath $png.FullName -DestPath $jpgPath -Watermark $watermarkBitmap -Quality $JpegQuality) {
                Write-Host " Ok" -ForegroundColor Green
            }
        }
        else {
            Write-Host "JPG dejà à jour pour $($png.Name)" -ForegroundColor Gray
        }

        # Suppression du PNG brut (on garde seulement les JPG)
        Remove-Item $png.FullName -ErrorAction SilentlyContinue
    }

    # 2) Creer le dossier thumbs s'il n'existe pas
    $thumbsPath = Join-Path $folder.FullName "thumbs"
    if (-not (Test-Path $thumbsPath)) {
        New-Item -ItemType Directory -Path $thumbsPath | Out-Null
    }
    
    # 3) Recuperer toutes les images JPG (originaux definitifs)
    $images = Get-ChildItem -Path $folder.FullName -Filter "*.jpg"
    
    if ($images.Count -eq 0) {
        Write-Host "Aucune image JPG trouvee dans $($folder.Name)" -ForegroundColor Yellow
        continue
    }
    
    $imagesList     = @()
    $processedCount = 0
    
    foreach ($image in $images) {
        $thumbName = [System.IO.Path]::GetFileNameWithoutExtension($image.Name) + "_thumb.jpg"
        $thumbPath = Join-Path $thumbsPath $thumbName
        
        # Generer la miniature si elle n'existe pas ou si l'image source est plus recente
        if (-not (Test-Path $thumbPath) -or $image.LastWriteTime -gt (Get-Item $thumbPath).LastWriteTime) {
            Write-Host "Miniature: $($image.Name)..." -NoNewline
            
            if (Create-Thumbnail -SourcePath $image.FullName -DestPath $thumbPath -Width $ThumbnailWidth -Quality $JpegQuality) {
                Write-Host " Ok" -ForegroundColor Green
                $processedCount++
            }
        }
        else {
            Write-Host " Miniature dejà à jour: $($image.Name)" -ForegroundColor Gray
        }
        
        # Ajouter à la liste pour le JSON
        $imagesList += @{
            original = $image.Name
            thumb    = "thumbs/$thumbName"
        }
    }

    # 4) Determiner une date de galerie basee sur les fichiers (PNG -> JPG dejà geres)
    $galleryDate = $null

    if ($images.Count -gt 0) {
        $refImage = $images | Sort-Object LastWriteTime | Select-Object -Last 1
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($refImage.Name)

        # Pattern Game Bar : 13_04_2025
        $matchGameBar = [regex]::Match($baseName, '\b\d{2}_\d{2}_\d{4}\b')
        # Pattern ReShade : 2025-07-12
        $matchReShade = [regex]::Match($baseName, '\b\d{4}-\d{2}-\d{2}\b')

        if ($matchGameBar.Success) {
            $rawDate = $matchGameBar.Value
            try {
                $galleryDate = [datetime]::ParseExact($rawDate, 'dd_MM_yyyy', $null)
            }
            catch {
                $galleryDate = $null
            }
        }
        elseif ($matchReShade.Success) {
            $rawDate = $matchReShade.Value
            try {
                $galleryDate = [datetime]::ParseExact($rawDate, 'yyyy-MM-dd', $null)
            }
            catch {
                $galleryDate = $null
            }
        }

        if (-not $galleryDate) {
            $galleryDate = $refImage.LastWriteTime
        }
    }

    if (-not $galleryDate) {
        $galleryDate = Get-Date
    }
    
    # 5) Creer le fichier index.json
    $jsonPath = Join-Path $folder.FullName "index.json"
    $galerieData = @{
        nom    = $folder.Name -replace '-', ' ' -replace '_', ' '
        date   = $galleryDate.ToString("yyyy-MM-dd")
        images = $imagesList
    }
    
    $galerieData | ConvertTo-Json -Depth 3 | Set-Content -Path $jsonPath -Encoding UTF8
    
    Write-Host "index.json cree avec $($images.Count) images (date galerie: $($galerieData.date))" -ForegroundColor Cyan
    Write-Host "$processedCount nouvelle(s) miniature(s) generee(s)" -ForegroundColor Green
    Write-Host ""
    
    $totalProcessed += $processedCount
}

# 6) Creer le fichier index global des galeries
$globalIndex = @()
foreach ($folder in $galerieFolders) {
    $jsonPath = Join-Path $folder.FullName "index.json"
    if (Test-Path $jsonPath) {
        $galerieData = Get-Content $jsonPath | ConvertFrom-Json
        $globalIndex += @{
            id         = $folder.Name
            nom        = $galerieData.nom
            date       = $galerieData.date
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
Write-Host "Termine!" -ForegroundColor Green
Write-Host "Total: $totalProcessed miniature(s) generee(s)" -ForegroundColor Green
Write-Host "Fichier index global cree: galleries-index.json" -ForegroundColor Cyan
Write-Host ""
Write-Host "Prochaines etapes:" -ForegroundColor Yellow
Write-Host "   git"
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
