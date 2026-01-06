-- =====================================================
-- BEISPIEL-ABFRAGEN FÜR IACS BLÜHSTREIFEN-FÖRDERUNG
-- =====================================================
-- Diese Queries demonstrieren typische Anwendungsfälle
-- in der Verwaltung von Förderanträgen
-- =====================================================

USE iacs_bluehstreifen;

-- =====================================================
-- 1. REPORTING & STATISTIK
-- =====================================================

-- 1.1 Übersicht: Alle Anträge des Jahres 2025
-- Zeigt: Status, Antragsteller, beantragte/bewilligte Beträge
SELECT 
    f.id AS antrag_id,
    a.betriebsnummer,
    a.name AS landwirt,
    f.foerderart,
    f.status,
    f.beantragt_betrag,
    f.bewilligt_betrag,
    f.eingereicht_am
FROM foerderantrag f
JOIN antragsteller a ON f.antragsteller_id = a.id
WHERE f.antragsjahr = 2025
ORDER BY f.eingereicht_am DESC;

-- 1.2 Statistik: Anzahl Anträge pro Status
SELECT 
    status,
    COUNT(*) AS anzahl_antraege,
    SUM(beantragt_betrag) AS summe_beantragt,
    SUM(bewilligt_betrag) AS summe_bewilligt
FROM foerderantrag
WHERE antragsjahr = 2025
GROUP BY status
ORDER BY anzahl_antraege DESC;

-- 1.3 Top 5 Antragsteller nach Förderbetrag
SELECT 
    a.name AS landwirt,
    a.betriebsnummer,
    COUNT(f.id) AS anzahl_antraege,
    SUM(f.bewilligt_betrag) AS gesamt_foerderung
FROM antragsteller a
JOIN foerderantrag f ON a.id = f.antragsteller_id
WHERE f.status = 'bewilligt'
GROUP BY a.id, a.name, a.betriebsnummer
ORDER BY gesamt_foerderung DESC
LIMIT 5;

-- 1.4 Gesamtfläche der Blühstreifen (nach Förderart)
SELECT 
    f.foerderart,
    COUNT(DISTINCT fl.antrag_id) AS anzahl_antraege,
    COUNT(fl.id) AS anzahl_flaechen,
    SUM(fl.groesse_ha) AS gesamt_flaeche_ha,
    ROUND(AVG(fl.groesse_ha), 2) AS durchschnitt_flaeche_ha
FROM foerderantrag f
JOIN flaeche fl ON f.id = fl.antrag_id
WHERE f.antragsjahr = 2025
GROUP BY f.foerderart;

-- =====================================================
-- 2. PRÜFWORKFLOW & QUALITÄTSSICHERUNG
-- =====================================================

-- 2.1 Alle Anträge in Prüfung, die älter als 14 Tage sind
-- (Eskalation bei langer Bearbeitungszeit)
SELECT 
    f.id AS antrag_id,
    a.name AS landwirt,
    f.eingereicht_am,
    DATEDIFF(CURDATE(), f.eingereicht_am) AS tage_in_bearbeitung,
    f.status
FROM foerderantrag f
JOIN antragsteller a ON f.antragsteller_id = a.id
WHERE f.status IN ('in_pruefung', 'nachforderung')
  AND DATEDIFF(CURDATE(), f.eingereicht_am) > 14
ORDER BY tage_in_bearbeitung DESC;

-- 2.2 Anträge mit fehlgeschlagenen GIS-Prüfungen
SELECT 
    f.id AS antrag_id,
    a.name AS landwirt,
    p.kommentar AS grund,
    p.geprueft_am
FROM foerderantrag f
JOIN antragsteller a ON f.antragsteller_id = a.id
JOIN pruefung p ON f.id = p.antrag_id
WHERE p.pruefungstyp = 'gis_abgleich'
  AND p.ergebnis = 'nicht_bestanden';

-- 2.3 Prüfstatistik pro Sachbearbeiter
SELECT 
    pruefer_name,
    COUNT(*) AS anzahl_pruefungen,
    SUM(CASE WHEN ergebnis = 'bestanden' THEN 1 ELSE 0 END) AS bestanden,
    SUM(CASE WHEN ergebnis = 'nicht_bestanden' THEN 1 ELSE 0 END) AS nicht_bestanden,
    ROUND(
        100.0 * SUM(CASE WHEN ergebnis = 'bestanden' THEN 1 ELSE 0 END) / COUNT(*), 
        1
    ) AS erfolgsquote_prozent
