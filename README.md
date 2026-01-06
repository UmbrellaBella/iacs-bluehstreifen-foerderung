# 🌸🐝 IACS Blühstreifen-Förderprogramm
## Datenmodell und Prozessmodellierung für EU-Agrarumweltmaßnahmen

---

## 📋 Projekthintergrund

### Fiktives Szenario
Das Sächsische Staatsministerium für Umwelt und Landwirtschaft (SMUL) plant die Einführung eines neuen Förderprogramms für Agrarumweltmaßnahmen mit Schwerpunkt **Biodiversität durch Blühstreifen**. 

**Zielsetzung des Programms:**
- Förderung von Landwirten, die Blühstreifen anlegen und pflegen
- Stärkung der Biodiversität und des Insektenschutzes in Sachsen
- Integration in das bestehende Verwaltungs- und Kontrollsystem

**Meine Aufgabe (simuliert):**
Als IT-Referentin im LfULG würde ich für dieses neue Förderprogramm die **Anforderungsanalyse, Datenbankmodellierung und Prozesskonzeption** übernehmen.

---

## 🎯 Zielsetzung dieses kleinen Portfolio-Projekts

Dieses Projekt demonstriert meine Fähigkeiten in den **Kernkompetenzen der ausgeschriebenen Stelle** (Referent/in IT-Projekt IACS, LfULG):

| Stellenanforderung | Nachweis in diesem Projekt |
|-------------------|---------------------------|
| Anforderungsanalyse und Projektierung | `docs/anforderungen.md` - Strukturierte Erhebung fachlicher Anforderungen |
| Entwurf und Modellierung von Datenbanken | `diagrams/er-modell.png` + `sql/schema.sql` - ER-Diagramm und ausführbares Schema |
| Prozess- und Verfahrensmodellierung | `diagrams/antragsprozess.png` - BPMN 2.0 Prozessdiagramm |
| Konzeption von Datenschnittstellen | Tabellen `schnittstelle_auszahlung` und `schnittstelle_gis` im Schema |
| IT-Projektmanagement | Strukturierte Projektdokumentation (README) |

Weitere Kenntnisse & Fähigkeiten sind dem Lebenslauf zu entnehmen.

---

## 📂 Projektstruktur

```
iacs-bluehstreifen-foerderung/
│
├── README.md                          ← Sie lesen gerade hier
│
├── docs/
│   └── anforderungen.md               ← Funktionale und nicht-funktionale Anforderungen
│
├── diagrams/
│   ├── er-modell.png                  ← Entity-Relationship-Diagramm der Datenbank
│   └── antragsprozess.png             ← BPMN-Prozessdiagramm des Antragsdurchlaufs
│
└── sql/
    ├── schema.sql                     ← Vollständiges Datenbankschema (MySQL)
    └── beispiel-queries.sql           ← SQL-Abfragen für typische Anwendungsfälle
```

---

## 🗂️ Fachlicher Kontext zur fiktiven Projektidee: Wie funktioniert die Förderung?

### Ablauf aus Sicht des Landwirts:

1. **Antragstellung**
   - Landwirt meldet sich mit Betriebsnummer an
   - Gibt an, welche Flächen als Blühstreifen bewirtschaftet werden sollen
   - Wählt Förderart (einjährig vs. mehrjährig)

2. **Prüfung durch Zahlstelle**
   - Vollständigkeitsprüfung der Unterlagen
   - Fachliche Prüfung: Sind die Flächen förderfähig?
   - GIS-Abgleich: Überschneidungen mit Schutzgebieten?

3. **Bewilligung & Auszahlung**
   - Bei positivem Bescheid: Auszahlung des Förderbetrags
   - Bei Ablehnung: Begründung und Widerspruchsmöglichkeit

4. **Vor-Ort-Kontrolle**
   - Stichprobenartige Kontrollen, ob Blühstreifen tatsächlich angelegt wurden

### Technische Anforderungen:
- Anbindung an bestehende IACS-Infrastruktur
- Schnittstellen zu GIS-Systemen (Flächenabgleich)
- Schnittstelle zum Auszahlungssystem der EU-Zahlstelle
- DSGVO-konforme Speicherung personenbezogener Daten

