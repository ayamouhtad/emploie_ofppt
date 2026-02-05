-- ============================================================================
-- SCRIPT SQL COMPLET ET CORRIGÉ
-- Système de Gestion d'Emplois du Temps
-- Version: 2.0 Sécurisée
-- ============================================================================

-- Suppression de la base si elle existe (⚠️ ATTENTION : supprime toutes les données)
DROP DATABASE IF EXISTS gestion_emplois_temps;

-- Création de la base de données avec encodage UTF-8
CREATE DATABASE gestion_emplois_temps 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE gestion_emplois_temps;

-- ============================================================================
-- 1. TABLE UTILISATEURS (Authentification)
-- ============================================================================
CREATE TABLE utilisateurs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'gestionnaire') DEFAULT 'gestionnaire',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 2. TABLE ENSEIGNANTS
-- ============================================================================
CREATE TABLE enseignant (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    specialite VARCHAR(150),
    email VARCHAR(150),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_nom (nom, prenom),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 3. TABLE GROUPES
-- ============================================================================
CREATE TABLE groupes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL UNIQUE,
    niveau VARCHAR(50),
    effectif INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_nom (nom),
    INDEX idx_niveau (niveau)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 4. TABLE SALLES
-- ============================================================================
CREATE TABLE salles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL UNIQUE,
    capacite INT NOT NULL,
    type ENUM('cours', 'tp', 'amphi') DEFAULT 'cours',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_nom (nom),
    INDEX idx_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 5. TABLE MODULES
-- ============================================================================
CREATE TABLE modules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(150) NOT NULL,
    volume_horaire INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_nom (nom)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 6. TABLE AFFECTATIONS
-- ============================================================================
CREATE TABLE affectations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    enseignant_id INT NOT NULL,
    module_id INT NOT NULL,
    groupe_id INT NOT NULL,
    salle_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (enseignant_id) REFERENCES enseignant(id) ON DELETE CASCADE,
    FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE,
    FOREIGN KEY (groupe_id) REFERENCES groupes(id) ON DELETE CASCADE,
    FOREIGN KEY (salle_id) REFERENCES salles(id) ON DELETE CASCADE,
    INDEX idx_enseignant (enseignant_id),
    INDEX idx_module (module_id),
    INDEX idx_groupe (groupe_id),
    INDEX idx_salle (salle_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 7. TABLE SEANCES
-- ============================================================================
CREATE TABLE seances (
    id INT AUTO_INCREMENT PRIMARY KEY,
    affectation_id INT NOT NULL,
    jour ENUM('Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi') NOT NULL,
    heure_debut TIME NOT NULL,
    heure_fin TIME NOT NULL,
    validated TINYINT(1) DEFAULT 0,
    validated_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (affectation_id) REFERENCES affectations(id) ON DELETE CASCADE,
    INDEX idx_jour (jour),
    INDEX idx_affectation (affectation_id),
    INDEX idx_validated (validated)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 8. TABLE MASSE HORAIRE PAR GROUPE
-- ============================================================================
CREATE TABLE masse_horaire_groupes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    module_id INT NOT NULL,
    groupe_id INT NOT NULL,
    masse_horaire_totale DECIMAL(10,2) NOT NULL DEFAULT 0,
    masse_horaire_restante DECIMAL(10,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_module_groupe (module_id, groupe_id),
    FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE,
    FOREIGN KEY (groupe_id) REFERENCES groupes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 9. VUE EMPLOI DU TEMPS
-- ============================================================================
CREATE VIEW vue_emploi_temps AS
SELECT 
    s.id as seance_id,
    s.jour,
    s.heure_debut,
    s.heure_fin,
    s.validated,
    m.nom as module,
    m.volume_horaire,
    CONCAT(e.nom, ' ', e.prenom) as enseignant,
    g.nom as groupe,
    g.niveau,
    sal.nom as salle,
    sal.type as type_salle
FROM seances s
JOIN affectations a ON s.affectation_id = a.id
JOIN enseignant e ON a.enseignant_id = e.id
JOIN modules m ON a.module_id = m.id
JOIN groupes g ON a.groupe_id = g.id
JOIN salles sal ON a.salle_id = sal.id
ORDER BY 
    FIELD(s.jour, 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'),
    s.heure_debut;

-- ============================================================================
-- INSERTION DES DONNÉES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. UTILISATEURS (Authentification)
-- ----------------------------------------------------------------------------
-- ⚠️ Mot de passe par défaut pour tous : "password"
-- Hash généré avec : password_hash('password', PASSWORD_DEFAULT)
-- Pour générer un nouveau hash : php -r "echo password_hash('password', PASSWORD_DEFAULT);"
INSERT INTO utilisateurs (name, email, password, role) VALUES 
('Administrateur Système', 'admin@emploitemps.ma', '$2y$10$u5AjuM15ADqiziLpsqQiRejTkHBg3Hc7V1POvPrOmvlvGox7cqnn2', 'admin'),
('Gestionnaire Principal', 'gestionnaire@emploitemps.ma', '$2y$10$u5AjuM15ADqiziLpsqQiRejTkHBg3Hc7V1POvPrOmvlvGox7cqnn2', 'gestionnaire'),
('Coordinateur Pédagogique', 'coordinateur@emploitemps.ma', '$2y$10$u5AjuM15ADqiziLpsqQiRejTkHBg3Hc7V1POvPrOmvlvGox7cqnn2', 'gestionnaire');

-- ----------------------------------------------------------------------------
-- 2. ENSEIGNANTS
-- ----------------------------------------------------------------------------
INSERT INTO enseignant (nom, prenom, specialite, email) VALUES
('EL HAKIKI', 'Mohammed', 'Développement Web', 'elhakiki@ista.ma'),
('DAOUDI', 'Fatima', 'Base de Données', 'daoudi@ista.ma'),
('JALAL', 'Ahmed', 'Réseaux Informatiques', 'jalal@ista.ma'),
('TITOUICH', 'Youssef', 'Programmation Java', 'titouich@ista.ma'),
('NACHITE', 'Khadija', 'Développement Mobile', 'nachite@ista.ma'),
('JANAH', 'Hassan', 'Cloud Computing', 'janah@ista.ma'),
('HAQAY', 'Samira', 'Intelligence Artificielle', 'haqay@ista.ma'),
('BRINSI', 'Omar', 'Sécurité Informatique', 'brinsi@ista.ma'),
('ASCOUR', 'Rachid', 'Génie Logiciel', 'ascour@ista.ma'),
('FENTIS', 'Nadia', 'Systèmes Embarqués', 'fentis@ista.ma'),
('SNINY', 'Karim', 'Data Science', 'sniny@ista.ma'),
('BENHILAL', 'Amal', 'UX/UI Design', 'benhilal@ista.ma'),
('MERBOUH', 'Mehdi', 'DevOps', 'merbouh@ista.ma'),
('EL ALAMI', 'Sara', 'Algorithmique', 'elalami@ista.ma'),
('BAKAR', 'Bilal', 'Python', 'bakar@ista.ma'),
('ZERRARI', 'Hind', 'JavaScript', 'zerrari@ista.ma'),
('EL MADANI', 'Zakaria', 'PHP/Laravel', 'elmadani@ista.ma'),
('ESSOUFIANI', 'Imane', 'React/Angular', 'essoufiani@ista.ma'),
('ABIDAR', 'Amine', 'Gestion de Projet', 'abidar@ista.ma'),
('EL-OMARI', 'Salma', 'Communication', 'elomari@ista.ma');

-- ----------------------------------------------------------------------------
-- 3. GROUPES (Classes)
-- ----------------------------------------------------------------------------
INSERT INTO groupes (nom, niveau, effectif) VALUES
-- CMOSA (8 groupes)
('CMOSA101', 'CMOSA', 30), ('CMOSA102', 'CMOSA', 30), ('CMOSA103', 'CMOSA', 28),
('CMOSA104', 'CMOSA', 32), ('CMOSA105', 'CMOSA', 29), ('CMOSA106', 'CMOSA', 31),
('CMOSA107', 'CMOSA', 30), ('CMOSA108', 'CMOSA', 27),

-- CMOSE (10 groupes)
('CMOSE101', 'CMOSE', 30), ('CMOSE102', 'CMOSE', 29), ('CMOSE103', 'CMOSE', 31),
('CMOSE104', 'CMOSE', 28), ('CMOSE105', 'CMOSE', 30), ('CMOSE106', 'CMOSE', 32),
('CMOSE107', 'CMOSE', 29), ('CMOSE108', 'CMOSE', 30), ('CMOSE109', 'CMOSE', 28),
('CMOSE110', 'CMOSE', 31),

-- CMOSP (8 groupes)
('CMOSP101', 'CMOSP', 30), ('CMOSP102', 'CMOSP', 29), ('CMOSP103', 'CMOSP', 31),
('CMOSP104', 'CMOSP', 28), ('CMOSP105', 'CMOSP', 30), ('CMOSP106', 'CMOSP', 32),
('CMOSP107', 'CMOSP', 29), ('CMOSP108', 'CMOSP', 30),

-- CMOSW (12 groupes)
('CMOSW101', 'CMOSW', 30), ('CMOSW102', 'CMOSW', 29), ('CMOSW103', 'CMOSW', 31),
('CMOSW104', 'CMOSW', 28), ('CMOSW105', 'CMOSW', 30), ('CMOSW106', 'CMOSW', 32),
('CMOSW107', 'CMOSW', 29), ('CMOSW108', 'CMOSW', 30), ('CMOSW109', 'CMOSW', 28),
('CMOSW110', 'CMOSW', 31), ('CMOSW111', 'CMOSW', 29), ('CMOSW112', 'CMOSW', 30),

-- CMOSWINT (15 groupes)
('CMOSWINT101', 'CMOSWINT', 30), ('CMOSWINT102', 'CMOSWINT', 29), ('CMOSWINT103', 'CMOSWINT', 31),
('CMOSWINT104', 'CMOSWINT', 28), ('CMOSWINT105', 'CMOSWINT', 30), ('CMOSWINT106', 'CMOSWINT', 32),
('CMOSWINT107', 'CMOSWINT', 29), ('CMOSWINT108', 'CMOSWINT', 30), ('CMOSWINT109', 'CMOSWINT', 28),
('CMOSWINT110', 'CMOSWINT', 31), ('CMOSWINT111', 'CMOSWINT', 29), ('CMOSWINT112', 'CMOSWINT', 30),
('CMOSWINT113', 'CMOSWINT', 28), ('CMOSWINT114', 'CMOSWINT', 31), ('CMOSWINT115', 'CMOSWINT', 29),

-- DEV (7 groupes)
('DEV101', 'DEV', 30), ('DEV102', 'DEV', 29), ('DEV103', 'DEV', 31),
('DEV104', 'DEV', 28), ('DEV105', 'DEV', 30), ('DEV106', 'DEV', 32),
('DEV107', 'DEV', 29),

-- DEVOWFS (6 groupes)
('DEVOWFS201', 'DEVOWFS', 30), ('DEVOWFS202', 'DEVOWFS', 29), ('DEVOWFS203', 'DEVOWFS', 31),
('DEVOWFS204', 'DEVOWFS', 28), ('DEVOWFS205', 'DEVOWFS', 30), ('DEVOWFS206', 'DEVOWFS', 32),

-- GE (8 groupes)
('GE101', 'GE', 30), ('GE102', 'GE', 29), ('GE103', 'GE', 31),
('GE104', 'GE', 28), ('GE105', 'GE', 30), ('GE106', 'GE', 32),
('GE107', 'GE', 29), ('GE108', 'GE', 30),

-- GEOCF (7 groupes)
('GEOCF201', 'GEOCF', 30), ('GEOCF202', 'GEOCF', 29), ('GEOCF203', 'GEOCF', 31),
('GEOCF301', 'GEOCF', 28), ('GEOCF302', 'GEOCF', 30), ('GEOCF303', 'GEOCF', 32),
('GEOCF304', 'GEOCF', 29),

-- GEOCM (5 groupes)
('GEOCM201', 'GEOCM', 30), ('GEOCM202', 'GEOCM', 29), ('GEOCM203', 'GEOCM', 31),
('GEOCM301', 'GEOCM', 28), ('GEOCM302', 'GEOCM', 30),

-- ID (5 groupes)
('ID101', 'ID', 30), ('ID102', 'ID', 29), ('ID103', 'ID', 31),
('ID104', 'ID', 28), ('ID105', 'ID', 30),

-- IDOSR (3 groupes)
('IDOSR201', 'IDOSR', 30), ('IDOSR202', 'IDOSR', 29), ('IDOSR203', 'IDOSR', 31),

-- TSM (2 groupes)
('TSM101', 'TSM', 30), ('TSM102', 'TSM', 29),

-- WEB (1 groupe)
('WEB101', 'WEB', 30);

-- ----------------------------------------------------------------------------
-- 4. SALLES
-- ----------------------------------------------------------------------------
INSERT INTO salles (nom, capacite, type) VALUES
-- Salles Polyvalentes (SP)
('SP1', 30, 'cours'), ('SP3', 30, 'cours'), ('SP4', 30, 'cours'),
('SP5', 30, 'cours'), ('SP6', 30, 'cours'), ('SP7', 30, 'cours'),
('SP8', 30, 'cours'), ('SP9', 30, 'cours'),

-- Salles de Cours (SC)
('SC2', 35, 'cours'), ('SC6', 35, 'cours'), ('SC7', 35, 'cours'),
('SC8', 35, 'cours'), ('SC9', 35, 'cours'), ('SC10', 35, 'cours'),

-- Laboratoires
('LABO1', 25, 'tp'), ('LABO2', 25, 'tp'),

-- Amphithéâtre
('AMPHI', 100, 'amphi'),

-- Autres espaces
('TEAM', 40, 'cours'), ('COWORKING', 40, 'cours');

-- ----------------------------------------------------------------------------
-- 5. MODULES
-- ----------------------------------------------------------------------------
INSERT INTO modules (nom, volume_horaire) VALUES
('Préparer un projet web', 60),
('Approche agile', 40),
('Français professionnel', 30),
('Anglais technique', 30),
('Développement front-end', 60),
('Création d\'une application Cloud native', 60),
('Culture et techniques avancées du numérique', 40),
('Culture et Techniques Numérique', 40),
('Les bases de l\'algorithmique', 50),
('Sites Web statiques', 40),
('Gestion de Données', 45),
('Culture entrepreneuriale', 30),
('Compétences comportementales et sociales', 20),
('Projet Intégrateur d\'Entreprise - 1', 20),
('Évaluation Fin de Module', 10),
('Formation Cloud AWS/Azure', 30),
('Développement Mobile Android', 50),
('Développement Mobile iOS', 50),
('Base de données avancées', 45),
('Sécurité des applications web', 35);

-- ----------------------------------------------------------------------------
-- 6. AFFECTATIONS EXEMPLES
-- ----------------------------------------------------------------------------
INSERT INTO affectations (enseignant_id, module_id, groupe_id, salle_id) VALUES 
-- Affectations groupe CMOSA101
(1, 1, 1, 1),  -- EL HAKIKI - Projet Web - CMOSA101 - SP1
(2, 11, 1, 2), -- DAOUDI - Gestion Données - CMOSA101 - SP3
(14, 9, 1, 4), -- EL ALAMI - Algorithmique - CMOSA101 - SP5

-- Affectations groupe CMOSA102
(3, 2, 2, 3),  -- JALAL - Approche agile - CMOSA102 - SP4
(20, 3, 2, 5), -- EL-OMARI - Français - CMOSA102 - SP6

-- Affectations groupe DEV101
(17, 5, 54, 15), -- EL MADANI - Dev Front-end - DEV101 - LABO1
(16, 10, 54, 6),  -- ZERRARI - Sites Web - DEV101 - SP7

-- Affectations en Amphi (plusieurs groupes possibles)
(6, 8, 1, 17),  -- JANAH - Culture Numérique - CMOSA101 - AMPHI
(6, 8, 2, 17),  -- JANAH - Culture Numérique - CMOSA102 - AMPHI
(6, 8, 3, 17);  -- JANAH - Culture Numérique - CMOSA103 - AMPHI

-- ----------------------------------------------------------------------------
-- 7. SÉANCES EXEMPLES
-- ----------------------------------------------------------------------------
INSERT INTO seances (affectation_id, jour, heure_debut, heure_fin, validated) VALUES 
-- Séances pour CMOSA101 - Projet Web
(1, 'Lundi', '08:30:00', '10:15:00', 0),
(1, 'Mercredi', '10:30:00', '13:15:00', 0),

-- Séances pour CMOSA101 - Gestion Données
(2, 'Mardi', '08:30:00', '10:15:00', 0),
(2, 'Jeudi', '13:30:00', '16:15:00', 1),

-- Séances pour CMOSA101 - Algorithmique
(3, 'Lundi', '10:30:00', '13:15:00', 0),
(3, 'Vendredi', '08:30:00', '10:15:00', 0),

-- Séances pour CMOSA102 - Approche agile
(4, 'Mardi', '10:30:00', '13:15:00', 0),
(4, 'Jeudi', '08:30:00', '10:15:00', 0),

-- Séances pour CMOSA102 - Français
(5, 'Mercredi', '08:30:00', '10:15:00', 0),

-- Séances pour DEV101 - Dev Front-end
(6, 'Lundi', '13:30:00', '16:15:00', 0),
(6, 'Mercredi', '13:30:00', '16:15:00', 0),

-- Séances pour DEV101 - Sites Web
(7, 'Mardi', '13:30:00', '16:15:00', 0),
(7, 'Jeudi', '10:30:00', '13:15:00', 0),

-- Séances en Amphi (Culture Numérique) - plusieurs groupes
(8, 'Vendredi', '10:30:00', '13:15:00', 0),
(9, 'Vendredi', '10:30:00', '13:15:00', 0),
(10, 'Vendredi', '10:30:00', '13:15:00', 0);

-- ============================================================================
-- VÉRIFICATIONS ET STATISTIQUES
-- ============================================================================

-- Compter les enregistrements
SELECT 'STATISTIQUES DE LA BASE DE DONNÉES' as '';
SELECT 
    (SELECT COUNT(*) FROM utilisateurs) as 'Utilisateurs',
    (SELECT COUNT(*) FROM enseignant) as 'Enseignants',
    (SELECT COUNT(*) FROM groupes) as 'Groupes',
    (SELECT COUNT(*) FROM salles) as 'Salles',
    (SELECT COUNT(*) FROM modules) as 'Modules',
    (SELECT COUNT(*) FROM affectations) as 'Affectations',
    (SELECT COUNT(*) FROM seances) as 'Séances';

-- Afficher les utilisateurs
SELECT '' as '';
SELECT '👤 UTILISATEURS CRÉÉS' as '';
SELECT id, name, email, role FROM utilisateurs;

-- Afficher un aperçu des enseignants
SELECT '' as '';
SELECT '👨‍🏫 APERÇU DES ENSEIGNANTS' as '';
SELECT id, CONCAT(nom, ' ', prenom) as nom_complet, specialite, email 
FROM enseignant 
LIMIT 10;

-- Afficher un aperçu des groupes
SELECT '' as '';
SELECT '👥 APERÇU DES GROUPES' as '';
SELECT id, nom, niveau, effectif 
FROM groupes 
LIMIT 10;

-- Afficher les salles
SELECT '' as '';
SELECT '🏫 SALLES DISPONIBLES' as '';
SELECT id, nom, capacite, type FROM salles;

-- Afficher un aperçu des modules
SELECT '' as '';
SELECT '📚 APERÇU DES MODULES' as '';
SELECT id, nom, volume_horaire 
FROM modules 
LIMIT 10;

-- Afficher les affectations
SELECT '' as '';
SELECT '🔗 AFFECTATIONS CRÉÉES' as '';
SELECT 
    a.id,
    CONCAT(e.nom, ' ', e.prenom) as enseignant,
    m.nom as module,
    g.nom as groupe,
    s.nom as salle
FROM affectations a
JOIN enseignant e ON a.enseignant_id = e.id
JOIN modules m ON a.module_id = m.id
JOIN groupes g ON a.groupe_id = g.id
JOIN salles s ON a.salle_id = s.id;

-- Afficher les séances
SELECT '' as '';
SELECT '📅 SÉANCES PROGRAMMÉES' as '';
SELECT 
    s.id,
    s.jour,
    s.heure_debut,
    s.heure_fin,
    CONCAT(e.nom, ' ', e.prenom) as enseignant,
    m.nom as module,
    g.nom as groupe,
    sal.nom as salle,
    IF(s.validated = 1, '✓ Validée', '⏳ En attente') as statut
FROM seances s
JOIN affectations a ON s.affectation_id = a.id
JOIN enseignant e ON a.enseignant_id = e.id
JOIN modules m ON a.module_id = m.id
JOIN groupes g ON a.groupe_id = g.id
JOIN salles sal ON a.salle_id = sal.id
ORDER BY 
    FIELD(s.jour, 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'),
    s.heure_debut;

-- Message de fin
SELECT '' as '';
SELECT '✅ BASE DE DONNÉES CRÉÉE ET PEUPLÉE AVEC SUCCÈS !' as '';
SELECT '🔐 Mot de passe par défaut pour tous les utilisateurs : password' as '';
SELECT '📧 Emails de connexion : admin@emploitemps.ma | gestionnaire@emploitemps.ma' as '';