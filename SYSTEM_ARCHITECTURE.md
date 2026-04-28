# 🎯 Complete System Architecture & Setup Guide

## The Big Picture

```
                         ┌─────────────────────────────┐
                         │   Temporal UI Dashboard     │
                         │   (localhost:8233)          │
                         │  - View all workflows       │
                         │  - See order execution      │
                         │  - Monitor retries          │
                         └──────────────┬──────────────┘
                                        │
┌──────────────────────────────────────────────────────────────────┐
│                       YOUR SYSTEM (3 Processes)                  │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  🐳 DOCKER COMPOSE (Runs Once - Infrastructure)                │
│     ├─ temporal-postgres (DB for Temporal)                      │
│     ├─ app-postgres (DB for app data)                           │
│     ├─ temporal-server (Workflow engine - Port 7233)            │
│     └─ temporal-ui (Dashboard - Port 8233)                      │
│                                                                  │
│  ✅ Terminal 1: npm run dev:api (Node.js API)                  │
│     └─ Listens on http://localhost:4000                         │
│     └─ Receives requests from mobile app                        │
│     └─ Starts Temporal workflows                                │
│                                                                  │
│  ✅ Terminal 2: npm run dev:worker (Temporal Worker)           │
│     └─ Executes workflow activities                             │
│     └─ Updates database                                         │
│     └─ Sends status updates                                     │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                            ▲
         (REST API calls to port 4000)
                            │
┌──────────────────────────────────────────────────────────────────┐
│         FLUTTER MOBILE APP (Your Customer App)                   │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ✅ Menu Screen         → GET /api/orders                       │
│  ✅ Cart Screen         → Uses local CartProvider               │
│  ✅ Checkout           → POST /api/orders                       │
│  ✅ Order Tracker      → WebSocket for real-time updates        │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## ⚙️ SETUP: Step by Step

### ❶ START DOCKER (First Time Only)

```bash
cd e:\resturents how do they work\web_application\backend

docker-compose up -d

# Wait 30 seconds for containers to start
# Then check:
docker-compose ps

# Should show:
# ✅ le-frais-app-postgres
# ✅ temporal-postgres  
# ✅ temporal
# ✅ temporal-ui
```

**Verify Temporal is working:**
```bash
# Check API health
curl http://localhost:4000/health

# Should return:
# {"status":"ok","db":"connected","timestamp":"2026-04-27T..."}

# Open Temporal UI
# http://localhost:8233
```

### ❷ START NODE.JS API (Terminal 1)

```bash
cd e:\resturents how do they work\web_application\backend

npm install

npm run dev:api

# Should show:
# ✅ Le Frais API running on http://localhost:4000
# Health: http://localhost:4000/health
# Orders: http://localhost:4000/api/orders

# KEEP THIS RUNNING
```

### ❸ START TEMPORAL WORKER (Terminal 2)

```bash
cd e:\resturents how do they work\web_application\backend

npm run dev:worker

# Should show:
# Temporal worker started

# KEEP THIS RUNNING
```

### ❹ START FLUTTER APP (Terminal 3)

```bash
cd e:\Le frais\le_frais_mobile_application

flutter run -d chrome

# App connects to: http://localhost:4000
```

---

## ✅ What Each Component Does

### Node.js API (`npm run dev:api`)
- **Receives** order requests from mobile app
- **Validates** order data
- **Starts** Temporal workflow
- **Returns** order ID to client
- **Port:** 4000

### Temporal Worker (`npm run dev:worker`)
- **Executes** workflow activities
- **Updates** database with order status
- **Sends** real-time notifications
- **Handles** retries automatically
- **Logs** everything to Temporal UI

### Temporal Server (Docker)
- **Stores** workflow state durably
- **Tracks** all activities
- **Provides** UI dashboard
- **Guarantees** no orders are lost
- **Port:** 7233 (API), 8233 (UI)

### PostgreSQL (Docker)
- **Database:** app_db (port 5434) → App data
- **Database:** temporal (port 5433) → Temporal state

---

## 🔄 How an Order Flows Through the System

### Step-by-step execution:

```
1️⃣  MOBILE APP
    └─ Customer clicks "Place Order"
    └─ App sends: POST http://localhost:4000/api/orders
    
2️⃣  NODE.JS API (Port 4000)
    └─ Receives order payload
    └─ Validates: orderId, items, orderType
    └─ Creates orderId (UUID)
    └─ Calls Temporal client.start(orderWorkflow, ...)
    └─ Returns 201 {orderId: "abc-123"}
    
3️⃣  TEMPORAL SERVER (Port 7233)
    └─ Receives workflow start request
    └─ Creates workflow execution
    └─ Saves state to temporal-postgres
    └─ Schedules first activity
    └─ Visible in: http://localhost:8233
    
