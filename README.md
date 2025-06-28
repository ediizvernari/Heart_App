# HeartApp: Sistem de monitorizare și asistență medicală

## Adresa repository

Codul sursă complet al acestui proiect este disponibil la:

```
https://github.com/ediizvernari/Heart_App.git
```
---

## Pași de compilare

### 1. Clonare repository

```bash
git clone https://github.com/ediizvernari/Heart_App.git
cd Heart_App
```

### 2. Backend (FastAPI)

1. Creare mediu virtual și activare:

   ```bash
   python -m venv venv
   venv\\Scripts\\activate
   ```
2. Instalare dependențe:

   ```bash
   pip install -r backend/requirements.txt
   ```
3. Copiere fișier `.env.example` în `backend/.env` și completare:

   ```ini
   DATABASE_URL=postgresql+asyncpg://<user>:<pass>@localhost:5432/heart_app
   SECRET_KEY_JWT=<cheia_secretă>
   AES_KEY=<cheia_AES_256>
   ```

### 3. Frontend (Flutter)

1. Intrați în directorul frontend:

   ```bash
   cd frontend
   ```
2. Instalare dependențe:

   ```bash
   flutter pub get
   ```

---

## Pași de instalare și lansare a aplicației

1. **Precondiții**

   * PostgreSQL rulează și are creată baza de date `heart_app`
   * Certificatele SSL (`cert.key`, `cert.pem`) plasate în directorul rădăcină

2. **Pornire backend cu SSL**

```bash
uvicorn backend.main:app \
  --reload \
  --host 0.0.0.0 \
  --port 8000 \
  --ssl-keyfile cert.key \
  --ssl-certfile cert.pem \
  --log-level debug \
  --access-log
```

3. **Pornire frontend**

* Pentru dezvoltare (hot reload):

  ```bash
  cd frontend
  flutter run
  ```