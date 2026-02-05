# Architecture Refactorisée - Code Structuré et Logique

## 📁 Nouvelle Structure

```
gestion_emplois_temps/
├── classes/                          # ✨ NOUVEAU - Classes réutilisables
│   ├── User.php                      # Classe de base User + AdminUser + StudentUser
│   ├── AuthService.php               # Authentification centralisée
│   ├── UserService.php               # Gestion des utilisateurs
│   └── ValidationService.php         # Validation + Helpers
├── config/
│   └── database.php                  # Connexion PDO + configs
├── auth/
│   ├── login_unified.php             # ✨ NOUVEAU - Login unifié (admin + student)
│   ├── logout_unified.php            # ✨ NOUVEAU - Logout admin
│   ├── logout_student_unified.php    # ✨ NOUVEAU - Logout student
│   ├── login.php                     # ⚠️ LEGACY (garder pour compatibilité)
│   └── login_stagiaire.php           # ⚠️ LEGACY (garder pour compatibilité)
├── includes/
│   ├── header_unified.php            # ✨ NOUVEAU - Header unifié
│   ├── footer_unified.php            # ✨ NOUVEAU - Footer unifié
│   ├── header.php                    # ⚠️ LEGACY (garder pour compatibilité)
│   └── header_stagiaire.php          # ⚠️ LEGACY (garder pour compatibilité)
├── pages/
│   ├── profile_unified.php           # ✨ NOUVEAU - Profil unifié (admin + student)
│   ├── profile.php                   # ⚠️ LEGACY (garder pour compatibilité)
│   └── profile_stagiaire.php         # ⚠️ LEGACY (garder pour compatibilité)
└── [autres pages...]
```

## 🎯 Principes Clés

### 1. **Authentification Centralisée** (AuthService)
```php
// Avant (redondance):
if (!isset($_SESSION['user_id'])) { redirect(); }
if (!isset($_SESSION['stagiaire_id'])) { redirect(); }

// Après (unifié):
$authService = new AuthService($pdo);
if (!$authService->isSessionValid('admin')) { redirect(); }
if (!$authService->isSessionValid('student')) { redirect(); }
```

### 2. **Utilisateurs Typés** (User Classes)
```php
// Avant:
$nom = $_SESSION['user_nom'];
$groupe = $_SESSION['groupe_id'];

// Après:
$user = $authService->getAdminUser();
$user->getNom();
$user->getFullName();
```

### 3. **Validation et Sécurité** (ValidationService)
```php
// Avant:
$email = $_POST['email'];
if (empty($email)) { $error = ...; }
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) { ... }

// Après:
$email = HelperService::getPost('email');
if (!ValidationService::validateEmail($email)) { ... }
```

### 4. **Header/Footer Unifié**
```php
// Avant:
if (admin) require 'header.php';
else require 'header_stagiaire.php';

// Après:
require 'header_unified.php';  // Gère automatiquement le contexte
```

### 5. **Pages Unifiées**
```php
// Pages maintenant partagées:
- pages/profile_unified.php (remplace profile.php + profile_stagiaire.php)
- auth/login_unified.php (remplace login.php + login_stagiaire.php)
```

## 📚 Classes et Services

### `User.php`
Hiérarchie de classes:
- **User** (classe de base)
  - `getId()`, `getNom()`, `getPrenom()`, `getEmail()`, `getFullName()`, `getType()`
- **AdminUser** extends User
  - `getSpecialite()`, `getDateInscription()`
- **StudentUser** extends User
  - `getGroupeId()`, `getGroupeNom()`, `getNiveau()`, `getDateInscription()`

### `AuthService.php`
Services d'authentification et gestion de session:
- `authenticateAdmin($email, $password)` → AdminUser | null
- `authenticateStudent($email, $password)` → StudentUser | null
- `createAdminSession(AdminUser)` → void
- `createStudentSession(StudentUser)` → void
- `isSessionValid($type = 'admin')` → bool
- `getAdminUser()` → AdminUser | null
- `getStudentUser()` → StudentUser | null
- `changeAdminPassword($id, $password)` → bool
- `changeStudentPassword($id, $password)` → bool
- `destroySession()` → void

### `UserService.php`
CRUD et requêtes pour utilisateurs:
- `getAdminById($id)` → AdminUser | null
- `getStudentById($id)` → StudentUser | null
- `updateAdmin($id, $nom, $prenom, $email, $specialite)` → bool
- `updateStudent($id, $nom, $prenom, $email)` → bool
- `adminEmailExists($email, $excludeId)` → bool
- `studentEmailExists($email, $excludeId)` → bool
- `getAllAdmins()` → array
- `getAllStudents()` → array

