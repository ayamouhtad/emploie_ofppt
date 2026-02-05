# ⚡ Quick Start - 5 Minutes

## 🎯 Objectif
Comprendre la nouvelle structure en 5 minutes et être prêt à utiliser.

---

## ✨ Ce Qu'il Faut Savoir

### 1. **Un Seul Point d'Entrée: `init.php`**
```php
<?php
$page_title = "Ma Page";
require_once '../includes/init.php';
// Tout est initialisé automatiquement!
?>
```

### 2. **Trois Services Principaux**
```php
$authService;        // Authentification + sessions
$userService;        // Récupérer/modifier utilisateurs
ValidationService;   // Valider données + sécurité
```

### 3. **Deux Variables d'Authentification**
```php
$isAdmin;     // true si admin connecté
$isStudent;   // true si student connecté
```

### 4. **Deux Fonctions de Vérification**
```php
requireAdmin();      // Force l'accès admin
requireStudent();    // Force l'accès student
requireAuth();       // Force admin OU student
```

---

## 🚀 Votre Première Page en 2 Minutes

```php
<?php
$page_title = "Bienvenue";
require_once '../includes/init.php';

// Vérifier l'accès
requireAuth();  // Force connecté

// Récupérer l'utilisateur
$user = $isAdmin ? $authService->getAdminUser() : $authService->getStudentUser();
?>

<!DOCTYPE html>
<html>
<head>
    <title><?= $page_title ?></title>
</head>
<body>
    <?php require_once '../includes/header_unified.php'; ?>
    
    <h1>Bienvenue <?= $user->getFullName() ?></h1>
    
    <?php require_once '../includes/footer_unified.php'; ?>
</body>
</html>
```

**C'est tout!** Cette page est:
- ✅ Sécurisée
- ✅ Responsive
- ✅ Avec navigation
- ✅ Avec authentification

---

## 🔐 Sécuriser une Saisie en 1 Ligne

```php
// Avant (DANGEREUX):
$nom = $_POST['nom'];
echo "Bienvenue " . $nom;  // Pas sûr!

// Après (SÉCURISÉ):
$nom = HelperService::getPost('nom');
echo "Bienvenue " . $nom;  // Automatiquement sécurisé!
```

---

## ✅ Valider une Saisie en 1 Ligne

```php
$email = HelperService::getPost('email');

if (!ValidationService::validateEmail($email)) {
    echo "Email invalide";
} else {
    // Email valide, continuer
}
```

---

## 📝 Mettre à Jour un Utilisateur en 2 Lignes

```php
$userService->updateAdmin(
    $userId,
    'Dupont',
    'Jean',
    'jean@example.com',
    'Informatique'
);
```

---

## 🔑 Authentifier un Utilisateur en 5 Lignes

```php
$email = HelperService::getPost('email');
$password = $_POST['password'];

$user = $authService->authenticateAdmin($email, $password);
if ($user) {
    $authService->createAdminSession($user);
    HelperService::redirect('dashboard.php');
} else {
    echo "Erreur: Email ou mot de passe incorrect";
}
```

---

## 📋 Les 5 Commandes à Mémoriser

```php
// 1. Vérifier l'authentification
requireAdmin();                    // Force admin
requireStudent();                  // Force student
requireAuth();                     // Force l'un ou l'autre

// 2. Récupérer l'utilisateur
$user = $authService->getAdminUser();
$user = $authService->getStudentUser();

// 3. Récupérer données de manière sécurisée
$nom = HelperService::getPost('nom');
$email = HelperService::getPost('email');

// 4. Valider les données
ValidationService::validateEmail($email);
ValidationService::validatePassword($password);

// 5. Rediriger
HelperService::redirect('dashboard.php');
```

---

## 🔍 Structure des Pages: 3 Parties

```php
<?php
/* PARTIE 1: INITIALISATION */
$page_title = "Titre";
require_once '../includes/init.php';

// Code PHP ici
?>

<!-- PARTIE 2: HTML -->
<?php require_once '../includes/header_unified.php'; ?>

<h1>Contenu</h1>

<?php require_once '../includes/footer_unified.php'; ?>

<!-- C'est tout! -->
```

---

## 🎯 Cas d'Usage Courants

### Afficher le Nom de l'Utilisateur
```php
<p>Bonjour <?= $user->getFullName() ?></p>
```

### Afficher le Email
```php
<p>Email: <?= $user->getEmail() ?></p>
```

### Afficher le Groupe (Student)
```php
<?php if ($isStudent): ?>
    <p>Groupe: <?= $user->getGroupeNom() ?></p>
<?php endif; ?>
```

### Afficher la Spécialité (Admin)
```php
<?php if ($isAdmin): ?>
    <p>Spécialité: <?= $user->getSpecialite() ?></p>
<?php endif; ?>
```

