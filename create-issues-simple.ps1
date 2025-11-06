# -*- coding: utf-8 -*-
# 繝・Μ繝｢繝ｳ Issue #1-13 閾ｪ蜍穂ｽ懈・繧ｹ繧ｯ繝ｪ繝励ヨ

Write-Host "=== Issue菴懈・髢句ｧ・===" -ForegroundColor Cyan

Set-Location "C:\Users\cr9ka\MyProject\delimon"

$issues = @(
    @{Number=1; File="docs\issues\1-expo-project-setup.md"},
    @{Number=2; File="docs\issues\2-supabase-project-setup.md"},
    @{Number=3; File="docs\issues\3-database-schema-creation.md"},
    @{Number=4; File="docs\issues\4-state-management-api-foundation.md"},
    @{Number=5; File="docs\issues\5-login-screen.md"},
    @{Number=6; File="docs\issues\6-signup-screen.md"},
    @{Number=7; File="docs\issues\7-character-select-screen.md"},
    @{Number=8; File="docs\issues\8-home-screen-basic.md"},
    @{Number=9; File="docs\issues\9-gps-tracking-basic-frontend.md"},
    @{Number=10; File="docs\issues\10-gps-tracking-basic-backend.md"},
    @{Number=11; File="docs\issues\11-map-display.md"},
    @{Number=12; File="docs\issues\12-experience-level-system.md"},
    @{Number=13; File="docs\issues\13-delivery-result-screen.md"}
)

foreach ($issue in $issues) {
    Write-Host "Creating Issue #$($issue.Number)..." -ForegroundColor Yellow
    
    $content = Get-Content -Path $issue.File -Raw -Encoding UTF8
    $firstLine = ($content -split "`n")[0]
    $title = $firstLine -replace "^# ", ""
    
    gh issue create --repo jingbird/delimon --title $title --body-file $issue.File
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Success: Issue #$($issue.Number)" -ForegroundColor Green
    } else {
        Write-Host "Failed: Issue #$($issue.Number)" -ForegroundColor Red
    }
    
    Start-Sleep -Seconds 1
}

Write-Host ""
Write-Host "=== Complete ===" -ForegroundColor Cyan
Write-Host "Check: https://github.com/jingbird/delimon/issues" -ForegroundColor Green
