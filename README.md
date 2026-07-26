# Wellness Check-in App — návod na spuštění (vše zdarma)

Appka má dvě části:
- **index.html** — appka pro klienty (denní wellness formulář + RPE po tréninku, vidí jen svá data). Tuhle si klienti dají na plochu telefonu.
- **coach.html** — tvůj dashboard, kde vidíš všechny klienty a jejich trendy.

Data se ukládají do **Supabase** (zdarma databáze v cloudu). Nikam se neplatí, dokud nemáš stovky klientů s obřím provozem.

---

## 1. Vytvoř Supabase projekt (5 min)

1. Jdi na [supabase.com](https://supabase.com) → **Start your project** → zaregistruj se (zdarma, bez karty).
2. **New project** → dej mu jméno (např. `wellness-app`) → zvol heslo k databázi (ulož si ho) → region klidně `Central EU (Frankfurt)`.
3. Počkej ~2 minuty, než se projekt vytvoří.

## 2. Nahraj databázové schéma

1. V levém menu klikni na **SQL Editor**.
2. Otevři soubor `supabase-schema.sql` (je v této složce), zkopíruj celý obsah.
3. Vlož ho do SQL editoru a klikni **Run**.

Tím vznikly dvě tabulky (`profiles`, `checkins`) a nastavilo se zabezpečení, aby každý klient viděl jen svoje data a ty (kouč) jsi viděl všechno.

## 3. Zkopíruj API klíče

1. V levém menu **Project Settings** → **API**.
2. Zkopíruj **Project URL** a **anon public** klíč.
3. Otevři soubor `config.js` a vlož je sem:

```js
const SUPABASE_URL = "https://tvuj-projekt.supabase.co";
const SUPABASE_ANON_KEY = "tvuj-anon-klic";
```

## 4. Nahraj appku na zdarma hosting

Nejjednodušší způsob (bez příkazové řádky):

1. Jdi na [app.netlify.com/drop](https://app.netlify.com/drop).
2. Přetáhni celou složku `wellness-app` do prohlížeče.
3. Netlify ti během pár vteřin dá odkaz typu `https://nejaky-nazev.netlify.app`.

(Pro pozdější úpravy si na Netlify založ zdarma účet, ať appku můžeš znovu nahrávat.)

## 5. Nastav se jako kouč

1. Otevři svůj nový odkaz (`.../index.html`) a **zaregistruj se** jako běžný klient (jméno, email, heslo) — to bude tvůj kouč-účet.
2. Zpátky v Supabase → **SQL Editor** → spusť (nahraď email svým):

```sql
update profiles set role = 'coach'
where id = (select id from auth.users where email = 'tvuj-email@example.com');
```

3. Otevři `.../coach.html` a přihlas se stejným emailem/heslem → uvidíš dashboard.

## 6. Přidej klienty

Klienti si appku otevřou na `.../index.html`, sami se zaregistrují (jméno, email, heslo) a rovnou vidí formulář. Ty je pak uvidíš v `coach.html`.

**Instalace na plochu telefonu:**
- **iPhone (Safari):** otevři odkaz → tlačítko Sdílet → *Přidat na plochu*.
- **Android (Chrome):** otevři odkaz → nabídka (tři tečky) → *Přidat na plochu* / *Nainstalovat aplikaci*.

## 7. Volitelně: vlastní doména

Místo `nazev.netlify.app` si můžeš v Netlify (Domain settings) připojit vlastní doménu (řádově desítky Kč/rok u registrátora), ale není to nutné — appka funguje i na zdarma subdoméně.

---

### Co appka umí

- Klient: registrace/login, denní wellness (spánek, bolestivost, nálada, stres, readiness), RPE + délka po tréninku, vlastní graf trendu za 30 dní.
- Kouč: seznam všech klientů, po rozkliknutí graf wellness trendu, graf RPE trendu, průměry a posledních 15 záznamů.
- Data jsou zabezpečená na úrovni databáze (Row Level Security) — klient fyzicky nemůže vidět data jiného klienta, ani kdyby zkusil upravit appku.

### Limity zdarma tarifu Supabase (orientačně)

Zdarma tarif zvládne v pohodě desítky až stovky klientů s denními záznamy. Pokud projekt 7 dní "nežije" (nikdo se nepřihlásí), databáze se uspí a při první další návštěvě se do pár vteřin sama probudí — nic se neztratí.
