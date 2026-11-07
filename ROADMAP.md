# 3D Vandal Simulátor – roadmapa krok za krokem (Unity + Antigravity)

## Údaje o projektu
- **Složka projektu:** `C:\Dev\VandalSimulator`
- **Unity:** 6.3 LTS (`6000.3.28f1`), šablona Universal 3D (URP)
- **Moduly:** Windows, Android, Web
- **GitHub účet:** `sickofideas` (přihlášeno přes `gh auth login`)
- **Cíl hraní z prohlížeče:** `https://sickofideas.github.io/VandalSimulator` (GitHub Pages, build přes GitHub Actions / GameCI)
- **Stav:** Projekt vytvořen v Unity. Další krok = **0.2 Git a struktura složek**.

> [!NOTE]
> **Jak s Antigravity pracovat:** V Antigravity je jako workspace otevřená **složka Unity projektu**. Agent C# skripty zapisuje rovnou do `Assets/`, Unity je po přepnutí okna samo zkompiluje. Chyby z Unity Console agent čte přes Unity MCP (krok 0.4), jinak je uživatel zkopíruje do chatu. Uživatel v Unity dělá jen to, co se musí naklikat ručně, a testuje hru tlačítkem Play.

**Zásady pro každý krok:**
- Jeden krok = jeden úkol. Nezadávat víc kroků najednou.
- Po každém funkčním kroku **commit + push na GitHub**.
- Každý krok má **„Hotovo, když“** – dokud to neplatí, nepokračovat dál.

---

## Fáze 0 – Základ projektu

### 0.1 Instalace ✅
Unity Hub, Unity 6.3 LTS (Windows, Android, Web), Git, GitHub CLI, projekt `VandalSimulator` v `C:\Dev`.

### 0.2 Git, GitHub a struktura složek
- `.gitignore` pro Unity, `.gitattributes` pro Git LFS (fbx, png, wav, …).
- Struktura `Assets/_Project/{Scripts,Prefabs,Materials,Scenes,Data,UI,Art}`, namespace `VandalSim.*`.
- `git init`, první commit, vytvořit repozitář na GitHubu (`gh repo create`) a push.

**Hotovo, když:** projekt jde otevřít v Unity bez chyb a je na GitHubu.

### 0.3 Pravidla projektu pro AI
Vytvořit `AGENTS.md` v kořeni: Unity 6 + URP, C#, nový Input System, namespace `VandalSim`, low-poly kreslený styl, platformy PC → Web → Android, mapová data z OpenStreetMap, výkon je priorita (pooling, žádné alokace v Update), krátké skripty s jednou zodpovědností, komentáře česky. Herní koncept: hráč si vybere postavičku a ničí budovy a auta na reálné mapě ČR, začínáme městem Příbram.

### 0.4 Propojení Antigravity ↔ Unity (MCP)
Napojit Unity MCP / oficiální Unity plugin pro Antigravity, aby agent uměl číst Console, vytvářet GameObjecty a spouštět Play mód.

### 0.5 Automatický build na GitHub Pages
- GitHub Actions s GameCI (`unity-builder`) – WebGL build po každém pushi na `main`.
- Unity licence (Personal) jako GitHub secrets (`UNITY_LICENSE`, `UNITY_EMAIL`, `UNITY_PASSWORD`).
- WebGL: komprese Gzip + Decompression Fallback (GitHub Pages neposílá Content-Encoding hlavičky).
- Deploy na GitHub Pages (repozitář musí být veřejný).

**Hotovo, když:** po pushi se hra (zatím prázdná scéna) otevře na `sickofideas.github.io/VandalSimulator`.

---

## Fáze 1 – Hráč a ovládání v prázdném světě (bez mapy)

### 1.1 Testovací scéna
Editor skript (menu `VandalSim/Create Test Scene`) vygeneruje scénu `Sandbox`: rovina 500×500 m, směrové světlo, obloha, 20 náhodných kvádrů jako „budovy“ s tagem `Building`.

### 1.2 Postava a kamera (third-person)
Chůze, běh (Shift), skok, CharacterController, kamera Cinemachine 3 s otáčením myší, nový Input System (klávesnice+myš i gamepad), připravit místo pro dotykové ovládání.

**Hotovo, když:** v Sandboxu běháš kapslí po rovině a kamera plynule sleduje.

### 1.3 Grafika postav (zdarma, CC0)
Low-poly animované postavy (Quaternius, Kenney – CC0) nebo animace z Mixamo do `Assets/_Project/Art`. Animator: idle, chůze, běh, skok, úder.

---

## Fáze 2 – Destrukce (jádro zábavy, stále v Sandboxu)

### 2.1 Systém poškození
Rozhraní `IDamageable` (HP, `TakeDamage(amount, point, force)`), komponenta `Destructible`, událost `OnDestroyed`, „cena škody v Kč“ pro skóre.

### 2.2 Zbraně na blízko
ScriptableObject `WeaponData` (poškození, dosah, cooldown, síla odhozu, typ melee/throw/explosive). Kladivo a baseballka: úder levým tlačítkem, OverlapSphere před postavou. Přepínání kolečkem / čísly.

### 2.3 Rozpad budov na kostky
Při 0 HP nahradit budovu troskami: mřížka bloků cca 1,5 m s Rigidbody, odlet od místa zásahu, object pooling (max. 300 trosek), po 10 s se propadnou a vrátí do poolu, oblak prachu. Postupná destrukce: zásah ulomí jen bloky v okolí, celá budova padne pod 30 % HP.

