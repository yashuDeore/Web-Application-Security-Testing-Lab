# VAPT Report — OWASP Juice Shop

**Report Type:** Vulnerability Assessment & Penetration Test  
**Target Application:** OWASP Juice Shop v15.x  
**Test Environment:** Localhost:3000 (Docker)  
**Test Date:** [Your Date]  
**Tester:** [Your Name]  
**Classification:** Confidential – Lab Exercise  

---

## 1. Executive Summary

A comprehensive penetration test was performed on OWASP Juice Shop. A total of **7 vulnerabilities** were identified and exploited spanning broken authentication, IDOR, sensitive data exposure, injection, and JWT manipulation.

| Severity | Count |
|----------|-------|
| 🔴 Critical | 3 |
| 🟠 High | 2 |
| 🟡 Medium | 2 |

---

## 2. Scope

| Item | Details |
|------|---------|
| URL | http://localhost:3000 |
| API Base | http://localhost:3000/api / /rest |
| Application | Juice Shop v15.x |
| Test Type | Black-box with API exploration |

---

## 3. Findings

---

### JS-001: Admin Panel Access via URL Guessing

**Severity:** 🔴 Critical  
**OWASP Category:** A01:2021 – Broken Access Control  

#### Description
The admin panel at `/#!/administration` is accessible without any server-side access control check. Any authenticated user can access the full admin interface by navigating directly to the URL.

#### Steps to Reproduce
```
1. Login as any regular user (register a new account)
2. Navigate to: http://localhost:3000/#!/administration
3. Full admin panel loads — all users, all orders visible
```

#### Evidence
- Screenshot: `screenshots/juice-admin-panel.png`

#### Remediation
- Implement **server-side role checks** on all admin routes
- Return `403 Forbidden` for unauthorized access
- Never rely on **security through obscurity**

---

### JS-002: Broken Access Control — IDOR on User API

**Severity:** 🔴 Critical  
**CVSS v3.1 Score:** 8.8  
**OWASP Category:** A01:2021 – Broken Access Control  

#### Description
The REST API endpoint `/api/Users/:id` returns any user's full profile when called with a valid JWT token, regardless of whether the token belongs to that user. This is a classic **Insecure Direct Object Reference (IDOR)** vulnerability.

#### Steps to Reproduce
```
1. Login as user@example.com — note your JWT token
2. Send request in Burp Suite:
   GET /api/Users/1 HTTP/1.1
   Authorization: Bearer <your_token>
3. Response returns admin user's full profile including email
4. Change ID 1→2, 1→3 to enumerate all users
```

#### Burp Suite Request
```http
GET /api/Users/1 HTTP/1.1
Host: localhost:3000
Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...

HTTP/1.1 200 OK
{
  "status": "success",
  "data": {
    "id": 1,
    "username": "admin",
    "email": "admin@juice-sh.op",
    "role": "admin",
    ...
  }
}
```

#### Evidence
- Screenshot: `screenshots/idor-user-data.png`

#### Remediation
- **Validate user ownership** on every API request
- Use **UUIDs** instead of sequential integers
- Implement proper **authorization middleware**

---

### JS-003: JWT Token Manipulation — Algorithm Confusion

**Severity:** 🔴 Critical  
**CVSS v3.1 Score:** 9.1  
**OWASP Category:** A07:2021 – Identification and Authentication Failures  

#### Description
The application accepts JWT tokens signed with the `alg: none` algorithm or weak secret. By modifying the JWT payload and stripping the signature, an attacker can forge tokens for any user including admin.

#### Steps to Reproduce
```
1. Login and capture your JWT token
2. Decode the payload (base64):
   {"alg":"HS256","typ":"JWT"}
   {"data":{"id":5,"email":"user@example.com","role":"customer"}}

3. Modify payload:
   {"data":{"id":1,"email":"admin@juice-sh.op","role":"admin"}}

4. Set alg to "none" and remove signature:
   header.payload.  (empty signature)

5. Use forged token to access admin endpoints
```

