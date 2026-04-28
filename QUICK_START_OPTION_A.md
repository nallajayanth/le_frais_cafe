# ⚡ QUICK START: Option A - Test Order Flow (Today!)

## 🎯 Goal
Get the complete order flow working end-to-end:
- Mobile app ↔ Backend API ↔ Temporal ↔ Database

---

## 📋 Prerequisites Checklist

Before starting, verify you have:

- ✅ Docker installed and running
- ✅ Node.js 18+ installed
- ✅ Flutter SDK installed
- ✅ Backend folder: `e:\resturents how do they work\web_application\backend`
- ✅ Mobile folder: `e:\Le frais\le_frais_mobile_application`
- ✅ Terminal/PowerShell access

---

## 🚀 Step-by-Step (Copy-Paste Commands)

### ⏱️ Total Time: ~15 minutes

---

## Phase 1: Start Docker (First Time Only)

**Terminal:** PowerShell (can be in any folder)

```powershell
cd "e:\resturents how do they work\web_application\backend"
docker-compose up -d
```

**Wait 30 seconds**, then verify:

```powershell
docker-compose ps
```

✅ **Expected Output:**
```
NAME                    COMMAND                  STATE
le-frais-app-postgres   "docker-entrypoint..."   Up
temporal-postgres       "docker-entrypoint..."   Up
temporal                "docker-entrypoint..."   Up
temporal-ui             "node /app/server..."    Up
```

If all show "Up", continue! ✅

---

## Phase 2: Start Backend API (Terminal 1)

**Open NEW PowerShell Terminal**

```powershell
cd "e:\resturents how do they work\web_application\backend"
npm install
npm run dev:api
```

⏳ **Wait for message like:**
```
✅ Le Frais API running on http://localhost:4000
Health: http://localhost:4000/health
Orders: http://localhost:4000/api/orders
```

**Keep this terminal OPEN** ← Don't close it!

---

## Phase 3: Start Temporal Worker (Terminal 2)

**Open ANOTHER NEW PowerShell Terminal**

```powershell
cd "e:\resturents how do they work\web_application\backend"
npm run dev:worker
```

✅ **Should show:**
```
Temporal worker started
```

**Keep this terminal OPEN** ← Don't close it!

---

## Phase 4: Start Mobile App (Terminal 3)

**Open ANOTHER NEW PowerShell Terminal**

```powershell
cd "e:\Le frais\le_frais_mobile_application"
flutter run -d chrome
```

✅ **Should see Chrome browser open with app**

**Keep this terminal OPEN** ← Don't close it!

---

## ✅ Verification: Everything Running?

### Check 1: API is responding
```powershell
# Run in any terminal
curl http://localhost:4000/health
```

Should return: `{"status":"ok","db":"connected"}`

### Check 2: Temporal UI is accessible
```
Open in browser: http://localhost:8233
Should show Temporal dashboard
```

### Check 3: Mobile app is connected
```
Chrome browser should show Flutter app
App should not show connection errors
```

### Check 4: All 4 processes running
```
✅ Docker: docker-compose ps (all "Up")
✅ Terminal 1: npm run dev:api (showing "running on 4000")
✅ Terminal 2: npm run dev:worker (showing "started")
✅ Terminal 3: Flutter app (Chrome browser showing app)
```

If all 4 are running → **You're ready to test!** 🎉

---

## 🧪 Test 1: Create Order from API

**Run in any PowerShell terminal (not the 3 running ones):**

```powershell
$orderData = @{
    orderType = "Delivery"
    items = @(
        @{
            itemId = 1
            name = "Biryani"
            price = 250
            quantity = 2
            isVeg = $false
        }
    )
    customerName = "John Doe"
    phone = "9876543210"
    deliveryAddress = "123 Main Street"
} | ConvertTo-Json

curl -X POST "http://localhost:4000/api/orders" `
  -Headers @{"Content-Type"="application/json"} `
  -Body $orderData
```