4️⃣  TEMPORAL WORKER (Node.js process)
    └─ Picks up activity from task queue
    └─ Runs activity (e.g., createOrder)
    └─ Updates app_db with order
    └─ Activity completes
    
5️⃣  TEMPORAL WORKFLOW CONTINUES
    └─ Workflow waits for signal (setStatus)
    └─ Mobile app can call: POST /api/orders/{id}/status
    └─ This signals workflow to advance
    └─ Workflow executes next activity
    
6️⃣  DATABASE (PostgreSQL)
    └─ Order saved in orders table
    └─ Order items saved in order_items table
    └─ Workflow state saved in temporal tables
    
7️⃣  MONITORING
    └─ Temporal UI shows complete execution history
    └─ Each activity logged with timestamp
    └─ Can replay entire execution for debugging
```

---

## 📊 Monitoring URLs

| Component | URL | Purpose |
|-----------|-----|---------|
| **API Health** | http://localhost:4000/health | Check if API running |
| **Temporal UI** | http://localhost:8233 | View workflows & activities |
| **Orders List** | http://localhost:4000/api/orders | List all orders |
| **Docker Status** | `docker-compose ps` | Check all containers |

---

## 🐛 Troubleshooting

### Problem: "Can't connect to localhost:4000"
```
Solution:
1. Check if API is running: npm run dev:api in Terminal 1
2. Check if it's in the backend folder: e:\resturents how do they work\web_application\backend
3. Check: curl http://localhost:4000/health
```

### Problem: "Worker not picking up tasks"
```
Solution:
1. Check if worker started: npm run dev:worker in Terminal 2
2. Check if Temporal server running: docker-compose ps
3. Check worker terminal for errors
```

### Problem: "Temporal UI shows no workflows"
```
Solution:
1. Check if Temporal running: docker-compose ps
2. Check if you created an order: POST /api/orders
3. Check if worker running to execute activities
```

### Problem: "Database connection failed"
```
Solution:
1. Check Docker containers: docker-compose ps
2. Check app-postgres running on port 5434
3. Check temporal-postgres running on port 5433
```

---

## 🚀 QUICK START COMMANDS

**First time ever:**
```bash
cd e:\resturents how do they work\web_application\backend
docker-compose up -d
npm install
```

**Every day after:**
```bash
# Terminal 1
cd e:\resturents how do they work\web_application\backend
npm run dev:api

# Terminal 2
cd e:\resturents how do they work\web_application\backend
npm run dev:worker

# Terminal 3
cd e:\Le frais\le_frais_mobile_application
flutter run -d chrome
```

---

## 📋 Checklist Before Running

- [ ] Docker installed and running
- [ ] Docker Compose file exists: `docker-compose.yml`
- [ ] Node.js 18+ installed
- [ ] npm packages installed: `npm install`
- [ ] PostgreSQL containers started: `docker-compose ps`
- [ ] Terminal 1: API starting on port 4000
- [ ] Terminal 2: Worker started
- [ ] Terminal 3: Flutter app running
- [ ] Can access: http://localhost:8233

---

## 🎯 What's Connected

✅ **Mobile App → Node.js API**
- Via REST API on port 4000

✅ **Node.js API → Temporal Server**
- Via Temporal client library

✅ **Temporal Worker → Database**
- Via PostgreSQL connections

✅ **Everything → Docker**
- All infrastructure in docker-compose.yml

❌ **Nothing runs separately**
- All connected through your existing backend

---

## 🔐 Important Notes

1. **DO NOT** create a new Temporal setup in the mobile project
2. **DO NOT** run `temporal start-dev` separately
3. **DO NOT** run multiple backends
4. **DO** use your existing backend folder
5. **DO** run API + Worker from same backend folder
6. **DO** keep Docker containers running in background

---

## Final Summary

```
Your Backend System:
├─ Docker Compose ............. Infrastructure (runs once)
├─ npm run dev:api ............ Node.js API (Terminal 1)
├─ npm run dev:worker ......... Temporal Worker (Terminal 2)
└─ Flutter App ................ Mobile client (Terminal 3)

Total processes: 4 (1 docker-compose + 3 npm/flutter)
Total terminals: 3 (after docker-compose starts)

STOP order:
1. Stop Flutter (Ctrl+C in Terminal 3)
2. Stop Worker (Ctrl+C in Terminal 2)
3. Stop API (Ctrl+C in Terminal 1)
4. Stop Docker (optional, can leave running)
```

---

**Status:** ✅ Ready to implement
**Last Updated:** April 27, 2026
