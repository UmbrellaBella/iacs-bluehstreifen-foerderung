# Anforderungsdokumentation
## Blühstreifen-Förderprogramm Sachsen 2025

---

## 1. Projektkontext

### 1.1 Ausgangssituation
Das Sächsische Staatsministerium für Umwelt und Landwirtschaft (SMUL) plant die Einführung eines neuen Agrarumweltprogramms zur Förderung von Blühstreifen. Ziel ist die Stärkung der Biodiversität und des Insektenschutzes in der sächsischen Landwirtschaft.

### 1.2 Zielsetzung
Entwicklung eines IT-Systems zur digitalen Abwicklung von Förderanträgen, das nahtlos in die bestehende IACS-Infrastruktur integriert werden kann.

### 1.3 Stakeholder
- **Antragsteller**: Landwirtschaftliche Betriebe in Sachsen
- **Sachbearbeiter**: Mitarbeiter der EU-Zahlstelle (LfULG)
- **IT-Betrieb**: Referat 112 "Förderverfahren"
- **Externe Systeme**: GIS-Fachanwendung, EU-Auszahlungssystem

---

## 2. Funktionale Anforderungen

### FA-01: Antragstellung
**Beschreibung**: Das System muss es Landwirten ermöglichen, Förderanträge für Blühstreifen digital einzureichen.

**Akzeptanzkriterien**:
- Eingabe der Betriebsnummer (Pflichtfeld, 10-stellig)
- Auswahl des Antragsjahrs (2025-2030)
- Auswahl der Förderart:
  - Einjährige Blühstreifen (150 €/ha)
  - Mehrjährige Blühstreifen (250 €/ha)
- Upload von Flächennachweisen (PDF, max. 5 MB)
- Bestätigung der Förderbedingungen (Checkbox)

**Priorität**: Hoch

---

### FA-02: Flächenverwaltung
**Beschreibung**: Antragsteller müssen die zu fördernden Flächen detailliert angeben können.

**Akzeptanzkriterien**:
- Eingabe von Flurstück-Identifikatoren (Gemarkung, Flur, Flurstück)
- Angabe der Flächengröße in Hektar (min. 0.1 ha, max. 50 ha)
- Optionale Angabe von GPS-Koordinaten (WGS84)
- Zuordnung zu einem Förderantrag (1:n-Beziehung)

**Priorität**: Hoch

---

### FA-03: Statusverfolgung
**Beschreibung**: Antragsteller müssen den aktuellen Bearbeitungsstatus ihres Antrags einsehen können.

**Akzeptanzkriterien**:
- Anzeige des aktuellen Status (eingereicht, in Prüfung, bewilligt, abgelehnt)
- Zeitstempel für jeden Statuswechsel
- Nachrichtenfeld für Rückmeldungen der Zahlstelle (z.B. fehlende Unterlagen)

**Priorität**: Mittel

---

### FA-04: Prüfworkflow
**Beschreibung**: Sachbearbeiter der Zahlstelle müssen Anträge systematisch prüfen können.

**Akzeptanzkriterien**:
- Vollständigkeitsprüfung: Sind alle Pflichtfelder ausgefüllt?
- Fachliche Prüfung: Entsprechen die Flächen den Förderbedingungen?
- GIS-Abgleich: Überschneidungen mit Schutzgebieten prüfen
- Dokumentation der Prüfergebnisse (Freitextfeld + Datum + Prüfer-ID)
- Status-Update nach erfolgter Prüfung

**Priorität**: Hoch

---

### FA-05: Bewilligung und Auszahlung
**Beschreibung**: Das System muss bewilligte Förderbeträge berechnen und zur Auszahlung freigeben.

**Akzeptanzkriterien**:
- Automatische Berechnung: `Förderbetrag = Summe(Flächen) × Fördersatz`
- Vergleich mit beantragtem Betrag (Plausibilitätsprüfung)
- Export der Auszahlungsdaten als XML (Schema: EU-Standard IACS)
- Zeitstempel der Auszahlungsfreigabe

**Priorität**: Hoch

---

### FA-06: Schnittstellen zu externen Systemen
**Beschreibung**: Das System muss Daten mit bestehenden Systemen austauschen können.

**Akzeptanzkriterien**:
- **GIS-Schnittstelle**: Import von Flächengeometrien (GeoJSON, WKT)
- **Auszahlungssystem**: Export bewilligter Anträge (XML, täglich um 03:00 Uhr)
- **IACS-Kernsystem**: Abgleich mit Betriebsstammdaten (REST-API)

**Priorität**: Hoch

---

### FA-07: Reporting und Statistik
**Beschreibung**: Die Fachseite benötigt Auswertungen für EU-Berichtspflichten.

**Akzeptanzkriterien**:
- Anzahl Anträge pro Jahr und Förderart
- Gesamtfläche der geförderten Blühstreifen (in ha)
- Durchschnittlicher Förderbetrag pro Antrag
- Export als CSV oder Excel

