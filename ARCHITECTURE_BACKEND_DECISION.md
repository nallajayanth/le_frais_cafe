# Architecture Decision: Where to Write New Endpoints

## Question: Add Auth/Endpoints to Existing Backend or Create Separate?

### ✅ ANSWER: ADD EVERYTHING TO YOUR EXISTING BACKEND FOLDER

**Why?**
- ✅ Single source of truth
- ✅ Shared database (PostgreSQL)
- ✅ Shared Temporal server
- ✅ Single Node.js process
- ✅ Easier maintenance
- ✅ No coordination between services
- ✅ This is the standard approach

---

## 🏗️ Backend Architecture (Now and Later)

```
Your Backend Folder: e:\resturents how do they work\web_application\backend
│
├─ src/
│  ├─ server.js ......................... Express app (PORT 4000)
│  ├─ routes/
│  │  ├─ orders.js ..................... ✅ Exists now
│  │  ├─ auth.js ....................... ❌ Add later
│  │  ├─ menu.js ....................... ❌ Add later
│  │  ├─ payments.js ................... ❌ Add later
│  │  └─ delivery.js ................... ❌ Add later
│  ├─ models/
│  │  ├─ Order.js ...................... ✅ Exists now
│  │  ├─ Customer.js ................... ❌ Add later
│  │  ├─ MenuItem.js ................... ❌ Add later
│  │  └─ PaymentTransaction.js ......... ❌ Add later
│  ├─ temporal/
│  │  ├─ workflows.js .................. ✅ Exists now
│  │  ├─ activities.js ................. ✅ Exists now
│  │  └─ client.js ..................... ✅ Exists now
│  ├─ db/
│  │  └─ init/
│  │     └─ 001_schema.sql ............ ✅ Update as needed
│  └─ config.js ........................ ✅ Exists now
│
├─ docker-compose.yml .................. ✅ Exists now
├─ package.json ........................ ✅ Exists now
└─ README.md ........................... ✅ Exists now
```

---

## 🚀 OPTION A: Testing Order Flow (TODAY)

### What We're Testing:
- ✅ Mobile app connects to backend
- ✅ Place order (POST /api/orders)
- ✅ View orders (GET /api/orders)
- ✅ Update order status
- ✅ Temporal workflow executes
- ✅ Real-time updates via WebSocket

### What We're NOT testing (yet):
- ❌ Authentication
- ❌ Menu browsing
- ❌ Payments
- ❌ Delivery addresses

---

## 📋 Steps to Get Testing Working

### Step 1: Verify Backend is Ready
```bash
cd e:\resturents how do they work\web_application\backend

# Check files exist
ls -la docker-compose.yml
ls -la src/server.js
ls -la src/temporal/workflows.js

# Check dependencies installed
npm install
```

### Step 2: Start Docker Containers
```bash
docker-compose up -d

# Wait 30 seconds
sleep 30

# Verify all running
docker-compose ps

# Should show:
# le-frais-app-postgres .... UP
# temporal-postgres ........ UP
# temporal ................. UP
# temporal-ui .............. UP
```

### Step 3: Start API Server (Terminal 1)
```bash
cd e:\resturents how do they work\web_application\backend
npm run dev:api

# Should show:
# ✅ Le Frais API running on http://localhost:4000
# Health: http://localhost:4000/health
```

### Step 4: Start Temporal Worker (Terminal 2)
```bash
cd e:\resturents how do they work\web_application\backend
npm run dev:worker

# Should show:
# Temporal worker started
```

### Step 5: Prepare Mobile App
```bash
cd e:\Le frais\le_frais_mobile_application

# Update dependencies (if not done yet)
flutter pub get

# Check API_URL is correct in lib/services/api/api_client.dart
# Should be: http://localhost:4000/api
```

### Step 6: Start Flutter App (Terminal 3)
```bash
cd e:\Le frais\le_frais_mobile_application
flutter run -d chrome

# App should start and connect to http://localhost:4000
```

---

## ✅ Testing Workflow

Once everything is running:

