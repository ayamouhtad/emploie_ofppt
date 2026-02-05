# Guide de Migration Vers la Nouvelle Structure

## 📋 Vue d'ensemble

Le projet a été refactorisé pour:
- ✅ Éliminer la redondance de code
- ✅ Centraliser la logique d'authentification
- ✅ Utiliser la programmation orientée objet
- ✅ Améliorer la maintenabilité
- ✅ Augmenter la sécurité

## 🚀 Démarrage Rapide

### Pour une Nouvelle Page

```php
<?php
$page_title = "Titre de la Page";
require_once '../includes/init.php';

// Vérifier l'accès
requireAdmin();  // OU requireStudent() OU requireAuth()

// Récupérer l'utilisateur
$user = $authService->getAdminUser();

// Utiliser les services
$user->getFullName();
$userService->updateAdmin(...);
ValidationService::validateEmail(...);
HelperService::redirect(...);
?>
```

## 📦 Composants Créés

### Classes (`classes/`)
1. **User.php** - Modèles d'utilisateurs (User, AdminUser, StudentUser)
2. **AuthService.php** - Authentification et gestion de session
3. **UserService.php** - CRUD et requêtes utilisateurs
4. **ValidationService.php** - Validation, sécurité, helpers

### Includes (`includes/`)
1. **init.php** - Fichier d'initialisation unifié (à inclure au début)
2. **header_unified.php** - Navigation unifiée (admin + student)
3. **footer_unified.php** - Footer unifié
4. **header.php** (legacy) - Garder pour compatibilité
5. **header_stagiaire.php** (legacy) - Garder pour compatibilité

### Pages (`pages/`)
1. **profile_unified.php** - Profil unifié (remplace profile.php + profile_stagiaire.php)
2. **dashboard_refactored_example.php** - Exemple de refactorisation
3. Pages existantes - À refactoriser progressivement

### Auth (`auth/`)
1. **login_unified.php** - Login unifié (admin + student)
2. **logout_unified.php** - Logout admin
3. **logout_student_unified.php** - Logout student

## 🔄 Migration Pas à Pas

### Étape 1: Utiliser init.php

Au lieu de:
```php
<?php
require_once '../config/database.php';
session_start();
// ... require manuels
```

Utiliser:
```php
<?php
$page_title = "Ma Page";
require_once '../includes/init.php';
```

### Étape 2: Remplacer les Headers

Au lieu de:
```php
<?php require_once '../includes/header.php'; ?>
```

Utiliser:
```php
<?php require_once '../includes/header_unified.php'; ?>
```

### Étape 3: Utiliser les Services

Au lieu de:
```php
if (!isset($_SESSION['user_id'])) {
    redirect('../auth/login.php');
}
$email = $_SESSION['user_email'];
```

Utiliser:
```php
if (!$isAdmin) {
    HelperService::redirect('../auth/login_unified.php');
}
$user = $authService->getAdminUser();
$email = $user->getEmail();
```

### Étape 4: Validation Unifiée

Au lieu de:
```php
$email = $_POST['email'];
$email = htmlspecialchars($email);
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo "Email invalide";
}
```

Utiliser:
```php
$email = HelperService::getPost('email');
if (!ValidationService::validateEmail($email)) {
    echo "Email invalide";
}
```

## 💡 Exemples d'Utilisation

### Vérifier l'Accès

```php
// Accès admin uniquement
requireAdmin();

// Accès student uniquement
requireStudent();

// Accès admin OU student
requireAuth();

// Vérification manuelle
if (!$isAdmin && !$isStudent) {
    HelperService::redirect('../auth/login_unified.php');
}
```

### Récupérer l'Utilisateur

```php
// Admin
$user = $authService->getAdminUser();
echo $user->getNom();
echo $user->getSpecialite();

// Student
$user = $authService->getStudentUser();
echo $user->getGroupeId();
echo $user->getNiveau();
```

### Valider les Données

```php
$email = HelperService::getPost('email');
$password = HelperService::getPost('password');

if (!ValidationService::validateEmail($email)) {
    $error = "Email invalide";
}

if (!ValidationService::validatePassword($password)) {
    $error = "Mot de passe trop court";
}

if (!ValidationService::isRequired($nom)) {
    $error = "Le nom est obligatoire";
}
```

