-- =====================================================
-- IACS Blühstreifen-Förderprogramm - Datenbankschema
-- =====================================================
-- Version: 1.0
-- Datenbank: MySQL 8.0+ / MariaDB 10.5+
-- Zweck: Portfolio-Projekt für Bewerbung LfULG
-- Autor: Isabell Mrotzek
-- =====================================================

-- Datenbank erstellen (falls noch nicht vorhanden)
CREATE DATABASE IF NOT EXISTS iacs_bluehstreifen 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE iacs_bluehstreifen;

-- =====================================================
-- Tabelle: antragsteller
-- Beschreibung: Stammdaten der landwirtschaftlichen Betriebe
-- =====================================================

CREATE TABLE antragsteller (
    id INT PRIMARY KEY AUTO_INCREMENT,
    betriebsnummer VARCHAR(20) UNIQUE NOT NULL COMMENT 'Eindeutige Betriebsnummer (z.B. SN-2025-001)',
    name VARCHAR(100) NOT NULL COMMENT 'Name des Betriebs/Inhabers',
    strasse VARCHAR(100),
    plz VARCHAR(5),
    ort VARCHAR(100),
    telefon VARCHAR(20),
    email VARCHAR(100),
    erstellt_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    aktualisiert_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_betriebsnummer (betriebsnummer),
    INDEX idx_ort (ort)
) COMMENT 'Landwirtschaftliche Betriebe (Antragsteller)';

-- =====================================================
-- Tabelle: foerderantrag
-- Beschreibung: Förderanträge für Blühstreifen
-- =====================================================

