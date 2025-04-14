# Script tối ưu hóa taskbar lên trên và sửa lỗi che title bar

Write-Host "`n[+] Đang khởi chạy script sửa lỗi taskbar..." -ForegroundColor Cyan

# 1. Xóa các khóa Registry để reset vị trí và cache của taskbar
$keysToDelete = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Streams"
)

foreach ($key in $keysToDelete) {
    if (Test-Path $key) {
        Remove-Item $key -Recurse -Force
        Write-Host "[+] Đã xóa khóa: $key"
    } else {
        Write-Host "[-] Không tìm thấy khóa: $key"
    }
}

# 2. Thiết lập taskbar ở trên cùng màn hình (top)
# Tạo lại StuckRects3 với cấu hình taskbar ở trên
# Byte thứ 12 (offset 0x0C) cần là 03 để taskbar ở top

$binary = [byte[]](
    0x28,0x00,0x00,0x00,0x02,0x00,0x00,0x00,
    0x03,0x00,0x00,0x00,0x03,0x00,0x00,0x00,
    0xFE,0xFF,0xFF,0xFF,0xFE,0xFF,0xFF,0xFF,
    0xFE,0xFF,0xFF,0xFF,0xFE,0xFF,0xFF,0xFF,
    0x01,0x00,0x00,0x00
)

New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" -Name Settings -Value $binary
Write-Host "[+] Đã thiết lập vị trí taskbar ở TOP (03)"

# 3. Khởi động lại Windows Explorer
Write-Host "[~] Đang khởi động lại Windows Explorer..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force
Start-Process explorer
Start-Sleep -Seconds 2

# 4. Khóa taskbar mà không kích hoạt tự ẩn
$regTaskbarSettings = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $regTaskbarSettings -Name TaskbarSizeMove -Value 0  # Khóa taskbar

Write-Host "[+] Taskbar đã được đặt lên trên và khóa lại." -ForegroundColor Green
Write-Host "[!] Hoàn tất. Hãy thử mở ứng dụng để kiểm tra lỗi title bar bị che đã biến mất chưa.`n" -ForegroundColor Cyan
