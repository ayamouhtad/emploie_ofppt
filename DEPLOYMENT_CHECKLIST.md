# ✅ Checklist de Déploiement et Intégration

## 🎯 Phase 1: Vérification (30 min)

- [ ] Lire `REFACTORING_SUMMARY.md` - Comprendre le changement
- [ ] Lire `MIGRATION_GUIDE.md` - Apprendre à migrer
- [ ] Lire `REFACTORING_GUIDE.md` - Comprendre l'architecture
- [ ] Explorer `classes/` - Vérifier les services
- [ ] Vérifier que `includes/init.php` existe
- [ ] Vérifier que `includes/header_unified.php` existe
- [ ] Vérifier que `includes/footer_unified.php` existe

## 🧪 Phase 2: Tests des Composants (1-2 heures)

### Test de `init.php`
- [ ] Créer une page test simple
- [ ] Ajouter `require_once '../includes/init.php'`
- [ ] Vérifier que `$authService` est défini
- [ ] Vérifier que `$userService` est défini
- [ ] Vérifier que `$isAdmin` est défini
- [ ] Vérifier que `$isStudent` est défini

### Test d'Authentification Admin
- [ ] Visiter `auth/login_unified.php?type=admin`
- [ ] Entrer email/password admin valides
- [ ] Vérifier redirection vers dashboard
- [ ] Vérifier affichage du nom dans la navbar
- [ ] Vérifier que `$isAdmin = true`
- [ ] Tester logout
- [ ] Vérifier redirection vers login

### Test d'Authentification Student
- [ ] Visiter `auth/login_unified.php?type=student`
- [ ] Entrer email/password stagiaire valides
- [ ] Vérifier redirection vers dashboard_stagiaire
- [ ] Vérifier affichage du nom dans la navbar
- [ ] Vérifier que `$isStudent = true`
- [ ] Tester logout
- [ ] Vérifier redirection vers login

### Test du Header Unifié
- [ ] Vérifier navbar admin affiche les bons liens
- [ ] Vérifier navbar student affiche les bons liens
- [ ] Vérifier menu hamburger sur mobile (768px)
- [ ] Vérifier fermeture menu au clic sur un lien
- [ ] Vérifier affichage du nom utilisateur

### Test du Profile Unifié
- [ ] Visiter `pages/profile_unified.php` en tant qu'admin
- [ ] Vérifier affichage des données admin
- [ ] Modifier un champ
- [ ] Vérifier mise à jour en BD
- [ ] Tester changement de mot de passe
- [ ] Visiter en tant que student
- [ ] Vérifier affichage des données student
- [ ] Modifier un champ student
- [ ] Vérifier mise à jour

### Test de Validation
- [ ] Essayer un email invalide → message erreur
- [ ] Essayer mot de passe < 6 caractères → message erreur
- [ ] Essayer un email déjà existant → message erreur
- [ ] Essayer des champs vides → message erreur
- [ ] Vérifier HTML escape des caractères spéciaux

### Test de Sécurité
- [ ] Vérifier que sessions ne peuvent pas être volées (fingerprint)
- [ ] Vérifier que passwords ne sont pas loggés
- [ ] Vérifier qu'erreurs DB ne sont pas affichées
- [ ] Vérifier que code source n'est pas exposé
- [ ] Tester injection SQL (doit échouer)
- [ ] Tester XSS (doit être échappé)

## 📝 Phase 3: Migration des Pages (graduelle)

### Priorité 1: Pages Critiques
- [ ] `pages/dashboard.php`
- [ ] `pages/dashboard_stagiaire.php`
- [ ] `pages/emploi_temps.php`
- [ ] `pages/emploi_stagiaire.php`

Processus par page:
1. [ ] Créer sauvegarde du fichier original
2. [ ] Lire le fichier original
3. [ ] Appliquer les changements de migration
4. [ ] Tester en admin
5. [ ] Tester en student (si applicable)
6. [ ] Valider que la page fonctionne
7. [ ] Valider que le design est intact
8. [ ] Valider que la sécurité est améliorée

### Priorité 2: Pages d'Administration
- [ ] `pages/enseignants.php`
- [ ] `pages/groupes.php`
- [ ] `pages/modules.php`
- [ ] `pages/salles.php`

Même processus que Priorité 1

### Priorité 3: Pages de Données
- [ ] `pages/export_timetable.php`
- [ ] `pages/export_timetable_pdf.php`
- [ ] Autres pages utilitaires

### Priorité 4: Legacy (Optionnel)
- [ ] `actions/` - Vérifier usage du nouvel AuthService
- [ ] `includes/validation.php` - Intégrer à ValidationService si nécessaire