### 2.4 Auta
Low-poly auto (3 barevné varianty) s `Destructible`: promáčknutí, rozbitá skla, při 0 HP výbuch s odhozem a poškozením okolí.

### 2.5 Pocit z ničení („juice“)
Třesení kamery, hitstop 50 ms, zvuky s náhodným pitchem, plovoucí text „+15 000 Kč“.

**Hotovo, když:** ničit kvádry a auta v Sandboxu je samo o sobě zábavné. **Teprve pak mapa.**

---

## Fáze 3 – Reálná mapa: Příbram

> [!IMPORTANT]
> Žádné placené mapové SDK. Data z OSM stáhnout **jednou** a uložit do projektu. Žádné API volání za běhu.

### 3.1 Stažení dat Příbrami
Editor nástroj (menu `VandalSim/Download OSM Area`) – Overpass API, bounding box Příbrami: budovy (`building`, `building:levels`, `height`), silnice (`highway`), voda, zeleň, parkoviště → `Assets/_Project/Data/Pribram.json`.

### 3.2 Převod souřadnic
`GeoConverter`: lat/lon → lokální metry, střed = náměstí T. G. Masaryka = (0,0,0).

### 3.3 Generování budov
Vytažení půdorysů (ear-clipping), výška z `height` / `building:levels × 3 m` / odhad podle typu. Kreslený styl, plochá barva podle typu. Kompatibilní s destrukcí z fáze 2.

### 3.4 Silnice, zeleň, voda
Ploché pásy podle šířky typu `highway`, chodníky, zeleň a voda jako polygony.

### 3.5 Auta na ulicích
Zaparkovaná auta podél silnic a na parkovištích, volitelně jednoduchý provoz.

### 3.6 Výkon
Chunky 200×200 m, načítání podle vzdálenosti, slučování statických meshů na chunk, LOD. Cíl 60 FPS PC, 30 FPS střední Android.

### 3.7 Atribuce OSM (povinné)
Trvalý text „© OpenStreetMap contributors“ + obrazovka Licence (ODbL).

**Hotovo, když:** proběhneš se po Příbrami, poznáš náměstí/Svatou Horu a můžeš tam ničit.

---

## Fáze 4 – Postavičky na výběr
- 4.1 ScriptableObject `CharacterData` (jméno, prefab, rychlost, síla, schopnost, zamčeno, cena). Postavy: Obří kachna, Agresivní důchodkyně, Bobr s motorovkou, Kostkový robot.
- 4.2 Scéna `CharacterSelect`: otáčející se postava, šipky, Vybrat, zámky a ceny, přenos volby do hry.
- 4.3 Speciální schopnosti na Q (kvákací tlaková vlna, hod kabelkou, řezání motorovkou, dupnutí).

---

## Fáze 5 – Herní smyčka
| Krok | Obsah |
|---|---|
| 5.1 Skóre | Celková škoda v Kč, kombo násobič, HUD |
| 5.2 Mise | „Znič 10 aut za 60 s“, „Shoď 3 paneláky“, „Pomaluj 5 zdí“ |
| 5.3 Sprej | Graffiti decaly na budovy |
| 5.4 Komická policie | Hledanost, kreslení policajti na koloběžkách |
| 5.5 Měna a odemykání | Mince za škodu, odemykání postav/zbraní, ukládání (JSON) |
| 5.6 Menu | Hlavní menu, pauza, nastavení, lokalizace CZ/EN |

---

## Fáze 6 – Celá Česká republika
- 6.1 Pipeline (Python): `czech-republic-latest.osm.pbf` z Geofabriku → filtrace → dlaždice (cca 1×1 km).
- 6.2 Hosting dlaždic: Cloudflare R2 (bez poplatků za přenos) / GitHub Pages pro start.
- 6.3 Načítání dlaždic za běhu podle polohy, cache na disku, generování na pozadí.
- 6.4 Výběr místa: offline seznam obcí ČR (RÚIAN), oblíbená místa, GPS na mobilu.
- 6.5 Terén (volitelně): ČÚZK DMR 5G nebo Terrarium dlaždice (AWS Open Data).

---

## Fáze 7 – Mobil a monetizace
| Krok | Obsah |
|---|---|
| 7.1 Dotykové ovládání | Joystick vlevo, tlačítka vpravo, otáčení kamery tahem |
| 7.2 Optimalizace Android | Draw cally, stíny, počet trosek dle výkonu (Low/Mid/High) |
| 7.3 Rewarded reklamy | AdMob / Unity LevelPlay → prémiová zbraň na 1 hru |
| 7.4 Prémiové zbraně | C4, Meteorit, Tornádo, Godzilla mód |
| 7.5 IAP | „Bez reklam“, balíčky mincí |
| 7.6 Analytika | Firebase Analytics |

> [!WARNING]
> Google Play: komický kreslený styl, žádní lidé jako oběti, žádné reálné zbraně, poctivý IARC rating, popis „parodie / sandbox“.

---

## Fáze 8 – Vydání a virální růst
1. Sdílení: „Nahrát posledních 15 s“ + text „Zdemoloval jsem Příbram za 2,4 mil. Kč“.
2. Android build (.aab) → Google Play.
3. WebGL verze pro CrazyGames / Poki (jejich SDK).
4. TikTok/Shorts videa z ničení známých míst.

> [!TIP]
> Po milníku „hratelné demo“ (konec fáze 3) natočit 30s video na TikTok a podle reakcí rozhodnout o fázích 6–8.