FROM pruefung
WHERE geprueft_am >= '2025-01-01'
GROUP BY pruefer_name
ORDER BY anzahl_pruefungen DESC;

-- =====================================================
-- 3. FINANZIELLE AUSWERTUNGEN
-- =====================================================

-- 3.1 Vergleich: Beantragt vs. Bewilligt
-- (Identifiziert Anträge mit Kürzungen)
SELECT 
    f.id AS antrag_id,
    a.name AS landwirt,
    f.beantragt_betrag,
    f.bewilligt_betrag,
    (f.beantragt_betrag - f.bewilligt_betrag) AS differenz,
    ROUND(
        100.0 * f.bewilligt_betrag / f.beantragt_betrag, 
        1
    ) AS bewilligungsquote_prozent
FROM foerderantrag f
JOIN antragsteller a ON f.antragsteller_id = a.id
WHERE f.status = 'bewilligt'
  AND f.beantragt_betrag != f.bewilligt_betrag
ORDER BY differenz DESC;

-- 3.2 Offene Auszahlungen (bewilligt, aber noch nicht überwiesen)
SELECT 
    f.id AS antrag_id,
    a.name AS landwirt,
    f.bewilligt_betrag,
    f.bewilligt_am,
    DATEDIFF(CURDATE(), f.bewilligt_am) AS tage_seit_bewilligung
FROM foerderantrag f
JOIN antragsteller a ON f.antragsteller_id = a.id
LEFT JOIN auszahlung z ON f.id = z.antrag_id
WHERE f.status = 'bewilligt'
  AND z.id IS NULL
ORDER BY f.bewilligt_am ASC;

-- 3.3 Monatliche Auszahlungsübersicht 2025
SELECT 
    DATE_FORMAT(z.auszahlung_datum, '%Y-%m') AS monat,
    COUNT(*) AS anzahl_auszahlungen,
    SUM(z.betrag) AS gesamt_betrag,
    ROUND(AVG(z.betrag), 2) AS durchschnitt_betrag
FROM auszahlung z
WHERE YEAR(z.auszahlung_datum) = 2025
  AND z.status = 'ausgezahlt'
GROUP BY DATE_FORMAT(z.auszahlung_datum, '%Y-%m')
ORDER BY monat;

-- =====================================================
-- 4. FLÄCHENMANAGEMENT
-- =====================================================

-- 4.1 Detaillierte Flächenübersicht pro Antrag
SELECT 
    f.id AS antrag_id,
    a.name AS landwirt,
    COUNT(fl.id) AS anzahl_flaechen,
    SUM(fl.groesse_ha) AS gesamt_flaeche_ha,
    f.foerderart,
    (SUM(fl.groesse_ha) * MAX(fl.foerdersatz)) AS berechneter_betrag
FROM foerderantrag f
JOIN antragsteller a ON f.antragsteller_id = a.id
JOIN flaeche fl ON f.id = fl.antrag_id
GROUP BY f.id, a.name, f.foerderart
ORDER BY gesamt_flaeche_ha DESC;

-- 4.2 Flächen ohne GIS-Validierung
-- (Identifiziert fehlende Geometriedaten)
SELECT 
    fl.id AS flaeche_id,
    fl.flurstueck_id,
    fl.groesse_ha,
    f.id AS antrag_id,
    a.name AS landwirt
FROM flaeche fl
JOIN foerderantrag f ON fl.antrag_id = f.id
JOIN antragsteller a ON f.antragsteller_id = a.id
LEFT JOIN schnittstelle_gis gis ON fl.id = gis.flaeche_id
WHERE gis.id IS NULL
  AND f.status != 'abgelehnt';

-- 4.3 Größte zusammenhängende Blühstreifenflächen
-- (Interessant für Biodiversitäts-Monitoring)
SELECT 
    fl.flurstueck_id,
    fl.gemarkung,
    fl.groesse_ha,
    a.name AS landwirt,
    f.foerderart
FROM flaeche fl
JOIN foerderantrag f ON fl.antrag_id = f.id
JOIN antragsteller a ON f.antragsteller_id = a.id
WHERE fl.groesse_ha >= 5.0
ORDER BY fl.groesse_ha DESC
LIMIT 10;

-- =====================================================
-- 5. SCHNITTSTELLEN-MONITORING
-- =====================================================

-- 5.1 GIS-Import-Fehler der letzten 30 Tage
SELECT 
    gis.import_datum,
    fl.flurstueck_id,
    gis.quellsystem,
    gis.fehlermeldung