✅ **Should return something like:**
```json
{"orderId":"550e8400-e29b-41d4-a716-446655440000"}
```

**Copy this orderId** - you'll need it!

---

## 🧪 Test 2: Check Order in Database

```powershell
curl "http://localhost:4000/api/orders"
```

✅ **Should show your order** in a JSON list

---

## 🧪 Test 3: Monitor Workflow in Temporal UI

**Open:** http://localhost:8233

You should see:
- ✅ Workflow execution with your orderId
- ✅ Each activity executed
- ✅ Status: RUNNING or COMPLETED
- ✅ Timeline of events

---

## 🧪 Test 4: View Order Status

```powershell
# Replace with your actual orderId
curl "http://localhost:4000/api/orders/{orderId}"
```

Example:
```powershell
curl "http://localhost:4000/api/orders/550e8400-e29b-41d4-a716-446655440000"
```

---

## 🎯 Testing Checklist

- [ ] Docker containers all running (`docker-compose ps`)
- [ ] API server running on :4000
- [ ] Temporal worker running
- [ ] Flutter app loaded in Chrome
- [ ] API health check passes
- [ ] Created test order via API
- [ ] Order appears in database
- [ ] Workflow visible in Temporal UI
- [ ] Can retrieve order status

If all checkmarks complete → **Testing successful!** ✅

---

## 📊 What's Happening Behind the Scenes

```
1. You create order (curl or app)
2. API validates and calls Temporal
3. Temporal saves workflow state
4. Temporal schedules activity
5. Worker picks up activity
6. Worker executes activity (saves to DB)
7. Workflow completes
8. You see order in database
9. Temporal UI shows execution history
```

Total time: ~2-3 seconds

---

## 🛑 When to Stop Testing

You've successfully tested when:
- ✅ Order created successfully
- ✅ Order saved in database
- ✅ Workflow visible in Temporal UI
- ✅ Can retrieve order status
- ✅ No errors in terminals

**Result:** Complete order pipeline working! 🎉

---

## ❌ Common Issues & Fixes

### Issue: "Connection refused on :4000"
```
❌ Problem: API not running
✅ Fix: Check Terminal 1, restart: npm run dev:api
```

### Issue: "docker-compose: command not found"
```
❌ Problem: Docker not installed properly
✅ Fix: Reinstall Docker Desktop
```

### Issue: "Port 4000 already in use"
```
❌ Problem: Another app using :4000
✅ Fix: Kill process: lsof -i :4000 | kill -9 PID
```

### Issue: "Workflow not showing in Temporal UI"
```
❌ Problem: Worker not running
✅ Fix: Check Terminal 2, restart: npm run dev:worker
```

### Issue: "Database connection error"
```
❌ Problem: PostgreSQL container not running
✅ Fix: docker-compose restart app-postgres
```

---

## 🧹 When Done: Cleanup

**To STOP everything:**

```powershell
# Terminal 1: Stop API
# Press Ctrl+C

# Terminal 2: Stop Worker
# Press Ctrl+C

# Terminal 3: Stop Flutter
# Press Ctrl+C

# Keep Docker running OR stop it:
docker-compose down
# (This only removes containers, not data)
```

**To START again next time:**
```powershell
# Just run Phase 2, 3, 4 again
# Skip Phase 1 (unless you need to reset)
```

---

## 📝 Next: After Testing Works

Once you confirm everything works:

1. ✅ You've proven Temporal works perfectly
2. ✅ You've proven backend is production-ready
3. ✅ You've proven mobile app can connect

**Next step:** Add authentication endpoints to the same backend folder

---

## 🎯 Remember

```
This backend folder:
├─ Has Temporal configured ✅
├─ Has Docker setup ✅
├─ Has Order workflow ✅
└─ Is ready for more features ✅

You're NOT creating anything new!
Just testing what exists.
```

**Ready? Start Phase 1!** 🚀
