<?php
/**
 * Script de migration : Suppression du concept d'affectation
 * Exécutez ce fichier via votre navigateur : http://localhost/gestion_emplois_temps/migrate_remove_affectations.php
 */

require_once 'config/database.php';

if (!isLoggedIn()) {
    die('Vous devez être connecté pour exécuter cette migration.');
}

// Vérifier si l'utilisateur est admin
if (!isAdmin()) {
    die('Seuls les administrateurs peuvent exécuter cette migration.');
}

header('Content-Type: text/html; charset=utf-8');
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Migration - Suppression des Affectations</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #00a693;
        }
        .step {
            margin: 20px 0;
            padding: 15px;
            background: #f8f9fa;
            border-left: 4px solid #00a693;
            border-radius: 5px;
        }
        .success {
            color: #28a745;
            font-weight: bold;
        }
        .error {
            color: #dc3545;
            font-weight: bold;
        }
        .warning {
            color: #ffc107;
            font-weight: bold;
        }
        button {
            background: #00a693;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 20px;
        }
        button:hover {
            background: #0891b2;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔄 Migration : Suppression du concept d'affectation</h1>
        
        <?php
        $errors = [];
        $warnings = [];
        $success = [];
        
        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['execute_migration'])) {
            try {
                // Note: Les opérations DDL (ALTER TABLE, DROP TABLE, etc.) committent automatiquement
                // les transactions dans MySQL, donc on n'utilise pas de transaction ici
                
                // Étape 1: Vérifier si les colonnes existent déjà
                $stmt = $pdo->query("SHOW COLUMNS FROM seances");
                $columns = $stmt->fetchAll(PDO::FETCH_COLUMN);
                
                $has_enseignant = in_array('enseignant_id', $columns);
                $has_module = in_array('module_id', $columns);
                $has_groupe = in_array('groupe_id', $columns);
                $has_salle = in_array('salle_id', $columns);
                $has_affectation = in_array('affectation_id', $columns);
                
                // Étape 2: Ajouter les colonnes si elles n'existent pas
                if (!$has_enseignant) {
                    try {
                        if ($has_affectation) {
                            $pdo->exec("ALTER TABLE seances ADD COLUMN enseignant_id INT NULL AFTER affectation_id");
                        } else {
                            $pdo->exec("ALTER TABLE seances ADD COLUMN enseignant_id INT NULL");
                        }
                        $success[] = "Colonne enseignant_id ajoutée";
                    } catch (PDOException $e) {
                        $errors[] = "Erreur lors de l'ajout de enseignant_id: " . $e->getMessage();
                    }
                } else {
                    $warnings[] = "Colonne enseignant_id existe déjà";
                }
                
                if (!$has_module) {
                    try {
                        $pdo->exec("ALTER TABLE seances ADD COLUMN module_id INT NULL AFTER enseignant_id");
                        $success[] = "Colonne module_id ajoutée";
                    } catch (PDOException $e) {
                        $errors[] = "Erreur lors de l'ajout de module_id: " . $e->getMessage();
                    }
                } else {
                    $warnings[] = "Colonne module_id existe déjà";
                }
                
                if (!$has_groupe) {
                    try {
                        $pdo->exec("ALTER TABLE seances ADD COLUMN groupe_id INT NULL AFTER module_id");
                        $success[] = "Colonne groupe_id ajoutée";
                    } catch (PDOException $e) {
                        $errors[] = "Erreur lors de l'ajout de groupe_id: " . $e->getMessage();
                    }
                } else {
                    $warnings[] = "Colonne groupe_id existe déjà";
                }
                
                if (!$has_salle) {
                    try {
                        $pdo->exec("ALTER TABLE seances ADD COLUMN salle_id INT NULL AFTER groupe_id");
                        $success[] = "Colonne salle_id ajoutée";
                    } catch (PDOException $e) {
                        $errors[] = "Erreur lors de l'ajout de salle_id: " . $e->getMessage();
                    }
                } else {
                    $warnings[] = "Colonne salle_id existe déjà";
                }
                
                // Étape 3: Migrer les données depuis affectations si la table existe
                if ($has_affectation) {
                    $tableExists = $pdo->query("SHOW TABLES LIKE 'affectations'")->rowCount() > 0;
                    
                    if ($tableExists) {
                        // Migrer les données
                        $pdo->exec("
                            UPDATE seances s
                            INNER JOIN affectations a ON s.affectation_id = a.id
                            SET 
                                s.enseignant_id = COALESCE(s.enseignant_id, a.enseignant_id),
                                s.module_id = COALESCE(s.module_id, a.module_id),
                                s.groupe_id = COALESCE(s.groupe_id, a.groupe_id),
                                s.salle_id = COALESCE(s.salle_id, a.salle_id)
                            WHERE s.enseignant_id IS NULL OR s.module_id IS NULL OR s.groupe_id IS NULL OR s.salle_id IS NULL
                        ");
                        $success[] = "Données migrées depuis la table affectations";
                    }
                }
                
                // Étape 4: Rendre les colonnes NOT NULL (seulement si elles sont toutes remplies)
                $nullCount = $pdo->query("SELECT COUNT(*) FROM seances WHERE enseignant_id IS NULL OR module_id IS NULL OR groupe_id IS NULL OR salle_id IS NULL")->fetchColumn();
                
                if ($nullCount == 0) {
                    $pdo->exec("ALTER TABLE seances MODIFY COLUMN enseignant_id INT NOT NULL");
                    $pdo->exec("ALTER TABLE seances MODIFY COLUMN module_id INT NOT NULL");
                    $pdo->exec("ALTER TABLE seances MODIFY COLUMN groupe_id INT NOT NULL");
                    $pdo->exec("ALTER TABLE seances MODIFY COLUMN salle_id INT NOT NULL");
                    $success[] = "Colonnes rendues NOT NULL";
                } else {
                    $warnings[] = "$nullCount séances ont des valeurs NULL. Les colonnes restent NULLables.";
                }
                
                // Étape 5: Ajouter les clés étrangères (si elles n'existent pas)
                try {
                    $pdo->exec("ALTER TABLE seances ADD CONSTRAINT fk_seances_enseignant FOREIGN KEY (enseignant_id) REFERENCES enseignant(id) ON DELETE CASCADE");
                    $success[] = "Clé étrangère enseignant ajoutée";
                } catch (PDOException $e) {
                    if (strpos($e->getMessage(), 'Duplicate key name') === false) {
                        $warnings[] = "Clé étrangère enseignant: " . $e->getMessage();
                    }
                }
                
                try {
                    $pdo->exec("ALTER TABLE seances ADD CONSTRAINT fk_seances_module FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE");
                    $success[] = "Clé étrangère module ajoutée";
                } catch (PDOException $e) {
                    if (strpos($e->getMessage(), 'Duplicate key name') === false) {
                        $warnings[] = "Clé étrangère module: " . $e->getMessage();
                    }
                }
                
                try {
                    $pdo->exec("ALTER TABLE seances ADD CONSTRAINT fk_seances_groupe FOREIGN KEY (groupe_id) REFERENCES groupes(id) ON DELETE CASCADE");
                    $success[] = "Clé étrangère groupe ajoutée";
                } catch (PDOException $e) {
                    if (strpos($e->getMessage(), 'Duplicate key name') === false) {
                        $warnings[] = "Clé étrangère groupe: " . $e->getMessage();
                    }
                }
                
                try {
                    $pdo->exec("ALTER TABLE seances ADD CONSTRAINT fk_seances_salle FOREIGN KEY (salle_id) REFERENCES salles(id) ON DELETE CASCADE");
                    $success[] = "Clé étrangère salle ajoutée";
                } catch (PDOException $e) {
                    if (strpos($e->getMessage(), 'Duplicate key name') === false) {
                        $warnings[] = "Clé étrangère salle: " . $e->getMessage();
                    }
                }
                
                // Étape 6: Ajouter les index
                try {
                    $pdo->exec("ALTER TABLE seances ADD INDEX idx_enseignant (enseignant_id)");
                    $success[] = "Index enseignant ajouté";
                } catch (PDOException $e) {
                    // Index existe peut-être déjà
                }
                
                try {
                    $pdo->exec("ALTER TABLE seances ADD INDEX idx_module (module_id)");
                    $success[] = "Index module ajouté";
                } catch (PDOException $e) {
                    // Index existe peut-être déjà
                }
                
                try {
                    $pdo->exec("ALTER TABLE seances ADD INDEX idx_groupe (groupe_id)");
                    $success[] = "Index groupe ajouté";
                } catch (PDOException $e) {
                    // Index existe peut-être déjà
                }
                
                try {
                    $pdo->exec("ALTER TABLE seances ADD INDEX idx_salle (salle_id)");
                    $success[] = "Index salle ajouté";
                } catch (PDOException $e) {
                    // Index existe peut-être déjà
                }
                
                // Étape 7: Supprimer la colonne affectation_id et la clé étrangère
                if ($has_affectation) {
                    try {
                        // Supprimer la clé étrangère d'abord
                        $fkResult = $pdo->query("
                            SELECT CONSTRAINT_NAME 
                            FROM information_schema.KEY_COLUMN_USAGE 
                            WHERE TABLE_SCHEMA = DATABASE() 
                            AND TABLE_NAME = 'seances' 
                            AND COLUMN_NAME = 'affectation_id'
                            AND REFERENCED_TABLE_NAME IS NOT NULL
                        ")->fetch();
                        
                        if ($fkResult) {
                            $fkName = $fkResult['CONSTRAINT_NAME'];
                            $pdo->exec("ALTER TABLE seances DROP FOREIGN KEY $fkName");
                            $success[] = "Clé étrangère affectation_id supprimée";
                        }
                    } catch (PDOException $e) {
                        $warnings[] = "Erreur lors de la suppression de la clé étrangère: " . $e->getMessage();
                    }
                    
                    try {
                        $pdo->exec("ALTER TABLE seances DROP COLUMN affectation_id");
                        $success[] = "Colonne affectation_id supprimée";
                    } catch (PDOException $e) {
                        $errors[] = "Erreur lors de la suppression de la colonne affectation_id: " . $e->getMessage();
                    }
                }
                
                // Étape 8: Supprimer la table affectations
                $tableExists = $pdo->query("SHOW TABLES LIKE 'affectations'")->rowCount() > 0;
                if ($tableExists) {
                    $pdo->exec("DROP TABLE IF EXISTS affectations");
                    $success[] = "Table affectations supprimée";
                }
                
                // Étape 9: Recréer la vue
                $pdo->exec("DROP VIEW IF EXISTS vue_emploi_temps");
                $pdo->exec("
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
                        s.heure_debut
                ");
                $success[] = "Vue vue_emploi_temps recréée";
                
                echo '<div class="step success">';
                echo '<h2>✅ Migration terminée avec succès !</h2>';
                echo '</div>';
                
            } catch (Exception $e) {
                $errors[] = "Erreur lors de la migration: " . $e->getMessage();
                $errors[] = "Détails: " . $e->getFile() . " ligne " . $e->getLine();
                $errors[] = "Trace: " . $e->getTraceAsString();
            } catch (PDOException $e) {
                $errors[] = "Erreur PDO lors de la migration: " . $e->getMessage();
                $errors[] = "Code: " . $e->getCode();
                $errors[] = "Fichier: " . $e->getFile() . " ligne " . $e->getLine();
            }
        }
        
        // Afficher les résultats
        if (!empty($success)) {
            echo '<div class="step">';
            echo '<h3 class="success">✅ Succès:</h3>';
            echo '<ul>';
            foreach ($success as $msg) {
                echo '<li class="success">' . htmlspecialchars($msg) . '</li>';
            }
            echo '</ul>';
            echo '</div>';
        }
        
        if (!empty($warnings)) {
            echo '<div class="step">';
            echo '<h3 class="warning">⚠️ Avertissements:</h3>';
            echo '<ul>';
            foreach ($warnings as $msg) {
                echo '<li class="warning">' . htmlspecialchars($msg) . '</li>';
            }
            echo '</ul>';
            echo '</div>';
        }
        
        if (!empty($errors)) {
            echo '<div class="step">';
            echo '<h3 class="error">❌ Erreurs:</h3>';
            echo '<ul>';
            foreach ($errors as $msg) {
                echo '<li class="error">' . htmlspecialchars($msg) . '</li>';
            }
            echo '</ul>';
            echo '</div>';
        }
        
        if ($_SERVER['REQUEST_METHOD'] !== 'POST' || !empty($errors)) {
            ?>
            <div class="step">
                <h3>📋 Ce que cette migration va faire :</h3>
                <ol>
                    <li>Ajouter les colonnes <code>enseignant_id</code>, <code>module_id</code>, <code>groupe_id</code>, <code>salle_id</code> à la table <code>seances</code></li>
                    <li>Migrer les données depuis la table <code>affectations</code> vers <code>seances</code></li>
                    <li>Ajouter les clés étrangères et index nécessaires</li>
                    <li>Supprimer la colonne <code>affectation_id</code> de la table <code>seances</code></li>
                    <li>Supprimer la table <code>affectations</code></li>
                    <li>Recréer la vue <code>vue_emploi_temps</code></li>
                </ol>
                
                <p><strong>⚠️ Attention :</strong> Cette migration est irréversible. Assurez-vous d'avoir une sauvegarde de votre base de données avant de continuer.</p>
                
                <form method="POST">
                    <button type="submit" name="execute_migration" onclick="return confirm('Êtes-vous sûr de vouloir exécuter cette migration ? Cette action est irréversible.');">
                        Exécuter la migration
                    </button>
                </form>
            </div>
            <?php
        } else {
            ?>
            <div class="step">
                <p><strong>✅ La migration a été exécutée avec succès !</strong></p>
                <p>Vous pouvez maintenant utiliser le système sans la table d'affectations.</p>
                <a href="pages/emploi_temps.php" style="display: inline-block; margin-top: 20px; padding: 12px 24px; background: #00a693; color: white; text-decoration: none; border-radius: 5px;">
                    Aller à l'emploi du temps
                </a>
            </div>
            <?php
        }
        ?>
    </div>
</body>
</html>