**Priorität**: Mittel

---

## 3. Nicht-funktionale Anforderungen

### NFA-01: Performance
**Anforderung**: Das System muss mindestens 10.000 Anträge pro Jahr verwalten können, ohne dass die Antwortzeiten 3 Sekunden überschreiten.

**Messkriterium**: Load-Test mit simulierten 10.000 Datensätzen.

---

### NFA-02: Datenschutz (DSGVO)
**Anforderung**: Personenbezogene Daten müssen DSGVO-konform gespeichert und verarbeitet werden.

**Maßnahmen**:
- Verschlüsselung von Stammdaten (AES-256)
- Rollenbasierte Zugriffsrechte (RBAC)
- Löschkonzept: Anträge werden 10 Jahre nach Bewilligung gelöscht
- Protokollierung aller Zugriffe (Audit-Log)

---

### NFA-03: Verfügbarkeit
**Anforderung**: Das System muss während der Antragsphase (Januar-März) eine Verfügbarkeit von 99% gewährleisten.

**Maßnahmen**:
- Failover-Datenbank (Hot-Standby)
- Monitoring und Alerting (Nagios/Zabbix)

---

### NFA-04: Skalierbarkeit
**Anforderung**: Das Datenmodell muss erweiterbar sein für zukünftige Förderprogramme (z.B. Streuobstwiesen, Hecken).

**Maßnahmen**:
- Generische Tabelle `foerderart` statt Hardcoding
- Modular aufgebaute Schnittstellen

---

### NFA-05: Benutzerfreundlichkeit
**Anforderung**: Die Benutzeroberfläche muss auch für IT-unerfahrene Landwirte bedienbar sein.

**Maßnahmen**:
- Maximal 3 Klicks bis zur Antragstellung
- Kontextsensitive Hilfe-Texte
- Barrierefreiheit (WCAG 2.1 Level AA)

---

## 4. Datenschnittstellen

### 4.1 GIS-Schnittstelle (Import)
**Format**: GeoJSON  
**Frequenz**: On-Demand (bei Antragstellung)  
**Beispiel**:
```json
{
  "type": "Feature",
  "geometry": {
    "type": "Polygon",
    "coordinates": [[[13.5, 51.0], [13.6, 51.0], ...]]
  },
  "properties": {
    "flurstueck_id": "123456",
    "groesse_ha": 2.5
  }
}
```

### 4.2 Auszahlungssystem (Export)
**Format**: XML (IACS-Standard)  
**Frequenz**: Täglich, 03:00 Uhr  
**Beispiel**:
```xml
<auszahlung>
  <antrag_id>12345</antrag_id>
  <betriebsnummer>SN-2025-001</betriebsnummer>
  <betrag>3750.00</betrag>
  <waehrung>EUR</waehrung>
</auszahlung>
```

---

## 5. Testfälle (Auswahl)

### TC-01: Erfolgreiche Antragstellung
**Vorbedingung**: Landwirt ist im System registriert  
**Schritte**:
1. Einloggen mit Betriebsnummer
2. "Neuer Antrag" klicken
3. Fläche hinzufügen (2 ha, einjährig)
4. Antrag absenden

**Erwartetes Ergebnis**: Status = "eingereicht", Bestätigung per E-Mail

---

### TC-02: Ablehnung wegen fehlender Unterlagen
**Vorbedingung**: Antrag ohne Flächennachweis  
**Schritte**:
1. Sachbearbeiter ruft Antrag auf
2. Prüfung: "Unterlagen unvollständig"
3. Status ändern auf "Nachforderung"

**Erwartetes Ergebnis**: Landwirt erhält Nachricht mit Aufforderung zur Nachreichung

---

## 6. Offene Punkte / Risiken

| ID | Thema | Beschreibung | Maßnahme |
|----|-------|--------------|----------|
| R-01 | GIS-Datenqualität | Flächengeometrien könnten fehlerhaft sein | Validierung gegen TopPlus-Daten |
| R-02 | EU-Vorgaben ändern sich | Neue Verordnungen könnten Schema-Änderungen erfordern | Flexible Datenstruktur, Versionierung |
| R-03 | Hohe Last bei Fristende | Am 31. März könnten viele Anträge gleichzeitig eingehen | Load-Balancing, Kapazitätsplanung |

---

## 7. Abnahmekriterien

Das System gilt als abgenommen, wenn:

- ✅ Alle funktionalen Anforderungen (FA-01 bis FA-07) implementiert sind
- ✅ Mindestens 95% der Testfälle erfolgreich durchlaufen
- ✅ Performance-Tests bestanden (NFA-01)
- ✅ DSGVO-Konformität durch Datenschutzbeauftragten bestätigt
- ✅ Schulung der Sachbearbeiter abgeschlossen

---

**Erstellt von**: [Ihr Name]  
**Datum**: Dezember 2024  
**Version**: 1.0  
**Status**: Entwurf (für Bewerbungsportfolio)
