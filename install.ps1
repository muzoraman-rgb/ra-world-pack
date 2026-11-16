# Ra World 26.3 - one-command installer for Windows (PowerShell 5.1+, no admin needed)
#
# Run in PowerShell:
#   irm https://raw.githubusercontent.com/muzoraman-rgb/ra-world-pack/main/install.ps1 | iex
#
# What it does:
#   - adds Fabric loader 0.20.1 for Minecraft 26.3 to the official launcher (version file only)
#   - makes a SEPARATE game folder %APPDATA%\.minecraft-raworld and a launcher profile "Ra World"
#     pointing at it, so your normal Minecraft stays exactly as it is
#   - downloads every mod and resource pack from Modrinth and checks each file's SHA-512
#   - never deletes your files; safe to run again (it only adds what is missing)

function Install-RaWorld {
    $ErrorActionPreference = 'Stop'
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    $FilesUrl    = 'https://github.com/muzoraman-rgb/ra-world-pack/releases/download/v1.1.0/ra-world-files.zip'
    $FilesSha512 = '3332b9b80d5282dfb99de0d01c9e7a3f9147423f83b9853c759d30ff028df8182ae9bcdc3e8ed3e2ccb8c2ae3d1d48ddc69fb88a67e9ab0d26717686ab956a85'
    $McVersion   = '26.3'
    $Loader      = '0.20.1'
    $VersionId   = "fabric-loader-$Loader-$McVersion"
    $UnboundUrl  = 'https://cdn.modrinth.com/data/R6NEzAwj/versions/B1kyfoUZ/ComplementaryUnbound_r5.9.3.zip'
    $UnboundSha  = 'a085d1d8cda67cd17a2b414eeba48bbd809da069f269bab46246235ec8fe714a275013c70d0504527b0987d810deddddba4564332414ab3b3bd7435932ff808c'
    $UnboundName = 'ComplementaryUnbound_r5.9.3.zip'
    $UA          = 'ra-world-installer/1.0'
    $Stamp       = Get-Date -Format 'yyyyMMdd-HHmmss'
    $Mc          = Join-Path $env:APPDATA '.minecraft'
    $Game        = Join-Path $env:APPDATA '.minecraft-raworld'
    $Utf8NoBom   = New-Object System.Text.UTF8Encoding $false

    function Say($msg, $color = 'Gray') { Write-Host $msg -ForegroundColor $color }
    function Get-Sha512($p) { (Get-FileHash -LiteralPath $p -Algorithm SHA512).Hash.ToLower() }
    function Backup-File($p) {
        if (Test-Path -LiteralPath $p) { Copy-Item -LiteralPath $p -Destination "$p.bak-$Stamp" }
    }
    function Save-Url($url, $dest, $sha512) {
        if (Test-Path -LiteralPath $dest) {
            if (-not $sha512 -or (Get-Sha512 $dest) -eq $sha512) { return 'have' }
            # Different file with the same name: keep it, renamed, never delete it.
            Rename-Item -LiteralPath $dest -NewName ((Split-Path $dest -Leaf) + ".old-$Stamp")
        }
        $dir = Split-Path $dest -Parent
        if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
        $tmp = "$dest.part"
        Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing -UserAgent $UA
        if ($sha512 -and (Get-Sha512 $tmp) -ne $sha512) {
            Remove-Item -LiteralPath $tmp
            throw "Download check failed (SHA-512 mismatch): $url"
        }
        Move-Item -LiteralPath $tmp -Destination $dest
        return 'new'
    }

    Say ''
    Say '=== Ra World 26.3 installer ===' 'Cyan'

    # 1. Launcher present and closed
    $profileFiles = @('launcher_profiles.json', 'launcher_profiles_microsoft_store.json') |
        ForEach-Object { Join-Path $Mc $_ } | Where-Object { Test-Path -LiteralPath $_ }
    if (-not $profileFiles) {
        Say "Couldn't find the Minecraft Launcher's files in $Mc." 'Yellow'
        Say 'Open the Minecraft Launcher once, sign in, close it, then run this command again.' 'Yellow'
        return
    }
    $running = Get-Process -Name 'MinecraftLauncher', 'Minecraft' -ErrorAction SilentlyContinue
    if ($running) {
        Say 'The Minecraft Launcher is open. Close it completely, then run this command again.' 'Yellow'
        return
    }

    # 2. Fabric loader version (the launcher downloads Minecraft 26.3 and the libraries itself)
    $vDir  = Join-Path $Mc "versions\$VersionId"
    $vJson = Join-Path $vDir "$VersionId.json"
    if (Test-Path -LiteralPath $vJson) {
        Say "Fabric $Loader for ${McVersion}: already there"
    } else {
        Save-Url "https://meta.fabricmc.net/v2/versions/loader/$McVersion/$Loader/profile/json" $vJson $null | Out-Null
        $check = Get-Content -LiteralPath $vJson -Raw | ConvertFrom-Json
        if ($check.id -ne $VersionId) { throw "Fabric version file looks wrong (id '$($check.id)')." }
        Say "Fabric $Loader for ${McVersion}: added" 'Green'
    }

    # 3. Pack files (mod list, settings, Ra's own mod)
    $stage = Join-Path $Game '.ra-world'
    $zip   = Join-Path $stage 'ra-world-files-v1.1.0.zip'
    Save-Url $FilesUrl $zip $FilesSha512 | Out-Null
    $files = Join-Path $stage 'files-v1.1.0'
    if (-not (Test-Path -LiteralPath $files)) { Expand-Archive -LiteralPath $zip -DestinationPath $files }
    $index = Get-Content -LiteralPath (Join-Path $files 'modrinth.index.json') -Raw | ConvertFrom-Json

    # 4. Mods and resource packs from Modrinth
    $new = 0; $have = 0
    foreach ($f in $index.files) {
        if ($f.path -match '\.\.' -or $f.path -match '^[\\/]' -or $f.path -match ':') { throw "Unsafe path in pack: $($f.path)" }
        $dest = Join-Path $Game ($f.path -replace '/', '\')
        $r = Save-Url $f.downloads[0] $dest $f.hashes.sha512
        if ($r -eq 'new') { $new++; Say "  + $($f.path)" } else { $have++ }
    }
    Say "Mods and packs: $new downloaded, $have already there (all SHA-512 checked)" 'Green'
    $raMod = Join-Path $Game 'mods\ra-shortcuts-1.5.0.jar'
    if (-not (Test-Path -LiteralPath $raMod)) {
        # an older copy of Ra's mod would load twice: move it aside (renamed, not deleted)
        Get-ChildItem -LiteralPath (Join-Path $Game 'mods') -Filter 'ra-shortcuts-*.jar' -ErrorAction SilentlyContinue | ForEach-Object {
            Rename-Item -LiteralPath $_.FullName -NewName ($_.Name + ".old-$Stamp")
            Say "  old $($_.Name) moved aside" 'Yellow'
        }
        Copy-Item -LiteralPath (Join-Path $files 'mods\ra-shortcuts-1.5.0.jar') -Destination $raMod
    }

    # 5. Ra's private files (not allowed to be posted publicly): copy them in if Ra sent them
    $searchDirs = @((Join-Path $env:USERPROFILE 'Downloads'), [Environment]::GetFolderPath('Desktop')) | Where-Object { $_ -and (Test-Path -LiteralPath $_) }
    $private = @(
        @{ Name = 'Musgo-6.5.zip';   To = 'resourcepacks' },
        @{ Name = 'RaFoliage.zip';   To = 'resourcepacks' },
        @{ Name = 'RaCustom_v1.zip'; To = 'shaderpacks' }
    )
    $missing = @()
    foreach ($p in $private) {
        $dest = Join-Path $Game "$($p.To)\$($p.Name)"
        if (Test-Path -LiteralPath $dest) { continue }
        $found = $searchDirs | ForEach-Object { Join-Path $_ $p.Name } | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
        if ($found) {
            $dir = Split-Path $dest -Parent
            if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
            Copy-Item -LiteralPath $found -Destination $dest
            Say "  + $($p.Name) (from $found)" 'Green'
        } else { $missing += $p.Name }
    }

    # 6. Shader: Ra's RaCustom if present, otherwise Complementary Unbound with Ra's settings
    $shaderDir = Join-Path $Game 'shaderpacks'
    if (-not (Test-Path -LiteralPath $shaderDir)) { New-Item -ItemType Directory -Path $shaderDir | Out-Null }
    if (Test-Path -LiteralPath (Join-Path $shaderDir 'RaCustom_v1.zip')) {
        $want = 'RaCustom_v1.zip'
        $txt = Join-Path $shaderDir 'RaCustom_v1.zip.txt'
        if (-not (Test-Path -LiteralPath $txt)) { Copy-Item -LiteralPath (Join-Path $files 'extra\RaCustom_v1.zip.txt') -Destination $txt }
    } else {
        $want = $UnboundName
        Save-Url $UnboundUrl (Join-Path $shaderDir $UnboundName) $UnboundSha | Out-Null
        $txt = Join-Path $shaderDir "$UnboundName.txt"
        if (-not (Test-Path -LiteralPath $txt)) { Copy-Item -LiteralPath (Join-Path $files "extra\$UnboundName.txt") -Destination $txt }
    }
    $iris = Join-Path $Game 'config\iris.properties'
    if (-not (Test-Path -LiteralPath $iris)) {
        New-Item -ItemType Directory -Path (Split-Path $iris -Parent) -Force | Out-Null
        [IO.File]::WriteAllText($iris, "enableShaders=true`r`nshaderPack=$want`r`n", $Utf8NoBom)
    } elseif ($want -eq 'RaCustom_v1.zip') {
        $lines = [IO.File]::ReadAllLines($iris)
        if ($lines -contains "shaderPack=$UnboundName") {
            Backup-File $iris
            $lines = $lines | ForEach-Object { if ($_ -eq "shaderPack=$UnboundName") { 'shaderPack=RaCustom_v1.zip' } else { $_ } }
            [IO.File]::WriteAllLines($iris, $lines, $Utf8NoBom)
            Say 'Shader switched to RaCustom_v1' 'Green'
        }
    }
    Say "Shader: $want"

    # 7. Resource pack order (same as Ra's), only the packs that are actually there
    $canon = (Get-Content -LiteralPath (Join-Path $files 'overrides\options.txt') | Where-Object { $_ -like 'resourcePacks:*' }) -replace '^resourcePacks:', ''
    $entries = @($canon.Trim('[', ']') -split ',' | ForEach-Object { $_.Trim('"') })
    $present = @($entries | Where-Object { $_ -eq 'vanilla' -or (Test-Path -LiteralPath (Join-Path $Game ("resourcepacks\" + ($_ -replace '^file/', '')))) })
    $packLine = 'resourcePacks:[' + (($present | ForEach-Object { '"' + $_ + '"' }) -join ',') + ']'
    $opts = Join-Path $Game 'options.txt'
    if (-not (Test-Path -LiteralPath $opts)) {
        [IO.File]::WriteAllLines($opts, @($packLine, 'incompatibleResourcePacks:[]'), $Utf8NoBom)
    } else {
        $lines = [IO.File]::ReadAllLines($opts)
        $cur = $lines | Where-Object { $_ -like 'resourcePacks:*' } | Select-Object -First 1
        $lacking = @($present | Where-Object { -not $cur -or $cur -notlike ('*"' + $_ + '"*') })
        if ($lacking.Count -gt 0) {
            Backup-File $opts
            if ($cur) { $lines = $lines | ForEach-Object { if ($_ -like 'resourcePacks:*') { $packLine } else { $_ } } }
            else { $lines = @($packLine) + $lines }
            [IO.File]::WriteAllLines($opts, $lines, $Utf8NoBom)
            Say ('Resource packs turned on: ' + ($lacking -join ', ')) 'Green'
        }
    }

    # 8. Launcher profile "Ra World" (separate game folder)
    $mem = 4
    try {
        $gb = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
        if ($gb -ge 16) { $mem = 6 } elseif ($gb -lt 8) { $mem = 3 }
    } catch { }
    $javaArgs = "-Xmx${mem}G -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M"
    $now = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
    foreach ($pf in $profileFiles) {
        $j = Get-Content -LiteralPath $pf -Raw | ConvertFrom-Json
        if (-not $j.profiles) { $j | Add-Member -NotePropertyName profiles -NotePropertyValue ([pscustomobject]@{}) -Force }
        $existing = $j.profiles.PSObject.Properties['ra-world']
        if ($existing -and $existing.Value.lastVersionId -eq $VersionId -and $existing.Value.gameDir -eq $Game) { continue }
        Backup-File $pf
        $prof = [pscustomobject]@{
            name          = 'Ra World'
            type          = 'custom'
            created       = $now
            lastUsed      = $now
            icon          = 'Grass'
            lastVersionId = $VersionId
            gameDir       = $Game
            javaArgs      = $javaArgs
        }
        $j.profiles | Add-Member -NotePropertyName 'ra-world' -NotePropertyValue $prof -Force
        [IO.File]::WriteAllText($pf, ($j | ConvertTo-Json -Depth 64), $Utf8NoBom)
    }
    Say "Launcher profile 'Ra World' ready (game folder $Game, ${mem} GB RAM)" 'Green'

    # 9. Server in the multiplayer list (address comes from Ra, not stored here)
    $servers = Join-Path $Game 'servers.dat'
    if (-not (Test-Path -LiteralPath $servers)) {
        $addr = ''
        try { $addr = (Read-Host 'Paste the server address Ra sent you (or press Enter to skip)').Trim() } catch { }
        if ($addr) {
            $ms = New-Object System.IO.MemoryStream
            $bw = New-Object System.IO.BinaryWriter($ms)
            function W-Str($s) {
                $b = [Text.Encoding]::UTF8.GetBytes($s)
                $bw.Write([byte](($b.Length -shr 8) -band 0xFF)); $bw.Write([byte]($b.Length -band 0xFF)); $bw.Write($b)
            }
            $bw.Write([byte]10); W-Str ''                      # root compound
            $bw.Write([byte]9);  W-Str 'servers'               # list "servers"
            $bw.Write([byte]10); $bw.Write([byte[]](0, 0, 0, 1)) # of 1 compound
            $bw.Write([byte]8);  W-Str 'name'; W-Str "Ra's World"
            $bw.Write([byte]8);  W-Str 'ip';   W-Str $addr
            $bw.Write([byte]0)                                 # end server
            $bw.Write([byte]0)                                 # end root
            $bw.Flush()
            [IO.File]::WriteAllBytes($servers, $ms.ToArray())
            Say "Server added to Multiplayer: $addr" 'Green'
        }
    }

    Say ''
    Say 'Done.' 'Cyan'
    Say "Open the Minecraft Launcher, pick 'Ra World' in the list next to the Play button, and press Play."
    Say 'The first start downloads Minecraft 26.3 and takes a few minutes.'
    if ($missing.Count -gt 0) {
        Say ''
        Say ('Still missing (Ra sends these to you directly): ' + ($missing -join ', ')) 'Yellow'
        Say 'Save them in your Downloads folder and run this same command again; it puts them in place and turns them on.' 'Yellow'
    }
}

try { Install-RaWorld } catch { Write-Host "Something went wrong: $($_.Exception.Message)" -ForegroundColor Red; Write-Host 'Nothing was deleted. Send Ra a screenshot of this window.' -ForegroundColor Red }
