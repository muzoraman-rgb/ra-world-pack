# Ra World 26.3

One-command Windows setup that makes Minecraft Java 26.3 look and play like Ra's world (Fabric loader 0.20.1).

## Install (Windows)

1. Open the Minecraft Launcher once and sign in, then close it.
2. Open **PowerShell** (Start menu, type `powershell`) and paste:

```powershell
irm https://raw.githubusercontent.com/muzoraman-rgb/ra-world-pack/main/install.ps1 | iex
```

3. Open the launcher, pick **Ra World** next to the Play button, press Play.

The script:
- adds the Fabric loader version file from meta.fabricmc.net (the launcher downloads Minecraft and the libraries itself)
- uses its own game folder, `%APPDATA%\.minecraft-raworld`, and its own launcher profile, so a normal Minecraft setup is not touched
- downloads every mod and resource pack from Modrinth and checks each file's SHA-512
- never deletes anything (it keeps `.bak-*` copies of any file it edits) and can be run again safely

No admin rights needed. Read `install.ps1` before running it if you like; it is one file.

## Not in this repo

A few of Ra's files are private merges or third-party packs whose licenses do not allow re-posting (RaCustom shader, RaFoliage, Musgo). Ra shares those directly. Save them in your Downloads folder and run the command again: the script puts them in place and turns them on. Until then the shader falls back to Complementary Unbound, downloaded from its official Modrinth page.

## Credits

All mods and packs are downloaded from their official Modrinth pages, under their own licenses:

- [BetterF3-20.0.0-Fabric-26.3.jar](https://modrinth.com/project/8shC1gFX)
- [BorderlessFullscreen-v2.5.1-mc26.3.jar](https://modrinth.com/project/UIexcMP1)
- [ForgeConfigAPIPort-v26.3.1-mc26.3.x-Fabric.jar](https://modrinth.com/project/ohNO6lps)
- [MouseTweaks-fabric-mc26.3-2.31.jar](https://modrinth.com/project/aC3cM3Vq)
- [betterstats-5.8.0+fn-26.3.jar](https://modrinth.com/project/n6PXGAoM)
- [bookshelfinspector-fabric-2.4+26.3.jar](https://modrinth.com/project/rOrXjyPb)
- [cherishedworlds-fabric-18.0.0+26.3.jar](https://modrinth.com/project/3azQ6p0W)
- [clientsort-fabric-3.104.1+26.3.jar](https://modrinth.com/project/K0AkAin6)
- [cloth-config-fabric-26.3.159.jar](https://modrinth.com/project/9s6osm5g)
- [controlify-3.5.3+mc26.3-universal.jar](https://modrinth.com/project/DOUdJVEm)
- [cropsloverain-3.2.2.jar](https://modrinth.com/project/cRci7UZp)
- [cutthrough-v26.3.0-mc26.3.x+fabric.jar](https://modrinth.com/project/Dk6su9JN)
- [deleteworldstotrash-v26.3.0-mc26.3.x+fabric.jar](https://modrinth.com/project/7diJQfvM)
- [easyshulkerboxes-v26.3.4-mc26.3.x+fabric.jar](https://modrinth.com/project/gA5euN8S)
- [entity_model_features-3.3.12-26.3-fabric.jar](https://modrinth.com/project/4I1XuqiY)
- [entity_texture_features-7.2.7-26.3-fabric.jar](https://modrinth.com/project/BVzZfTc1)
- [fabric-api-0.166.2+26.3.jar](https://modrinth.com/project/P7dR8mSH)
- [fallingleaves-2.0.8+26.3.jar](https://modrinth.com/project/WhbRG4iK)
- [fastitemframes-v26.3.0-mc26.3.x+fabric.jar](https://modrinth.com/project/FsoeTIV0)
- [freecam-fabric-1.5.1+mc26.3.jar](https://modrinth.com/project/XeEZ3fK2)
- [fwa+26.3-1.3.7.jar](https://modrinth.com/project/IAzUFvS6)
- [iris-fabric-1.11.7+mc26.3.jar](https://modrinth.com/project/YL57xq9U)
- [jamlib-fabric-2.3.2+26.3.x.jar](https://modrinth.com/project/IYY9Siz8)
- [light-overlay-2.13.1+26.3.jar](https://modrinth.com/project/8qVa1XCN)
- [modmenu-21.0.0.jar](https://modrinth.com/project/mOgUt4GM)
- [no-resource-pack-warnings-1.5.0.jar](https://modrinth.com/project/6xKUDQcB)
- [overlaylib-0.12.1+26.3.jar](https://modrinth.com/project/M1B8mLoH)
- [paginatedadvancements-2.9.0+26.3.jar](https://modrinth.com/project/pJogNFap)
- [particlerain-4.0.3+26.3-fabric.jar](https://modrinth.com/project/nrikgvxm)
- [pickupnotifications-fabric-3.0.1+26.3.jar](https://modrinth.com/project/wWiJfmyy)
- [placeholder-api-3.2.0+26.3.jar](https://modrinth.com/project/eXts2L7r)
- [puzzleslib-v26.3.17-mc26.3.x+fabric.jar](https://modrinth.com/project/QAGBst4M)
- [reachbehind-v26.3.0-mc26.3.x+fabric.jar](https://modrinth.com/project/MDljZreW)
- [rightclickharvest-fabric-4.6.2+26.3.x.jar](https://modrinth.com/project/Cnejf5xM)
- [seedmapper-2.38.0.jar](https://modrinth.com/project/C4GbEnuY)
- [smoothloadingscreen-1.0.12+26.3.jar](https://modrinth.com/project/LkxC6kKT)
- [sodium-fabric-0.9.2+mc26.3.jar](https://modrinth.com/project/AANobbMI)
- [status-effect-bars-1.0.12.jar](https://modrinth.com/project/x02cBj9Y)
- [tcdcommons-5.8.0+fn-26.3.jar](https://modrinth.com/project/Eldc1g37)
- [vanilla-fireflies-5.1.jar](https://modrinth.com/project/dxiyDLYV)
- [vehicleupgrade-v26.3.0-mc26.3.x+fabric.jar](https://modrinth.com/project/9B9c6QcJ)
- [visuality-0.7.15+26.3.jar](https://modrinth.com/project/rI0hvYcd)
- [xaerominimap-fabric-26.3-26.6.2.jar](https://modrinth.com/project/1bokaNcj)
- [xaeroworldmap-fabric-26.3-1.47.2.jar](https://modrinth.com/project/NcUtCpym)
- [yet_another_config_lib_v3-3.9.7+26.3-fabric.jar](https://modrinth.com/project/1eAoo2KR)
- [Better Lanterns v1.4.0 - 26.2+26.3.zip](https://modrinth.com/project/PGGrfcvL)
- [FreshAnimations_v1.11.2_26.1+.zip](https://modrinth.com/project/50dA9Sha)
- [FA+Emissive-v1.7.zip](https://modrinth.com/project/VRS2YQn9)
- [Enchantment Glows v1.12.1.zip](https://modrinth.com/project/m3tqASqD)

Shader fallback: [Complementary Unbound](https://www.complementary.dev/) by Complementary Development, downloaded unmodified from [Modrinth](https://modrinth.com/shader/complementary-unbound); only a settings file is included here.

`files/mods/ra-shortcuts-1.5.0.jar` is Ra's own small mod (`/xmap`, `/mini` shortcuts, click-an-icon popup, waypoints and objectives on the seed map).
