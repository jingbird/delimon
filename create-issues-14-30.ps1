# -*- coding: utf-8 -*-
# 繝・Μ繝｢繝ｳ Issue #14-30 閾ｪ蜍穂ｽ懈・繧ｹ繧ｯ繝ｪ繝励ヨ

Write-Host "=== Issue #14-30菴懈・髢句ｧ・===" -ForegroundColor Cyan

Set-Location "C:\Users\cr9ka\MyProject\delimon"

$issues = @(
    @{Number=14; File="docs\issues\14-profile-setup-screen.md"},
    @{Number=15; File="docs\issues\15-profile-edit-screen.md"},
    @{Number=16; File="docs\issues\16-tutorial-screen.md"},
    @{Number=17; File="docs\issues\17-splash-screen-routing-logic.md"},
    @{Number=18; File="docs\issues\18-evolution-feature.md"},
    @{Number=19; File="docs\issues\19-evolution-animation-screen.md"},
    @{Number=20; File="docs\issues\20-collection-screen.md"},
    @{Number=21; File="docs\issues\21-history-screen-list.md"},
    @{Number=22; File="docs\issues\22-history-screen-stats.md"},
    @{Number=23; File="docs\issues\23-settings-menu-screen.md"},
    @{Number=24; File="docs\issues\24-privacy-terms-screens.md"},
    @{Number=25; File="docs\issues\25-account-deletion.md"},
    @{Number=26; File="docs\issues\26-push-notifications.md"},
    @{Number=27; File="docs\issues\27-error-handling-loading.md"},
    @{Number=28; File="docs\issues\28-sentry-integration.md"},
    @{Number=29; File="docs\issues\29-performance-optimization.md"},
    @{Number=30; File="docs\issues\30-final-testing-bugfix.md"}
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