## 🗂️ Phase 4: Cleanup

### Après Migration Complète
- [ ] Vérifier que tous les `header.php` ont été remplacés
- [ ] Vérifier que tous les `header_stagiaire.php` ont été remplacés
- [ ] Vérifier que toutes les vérifications de session utilisent le nouvel AuthService
- [ ] Supprimer les fichiers legacy si plus utilisés
- [ ] Supprimer les classes anciennes de `database.php` si nécessaire

### Fichiers Legacy à Potentiellement Supprimer
- [ ] `includes/header.php` (si migration complète)
- [ ] `includes/header_stagiaire.php` (si migration complète)
- [ ] `includes/footer_stagiaire.php` (si migration complète)
- [ ] `auth/login.php` (si remplacé par login_unified.php)
- [ ] `auth/login_stagiaire.php` (si remplacé par login_unified.php)
- [ ] `pages/profile.php` (si remplacé par profile_unified.php)
- [ ] `pages/profile_stagiaire.php` (si remplacé par profile_unified.php)

**ATTENTION:** Garder une sauvegarde avant suppression!

## 📊 Phase 5: Documentation et Formation

- [ ] Créer un guide pour l'équipe sur la nouvelle structure
- [ ] Montrer les exemples (dashboard_refactored_example.php)
- [ ] Faire une session de formation
- [ ] Documenter les services disponibles
- [ ] Mettre à jour le README du projet

## 🚀 Phase 6: Déploiement Production

### Avant le Déploiement
- [ ] Tous les tests passent
- [ ] Configuration BD vérifiée
- [ ] Variables d'environnement correctes
- [ ] Erreurs loggées correctement
- [ ] HTTPS activé
- [ ] Cookies sécurisés configurés

### Déploiement
- [ ] Sauvegarder base de données
- [ ] Déployer les nouveaux fichiers
- [ ] Vérifier permissions fichiers
- [ ] Tester login admin
- [ ] Tester login student
- [ ] Vérifier tous les liens de navigation
- [ ] Vérifier performance

### Post-Déploiement
- [ ] Monitorer les erreurs (error_log)
- [ ] Vérifier les sessions actives
- [ ] Tester un cycle complet (login → utiliser → logout)
- [ ] Vérifier que les anciennes URLs redirigent correctement

## 🎯 Points Clés à Retenir

### DO ✅
- Utiliser `require_once '../includes/init.php'`
- Utiliser `$authService->` pour l'authentification
- Utiliser `$userService->` pour les données utilisateur
- Utiliser `ValidationService::` pour la validation
- Utiliser `HelperService::` pour les helpers
- Garder une sauvegarde avant de modifier

### DON'T ❌
- Ne pas accéder directement à `$_SESSION`
- Ne pas vérifier `isset($_SESSION['user_id'])` directement
- Ne pas sanitize avec `htmlspecialchars()` (utiliser `sanitize()`)
- Ne pas valider manuellement (utiliser `ValidationService`)
- Ne pas faire de redirections manuelles (utiliser `HelperService::redirect()`)
- Ne pas garder trop longtemps les fichiers legacy

## 📞 Support et Aide

### Si une Page ne Fonctionne pas
1. [ ] Vérifier que `init.php` est inclus
2. [ ] Vérifier que `$isAdmin` ou `$isStudent` est correct
3. [ ] Vérifier les erreurs dans `error_log`
4. [ ] Revérifier l'exemple `dashboard_refactored_example.php`
5. [ ] Relire `MIGRATION_GUIDE.md`

### Si la Sécurité pose Problème
1. [ ] Vérifier `AuthService::isSessionValid()`
2. [ ] Vérifier `ValidationService::sanitize()`
3. [ ] Vérifier les prepared statements PDO
4. [ ] Vérifier que mots de passe ne sont pas loggés
5. [ ] Lire la section Sécurité dans `REFACTORING_GUIDE.md`

### Pour les Questions Techniques
- [ ] Consulter les docblocks dans les classes
- [ ] Consulter les guides de documentation
- [ ] Consulter l'exemple complet

## 📈 Estimation de Temps

- **Phase 1**: 30 min
- **Phase 2**: 1-2 heures
- **Phase 3**: 4-8 heures (dépend du nombre de pages)
- **Phase 4**: 30 min
- **Phase 5**: 1 heure
- **Phase 6**: 1-2 heures
- **TOTAL**: 8-15 heures

**Temps économisé en maintenance future**: Énorme ✨

---

**Statut:** ✅ Prêt pour déploiement
**Danger Level:** 🟢 Bas (changements bien structurés)
**Rollback:** Facile (garder backups)