### Afficher un Message d'Erreur Sécurisé
```php
<?php if ($error): ?>
    <div class="alert alert-danger">
        <?= ValidationService::sanitize($error) ?>
    </div>
<?php endif; ?>
```

### Créer un Formulaire Sécurisé
```php
<form method="POST">
    <input type="email" name="email" required>
    <input type="password" name="password" required>
    <button type="submit">Login</button>
</form>

<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = HelperService::getPost('email');
    $password = $_POST['password'];  // Password never sanitized before verify
    
    // Validation
    if (!ValidationService::validateEmail($email)) {
        echo "Email invalide";
    }
    // ... continuer
}
?>
```

---

## 📚 Fichiers à Consulter

### Si vous ne savez pas comment faire...
1. Consulter `pages/dashboard_refactored_example.php` ← Exemple complet
2. Consulter `pages/profile_unified.php` ← Autre exemple
3. Lire `MIGRATION_GUIDE.md` ← Guide détaillé
4. Lire `REFACTORING_GUIDE.md` ← Documentation complète

### Si vous avez un problème de sécurité...
1. Lire `SECURITY_GUIDE.md`
2. Utiliser `ValidationService::sanitize()`
3. Utiliser `HelperService::getPost()`

### Si vous avez un problème de session...
1. Vérifier que `init.php` est inclus
2. Utiliser `requireAuth()` au début de page
3. Consulter `MIGRATION_GUIDE.md`

---

## 🎓 Les 10 Règles d'Or

1. ✅ Toujours inclure `init.php` au début
2. ✅ Ne jamais accéder à `$_SESSION` directement
3. ✅ Toujours valider avec `ValidationService`
4. ✅ Toujours sanitizer avec `sanitize()`
5. ✅ Toujours utiliser `getPost()` au lieu de `$_POST`
6. ✅ Toujours rediriger avec `HelperService::redirect()`
7. ✅ Toujours utiliser `header_unified.php`
8. ✅ Toujours utiliser `footer_unified.php`
9. ✅ Jamais logger les mots de passe
10. ✅ Jamais afficher les erreurs de BD

---

## ❌ Les 5 Erreurs Courantes

### ❌ Erreur 1: Pas inclure init.php
```php
// MAUVAIS:
<?php
$user = $authService->getAdminUser();  // ERREUR!
?>

// BON:
<?php
require_once '../includes/init.php';
$user = $authService->getAdminUser();  // OK!
?>
```

### ❌ Erreur 2: Accéder à $_SESSION
```php
// MAUVAIS:
<?php
echo $_SESSION['user_nom'];  // Pas sûr!
?>

// BON:
<?php
$user = $authService->getAdminUser();
echo $user->getNom();  // Sûr!
?>
```

### ❌ Erreur 3: Pas valider
```php
// MAUVAIS:
<?php
$email = $_POST['email'];  // Pas validé
?>

// BON:
<?php
$email = HelperService::getPost('email');
if (!ValidationService::validateEmail($email)) {
    echo "Erreur";
}
?>
```

### ❌ Erreur 4: Afficher erreur utilisateur
```php
// MAUVAIS:
<?php
try { ... } catch (Exception $e) {
    echo "Erreur: " . $e->getMessage();  // Expose détails!
}
?>

// BON:
<?php
try { ... } catch (Exception $e) {
    error_log("Erreur: " . $e->getMessage());  // Log
    echo "Une erreur est survenue";  // Message générique
}
?>
```

### ❌ Erreur 5: Pas utiliser header_unified
```php
// MAUVAIS:
<?php require_once '../includes/header.php'; ?>  // Old

// BON:
<?php require_once '../includes/header_unified.php'; ?>  // New
```

---

## 🎯 Résumé en 1 Minute

| Besoin | Solution |
|--------|----------|
| Créer une page | `init.php` + `header_unified.php` + HTML + `footer_unified.php` |
| Vérifier accès | `requireAuth()` ou `requireAdmin()` ou `requireStudent()` |
| Récupérer utilisateur | `$authService->getAdminUser()` |
| Récupérer données POST | `HelperService::getPost('nom')` |
| Valider email | `ValidationService::validateEmail($email)` |
| Sanitizer HTML | `ValidationService::sanitize($data)` |
| Rediriger | `HelperService::redirect('page.php')` |
| Mettre à jour utilisateur | `$userService->updateAdmin(...)` |

---

## 🚀 Prêt à Démarrer?

1. ✅ Lire ce document (fait!)
2. ✅ Consulter `pages/dashboard_refactored_example.php`
3. ✅ Créer votre première page
4. ✅ Lire `MIGRATION_GUIDE.md` pour les détails
5. ✅ Commencer la migration!

**Bonne chance! 🎉**

---

**Vous pouvez maintenant écrire du code sécurisé et structuré! ✨**
