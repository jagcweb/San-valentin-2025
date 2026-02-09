# Rotar fisicamente las fotos que estan mal orientadas
Add-Type -AssemblyName System.Drawing

$fotosARotar = @(
    ".\img\7-12-2025_1.jpg",
    ".\img\7-12-2025_2.jpg",
    ".\img\22-10-2025.jpg",
    ".\img\8-11-2025.jpg",
    ".\img\10-11-2025.jpg",
    ".\img\6-2-2026_1.jpg",
    ".\img\27-11-2025.jpg",
    ".\img\6-12-2025.jpg",
    ".\img\5-1-2026.jpg",
    ".\img\10-1-2026_1.jpg",
    ".\img\10-1-2026_2.jpg",
    ".\img\6-2-2026_2.jpg"
)

foreach ($foto in $fotosARotar) {
    if (Test-Path $foto) {
        try {
            Write-Host "Rotando: $foto" -ForegroundColor Cyan
            
            $img = [System.Drawing.Image]::FromFile($foto)
            $img.RotateFlip([System.Drawing.RotateFlipType]::Rotate90FlipNone)
            
            $tempPath = "$foto.tmp"
            $img.Save($tempPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
            $img.Dispose()
            
            Remove-Item $foto -Force
            Move-Item $tempPath $foto -Force
            
            Write-Host "  OK - Rotada correctamente" -ForegroundColor Green
        } catch {
            Write-Warning "Error rotando $foto"
        }
    } else {
        Write-Warning "No encontrada: $foto"
    }
}

Write-Host ""
Write-Host "Proceso completado!" -ForegroundColor Green