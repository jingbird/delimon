# デリモン Issue #1-13 自動作成スクリプト

Write-Host "=== デリモン Issue #1-13 自動作成スクリプト ===" -ForegroundColor Cyan
Write-Host ""

# リポジトリのディレクトリに移動
Set-Location "C:\Users\cr9ka\MyProject\delimon"

# GitHub CLI認証確認
Write-Host "GitHub CLI認証状態を確認中..." -ForegroundColor Yellow
gh auth status
if ($LASTEXITCODE -ne 0) {
    Write-Host "エラー: GitHub CLIが認証されていません。'gh auth login' を実行してください。" -ForegroundColor Red
    exit 1
}

Write-Host "✓ 認証OK" -ForegroundColor Green
Write-Host ""

# Issue作成関数
function Create-Issue {
    param (
        [int]$IssueNumber,
        [string]$Title,
        [string]$BodyFile,
        [string[]]$Labels
    )

    Write-Host "Issue #${IssueNumber}: $Title を作成中..." -ForegroundColor Yellow

    $body = Get-Content -Path $BodyFile -Raw -Encoding UTF8
    $labelString = $Labels -join ","

    gh issue create --title $Title --body $body --label $labelString

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Issue #${IssueNumber} 作成完了" -ForegroundColor Green
    } else {
        Write-Host "✗ Issue #${IssueNumber} 作成失敗" -ForegroundColor Red
    }
    Write-Host ""
}

# Issue #1-13を作成
Create-Issue -IssueNumber 1 -Title "Issue #1: Expoプロジェクトのセットアップ" -BodyFile "docs\issues\1-expo-project-setup.md" -Labels @("infra", "setup")
Create-Issue -IssueNumber 2 -Title "Issue #2: Supabaseプロジェクトのセットアップ" -BodyFile "docs\issues\2-supabase-project-setup.md" -Labels @("infra", "backend")
Create-Issue -IssueNumber 3 -Title "Issue #3: データベーススキーマの作成" -BodyFile "docs\issues\3-database-schema-creation.md" -Labels @("backend", "database")
Create-Issue -IssueNumber 4 -Title "Issue #4: 状態管理・API通信の基盤構築" -BodyFile "docs\issues\4-state-management-api-foundation.md" -Labels @("frontend", "infra")
Create-Issue -IssueNumber 5 -Title "Issue #5: ログイン画面の実装" -BodyFile "docs\issues\5-login-screen.md" -Labels @("frontend", "auth")
Create-Issue -IssueNumber 6 -Title "Issue #6: サインアップ画面の実装" -BodyFile "docs\issues\6-signup-screen.md" -Labels @("frontend", "auth")
Create-Issue -IssueNumber 7 -Title "Issue #7: キャラクター選択画面の実装" -BodyFile "docs\issues\7-character-select-screen.md" -Labels @("frontend", "feature")
Create-Issue -IssueNumber 8 -Title "Issue #8: ホーム画面の基本実装" -BodyFile "docs\issues\8-home-screen-basic.md" -Labels @("frontend", "feature")
Create-Issue -IssueNumber 9 -Title "Issue #9: GPS計測機能の基本実装（前半）" -BodyFile "docs\issues\9-gps-tracking-basic-frontend.md" -Labels @("frontend", "feature", "gps")
Create-Issue -IssueNumber 10 -Title "Issue #10: GPS計測機能の基本実装（後半）" -BodyFile "docs\issues\10-gps-tracking-basic-backend.md" -Labels @("frontend", "backend", "feature", "gps")
Create-Issue -IssueNumber 11 -Title "Issue #11: 地図表示機能の実装" -BodyFile "docs\issues\11-map-display.md" -Labels @("frontend", "feature")
Create-Issue -IssueNumber 12 -Title "Issue #12: 経験値・レベルシステムの実装" -BodyFile "docs\issues\12-experience-level-system.md" -Labels @("backend", "feature")
Create-Issue -IssueNumber 13 -Title "Issue #13: 配送結果画面の実装" -BodyFile "docs\issues\13-delivery-result-screen.md" -Labels @("frontend", "feature")

Write-Host ""
Write-Host "=== すべてのIssue作成が完了しました ===" -ForegroundColor Cyan
Write-Host "GitHubリポジトリを確認してください: https://github.com/jingbird/delimon/issues" -ForegroundColor Green
