<?php
/**
 * Script d'insertion de données de test pour stagiaires
 * Utiliser ce script pour ajouter des stagiaires de test avec les mots de passe hashés
 */

require_once 'config/database.php';

// Exemple de stagiaires à insérer
$stagiaires_data = [
    [
        'nom' => 'Dupont',
        'prenom' => 'Jean',
        'email' => 'jean.dupont@example.com',
        'password' => 'password123',
        'groupe_id' => 1
    ],
    [
        'nom' => 'Martin',
        'prenom' => 'Marie',
        'email' => 'marie.martin@example.com',
        'password' => 'password123',
        'groupe_id' => 1
    ],
    [
        'nom' => 'Bernard',
        'prenom' => 'Pierre',
        'email' => 'pierre.bernard@example.com',
        'password' => 'password123',
        'groupe_id' => 2
    ],
    [
        'nom' => 'Thomas',
        'prenom' => 'Sophie',
        'email' => 'sophie.thomas@example.com',
        'password' => 'password123',
        'groupe_id' => 2
    ]
];

// Vérifier si la table stagiaires existe
try {
    $stmt = $pdo->query("SELECT 1 FROM stagiaires LIMIT 1");
} catch (PDOException $e) {
    // Créer la table si elle n'existe pas
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS stagiaires (
            id INT PRIMARY KEY AUTO_INCREMENT,
            nom VARCHAR(100) NOT NULL,
            prenom VARCHAR(100) NOT NULL,
            email VARCHAR(120) UNIQUE NOT NULL,
            password_hash VARCHAR(255) NOT NULL,
            groupe_id INT NOT NULL,
            date_inscription TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            actif BOOLEAN DEFAULT 1,
            FOREIGN KEY (groupe_id) REFERENCES groupes(id) ON DELETE CASCADE,
            INDEX (email),
            INDEX (groupe_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ");
    echo "Table stagiaires créée.<br>";
}

// Insérer les stagiaires
foreach ($stagiaires_data as $data) {
    try {
        $stmt = $pdo->prepare("
            INSERT INTO stagiaires (nom, prenom, email, password_hash, groupe_id)
            VALUES (?, ?, ?, ?, ?)
        ");
        
        $password_hash = password_hash($data['password'], PASSWORD_BCRYPT);
        
        $stmt->execute([
            $data['nom'],
            $data['prenom'],
            $data['email'],
            $password_hash,
            $data['groupe_id']
        ]);
        
        echo "Stagiaire inséré : {$data['prenom']} {$data['nom']} ({$data['email']}) - Mot de passe: {$data['password']}<br>";
    } catch (PDOException $e) {
        echo "Erreur lors de l'insertion de {$data['prenom']} {$data['nom']}: " . $e->getMessage() . "<br>";
    }
}

echo "<br><strong>Données de test insérées avec succès!</strong><br>";
echo "Vous pouvez maintenant vous connecter avec:<br>";
echo "Email: jean.dupont@example.com<br>";
echo "Mot de passe: password123<br>";
?>