#### Tools Used
- [jwt.io](https://jwt.io) for token decoding
- Burp Suite Repeater for sending modified token

#### Evidence
- Screenshot: `screenshots/jwt-manipulation.png`

#### Remediation
- **Reject `alg: none`** tokens explicitly
- Use strong, random JWT secrets (minimum 256-bit)
- Validate JWT algorithm server-side
- Consider using **RS256** (asymmetric) over HS256

---

### JS-004: SQL Injection — Login Form

**Severity:** 🟠 High  
**CVSS v3.1 Score:** 8.2  
**OWASP Category:** A03:2021 – Injection  

#### Description
The login form is vulnerable to SQL injection via the `email` parameter, allowing authentication bypass using a classic `' OR 1=1--` payload.

#### Steps to Reproduce
```
1. Navigate to: http://localhost:3000/#/login
2. In email field enter: ' OR 1=1--
3. In password field enter: anything
4. Click login
5. Result: Logged in as admin (first user in DB)
```

#### Burp Suite Request
```http
POST /rest/user/login HTTP/1.1
Host: localhost:3000
Content-Type: application/json

{"email":"' OR 1=1--","password":"anything"}
```

#### Evidence
- Screenshot: `screenshots/juice-sqli-login.png`

#### Remediation
- Use **parameterized queries** / ORM (Sequelize)
- Sanitize email input with regex validation
- Never concatenate user input into SQL strings

---

### JS-005: Sensitive Data Exposure — FTP Directory

**Severity:** 🟠 High  
**OWASP Category:** A02:2021 – Cryptographic Failures / Sensitive Data Exposure  

#### Description
The application exposes an FTP directory at `/ftp` that is publicly accessible and contains sensitive files including backup archives and configuration files.

#### Steps to Reproduce
```
1. Navigate to: http://localhost:3000/ftp
2. Directory listing shows:
   - acquisitions.md (acquisition plans)
   - backup.tar.bz2 (source code backup)
   - coupons_2013.md.bak
   - package.json.bak (dependency info)
3. Download and inspect files
```

#### Evidence
- Screenshot: `screenshots/ftp-directory.png`

#### Remediation
- **Disable directory listing**
- Remove sensitive files from public directories
- Implement **authentication** on all sensitive endpoints
- Audit all publicly accessible paths

---

### JS-006: XSS — Search Field (DOM-based)

**Severity:** 🟡 Medium  
**OWASP Category:** A03:2021 – Injection  

#### Description
The search functionality reflects user input into the DOM without proper sanitization, enabling DOM-based XSS attacks.

#### Payload
```
http://localhost:3000/#/search?q=<iframe src="javascript:alert('XSS')">
```

#### Evidence
- Screenshot: `screenshots/juice-xss.png`

#### Remediation
- Sanitize user input before inserting into DOM
- Use `textContent` instead of `innerHTML`
- Implement Content Security Policy

---

### JS-007: Improper Error Handling — Stack Trace Exposure

**Severity:** 🟡 Medium  
**OWASP Category:** A05:2021 – Security Misconfiguration  

#### Description
API error responses return full stack traces exposing internal file paths, library versions, and application architecture.

#### Steps to Reproduce
```
1. Send malformed request to any API endpoint
2. Response contains:
   {
     "error": {
       "stack": "SequelizeDatabaseError: ...\n    at /juice-shop/node_modules/sequelize/...",
       "message": "...",
       "name": "SequelizeDatabaseError"
     }
   }
```

#### Evidence
- Screenshot: `screenshots/error-stack-trace.png`

#### Remediation
- Return **generic error messages** in production
- Log detailed errors **server-side only**
- Set `NODE_ENV=production` to suppress stack traces

---

## 4. Summary

| Vuln ID | Title | Severity | Status |
|---------|-------|----------|--------|
| JS-001 | Admin Panel Exposed | Critical | ✅ Exploited |
| JS-002 | IDOR — User API | Critical | ✅ Exploited |
| JS-003 | JWT Manipulation | Critical | ✅ Exploited |
| JS-004 | SQL Injection — Login | High | ✅ Exploited |
| JS-005 | Sensitive Data / FTP | High | ✅ Exploited |
| JS-006 | DOM-based XSS | Medium | ✅ Exploited |
| JS-007 | Stack Trace Exposure | Medium | ✅ Identified |

---

*Report generated as part of a security lab exercise. Not for use against real systems.*