### Mettre à Jour un Utilisateur

```php
// Admin
$userService->updateAdmin(
    $userId,
    'Dupont',
    'Jean',
    'jean@example.com',
    'Informatique'
);

// Student
$userService->updateStudent(
    $studentId,
    'Martin',
    'Marie',
    'marie@example.com'
);
```

### Changer le Mot de Passe

```php
try {
    $authService->changeAdminPassword($userId, $newPassword);
    echo "Mot de passe changé";
} catch (Exception $e) {
    echo "Erreur: " . $e->getMessage();
}
```

### Récupérer les Données POST de Manière Sécurisée

```php
// Sécurisé automatiquement (sanitize XSS)
$nom = HelperService::getPost('nom');
$email = HelperService::getPost('email', 'default@example.com');

// Récupérer GET
$id = HelperService::getGet('id');

// Récupérer SESSION
$userId = HelperService::getSession('user_id');
```

### Redirection

```php
// Simple
HelperService::redirect('dashboard.php');

// Avec paramètres
HelperService::redirect('page.php?success=1');

// Complète
HelperService::redirect('../auth/login_unified.php?type=admin');
```

### Formater une Date

```php
$date = HelperService::formatDate('2026-02-04');  // "04/02/2026"
$date = HelperService::formatDate('2026-02-04', 'Y-m-d');  // "2026-02-04"
```

### Réponse JSON (AJAX)

```php
if ($isAjax) {
    HelperService::jsonResponse(true, "Succès", ['id' => 123]);
    // {
    //   "success": true,
    //   "message": "Succès",
    //   "data": {"id": 123}
    // }
}
```

## ✅ Checklist de Migration

Pour chaque page à refactoriser:

- [ ] Ajouter `require_once '../includes/init.php'` au début
- [ ] Remplacer les vérifications de session par `requireAdmin()`, `requireStudent()`, ou `requireAuth()`
- [ ] Remplacer les accès `$_SESSION['user_id']` par `$authService->getAdminUser()`
- [ ] Remplacer les accès `$_POST`, `$_GET` par `HelperService::getPost()`, `HelperService::getGet()`
- [ ] Remplacer les validations manuelles par `ValidationService::`
- [ ] Remplacer `htmlspecialchars()` par `ValidationService::sanitize()`
- [ ] Remplacer les `redirect()` par `HelperService::redirect()`
- [ ] Remplacer `require_once '../includes/header.php'` par `require_once '../includes/header_unified.php'`
- [ ] Remplacer `require_once '../includes/footer.php'` par `require_once '../includes/footer_unified.php'`
- [ ] Tester la page dans les deux contextes (admin et student)

## 🔐 Sécurité Améliorée

La nouvelle structure inclut:

1. **Session Fingerprinting** - Détecte les vols de session
2. **Session Timeout** - 1 heure configurable
3. **XSS Prevention** - Sanitisation automatique
4. **SQL Injection Prevention** - PDO prepared statements
5. **Type Safety** - Objets User typés
6. **CSRF Protection** - Tokens CSRF générés
7. **Error Logging** - Erreurs loguées, pas affichées
8. **Bcrypt Hashing** - Mots de passe sécurisés

## 🆘 Dépannage

### "Call to undefined method" avec $authService
- Vérifier que `require_once '../includes/init.php'` est au début du fichier

### "Undefined index: user_id"
- Utiliser `$isAdmin` au lieu de vérifier `$_SESSION['user_id']`
- Utiliser `$authService->getAdminUser()` au lieu d'accéder directement à `$_SESSION`

### Headers déjà envoyés
- S'assurer que `require_once` est la première chose du fichier PHP
- Pas de `echo` ou `var_dump` avant les redirections

### "Email déjà utilisé"
- Utiliser `$userService->adminEmailExists()` ou `studentEmailExists()`
- Pour les updates, passer l'ID à exclure: `adminEmailExists($email, $currentUserId)`

## 📚 Fichiers de Référence

- `REFACTORING_GUIDE.md` - Documentation détaillée
- `classes/User.php` - Structure des classes
- `classes/AuthService.php` - Logique d'authentification
- `includes/init.php` - Point d'entrée global
- `pages/dashboard_refactored_example.php` - Exemple complet
- `pages/profile_unified.php` - Profil refactorisé
