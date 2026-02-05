-- ============================================================================
-- MIGRATION : Suppression du concept d'affectation
-- ============================================================================
-- Ce script supprime la table affectations et modifie la table seances
-- pour gérer directement les séances avec tous les champs nécessaires

USE gestion_emplois_temps;

-- 1. Vérifier et ajouter les colonnes directes dans seances si elles n'existent pas
ALTER TABLE seances 
    ADD COLUMN IF NOT EXISTS enseignant_id INT NULL AFTER affectation_id,
    ADD COLUMN IF NOT EXISTS module_id INT NULL AFTER enseignant_id,
    ADD COLUMN IF NOT EXISTS groupe_id INT NULL AFTER module_id,
    ADD COLUMN IF NOT EXISTS salle_id INT NULL AFTER groupe_id;

-- 2. Migrer les données depuis affectations vers seances
UPDATE seances s
INNER JOIN affectations a ON s.affectation_id = a.id
SET 
    s.enseignant_id = a.enseignant_id,
    s.module_id = a.module_id,
    s.groupe_id = a.groupe_id,
    s.salle_id = a.salle_id
WHERE s.enseignant_id IS NULL;

-- 3. Rendre les colonnes NOT NULL après migration
ALTER TABLE seances 
    MODIFY COLUMN enseignant_id INT NOT NULL,
    MODIFY COLUMN module_id INT NOT NULL,
    MODIFY COLUMN groupe_id INT NOT NULL,
    MODIFY COLUMN salle_id INT NOT NULL;

-- 4. Ajouter les clés étrangères
ALTER TABLE seances
    ADD CONSTRAINT fk_seances_enseignant FOREIGN KEY (enseignant_id) REFERENCES enseignant(id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_seances_module FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_seances_groupe FOREIGN KEY (groupe_id) REFERENCES groupes(id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_seances_salle FOREIGN KEY (salle_id) REFERENCES salles(id) ON DELETE CASCADE;

-- 5. Ajouter les index pour améliorer les performances
ALTER TABLE seances
    ADD INDEX idx_enseignant (enseignant_id),
    ADD INDEX idx_module (module_id),
    ADD INDEX idx_groupe (groupe_id),
    ADD INDEX idx_salle (salle_id);

-- 6. Supprimer la clé étrangère et la colonne affectation_id
ALTER TABLE seances
    DROP FOREIGN KEY seances_ibfk_1,
    DROP COLUMN affectation_id;

-- 7. Supprimer la table affectations
DROP TABLE IF EXISTS affectations;

-- 8. Recréer la vue emploi_temps sans affectations
DROP VIEW IF EXISTS vue_emploi_temps;

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
JOIN enseignant e ON s.enseignant_id = e.id
JOIN modules m ON s.module_id = m.id
JOIN groupes g ON s.groupe_id = g.id
JOIN salles sal ON s.salle_id = sal.id
ORDER BY 
    FIELD(s.jour, 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'),
    s.heure_debut;

-- Message de confirmation
SELECT '✅ Migration terminée avec succès !' as '';
SELECT 'La table affectations a été supprimée et les séances gèrent maintenant directement tous les champs.' as '';
