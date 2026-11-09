$ErrorActionPreference = 'Continue'
$log = 'C:\Users\edenn\mantra-beats\update.log'
function Log($m) { Add-Content -Path $log -Value ("{0} {1}" -f (Get-Date -Format 'HH:mm:ss'), $m) }
Set-Content -Path $log -Value 'start'
try {
  Set-Location 'C:\Users\edenn\mantra-beats'
  git add index.html 2>&1 | ForEach-Object { Log "git: $_" }
  git commit -m 'Add monk chorus, hit sound patterns and black theme' 2>&1 | ForEach-Object { Log "git: $_" }
  git push origin main 2>&1 | ForEach-Object { Log "push: $_" }
  Log 'DONE'
} catch {
  Log "FATAL: $($_.Exception.Message)"
  Log 'DONE'
}
