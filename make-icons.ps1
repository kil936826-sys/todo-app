Add-Type -AssemblyName System.Drawing

function SaveIcon($sz, $path) {
  $bmp = New-Object System.Drawing.Bitmap($sz, $sz)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'HighQuality'
  $cx = [int]($sz / 2)
  $cy = [int]($sz / 2)

  # 1. Rounded dark background
  $cr = [int]($sz * 0.22)
  $bg  = [System.Drawing.Color]::FromArgb(255, 28, 36, 32) # deep forest
  $bgb = New-Object System.Drawing.SolidBrush($bg)
  $pt  = New-Object System.Drawing.Drawing2D.GraphicsPath
  $pt.AddArc(0, 0, $cr, $cr, 180, 90)
  $pt.AddArc($sz - $cr, 0, $cr, $cr, 270, 90)
  $pt.AddArc($sz - $cr, $sz - $cr, $cr, $cr, 0, 90)
  $pt.AddArc(0, $sz - $cr, $cr, $cr, 90, 90)
  $pt.CloseFigure()
  $g.FillPath($bgb, $pt)

  # 2. Gold ring (progress circle)
  $rr    = [int]($sz * 0.33)
  $rw    = [int]($sz * 0.042)
  $gold  = [System.Drawing.Color]::FromArgb(255, 212, 168, 83)
  $goldP = New-Object System.Drawing.Pen($gold, $rw)
  $goldP.StartCap = [System.Drawing.Drawing2D.DashCap]::Round
  $goldP.EndCap   = [System.Drawing.Drawing2D.DashCap]::Round
  $rX = $cx - $rr
  $rY = $cy - $rr
  $rD = $rr * 2
  $g.DrawArc($goldP, $rX, $rY, $rD, $rD, -90, 270)

  # 3. Green remainder ring
  $ringB = [System.Drawing.Color]::FromArgb(255, 50, 60, 54)
  $ringP = New-Object System.Drawing.Pen($ringB, $rw)
  $ringP.StartCap = [System.Drawing.Drawing2D.DashCap]::Round
  $ringP.EndCap   = [System.Drawing.Drawing2D.DashCap]::Round
  $g.DrawArc($ringP, $rX, $rY, $rD, $rD, 180, 90)

  # 4. Center checkmark
  $scale = $sz / 512.0
  $cw = [int](16 * $scale)
  $hw = [int](7 * $scale)
  $c0x = $cx - [int](34 * $scale)
  $c0y = $cy + [int](4 * $scale)
  $c1x = $cx - [int](2 * $scale)
  $c1y = $cy + [int](34 * $scale)
  $c2x = $cx + [int](36 * $scale)
  $c2y = $cy - [int](24 * $scale)

  $cPen = New-Object System.Drawing.Pen($gold, $cw)
  $cPen.StartCap = [System.Drawing.Drawing2D.DashCap]::Round
  $cPen.EndCap   = [System.Drawing.Drawing2D.DashCap]::Round
  $g.DrawLine($cPen, $c0x, $c0y, $c1x, $c1y)
  $g.DrawLine($cPen, $c1x, $c1y, $c2x, $c2y)

  # Highlight line on checkmark
  $hiCol = [System.Drawing.Color]::FromArgb(255, 250, 235, 200)
  $hiPen = New-Object System.Drawing.Pen($hiCol, $hw)
  $hiPen.StartCap = [System.Drawing.Drawing2D.DashCap]::Round
  $hiPen.EndCap   = [System.Drawing.Drawing2D.DashCap]::Round
  $g.DrawLine($hiPen, $c0x, $c0y - [int](2*$scale), $c1x, $c1y - [int](2*$scale))
  $g.DrawLine($hiPen, $c1x, $c1y - [int](2*$scale), $c2x, $c2y - [int](2*$scale))

  # 5. Tiny dot at the start of gold ring (top)
  $dotR = [int]($sz * 0.018)
  $dtA  = -90.0 * [Math]::PI / 180.0
  $dtX  = [int]($cx + $rr * [Math]::Cos($dtA) - $dotR)
  $dtY  = [int]($cy + $rr * [Math]::Sin($dtA) - $dotR)
  $dtB  = New-Object System.Drawing.SolidBrush($gold)
  $g.FillEllipse($dtB, $dtX, $dtY, $dotR * 2, $dotR * 2)

  $g.Dispose()
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  Write-Host "  OK $($sz)x$sz -> $path"
}

Write-Host "Generating icons..."
SaveIcon 512 "D:\todo-app\icons\icon-512.png"
SaveIcon 192 "D:\todo-app\icons\icon-192.png"
SaveIcon 180 "D:\todo-app\icons\apple-icon.png"
Write-Host "All done."