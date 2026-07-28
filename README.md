# Wellness Monitoring — v2 (profesionální verze)

Appka teď má dvě části:
- **index.html** — appka pro klienty. Žádné heslo ani email pro klienta — jen osobní odkaz + krátký 6místný PIN.
- **coach.html** — tvůj profesionální dashboard (KPI, grafy, filtrování, export/import CSV, tvorba reportů).

---

## Krok 1 — spusť databázovou migraci

V Supabase → **SQL Editor** → smaž obsah editoru → vlož celý obsah souboru **`supabase-migration-v2.sql`** → **Run**.

Tohle přidá novou flexibilní strukturu (klienti s osobním odkazem, univerzální tabulka pro všechny typy formulářů), starou tabulku `checkins` jen bezpečně přejmenuje jako zálohu.

## Krok 2 — vypni potvrzování emailu

Klienti se nepřihlašují emailem, appka jim v zákulisí vytváří technický účet automaticky. Aby to fungovalo napoprvé bez čekání na potvrzovací email:

1. Supabase → **Authentication** → **Sign In / Providers** (nebo **Settings** → **Auth**)
2. Najdi **Email** provider → vypni **Confirm email**
3. Ulož

## Krok 3 — nahraj nové soubory

Nahraď na GitHubu tyto soubory novými verzemi (na stránce repa u každého souboru klikni na tužku ✏️ → smaž obsah → vlož nový → **Commit changes**), nebo je smaž a nahraj znovu přes "Add file → Upload files":

- `index.html`
- `coach.html`
- `manifest.json`
- `icon-192.png`, `icon-512.png`

Netlify web automaticky znovu nasadí během pár vteřin (je propojený s GitHubem).

## Krok 4 — přidej klienty

1. Otevři `coach.html`, přihlas se svým koučovským účtem
2. Klikni **+ Přidat klienta**, zadej jméno
3. Appka vygeneruje **osobní odkaz** a **6místný PIN**
4. Pošli oboje klientovi (WhatsApp, SMS...) — klient otevře odkaz, zadá PIN, hotovo. Appku si pak uloží na plochu telefonu (Sdílet → Přidat na plochu / Nainstalovat appku) a příště už jen klepne na ikonu — PIN si appka pamatuje.

**Důležité pořadí:** klient se musí nejdřív **úspěšně přihlásit v prohlížeči** (zadat PIN a počkat, až se objeví jeho domovská obrazovka) — až **potom** si má appku dát na plochu. Pokud si appku přidá na plochu dřív, než se poprvé přihlásí, ikona bude psát "Neplatný odkaz" (appka si totiž teprve po přihlášení zapamatuje, kterého klienta má otevírat). Řešení: smazat ikonu, znovu otevřít odkaz v prohlížeči, přihlásit se, a teprve pak přidat na plochu znovu.

**Klient nikdy nevidí email ani registrační formulář** — jen svůj odkaz a PIN od tebe.

---

## Co appka umí

### Klient
- Ranní wellness dotazník: spánek (usnutí/probuzení), kvalita spánku, zotavení, fyzická a duševní únava, bolest svalů, hydratace (barva moči 1–8), zranění/nemoc, menstruační cyklus a příznaky
- RPE po tréninku (škála 0–10 dle Borgovy stupnice) + délka tréninku
- Editace jakéhokoliv už odeslaného záznamu (i zpětně datovaného)
- Vlastní KPI (dnešní readiness, 7denní tréninková zátěž) a graf trendu za 30 dní

### Kouč (coach.html)
- KPI přehled celého týmu (počet klientů, kdo dnes vyplnil, průměrná readiness, upozornění na zranění/nemoc)
- Vyhledávání a filtrování klientů (nevyplnili dnes / zranění nebo nemoc / nízká readiness)
- Detail klienta: KPI, graf wellness trendu, graf tréninkové zátěže, řaditelná a filtrovatelná tabulka všech záznamů
- Export do CSV (jeden klient nebo všichni)
- Import CSV (doplnění historických dat)
- Tisk reportu (tlačítko "Tisk reportu" → uložit jako PDF přes tiskové dialogové okno prohlížeče)