---

## 🛠️ Meine Technische Umsetzung

### Datenmodell (ER-Diagramm)

Das Datenmodell bildet folgende Kernentitäten ab:

- **Antragsteller**: Landwirte mit Betriebsnummer, Stammdaten
- **Foerderantrag**: Einzelne Anträge mit Status, Beträgen, Zeitstempeln
- **Flaeche**: Geförderte Blühstreifenflächen (Geometrie, Größe, Förderart)
- **Pruefung**: Dokumentation des Prüfprozesses (Prüfer, Ergebnis, Kommentare)
- **Auszahlung**: Bewilligte und ausgezahlte Beträge
- **Schnittstellen**: Datenaustausch mit GIS und Auszahlungssystem

**Besonderheiten:**
- Normalisierte Struktur (3. Normalform)
- Foreign Key Constraints zur Datenintegrität
- Indizes für Performance-kritische Abfragen (Status, Antragsjahr)
- ENUM-Typen für Status-Workflows

### SQL-Schema

Das Schema (`sql/schema.sql`) ist **vollständig ausführbar** und enthält:

- CREATE TABLE statements mit Constraints
- Beispiel-Datensätze (INSERT statements)
- Kommentare zur Erläuterung der Feldlogik

**Technologie**: MySQL 8.0+ (kompatibel mit MariaDB)

### Prozessmodellierung (BPMN)

Das BPMN-Diagramm visualisiert den **End-to-End-Prozess**:

- Startpunkt: Antragstellung durch Landwirt
- Entscheidungspunkte (Gateways): Vollständig? Förderfähig?
- Parallele Prozesse: GIS-Prüfung läuft parallel zur fachlichen Prüfung
- Endpunkte: Bewilligung oder Ablehnung

---

## 🧪 Schema testen

Das SQL-Schema kann direkt getestet werden! Eine ausführliche Anleitung findest du in **[TESTING.md](TESTING.md)**.

**Schnelltest (kein Setup nötig):**
1. Öffne [DB Fiddle](https://www.db-fiddle.com/)
2. Wähle "MySQL 8.0"
3. Kopiere `sql/schema.sql` (ohne die ersten CREATE DATABASE Zeilen)
4. Klicke "Run" → Fertig!

Detaillierte Anleitungen für SQLite und MySQL findest du in der **[Test-Anleitung](TESTING.md)**.

---

## 💡 Anwendungsbeispiele (SQL-Queries)

Im Verzeichnis `sql/beispiel-queries.sql` finden sich praxisnahe Abfragen und können gern ausprobiert werden.

---

## 🚀 Nächste Schritte (wenn es ein echtes Projekt wäre, was würde ich als nächstes tun):

- [ ] Abstimmung mit Fachabteilung zu fachlichen Details
- [ ] Technische Spezifikation für externe Dienstleister erstellen
- [ ] Testfälle für Akzeptanztests definieren
- [ ] Datenschutz durchführen

---

## 👤 Über mich

Dieses Projekt entstand im Rahmen meiner Bewerbung auf die Stelle **Referent/Referentin (m/w/d) IT - Projekt IACS Kennziffer:
2 35 25** beim Landesamt für Umwelt, Landwirtschaft und Geologie (LfULG) in Niederwiesa

**Hintergrund:**
- Master in Informatik für Geistes- und Sozialwissenschaftler
- Bachelor in Medienkommunikation
- 2,5 Jahre Projekterfahrung (Hochschule): KI-basierter Chatbot zur Studienorientierung
- Koordination mit externen Dienstleistern, Anforderungsanalyse, Dokumentation

**Relevante Kenntnisse:**
- SQL (MySQL), Git, Python
- UML-Diagramme, BPMN-Prozessmodellierung
- Projektmanagementerfahrung und Horizon Europe Weiterbildung

---

## 📞 Kontakt

Entnehmen Sie bitte meinen Bewerbungsunterlagen
Vielen lieben Dank fürs Anschauen! ❤️

---

**Lizenz**: Dieses Projekt dient ausschließlich zu Demonstrationszwecken im Rahmen einer Bewerbung. Alle Daten sind fiktiv.


