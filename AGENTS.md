# AGENTS.md – pravidla projektu 3D Vandal Simulátor

Tento soubor čte AI agent (Antigravity) před každou prací na projektu. Plán práce je v [`ROADMAP.md`](ROADMAP.md).

## Herní koncept
- Hráč si vybere komickou postavičku (Obří kachna, Agresivní důchodkyně, Bobr s motorovkou, Kostkový robot…) a **ničí budovy a auta na reálné mapě České republiky**.
- Začínáme městem **Příbram** (střed mapy = náměstí T. G. Masaryka), později celá ČR.
- Styl: **low-poly, kreslený, komický**. Žádní lidé jako oběti, žádné reálné zbraně (kvůli Google Play / IARC).

## Technologie
- **Unity 6.3 LTS** (`6000.3.28f1`), **URP** (Universal 3D).
- Jazyk **C#**. Pouze **nový Input System** (`UnityEngine.InputSystem`) – starý `Input.GetKey…` nepoužívat.
- Kamera: **Cinemachine 3** (namespace `Unity.Cinemachine`).
- Platformy v pořadí priority: **PC (Windows) → Web (WebGL, GitHub Pages) → Android**.
- Mapová data: **OpenStreetMap** (Overpass API / Geofabrik). Data se stahují **jednou v editoru** a ukládají do projektu – žádná mapová API za běhu, žádná placená mapová SDK. Vždy zobrazit atribuci „© OpenStreetMap contributors“ (ODbL).

## Struktura projektu
- Veškerý vlastní obsah patří do `Assets/_Project/`:
  - `Scripts/` – C# kód (podsložky podle systému, např. `Player/`, `Destruction/`, `Map/`; editor kód do `Scripts/Editor/` nebo `…/Editor/`)
  - `Prefabs/`, `Materials/`, `Scenes/`, `Data/` (ScriptableObjecty, OSM JSON), `UI/`, `Art/` (modely, textury, animace)
- Namespace: **`VandalSim.*`** podle složky – např. `VandalSim.Player`, `VandalSim.Destruction`, `VandalSim.Map`, `VandalSim.EditorTools` (ne `VandalSim.Editor` – koliduje s třídou `UnityEditor.Editor`).
- Nástroje v editoru dávat do menu **`VandalSim/…`**.
- Assety třetích stran (Quaternius, Kenney – CC0, Mixamo) do `Assets/_Project/Art/`, s uvedením zdroje/licence.

## Pravidla pro kód
- **Výkon je priorita** (cíl 60 FPS PC, 30 FPS střední Android):
  - Žádné alokace v `Update`/`FixedUpdate`/`LateUpdate` (žádné `new`, LINQ, string konkatenace, `GetComponent`, `FindObjectOfType`, lambdy zachytávající proměnné).
  - Reference cachovat v `Awake`/`Start`. Pro trosky, efekty, zvuky a texty používat **object pooling** (`UnityEngine.Pool.ObjectPool<T>`).
  - Fyzikální dotazy přes `NonAlloc` / buffery (`Physics.OverlapSphereNonAlloc` apod.).
- **Krátké skripty s jednou zodpovědností.** Raději víc malých komponent než jeden velký „manager“.
- Konfigurace (zbraně, postavy, ceny) přes **ScriptableObjecty**, ne natvrdo v kódu.
- Komunikace mezi systémy přes rozhraní (`IDamageable`) a události (`event Action<…>`), ne přes přímé reference napříč systémy.
- `[SerializeField] private` místo veřejných polí. Pojmenování dle C# konvencí (PascalCase metody/vlastnosti, `_camelCase` privátní pole).
- **Komentáře a XML dokumentace česky.** Názvy tříd, metod a proměnných anglicky.
- Kód musí fungovat na všech platformách (žádné Windows-only API; pro WebGL žádné vlákna `System.Threading`).

## Pracovní postup
- Jeden krok z `ROADMAP.md` = jeden úkol. Krok je hotový, až platí jeho „Hotovo, když“.
- Po každém funkčním kroku **commit + push** na `main` (krátká zpráva česky, např. `1.2: postava a kamera`). Push spustí WebGL build a nasazení na `https://sickofideas.github.io/VandalSimulator`.
- Co se musí naklikat v Unity ručně, napsat uživateli jako přesný postup krok za krokem.
- Chyby z Unity Console číst přes Unity MCP (pokud je napojený), jinak požádat uživatele o jejich zkopírování.
- Nikdy necommitovat tajemství (Unity licence `.ulf`, hesla) – patří do GitHub Secrets.