### Formát CSV pro import/export
Export vytvoří normální tabulku se sloupci (jde otevřít, upravit a řadit přímo v Excelu/Google Sheets):

`full_name, form_type, entry_date, session_seq, sleep_bedtime, sleep_wake, sleep_quality, recovery, physical_fatigue, mental_fatigue, muscle_soreness, readiness, hydration, injury, injury_note, illness, illness_note, cycle_mode, cycle_day, symptom_menstrual_pain, symptom_bloating, symptom_lower_back_pain, symptom_sleep_disruption, symptom_mood_changes, symptom_appetite_changes, rpe, duration_min, load, session_note`

`session_seq` = pořadí tréninku v daném dni (0 = první, 1 = druhý atd.) — umožňuje víc RPE záznamů za jeden den. U wellness je vždy 0.

U wellness řádků jsou vyplněné sloupce pro wellness otázky, u RPE řádků sloupce `rpe`, `duration_min`, `load`, `session_note`. Prázdné buňky = otázka se daný den netýkala nebo nebyla zodpovězená.

**Legenda číselných hodnot:**
- `sleep_quality`, `recovery`, `physical_fatigue`, `mental_fatigue`, `muscle_soreness`: 1 = nejhorší, 5 = nejlepší
- `readiness`: 1–10 (průměr pěti hodnot výše ×2)
- `hydration`: 1 = světlá moč (dobrá hydratace), 8 = tmavá (dehydratace)
- `injury` / `illness`: `none` / `full` / `support` / `discuss` / `other`
- `symptom_*`: 0 = žádný příznak, 1 = mírné, 2 = střední, 3 = těžké, 4 = raději neříkám
- `rpe`: 0–10 (Borgova škála), `load` = rpe × duration_min

Exportovaný soubor jde rovnou upravit a nahrát zpátky přes Import CSV (musí obsahovat aspoň sloupce `full_name`, `form_type`, `entry_date` — klient musí už v appce existovat, hledá se podle jména).

---

## Zapomenuté heslo / PIN

**Ty (kouč):** na přihlašovací obrazovce klikni na "Zapomenuté heslo?" — appka pošle odkaz na reset na tvůj skutečný email.

**Klient zapomene PIN:** appka mu nemůže poslat reset (nemá skutečný email). Postup:

1. V coach dashboardu otevři detail klienta → v kartě "Přihlašovací údaje" najdeš jeho technický email (např. `client-abc123@wellness.internal`)
2. V Supabase → **SQL Editor** spusť (nahraď email a zvol nový PIN):

```sql
update auth.users
set encrypted_password = crypt('123456', gen_salt('bf'))
where email = 'client-abc123@wellness.internal';
```

3. Nový PIN pošli klientovi ručně — jeho osobní odkaz zůstává stejný, mění se jen PIN.

---

## Bezpečnost dat

Vše je zabezpečené na úrovni databáze (Row Level Security): klient vidí a upravuje jen svoje záznamy, ty jako kouč vidíš všechny. I když appka pro klienty nepoužívá klasické heslo, technicky pod kapotou pořád běží plnohodnotné ověřování — PIN je jen uživatelsky příjemnější vrstva navrch.

## Víc tréninků za den (RPE)

Appka umí uložit víc RPE záznamů ve stejný den (dvoufázové tréninky apod.) — tlačítko "Po tréninku"/"přidat další trénink" pokaždé založí novou session, nic nepřepíše. 7denní zátěž v KPI i grafu je součet přes všechny tréninky.

**Pokud appku už provozuješ**, spusť navíc v Supabase → SQL Editor soubor **`supabase-migration-v3.sql`** a nahraj na GitHub nové `index.html` a `coach.html`. Pokud appku zakládáš úplně od nuly, spusť migrace v pořadí v1 → v2 → v3.

## Budoucí rozšíření

Tabulka `submissions` ukládá odpovědi jako flexibilní JSON, takže přidání nového formuláře (např. GPS zátěž, spánek z hodinek, zranění/rehab, testování) znamená jen přidat novou definici formuře do `FORM_DEFS` v `index.html` — databáze ani zabezpečení se měnit nemusí.
