# 🧪 SQL-Schema testen - Anleitung

## Schnelltest mit DB Fiddle (Online, kein Setup nötig!)

**Empfohlen für:** Schnelles Testen ohne Installation

### Schritt-für-Schritt:

1. **Öffne [DB Fiddle](https://www.db-fiddle.com/)**

2. **Wähle die Datenbank:**
   - Oben links: Klicke auf das Dropdown-Menü
   - Wähle **"MySQL 8.0"**

3. **Schema laden:**
   - Öffne die Datei `sql/schema.sql` in diesem Repository
   - **Wichtig**: Entferne die ersten Zeilen (Zeile 11-13):
     ```sql
     CREATE DATABASE IF NOT EXISTS iacs_bluehstreifen ...;
     USE iacs_bluehstreifen;
     ```
   - Kopiere den Rest (ab `-- Tabelle: antragsteller`) ins **linke Fenster**
   - Klicke auf **"Run"**

4. **Queries testen:**
   - Öffne `sql/beispiel-queries.sql`
   - Kopiere eine oder mehrere Queries ins **rechte Fenster**
   - Klicke auf **"Run"**
   - Die Ergebnisse erscheinen unten!

### ✅ Was du sehen solltest:

**Beispiel-Query:**
```sql
SELECT * FROM foerderantrag;
```

**Erwartetes Ergebnis:**
```
id | antragsteller_id | antragsjahr | foerderart  | status      | beantragt_betrag
---|------------------|-------------|-------------|-------------|------------------
1  | 1                | 2025        | einjährig   | in_pruefung | 3750.00
2  | 2                | 2025        | mehrjährig  | bewilligt   | 7500.00
3  | 3                | 2025        | einjährig   | eingereicht | 1500.00
```

---

## Lokales Testen mit SQLite

**Empfohlen für:** Entwicklung und lokale Tests

### Voraussetzungen:
- SQLite installiert (auf den meisten Systemen vorinstalliert)

### Anleitung:

1. **Repository klonen:**
   ```bash
   git clone https://github.com/DEINUSERNAME/iacs-bluehstreifen-foerderung.git
   cd iacs-bluehstreifen-foerderung
   ```

2. **Schema-Anpassung für SQLite:**
   
   Erstelle `sql/schema-sqlite.sql` mit folgendem Inhalt:
   - Kopiere `schema.sql`
   - **Entferne** Zeile 11-13 (CREATE DATABASE, USE)
   - **Ersetze** alle `AUTO_INCREMENT` mit `AUTOINCREMENT`
   - **Ersetze** `ENUM(...)` mit `TEXT CHECK(...)`

3. **Datenbank erstellen:**
   ```bash
   sqlite3 test.db < sql/schema-sqlite.sql
   ```

4. **Queries testen:**
   ```bash
   sqlite3 test.db < sql/beispiel-queries.sql
   ```

5. **Interaktiv arbeiten:**
   ```bash
   sqlite3 test.db
   
   # In SQLite:
   SELECT * FROM antragsteller;
   SELECT COUNT(*) FROM foerderantrag;
   .quit
   ```

---

## Lokales Testen mit MySQL

**Empfohlen für:** Produktionsnahe Tests

### Voraussetzungen:
- MySQL 8.0+ installiert
- Root-Zugriff oder Berechtigung zum Erstellen von Datenbanken

### Anleitung:

1. **MySQL starten:**
   ```bash
   mysql -u root -p
   ```

2. **In MySQL:**
   ```sql
   -- Schema laden (DB wird automatisch erstellt)
   source /pfad/zu/sql/schema.sql;
   
   -- Queries testen
   source /pfad/zu/sql/beispiel-queries.sql;
   
   -- Oder einzelne Queries:
   SELECT * FROM foerderantrag;
   ```

3. **Alternativ über Kommandozeile:**
   ```bash
   # Datenbank erstellen
   mysql -u root -p -e "CREATE DATABASE iacs_bluehstreifen;"
   
   # Schema laden
   mysql -u root -p iacs_bluehstreifen < sql/schema.sql
   
   # Queries testen
   mysql -u root -p iacs_bluehstreifen < sql/beispiel-queries.sql
   ```

---

## Troubleshooting

### Problem: "Access denied for database"
**Lösung:** Nutze DB Fiddle (siehe oben) oder SQLite

### Problem: "Unknown database iacs_bluehstreifen"
**Lösung:** 
```sql
CREATE DATABASE iacs_bluehstreifen;
USE iacs_bluehstreifen;
```

### Problem: "ENUM type not supported" (SQLite)
**Lösung:** Nutze die SQLite-Version oder ersetze:
```sql
-- Von:
status ENUM('eingereicht', 'bewilligt')

-- Zu:
status TEXT CHECK(status IN ('eingereicht', 'bewilligt'))
```

---

## Beispiel-Queries zum Ausprobieren

```sql
-- 1. Alle Anträge mit Landwirt-Namen
SELECT 
    a.name AS landwirt,
    f.foerderart,
    f.status,
    f.beantragt_betrag
FROM foerderantrag f
JOIN antragsteller a ON f.antragsteller_id = a.id;

-- 2. Statistik nach Status
SELECT 
    status,
    COUNT(*) AS anzahl,
    SUM(beantragt_betrag) AS summe
FROM foerderantrag
GROUP BY status;

-- 3. Gesamtfläche pro Antrag
SELECT 
    f.id,
    a.name,
    SUM(fl.groesse_ha) AS gesamt_flaeche
FROM foerderantrag f
JOIN antragsteller a ON f.antragsteller_id = a.id
JOIN flaeche fl ON f.id = fl.antrag_id
GROUP BY f.id, a.name;
```

---

## 📊 Erwartete Ergebnisse

Wenn alles korrekt funktioniert, solltest du:

✅ 3 Antragsteller in der Datenbank haben  
✅ 3 Förderanträge sehen  
✅ 4 Flächen zugeordnet haben  
✅ 5 Prüfungen dokumentiert haben  
✅ 1 Auszahlung erfasst haben  

---

**Tipp:** Speichere dir den DB Fiddle Link (oben rechts "Share") für spätere Tests!
