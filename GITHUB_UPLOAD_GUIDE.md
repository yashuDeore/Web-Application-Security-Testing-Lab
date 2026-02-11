# 🚀 GitHub Upload Guide

Complete step-by-step instructions to upload this VAPT project to GitHub.

---

## Step 1: Create GitHub Repository

1. Go to [github.com](https://github.com) and log in
2. Click the **"+"** icon → **"New repository"**
3. Fill in:
   - **Repository name:** `web-security-testing-lab`
   - **Description:** `VAPT Lab — SQL Injection, XSS, Broken Auth testing on DVWA & Juice Shop`
   - **Visibility:** Public (for portfolio) or Private
   - ✅ **Check "Add a README file"** — NO (we have our own)
   - **.gitignore template:** None (we have our own)
   - **License:** MIT License
4. Click **"Create repository"**

---

## Step 2: Initialize Git Locally

Open a terminal in your project folder:

```bash
# Navigate to project directory
cd vapt-project/

# Initialize git repository
git init

# Set your identity (first time only)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

---

## Step 3: Add Files & First Commit

```bash
# Add all files to staging
git add .

# Check what will be committed
git status

# Create your first commit
git commit -m "Initial commit: VAPT lab project — DVWA & Juice Shop assessment"
```

---

## Step 4: Connect to GitHub & Push

```bash
# Add remote origin (replace with YOUR repo URL)
git remote add origin https://github.com/YOUR_USERNAME/web-security-testing-lab.git

# Rename branch to main (modern default)
git branch -M main

# Push to GitHub
git push -u origin main
```

---

## Step 5: Add Screenshots

Screenshots make your project stand out! Add them to the `screenshots/` folder.

```bash
# After adding screenshot files to /screenshots folder:
git add screenshots/
git commit -m "Add evidence screenshots for VAPT findings"
git push
```

### Recommended Screenshots to Add:
| Filename | What to Capture |
|----------|-----------------|
| `sqli-login-bypass.png` | SQLi login bypass in browser |
| `sqli-union-dump.png` | UNION injection returning user data |
| `xss-reflected.png` | Alert popup from reflected XSS |
| `xss-stored.png` | Stored XSS executing in browser |
| `burp-intercept.png` | Burp Suite HTTP interception |
| `burp-intruder.png` | Brute force results in Intruder |
| `idor-user-data.png` | API returning another user's data |
| `burp-repeater.png` | Request manipulation in Repeater |

---

## Step 6: Future Updates

```bash
# Make changes to files, then:
git add .
git commit -m "Add: Juice Shop JWT manipulation finding"
git push
```

---

## Optional: Add Topics/Tags on GitHub

After uploading, go to your repo → click **gear icon** next to "About":

Add topics:
```
cybersecurity  vapt  penetration-testing  burp-suite  
sql-injection  xss  owasp  dvwa  juice-shop  ethical-hacking
```

This helps recruiters and other security learners find your project!

---

## Optional: Enable GitHub Pages (HTML Report)

If you create an `index.html` report:

1. Go to repo → **Settings** → **Pages**
2. Source: **Deploy from branch**
3. Branch: **main** / folder: **/ (root)**
4. Your report will be live at: `https://username.github.io/web-security-testing-lab`

---

## 📁 Final GitHub Repository Structure

```
web-security-testing-lab/
├── README.md               ← Main project overview (shows on GitHub homepage)
├── .gitignore              ← Excludes sensitive/unnecessary files
├── reports/
│   ├── VAPT_Report_DVWA.md
│   ├── VAPT_Report_JuiceShop.md
│   └── Executive_Summary.md
├── screenshots/
│   ├── sqli-login-bypass.png
│   ├── xss-reflected.png
│   └── ... (your actual screenshots)
├── payloads/
│   ├── sqli_payloads.txt
│   ├── xss_payloads.txt
│   └── auth_wordlist.txt
└── scripts/
    ├── setup_lab.sh
    └── scan_headers.sh
```