### `ValidationService.php` & `HelperService.php`
Validation et fonctions utilitaires:
- `ValidationService::validateEmail($email)` → bool
- `ValidationService::validatePassword($password)` → bool
- `ValidationService::sanitize($data)` → string
- `ValidationService::isRequired($value)` → bool
- `HelperService::redirect($url)` → void
- `HelperService::generateCSRFToken()` → string
- `HelperService::getPost($key, $default)` → string
- `HelperService::formatDate($date)` → string
- `HelperService::jsonResponse($success, $message, $data)` → void

## 🔄 Flux d'Authentification

### Admin/Formateur
```
1. login_unified.php?type=admin
   ↓
2. AuthService::authenticateAdmin()
   ↓
3. AuthService::createAdminSession()
   ↓
4. redirect('pages/dashboard.php')
   ↓
5. header_unified.php détecte isAdmin = true
   ↓
6. Navigation admin s'affiche
```

### Stagiaire
```
1. login_unified.php?type=student
   ↓
2. AuthService::authenticateStudent()
   ↓
3. AuthService::createStudentSession()
   ↓
4. redirect('pages/dashboard_stagiaire.php')
   ↓
5. header_unified.php détecte isStudent = true
   ↓
6. Navigation stagiaire s'affiche
```

## 🔐 Sécurité

### Améliorations Apportées
- ✅ **Empreinte navigateur** (user-agent + IP) pour éviter le vol de session
- ✅ **Timeout de session** (1 heure configurable)
- ✅ **Validation stricte** de tous les inputs
- ✅ **Sanitisation XSS** automatique avec `htmlspecialchars()`
- ✅ **PDO prepared statements** pour prévenir SQL injection
- ✅ **Bcrypt password hashing** (PASSWORD_BCRYPT)
- ✅ **Gestion d'erreurs centralisée** (error_log)

## 🚀 Migration des Pages Existantes

Pour utiliser la nouvelle structure:

### Avant:
```php
<?php
require_once '../includes/header.php';
if (!isLoggedIn()) redirect();
?>
```

### Après:
```php
<?php
$page_title = "Ma Page";
require_once '../includes/header_unified.php';

$isAdmin = isset($_SESSION['user_id']) && $authService->isSessionValid('admin');
$isStudent = isset($_SESSION['stagiaire_id']) && $authService->isSessionValid('student');

if (!$isAdmin && !$isStudent) redirect();
?>
```

## ✨ Avantages de la Nouvelle Structure

| Aspect | Avant | Après |
|--------|-------|-------|
| **Redondance** | Code dupliqué (login.php + login_stagiaire.php) | Code partagé (login_unified.php) |
| **Maintenabilité** | Modifications partout | Modifications centralisées (services) |
| **Type-Safety** | Variables SESSION directes | Objets User typés |
| **Logique** | Éparpillée dans les pages | Centralisée dans les services |
| **Tests** | Difficile à tester | Services testables |
| **Sécurité** | Répétée | Centralisée |
| **Documentation** | Implicite | Explicite (docblocks) |

## 📝 Exemple: Créer une Nouvelle Page Admin

```php
<?php
$page_title = "Mes Données";
require_once '../includes/header_unified.php';

// Vérifier l'accès admin
if (!$isAdmin) {
    HelperService::redirect('../auth/login_unified.php?type=admin');
}

// Récupérer l'utilisateur
$user = $authService->getAdminUser();
echo "Bienvenue " . $user->getFullName();

// Valider une saisie
$email = HelperService::getPost('email');
if (!ValidationService::validateEmail($email)) {
    echo "Email invalide";
}

// Mettre à jour l'utilisateur
$userService->updateAdmin($user->getId(), $nom, $prenom, $email);
?>

... contenu HTML ...

<?php require_once '../includes/footer_unified.php'; ?>
```

## 🎯 Prochaines Étapes

1. **Migration progressive** - Convertir les pages une par une
2. **Tests** - Vérifier chaque flux d'authentification
3. **Suppression legacy** - Retirer les anciennes classes après migration
4. **Documentation** - Maintenir cette doc à jour

## 📖 Fichiers de Référence

- `classes/User.php` - Modèles de données
- `classes/AuthService.php` - Logique d'authentification
- `classes/UserService.php` - CRUD utilisateurs
- `classes/ValidationService.php` - Validation et helpers
- `includes/header_unified.php` - Navigation unifiée
- `pages/profile_unified.php` - Exemple d'intégration
- `auth/login_unified.php` - Authentification unifiée
