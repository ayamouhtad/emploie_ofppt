-- Table des stagiaires
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert some test data (optional)
-- INSERT INTO stagiaires (nom, prenom, email, password_hash, groupe_id) VALUES
-- ('Dupont', 'Jean', 'jean.dupont@example.com', '$2y$10$...', 1),
-- ('Martin', 'Marie', 'marie.martin@example.com', '$2y$10$...', 1);