### Test 1: Check API Health
```bash
curl http://localhost:4000/health

# Should return:
# {"status":"ok","db":"connected"}
```

### Test 2: Create an Order (from mobile app or API)
```bash
curl -X POST http://localhost:4000/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "orderType": "Delivery",
    "items": [
      {
        "itemId": 1,
        "name": "Biryani",
        "price": 250,
        "quantity": 2,
        "isVeg": false
      }
    ],
    "customerName": "John",
    "phone": "9876543210",
    "deliveryAddress": "123 Main St"
  }'

# Should return:
# {"orderId": "abc-123-def"}
```

### Test 3: View Orders
```bash
curl http://localhost:4000/api/orders

# Should return list of all orders
```

### Test 4: Monitor Workflow
```
Open: http://localhost:8233
- See workflow execution
- See all activities
- Watch status updates in real-time
```

---

## 🎯 What Happens When Order is Placed

```
Mobile App
  ↓ POST /api/orders
Node.js API (Port 4000)
  ↓ Validates order
  ↓ Starts Temporal workflow
Temporal Server (Port 7233)
  ↓ Saves workflow state
  ↓ Schedules first activity
Temporal Worker
  ↓ Executes createOrder activity
  ↓ Inserts into database
PostgreSQL (Port 5434)
  ↓ Order saved
  ↓ ready for processing
Temporal UI (Port 8233)
  ↓ Shows complete execution history
```

---

## 📊 Monitoring Dashboard

| Component | URL | Purpose |
|-----------|-----|---------|
| API Health | http://localhost:4000/health | Verify API running |
| All Orders | http://localhost:4000/api/orders | List all orders |
| Temporal UI | http://localhost:8233 | Watch workflows |
| Docker Status | `docker-compose ps` | Check containers |

---

## 🔍 Troubleshooting During Testing

### Problem: "Connection refused on localhost:4000"
```
Solution:
1. Check Terminal 1 - is API running?
2. Run: npm run dev:api
3. Check port: netstat -an | find ":4000"
```

### Problem: "Workflow doesn't appear in Temporal UI"
```
Solution:
1. Check if worker is running (Terminal 2)
2. Check if order was actually created
3. Reload Temporal UI: http://localhost:8233
```

### Problem: "Database connection error"
```
Solution:
1. Check Docker: docker-compose ps
2. Check PostgreSQL: docker-compose logs app-postgres
3. Restart: docker-compose restart
```

### Problem: "Flutter app can't connect to backend"
```
Solution:
1. Check API_URL in api_client.dart
2. Check if API is running on :4000
3. Check firewall allows localhost:4000
```

---

## 🚨 Important: Don't Do This Yet

❌ Don't modify mobile app auth services
❌ Don't add login screens
❌ Don't try to use menu services
❌ Don't modify payment services

Just test orders! 🎯

---

## 📝 After Testing Works (Next Phase)

Once you confirm orders work end-to-end:

### Phase 2: Add Authentication (in existing backend)
- Add `src/routes/auth.js`
- Create customers table
- Add JWT token logic
- Update mobile app auth services

### Phase 3: Add Menu (in existing backend)
- Add `src/routes/menu.js`
- Create menu_items table
- Update mobile app menu services

### Phase 4: Add Payments (in existing backend)
- Add `src/routes/payments.js`
- Integrate payment gateway
- Update mobile app payment services

### Phase 5: Add Delivery (in existing backend)
- Add `src/routes/delivery.js`
- Create delivery_addresses table
- Update mobile app delivery services

---

## Summary

**Question:** Where to add auth/endpoints?
**Answer:** Same backend folder! Don't create separate services.

**Structure:**
```
One backend (e:\resturents how do they work\web_application\backend)
├─ One Node.js app
├─ One Express server
├─ One PostgreSQL database
├─ One Temporal server
└─ All routes in one place
```

**Today:** Test orders only
**Tomorrow:** Add auth to same backend
**Next week:** Add menu/payments/delivery to same backend

All in one place = cleaner, easier, better! ✅
