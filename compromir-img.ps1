# Script para comprimir imágenes JPG usando .NET nativo
# Requiere Windows PowerShell (no PowerShell Core en Linux/Mac)

$imgFolder = ".\img"
$maxWidth = 1920
$quality = 70

Add-Type -AssemblyName System.Drawing

# Función para obtener el codec JPEG
function Get-JpegCodec {
    $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | 
                 Where-Object { $_.MimeType -eq 'image/jpeg' }
    return $jpegCodec
}

# Función para comprimir imagen
function Compress-Image {
    param(
        [string]$InputPath,
        [int]$MaxWidth,
        [int]$Quality
    )
    
    $img = [System.Drawing.Image]::FromFile($InputPath)
    
    # Calcular nuevas dimensiones manteniendo aspecto
    if ($img.Width -gt $MaxWidth) {
        $ratio = $MaxWidth / $img.Width
        $newWidth = $MaxWidth
        $newHeight = [int]($img.Height * $ratio)
    } else {
        $newWidth = $img.Width
        $newHeight = $img.Height
    }
    
    # Crear nueva imagen redimensionada
    $newImg = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
    $graphics = [System.Drawing.Graphics]::FromImage($newImg)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.DrawImage($img, 0, 0, $newWidth, $newHeight)
    
    # Configurar calidad JPEG
    $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
        [System.Drawing.Imaging.Encoder]::Quality, 
        $Quality
    )
    
    # Guardar imagen comprimida
    $codec = Get-JpegCodec
    $tempPath = "$InputPath.tmp"
    $newImg.Save($tempPath, $codec, $encoderParams)
    
    # Limpiar recursos
    $graphics.Dispose()
    $newImg.Dispose()
    $img.Dispose()
    
    return $tempPath
}

# Procesar imágenes
Get-ChildItem $imgFolder -Include *.jpg,*.jpeg -Recurse | ForEach-Object {
    $imgPath = $_.FullName
    
    try {
        Write-Host "Procesando: $($_.Name)..." -ForegroundColor Cyan
        
        $tempPath = Compress-Image -InputPath $imgPath -MaxWidth $maxWidth -Quality $quality
        
        if (Test-Path $tempPath) {
            # Reemplazar original
            Remove-Item $imgPath -Force
            Move-Item $tempPath $imgPath -Force
            Write-Host "  Completado" -ForegroundColor Green
        }
    } catch {
        Write-Warning "Error procesando $imgPath`: $($_.Exception.Message)"
    }
}

Write-Host "`nProceso finalizado." -ForegroundColor Green