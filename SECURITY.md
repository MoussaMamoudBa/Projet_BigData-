# 🔒 Guide de Sécurité

Ce document explique les bonnes pratiques de sécurité pour ce projet.

---

## ⚠️ Secrets et Credentials

### Credentials par Défaut (Développement Local)

Le projet utilise des credentials par défaut pour faciliter le développement local :

- **Username** : `admin`
- **Password** : `password`
- **Database** : `bigdata_project`

**⚠️ Ces credentials sont UNIQUEMENT pour le développement local avec Docker.**

### ⚠️ Ne JAMAIS faire :

1. ❌ Commiter des credentials réels dans le code
2. ❌ Partager des connection strings MongoDB Atlas avec des credentials réels
3. ❌ Utiliser les credentials par défaut en production
4. ❌ Exposer des fichiers `.env` avec des secrets réels

### ✅ À FAIRE :

1. ✅ Utiliser des variables d'environnement pour les credentials
2. ✅ Créer un fichier `.env` local (non versionné)
3. ✅ Utiliser des credentials forts en production
4. ✅ Changer les credentials par défaut si le projet est déployé

---

## 🔐 Utilisation de Variables d'Environnement

### Option 1 : Fichier .env (Recommandé)

1. Copiez `.env.example` vers `.env` :
   ```bash
   cp .env.example .env
   ```

2. Modifiez `.env` avec vos credentials :
   ```env
   MONGO_ROOT_USERNAME=votre_username
   MONGO_ROOT_PASSWORD=votre_password_fort
   ```

3. Utilisez `docker-compose.yml` qui lit les variables d'environnement

### Option 2 : Variables d'Environnement Système

```bash
export MONGO_ROOT_USERNAME=votre_username
export MONGO_ROOT_PASSWORD=votre_password_fort
docker compose up -d
```

---

## 🛡️ MongoDB Atlas

### Connection String Sécurisée

**Format générique (à utiliser dans la documentation) :**
```
mongodb+srv://<username>:<password>@<cluster>.mongodb.net/
```

**⚠️ Ne JAMAIS :**
- Commiter votre vraie connection string Atlas
- Partager votre connection string avec des credentials réels
- Utiliser des credentials faibles

**✅ À FAIRE :**
- Utiliser des variables d'environnement
- Stocker les credentials dans `.env` (non versionné)
- Utiliser des credentials forts
- Activer l'authentification à deux facteurs (2FA) sur Atlas

---

## 📝 Fichiers à Ne JAMAIS Commiter

Les fichiers suivants sont dans `.gitignore` :

- `.env` - Variables d'environnement avec credentials
- `.env.local` - Variables d'environnement locales
- `*.log` - Fichiers de logs (peuvent contenir des informations sensibles)

---

## 🔄 Si Vous Avez Accidentellement Commité un Secret

### Étapes Immédiates :

1. **Changez le secret immédiatement**
   - Changez le mot de passe/API key exposé
   - Révoquez les anciens credentials

2. **Supprimez le secret de l'historique Git**
   ```bash
   # Option 1 : Utiliser git filter-branch
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch FICHIER_AVEC_SECRET" \
     --prune-empty --tag-name-filter cat -- --all
   
   # Option 2 : Utiliser BFG Repo-Cleaner (plus simple)
   # Téléchargez depuis : https://rtyley.github.io/bfg-repo-cleaner/
   bfg --replace-text passwords.txt
   ```

3. **Force push** (⚠️ Attention : coordonnez avec votre équipe)
   ```bash
   git push origin --force --all
   ```

4. **Vérifiez GitHub/GitLab**
   - Vérifiez que le secret n'apparaît plus dans l'historique
   - Utilisez les outils de détection de secrets de la plateforme

---

## ✅ Checklist de Sécurité

Avant de commiter :

- [ ] Aucun credential réel dans le code
- [ ] Aucun fichier `.env` avec des secrets réels
- [ ] Connection strings MongoDB Atlas utilisent des placeholders (`<username>`, `<password>`)
- [ ] Les credentials par défaut sont uniquement pour le développement local
- [ ] Les fichiers sensibles sont dans `.gitignore`

Avant de déployer en production :

- [ ] Tous les credentials par défaut ont été changés
- [ ] Variables d'environnement configurées
- [ ] Authentification MongoDB activée
- [ ] Firewall/réseau sécurisé
- [ ] Logs ne contiennent pas de secrets

---

## 📚 Ressources

- [GitHub : Supprimer des données sensibles](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
- [MongoDB Security Checklist](https://www.mongodb.com/docs/manual/administration/security-checklist/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)

---

**Dernière mise à jour** : Décembre 2025

