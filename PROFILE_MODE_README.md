# Mode Profil - Documentation

## Aperçu
Le système de profil permet aux utilisateurs (Admin/Formateurs et Stagiaires) de gérer leurs informations personnelles et modifier leur mot de passe.

## Fonctionnalités

### Pour les Admins/Formateurs
- **Page de Profil:** `/pages/profile.php`
- **Accès:** Via le lien "Mon Profil" dans la navbar
- **Fonctionnalités:**
  - Voir et modifier: Nom, Prénom, Email, Spécialité
  - Changer le mot de passe (optionnel)
  - Afficher: ID, Date d'inscription

### Pour les Stagiaires
- **Page de Profil:** `/pages/profile_stagiaire.php`
- **Accès:** Via le lien "Mon Profil" dans la navbar (header_stagiaire.php)
- **Fonctionnalités:**
  - Voir et modifier: Nom, Prénom, Email
  - Changer le mot de passe (optionnel)
  - Afficher: Groupe, Niveau, Date d'inscription

## Navigation

### Header Admin/Formateurs
Fichier: `includes/header.php`
Liens de navigation:
- Dashboard
- Enseignants
- Groupes
- Salles
- Modules
- Emplois du Temps
- Emplois Formateurs
- **Mon Profil** ⭐ (NOUVEAU)
- Déconnexion

### Header Stagiaire
Fichier: `includes/header_stagiaire.php`
Liens de navigation:
- Accueil
- Mon Emploi
- **Mon Profil** ⭐ (NOUVEAU)
- Déconnexion

## Architecture

### Pages Créées
1. **`pages/profile.php`** - Profil pour admin/formateurs
   - Utilise: `includes/header.php` et `includes/footer.php`
   - Base de données: table `enseignant`
   - Authentification: session standard (`user_id`)

2. **`pages/profile_stagiaire.php`** - Profil pour stagiaires
   - Utilise: `includes/header_stagiaire.php` et `includes/footer_stagiaire.php`
   - Base de données: table `stagiaires` avec JOIN sur `groupes`
   - Authentification: session stagiaire (`stagiaire_id`)

### Headers Créés/Modifiés
1. **`includes/header.php`** (Modifié)
   - Ajout du lien "Mon Profil"
   - Ajout du lien "Déconnexion"

2. **`includes/header_stagiaire.php`** (Nouveau)
   - Version simplifiée pour les stagiaires
   - Responsive design (768px, 480px)
   - 4 liens: Accueil, Mon Emploi, Mon Profil, Déconnexion

### Footer Créé
3. **`includes/footer_stagiaire.php`** (Nouveau)
   - Footer minimal pour les pages stagiaires

## Sécurité

- **Authentification:** Vérification de session avant affichage
  - Admin/Formateurs: `isLoggedIn()` → `user_id`
  - Stagiaires: `$_SESSION['stagiaire_id']`

- **Modification de mot de passe:** Bcrypt password hashing
  - `password_hash()` pour création
  - `password_verify()` pour vérification (dans login)

- **Validation:** 
  - Champs obligatoires (nom, prénom, email)
  - Longueur minimale mot de passe: 6 caractères
  - Confirmation du mot de passe
  - Échappement HTML: `htmlspecialchars()`

## Design Responsive

Tous les profils incluent:
- **Desktop (1024px+):** Layout full-width
- **Tablet (768px):** Padding réduit, police 16px
- **Mobile (480px):** Padding minimal, police 13-14px

## Exemple d'Utilisation

### Admin/Formateur
1. Se connecter via `/auth/login.php`
2. Cliquer sur "Mon Profil" dans la navbar
3. Modifier ses informations
4. (Optionnel) Entrer un nouveau mot de passe
5. Cliquer "Enregistrer les modifications"

### Stagiaire
1. Se connecter via `/auth/login_stagiaire.php`
2. Cliquer sur "Mon Profil" dans la navbar
3. Modifier ses informations
4. (Optionnel) Entrer un nouveau mot de passe
5. Cliquer "Enregistrer les modifications"

## Messages de Feedback

- **Succès:** "Profil mis à jour avec succès!" (vert)
- **Succès avec mot de passe:** "Profil et mot de passe mis à jour avec succès!" (vert)
- **Erreur:** Message d'erreur spécifique (rouge)

## Intégration avec Système Existant

- ✅ Utilise PDO et prepared statements
- ✅ Respecte la structure existante
- ✅ Compatible avec responsive design existant
- ✅ Navbars existantes mises à jour
- ✅ Sessions existantes préservées
- ✅ Authentification existante vérifiée