FROM schnittstelle_gis gis
JOIN flaeche fl ON gis.flaeche_id = fl.id
WHERE gis.validierung_ok = FALSE
  AND gis.import_datum >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
ORDER BY gis.import_datum DESC;

-- 5.2 Auszahlungs-Export Status
SELECT 
    sa.export_datum,
    sa.zielsystem,
    sa.status,
    COUNT(*) AS anzahl_exporte,
    SUM(CASE WHEN sa.status = 'fehler' THEN 1 ELSE 0 END) AS fehler_anzahl
FROM schnittstelle_auszahlung sa
WHERE sa.export_datum >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY sa.export_datum, sa.zielsystem, sa.status
ORDER BY sa.export_datum DESC;

-- =====================================================
-- 6. KOMPLEXE ANALYSEN
-- =====================================================

-- 6.1 Vollständiger Antragsdurchlauf (alle Schritte)
-- Zeigt: Antrag → Prüfungen → Bewilligung → Auszahlung
SELECT 
    f.id AS antrag_id,
    a.name AS landwirt,
    f.eingereicht_am,
    GROUP_CONCAT(
        DISTINCT CONCAT(p.pruefungstyp, ': ', p.ergebnis) 
        ORDER BY p.geprueft_am 
        SEPARATOR '; '
    ) AS pruefungen,
    f.bewilligt_am,
    z.auszahlung_datum,
    z.betrag AS ausgezahlt
FROM foerderantrag f
JOIN antragsteller a ON f.antragsteller_id = a.id
LEFT JOIN pruefung p ON f.id = p.antrag_id
LEFT JOIN auszahlung z ON f.id = z.antrag_id
WHERE f.status = 'bewilligt'
GROUP BY f.id, a.name, f.eingereicht_am, f.bewilligt_am, z.auszahlung_datum, z.betrag
ORDER BY f.eingereicht_am DESC;

-- 6.2 Performance-Analyse: Durchschnittliche Bearbeitungszeit
SELECT 
    AVG(DATEDIFF(f.bewilligt_am, f.eingereicht_am)) AS durchschnitt_tage,
    MIN(DATEDIFF(f.bewilligt_am, f.eingereicht_am)) AS schnellster_antrag_tage,
    MAX(DATEDIFF(f.bewilligt_am, f.eingereicht_am)) AS langsamster_antrag_tage
FROM foerderantrag f
WHERE f.status = 'bewilligt'
  AND f.bewilligt_am IS NOT NULL;

-- =====================================================
-- 7. DATENQUALITÄT & PLAUSIBILITÄTSPRÜFUNGEN
-- =====================================================

-- 7.1 Anträge mit unplausibler Flächengröße
-- (Blühstreifen sollten zwischen 0.1 und 50 ha liegen)
SELECT 
    fl.id AS flaeche_id,
    fl.flurstueck_id,
    fl.groesse_ha,
    f.id AS antrag_id,
    a.name AS landwirt
FROM flaeche fl
JOIN foerderantrag f ON fl.antrag_id = f.id
JOIN antragsteller a ON f.antragsteller_id = a.id
WHERE fl.groesse_ha < 0.1 OR fl.groesse_ha > 50.0;

-- 7.2 Dubletten-Check: Gleicher Antragsteller, gleiches Jahr, mehrere Anträge
-- (Normalerweise sollte pro Jahr nur 1 Antrag möglich sein)
SELECT 
    a.betriebsnummer,
    a.name,
    f.antragsjahr,
    COUNT(*) AS anzahl_antraege
FROM foerderantrag f
JOIN antragsteller a ON f.antragsteller_id = a.id
GROUP BY a.id, a.betriebsnummer, a.name, f.antragsjahr
HAVING COUNT(*) > 1;

-- =====================================================
-- ENDE DER BEISPIEL-QUERIES
-- =====================================================

-- Diese Queries demonstrieren:
-- ✓ JOINs (INNER, LEFT)
-- ✓ Aggregatfunktionen (COUNT, SUM, AVG)
-- ✓ Gruppierung (GROUP BY)
-- ✓ Filtering (WHERE, HAVING)
-- ✓ Datumsfunktionen (DATEDIFF, DATE_FORMAT)
-- ✓ Bedingungslogik (CASE WHEN)
-- ✓ String-Funktionen (CONCAT, GROUP_CONCAT)
-- ✓ Subqueries (implizit in einigen Queries)
