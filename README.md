# Repo B — projet-demo

## README.md

# Projet Demo

Infrastructure live **Terragrunt** multi-environnements pour le projet "Demo".

## Structure

- Un dossier **par projet GCP** (dev, qa, preprod, prod-cache, prod)
- Un dossier `common/` pour ce qui est **vraiment partagé** :
    - Pins de modules
    - Labels org-wide
    - Policies
- **DRY** via `terragrunt.hcl` racine (state GCS + generate provider/versions)
- **Promotion** contrôlée en changeant les refs de modules (tags `vX.Y.Z`)

---

## 🎯 Objectifs & Philosophie

- **Lisibilité** alignée GCP/IAM : 1 dossier = 1 projet (env)
- **Séparation stricte** : états Terraform/SAs par env, moindres blast radius
- **Gouvernance** : modules **pinnés** (tags semver), apply **gated** en CI, policies (OPA) possibles

---

## 🧠 Raisonnement de Conception

### Dossier par projet GCP (env)

- Correspond aux frontières IAM/budgets/quotas/alerting réels
- Facilite l'onboarding et la revue de changements (PRs par env)

### Dossier `common/`

Contient **uniquement** des éléments **transverses et stables** :

- `modules.pins.hcl` (source + `?ref=vX.Y.Z`)
- Labels organisationnels
- Templates `generate` (optionnel si non placé dans la racine)
- Policies OPA/Conftest (optionnel)

> ⚠️ **Important** : Ne pas y glisser des variables qui divergent selon env (réseaux, KMS, budgets) → restent dans chaque `env.hcl`

### States & Providers

- **Backend GCS** : préfixes basés sur `path_relative_to_include()` → noms déterministes & pas de collision
- **Providers générés** au runtime (pas dans les modules) → meilleure portabilité

---

## ✅ Bonnes Pratiques Appliquées

- **Run-all plan** sur PR, **run-all apply** sur main (gated via `environment`/approvals)
- **Workload Identity Federation** pour auth GCP (pas de clés longues durées)
- **Pins** des modules (`?ref=vX.Y.Z`) + **semantic-release** dans le repo module
- **Labels** uniformes via `common/env.hcl` (merge avec labels d'env)

---

## 🔁 CI/CD & Releases

### Workflow

1. **PR (feature → main)** :
    - CI `plan` (sans apply)
    - Contrôle et visibilité des diffs

2. **Main** :
    - `apply` (gated)
    - **puis** `semantic-release` (changelog+tags) pour tracer l'évolution du **repo live**
    - Utile pour auditer quelles refs et inputs ont changé dans le temps

> 📝 Comme pour le module, **semantic-release gère le `CHANGELOG.md`** automatiquement.

---

## 🧪 Qualité

- **Validation** Terragrunt/Terraform, linters et security scanners (optionnels)
- **Policies** (OPA/Conftest) activables en PR pour bloquer les dérives

---

## 🧭 Organisation des Dossiers
```
projet-demo/
├── common/
│   ├── modules.pins.hcl        # Pins des modules
│   ├── labels.hcl               # Labels communs
│   └── policies/                # Policies OPA (optionnel)
├── dev/
│   ├── env.hcl                  # Config environnement dev
│   └── eu-west1/
│       └── cloudsql-postgres/
│           └── terragrunt.hcl   # Inputs module
├── qa/
│   ├── env.hcl
│   └── ...
├── preprod/
│   ├── env.hcl
│   └── ...
├── prod/
│   ├── env.hcl
│   └── ...
└── terragrunt.hcl               # Config racine (DRY)
```

### Détails des fichiers

- **`common/`** : pins, labels communs, policies
- **`<env>/env.hcl`** : `project_id`, `region`, `private_network`, labels env, etc.
- **`<env>/<region>/cloudsql-postgres/terragrunt.hcl`** : inputs module (diffèrent par env)