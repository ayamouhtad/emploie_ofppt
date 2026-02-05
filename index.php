<?php
session_start();

// Si l'utilisateur est déjà connecté, rediriger vers le dashboard
if (isset($_SESSION['user_id'])) {
    header("Location: pages/dashboard.php");
    exit();
}
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Accueil - Gestion Emplois du Temps</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow-x: hidden;
        }
        
        .container {
            text-align: center;
            color: white;
            padding: 40px;
            max-width: 800px;
        }
        
        .logo {
            font-size: 80px;
            margin-bottom: 20px;
            animation: bounce 2s infinite;
        }
        
        @keyframes bounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-20px); }
        }
        
        h1 {
            font-size: 48px;
            margin-bottom: 20px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        
        .subtitle {
            font-size: 20px;
            margin-bottom: 40px;
            opacity: 0.9;
        }
        
        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 40px 0;
        }
        
        .feature-card {
            background: rgba(255, 255, 255, 0.2);
            backdrop-filter: blur(10px);
            padding: 30px 20px;
            border-radius: 15px;
            transition: transform 0.3s, background 0.3s;
        }
        
        .feature-card:hover {
            transform: translateY(-10px);
            background: rgba(255, 255, 255, 0.3);
        }
        
        .feature-icon {
            font-size: 40px;
            margin-bottom: 10px;
        }
        
        .feature-title {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 10px;
        }
        
        .feature-desc {
            font-size: 14px;
            opacity: 0.9;
        }
        
        .cta-buttons {
            display: flex;
            gap: 20px;
            justify-content: center;
            flex-wrap: wrap;
            margin-top: 40px;
        }
        
        .btn {
            padding: 15px 40px;
            border: none;
            border-radius: 50px;
            font-size: 18px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }
        
        .btn-primary {
            background: white;
            color: #667eea;
        }
        
        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(0,0,0,0.3);
        }
        
        .btn-secondary {
            background: rgba(255, 255, 255, 0.2);
            color: white;
            border: 2px solid white;
        }
        
        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-3px);
        }
        
        .info-section {
            margin-top: 60px;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            padding: 30px;
            border-radius: 15px;
        }
        
        .info-section h3 {
            font-size: 24px;
            margin-bottom: 15px;
        }
        
        .info-section p {
            font-size: 16px;
            line-height: 1.6;
            opacity: 0.9;
        }
        
        @media (max-width: 768px) {
            h1 { font-size: 36px; }
            .subtitle { font-size: 16px; }
            .logo { font-size: 60px; }
            .features { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo"></div>
        <h1>Système de Gestion d'Emplois du Temps</h1>
        <p class="subtitle">
            Planifiez et organisez vos emplois du temps de manière simple et efficace
        </p>
        
        <div class="features">
            <div class="feature-card">
                <div class="feature-icon"></div>
                <div class="feature-title">Gestion Enseignants</div>
                <div class="feature-desc">Gérez facilement vos enseignants et leurs spécialités</div>
            </div>
            
            <div class="feature-card">
                <div class="feature-icon"></div>
                <div class="feature-title">Groupes & Classes</div>
                <div class="feature-desc">Organisez vos groupes d'étudiants par niveau</div>
            </div>
            
            <div class="feature-card">
                <div class="feature-icon"></div>
                <div class="feature-title">Salles & Espaces</div>
                <div class="feature-desc">Gérez vos salles de cours, TP et amphithéâtres</div>
            </div>
            
            <div class="feature-card">
                <div class="feature-icon"></div>
                <div class="feature-title">Modules</div>
                <div class="feature-desc">Définissez vos modules et leurs volumes horaires</div>
            </div>
            
            <div class="feature-card">
                <div class="feature-icon"></div>
                <div class="feature-title">Séances Directes</div>
                <div class="feature-desc">Créez et gérez vos séances directement dans l'emploi du temps</div>
            </div>
            
            <div class="feature-card">
                <div class="feature-icon"></div>
                <div class="feature-title">Planning Automatique</div>
                <div class="feature-desc">Générez et visualisez vos emplois du temps</div>
            </div>
        </div>
        
        <div class="cta-buttons">
            <a href="pages/dashboard.php" class="btn btn-primary">
                 Admin / Formateurs
            </a>
            <a href="auth/login_stagiaire.php" class="btn btn-secondary">
                 Connexion Stagiaires
            </a>
            <a href="#info" class="btn btn-secondary">
                 En savoir plus
            </a>
        </div>
        
        <div class="info-section" id="info">
            <h3> Pourquoi notre système ?</h3>
            <p>
                Notre système de gestion d'emplois du temps vous permet de créer, gérer et visualiser 
                des emplois du temps complexes en quelques clics. Interface intuitive, gestion complète 
                des ressources (enseignants, salles, groupes), et génération automatique d'emplois du temps 
                clairs et imprimables. Parfait pour les établissements scolaires, universités et centres de formation.
            </p>
        </div>
        
        <div style="margin-top: 40px; font-size: 14px; opacity: 0.8;">
            <p>&copy; <?= date('Y') ?> Système de Gestion d'Emplois du Temps | Développé avec PHP & PDO</p>
        </div>
    </div>
</body>
</html>