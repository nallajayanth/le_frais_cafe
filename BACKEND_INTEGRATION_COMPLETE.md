# 📱 Complete Backend Integration Guide

## ✅ What's Connected to Backend

### Already Updated:
- ✅ **main.dart** - All 6 providers initialized
- ✅ **MenuProvider** - Fetches from `/api/menu`
- ✅ **OrderProvider** - Manages order lifecycle
- ✅ **AuthProvider** - Handles authentication (not used yet)
- ✅ **PaymentProvider** - Handles payments
- ✅ **DeliveryProvider** - Manages delivery addresses
- ✅ **WebSocketService** - Real-time order updates

---

## 🎯 Screen Integration Checklist

### Onboarding Screen
- [x] Shows first screen
- [ ] Navigate to Menu after onboarding

### Menu Screen
- [x] Uses MenuProvider to fetch items
- [x] Shows loading state
- [x] Displays categories from backend
- [x] Add to cart functionality
- [ ] Connect to backend fully

### Cart Screen
- [x] Shows items added
- [ ] Calculate totals from items
- [ ] Show checkout button

### Checkout Screen
- [ ] Integrate OrderProvider
- [ ] Create order on backend
- [ ] Show order confirmation
- [ ] Navigate to Order Tracker

### Order Tracker Screen  
- [x] Added `orderId` parameter
- [x] Uses OrderProvider
- [x] Fetches real-time updates
- [x] Shows order progress
- [ ] Connect WebSocket for live updates

### Order History Screen
- [ ] Fetch from `/api/orders`
- [ ] Show list of orders
- [ ] Filter by status
- [ ] Allow reorder

### Delivery Screen
- [ ] Use DeliveryProvider
- [ ] Manage addresses
- [ ] Calculate delivery charges

---

## 🔌 API Connections by Screen

### Menu Screen
```dart
// Called on init
context.read<MenuProvider>().loadMenuItems();
context.read<MenuProvider>().loadCategories();
```

### Checkout Screen
```dart
// When user taps "Place Order"
final orderProvider = context.read<OrderProvider>();
await orderProvider.createOrder(
  items: cartItems,
  orderType: 'Delivery',
  deliveryAddress: address,
  paymentMethod: paymentMethod,
);
// Navigate to tracker
Navigator.push(...OrderTrackerScreen(orderId: orderProvider.currentOrder?.id));
```

### Order Tracker
```dart
// On init
context.read<OrderProvider>().loadOrder(orderId);

// Connects to WebSocket automatically
// Real-time status updates via OrderProvider
```

### Order History
```dart
// On init
context.read<OrderProvider>().loadOrderHistory();

// Watch for changes
context.watch<OrderProvider>().orders
```

---

## 📊 Data Flow Diagram

```
┌─ Menu Screen ────────────┐
│                           │
│ MenuProvider             │
│ ├─ categories            │
│ ├─ menuItems             │
│ └─ load...() methods      │
│                           │
│ → GET /api/menu          │
│ → GET /api/menu/categories
└───────────┬──────────────┘
            │ (user adds items)
            ↓
┌─ Cart Screen ────────────┐
│                           │
│ CartProvider             │
│ ├─ items: CartEntry[]    │
│ └─ calculations           │
│                           │
│ (Local state only)        │
└───────────┬──────────────┘
            │ (user checkout)
            ↓
┌─ Checkout Screen ────────┐
│                           │
│ OrderProvider            │
│ PaymentProvider          │
│ DeliveryProvider         │
│                           │
│ → POST /api/orders       │
│ → POST /api/payments     │
│ → GET /api/delivery/... │
└───────────┬──────────────┘
            │ (order created)
            ↓
┌─ Order Tracker ──────────┐
│                           │
│ OrderProvider            │
│ WebSocketService         │
│                           │
│ → GET /api/orders/{id}   │
│ → ws://localhost:4000    │
│ → Real-time updates      │
└───────────┬──────────────┘
            │
            ↓
┌─ Order History ──────────┐
│                           │
│ OrderProvider            │
│                           │
│ → GET /api/orders        │
│ → Filter by status       │
│ → Show all orders        │
└───────────────────────────┘
```

---

## 🛠️ Implementation Steps

### Step 1: Menu Screen (DONE)
- ✅ Added MenuProvider initialization
- ✅ loadMenuItems() on screen load
- ✅ Display categories
- ✅ Add to cart

### Step 2: Cart Screen (READY)
- Already built
- Uses CartProvider
- Calculate subtotal/total

### Step 3: Checkout Screen (NEXT)
Need to:
1. Add DeliveryProvider watch
2. Add PaymentProvider watch
3. Create order on backend
4. Handle response

### Step 4: Order Tracker (NEXT)
Need to:
1. Receive orderId as parameter
2. Fetch order details
3. Connect WebSocket
4. Show live updates

### Step 5: Order History (NEXT)
Need to:
1. Load all orders on init
2. Filter by status
3. Show order cards
4. Allow reorder

---

## 📝 Key Integration Points

### Authentication (Not Yet)
```dart
// Skip for now - testing without auth
// Later: Add AuthProvider.initialize() in main.dart
```

### Menu Loading
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<MenuProvider>().loadMenuItems();
    context.read<MenuProvider>().loadCategories();
  });
}
```

### Order Creation
```dart
final order = await context.read<OrderProvider>().createOrder(
  items: cartItems,
  orderType: selectedOrderType,
  deliveryAddress: address,
);

if (order != null) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => OrderTrackerScreen(orderId: order.id),
    ),
  );
}
```

### Real-time Updates
```dart
// OrderProvider automatically connects WebSocket
// when order is loaded
context.read<OrderProvider>().loadOrder(orderId);

// Watch for changes
context.watch<OrderProvider>().currentOrder.status
```

---

## ✨ Perfect Integration Checklist

- [x] All providers in main.dart
- [x] MenuProvider loads on Menu Screen init
- [ ] Checkout creates order
- [ ] Order Tracker shows real-time updates
- [ ] Order History fetches from backend
- [ ] Cart integrates with checkout
- [ ] Delivery addresses manageable
- [ ] Error handling for all API calls
- [ ] Loading states on all screens
- [ ] Error messages to user

---

## 🚀 Next Steps

1. Update Checkout Screen to create orders
2. Update Order History Screen to fetch from backend
3. Test complete flow:
   - Menu → Cart → Checkout → Order Tracker → History
4. Verify real-time WebSocket updates
5. Test error scenarios

All screens will then be perfectly connected to backend!