CREATE TABLE foerderantrag (
    id INT PRIMARY KEY AUTO_INCREMENT,
    antragsteller_id INT NOT NULL,
    antragsjahr YEAR NOT NULL COMMENT 'Jahr der Förderperiode (z.B. 2025)',
    foerderart ENUM('einjährig', 'mehrjährig') NOT NULL COMMENT 'Art der Blühstreifen',
    status ENUM(
        'eingereicht', 
        'in_pruefung', 
        'nachforderung', 
        'bewilligt', 
        'abgelehnt'
    ) DEFAULT 'eingereicht' COMMENT 'Aktueller Bearbeitungsstatus',
    
    beantragt_betrag DECIMAL(10,2) COMMENT 'Vom Antragsteller berechneter Betrag (EUR)',
    bewilligt_betrag DECIMAL(10,2) COMMENT 'Von Zahlstelle bewilligter Betrag (EUR)',
    
    eingereicht_am DATE NOT NULL,
    bewilligt_am DATE COMMENT 'Datum der Bewilligung (falls zutreffend)',
    
    bemerkung TEXT COMMENT 'Interne Anmerkungen oder Rückmeldungen an Antragsteller',
    
    FOREIGN KEY (antragsteller_id) REFERENCES antragsteller(id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    
    INDEX idx_status (status),
    INDEX idx_antragsjahr (antragsjahr),
    INDEX idx_eingereicht (eingereicht_am)
) COMMENT 'Förderanträge für Blühstreifen';

-- =====================================================
-- Tabelle: flaeche
-- Beschreibung: Geförderte Flächen (Blühstreifen)
-- =====================================================

CREATE TABLE flaeche (
    id INT PRIMARY KEY AUTO_INCREMENT,
    antrag_id INT NOT NULL,
    
    flurstueck_id VARCHAR(50) COMMENT 'Flurstück-Identifikator (Gemarkung-Flur-Flurstück)',
    gemarkung VARCHAR(100),
    flur VARCHAR(20),
    flurstuck_nr VARCHAR(20),
    
    groesse_ha DECIMAL(6,2) NOT NULL COMMENT 'Flächengröße in Hektar',
    
    geometrie TEXT COMMENT 'Flächengeometrie (WKT-Format oder GeoJSON)',
    
    foerdersatz DECIMAL(6,2) NOT NULL COMMENT 'Fördersatz in EUR/ha (150 oder 250)',
    
    erstellt_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (antrag_id) REFERENCES foerderantrag(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    INDEX idx_antrag (antrag_id),
    INDEX idx_flurstueck (flurstueck_id)
) COMMENT 'Einzelne geförderte Flächen (Blühstreifen)';

-- =====================================================
-- Tabelle: pruefung
-- Beschreibung: Dokumentation des Prüfprozesses
-- =====================================================

CREATE TABLE pruefung (
    id INT PRIMARY KEY AUTO_INCREMENT,
    antrag_id INT NOT NULL,
    
    pruefungstyp ENUM(
        'vollständigkeit', 
        'fachlich', 
        'gis_abgleich', 
        'vor_ort'
    ) NOT NULL COMMENT 'Art der Prüfung',
    
    ergebnis ENUM('bestanden', 'nicht_bestanden', 'in_bearbeitung') NOT NULL,
    
    pruefer_name VARCHAR(100) COMMENT 'Name des Sachbearbeiters',
    pruefer_id VARCHAR(50) COMMENT 'Mitarbeiter-ID',
    
    kommentar TEXT COMMENT 'Detaillierte Anmerkungen zur Prüfung',
    
    geprueft_am DATE NOT NULL,
    erstellt_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (antrag_id) REFERENCES foerderantrag(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    INDEX idx_antrag (antrag_id),
    INDEX idx_typ (pruefungstyp)
) COMMENT 'Prüfungsdokumentation für Förderanträge';

-- =====================================================
-- Tabelle: auszahlung
-- Beschreibung: Bewilligte und ausgezahlte Beträge
-- =====================================================

CREATE TABLE auszahlung (
    id INT PRIMARY KEY AUTO_INCREMENT,
    antrag_id INT NOT NULL,
    
    betrag DECIMAL(10,2) NOT NULL COMMENT 'Ausgezahlter Betrag in EUR',
    
    auszahlung_datum DATE NOT NULL COMMENT 'Datum der Überweisung',
    
    zahlungsreferenz VARCHAR(50) COMMENT 'Referenznummer der Zahlung',
    
    status ENUM('angewiesen', 'ausgezahlt', 'storniert') DEFAULT 'angewiesen',
    
    erstellt_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (antrag_id) REFERENCES foerderantrag(id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    
    INDEX idx_antrag (antrag_id),
    INDEX idx_datum (auszahlung_datum)
) COMMENT 'Auszahlungen an Antragsteller';

-- =====================================================
-- Tabelle: schnittstelle_gis
-- Beschreibung: Log für GIS-Datenabgleiche
-- =====================================================

CREATE TABLE schnittstelle_gis (
    id INT PRIMARY KEY AUTO_INCREMENT,
    flaeche_id INT NOT NULL,
    
    import_datum TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    quellsystem VARCHAR(50) COMMENT 'Name des GIS-Systems (z.B. "SaxGIS")',
    
    geometrie_format ENUM('WKT', 'GeoJSON', 'Shapefile') NOT NULL,
    geometrie_daten TEXT COMMENT 'Importierte Geometrie-Rohdaten',
    
    validierung_ok BOOLEAN DEFAULT FALSE COMMENT 'Geometrie erfolgreich validiert?',
    fehlermeldung TEXT COMMENT 'Ggf. Fehlermeldungen bei Import',
    
    FOREIGN KEY (flaeche_id) REFERENCES flaeche(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    INDEX idx_flaeche (flaeche_id),
    INDEX idx_import (import_datum)
) COMMENT 'Log für GIS-Schnittstelle (Flächengeometrien)';

-- =====================================================
-- Tabelle: schnittstelle_auszahlung
-- Beschreibung: Log für Exporte zum Auszahlungssystem
-- =====================================================

CREATE TABLE schnittstelle_auszahlung (
    id INT PRIMARY KEY AUTO_INCREMENT,
    auszahlung_id INT NOT NULL,
    
    export_datum TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    zielsystem VARCHAR(50) COMMENT 'Name des Auszahlungssystems',
    
    xml_payload TEXT COMMENT 'Exportierte XML-Daten (IACS-Standard)',
    
    status ENUM('pending', 'übertragen', 'fehler') DEFAULT 'pending',
    fehlermeldung TEXT,
    
    FOREIGN KEY (auszahlung_id) REFERENCES auszahlung(id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    
    INDEX idx_auszahlung (auszahlung_id),
    INDEX idx_export (export_datum)
) COMMENT 'Log für Auszahlungs-Schnittstelle (XML-Export)';

-- =====================================================
-- BEISPIELDATEN FÜR DEMONSTRATION
-- =====================================================

-- Antragsteller anlegen
INSERT INTO antragsteller (betriebsnummer, name, strasse, plz, ort, telefon, email) VALUES
('SN-2025-001', 'Müller Landwirtschaft GmbH', 'Dorfstraße 12', '01234', 'Beispieldorf', '0351-123456', 'mueller@beispiel.de'),
('SN-2025-002', 'Hofgut Schmidt', 'Feldweg 5', '09876', 'Musterhausen', '03731-987654', 'schmidt@hofgut.de'),
('SN-2025-003', 'Öko-Bauernhof Wagner', 'Grüne Wiese 3', '01587', 'Riesa', '03525-456789', 'wagner@oeko-hof.de');

-- Förderanträge anlegen
INSERT INTO foerderantrag (antragsteller_id, antragsjahr, foerderart, status, beantragt_betrag, eingereicht_am) VALUES
(1, 2025, 'einjährig', 'in_pruefung', 3750.00, '2025-01-15'),
(2, 2025, 'mehrjährig', 'bewilligt', 7500.00, '2025-02-03'),
(3, 2025, 'einjährig', 'eingereicht', 1500.00, '2025-02-28');

-- Flächen zu Anträgen hinzufügen
INSERT INTO flaeche (antrag_id, flurstueck_id, gemarkung, flur, flurstuck_nr, groesse_ha, foerdersatz) VALUES
(1, '12345-01-0123', 'Beispieldorf', '01', '0123', 15.50, 150.00),
(1, '12345-01-0124', 'Beispieldorf', '01', '0124', 9.50, 150.00),
(2, '98765-03-0456', 'Musterhausen', '03', '0456', 30.00, 250.00),
(3, '45678-02-0789', 'Riesa', '02', '0789', 10.00, 150.00);

-- Prüfungen dokumentieren
INSERT INTO pruefung (antrag_id, pruefungstyp, ergebnis, pruefer_name, pruefer_id, kommentar, geprueft_am) VALUES
(1, 'vollständigkeit', 'bestanden', 'Anna Meier', 'AM-42', 'Alle Unterlagen vollständig vorhanden.', '2025-01-20'),
(1, 'fachlich', 'in_bearbeitung', 'Thomas Keller', 'TK-17', 'Prüfung der Förderfähigkeit läuft noch.', '2025-01-25'),
(2, 'vollständigkeit', 'bestanden', 'Anna Meier', 'AM-42', 'Unterlagen OK.', '2025-02-05'),
(2, 'fachlich', 'bestanden', 'Thomas Keller', 'TK-17', 'Flächen förderfähig, keine Überschneidungen.', '2025-02-10'),
(2, 'gis_abgleich', 'bestanden', 'System', 'GIS-AUTO', 'Automatischer GIS-Abgleich erfolgreich.', '2025-02-10');

-- Auszahlungen (nur für bewilligte Anträge)
INSERT INTO auszahlung (antrag_id, betrag, auszahlung_datum, zahlungsreferenz, status) VALUES
(2, 7500.00, '2025-07-15', 'ZR-2025-07-0042', 'ausgezahlt');

-- GIS-Schnittstelle Beispieldaten
INSERT INTO schnittstelle_gis (flaeche_id, quellsystem, geometrie_format, geometrie_daten, validierung_ok) VALUES
(1, 'SaxGIS', 'GeoJSON', '{"type":"Polygon","coordinates":[[[13.5,51.0],[13.6,51.0],[13.6,51.1],[13.5,51.1],[13.5,51.0]]]}', TRUE),
(2, 'SaxGIS', 'GeoJSON', '{"type":"Polygon","coordinates":[[[13.7,51.2],[13.8,51.2],[13.8,51.3],[13.7,51.3],[13.7,51.2]]]}', TRUE);

-- Auszahlungs-Schnittstelle Beispieldaten
INSERT INTO schnittstelle_auszahlung (auszahlung_id, zielsystem, xml_payload, status) VALUES
(1, 'EU-Zahlstelle', '<auszahlung><antrag_id>2</antrag_id><betriebsnummer>SN-2025-002</betriebsnummer><betrag>7500.00</betrag><waehrung>EUR</waehrung></auszahlung>', 'übertragen');

-- =====================================================
-- ENDE DES SCHEMAS
-- =====================================================

-- Hinweis: Dieses Schema ist für Demonstrationszwecke erstellt.
-- In einem Produktivsystem würden weitere Aspekte hinzukommen:
-- - Audit-Logging (Trigger für Änderungsverfolgung)
-- - Partitionierung nach Antragsjahr (Performance)
-- - Verschlüsselung personenbezogener Daten (DSGVO)
-- - Zusätzliche Constraints und Checks
