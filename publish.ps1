$ErrorActionPreference = 'Continue'
$log = 'C:\Users\edenn\mantra-beats\publish.log'
function Log($m) { Add-Content -Path $log -Value ("{0} {1}" -f (Get-Date -Format 'HH:mm:ss'), $m) }
Set-Content -Path $log -Value 'start'
try {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  $dir = 'C:\Users\edenn\mantra-beats'
  Set-Location $dir
  $name = git -C 'C:\Users\edenn\rhythm-autoplay' config user.name
  $email = git -C 'C:\Users\edenn\rhythm-autoplay' config user.email
  Log "identity: $name / $email"
  git init -b main 2>&1 | ForEach-Object { Log "git: $_" }
  git config user.name $name
  git config user.email $email
  git add index.html
  git commit -m 'Publish Mantra Beats' 2>&1 | ForEach-Object { Log "git: $_" }
  $credInput = "protocol=https`nhost=github.com`n`n"
  $cred = $credInput | git credential fill
  $pw = ($cred | Where-Object { $_ -like 'password=*' }) -replace '^password=', ''
  if (-not $pw) { Log 'ERROR: no credential from GCM'; Log 'DONE'; exit 1 }
  Log 'credential obtained'
  $headers = @{ Authorization = "token $pw"; Accept = 'application/vnd.github+json'; 'User-Agent' = 'mantra-publish' }
  try {
    $repo = Invoke-RestMethod -Method Post -Uri 'https://api.github.com/user/repos' -Headers $headers -ContentType 'application/json' -Body '{"name":"mantra-beats","private":false,"description":"Mantra Beats - browser rhythm game"}'
    Log "repo created: $($repo.full_name)"
  } catch {
    Log "repo create note: $($_.Exception.Message)"
  }
  git remote remove origin 2>$null
  git remote add origin 'https://github.com/sinreikun/mantra-beats.git'
  git push -u origin main 2>&1 | ForEach-Object { Log "push: $_" }
  try {
    $pages = Invoke-RestMethod -Method Post -Uri 'https://api.github.com/repos/sinreikun/mantra-beats/pages' -Headers $headers -ContentType 'application/json' -Body '{"source":{"branch":"main","path":"/"}}'
    Log "pages enabled: $($pages.html_url)"
  } catch {
    Log "pages note: $($_.Exception.Message)"
  }
  Log 'DONE'
} catch {
  Log "FATAL: $($_.Exception.Message)"
  Log 'DONE'
}
