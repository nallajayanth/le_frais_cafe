# Customer Mobile App - Backend Integration Guide

## Overview

This document provides a comprehensive guide for integrating the **Le Frais Customer Mobile App** with the Node.js backend API using Temporal workflows for orchestration.

## Architecture

```
Customer Mobile App (Flutter)
        ↓
   API Service Layer
        ↓
   Node.js REST API
        ↓
   Temporal Workflows (Orchestration)
        ↓
   Activities (Individual Tasks)
        ↓
   Database + External Services
```

---

## Project Structure

### Mobile App (`lib/`)

#### Services Layer (`lib/services/`)
- **`api/api_client.dart`** - Base HTTP client with authentication
- **`api/auth_service.dart`** - Handle login/signup/profile
- **`api/menu_service.dart`** - Fetch menu items and categories
- **`api/order_service.dart`** - Create and track orders
- **`api/payment_service.dart`** - Process payments and discounts
- **`api/delivery_service.dart`** - Manage delivery addresses
- **`websocket_service.dart`** - Real-time order tracking

#### State Management (`lib/providers/`)
- **`auth_provider.dart`** - Authentication state
- **`menu_provider.dart`** - Menu data and filtering
- **`order_provider.dart`** - Order creation and tracking
- **`payment_provider.dart`** - Payment state
- **`delivery_provider.dart`** - Delivery addresses
- **`cart_provider.dart`** - Shopping cart (existing)

### Backend (`temporal/`)

#### Workflows
- **`workflows/customerOrderWorkflow.js`** - Main order processing workflow

#### Activities
- **`activities/customerOrderActivities.js`** - Individual workflow tasks

---

## API Endpoints Reference

### Authentication
```
POST   /api/auth/customer/register    - Sign up
POST   /api/auth/customer/login       - Login
POST   /api/auth/refresh              - Refresh token
POST   /api/auth/logout               - Logout
```

### Customer Profile
```
GET    /api/customer/profile          - Get profile
PUT    /api/customer/profile          - Update profile
```

### Menu
```
GET    /api/menu                      - Get all items
GET    /api/menu/categories           - Get categories
GET    /api/menu/search?query=        - Search items
GET    /api/menu/{itemId}             - Get item details
```

### Orders
```
POST   /api/orders                    - Create order
GET    /api/orders                    - Get order history
GET    /api/orders/{orderId}          - Get order details
GET    /api/orders/{orderId}/status   - Get order status
POST   /api/orders/{orderId}/cancel   - Cancel order
GET    /api/orders/{orderId}/receipt  - Download receipt
```

### Payments
```
POST   /api/payments/initiate         - Initiate payment
POST   /api/payments/verify           - Verify payment
GET    /api/payments/{paymentId}/status - Check status
POST   /api/orders/{orderId}/apply-discount - Apply discount
GET    /api/discounts                 - Get available discounts
```

### Delivery
```
GET    /api/customer/addresses        - Get saved addresses
POST   /api/customer/addresses        - Create address
PUT    /api/customer/addresses/{id}   - Update address
DELETE /api/customer/addresses/{id}   - Delete address
GET    /api/delivery/estimate         - Get delivery cost/time
```

---

## Temporal Workflows Explained

### Customer Order Workflow

**Purpose**: Orchestrates the complete order lifecycle from creation to completion.

**Flow**:

```
1. Order Creation (Customer submits order)
   ↓
2. Validate Order (Check items available)
   ↓
3. Payment Processing (Charge customer's payment method)
   ↓
4. Create KDS Order (Send to Kitchen Display System)
   ↓
5. Wait for Preparation (Monitor kitchen progress)
   ↓
6. Order Ready (Notify customer)
   ↓
7. Delivery/Pickup (Handle based on order type)
   ↓
8. Complete Order (Finalize and archive)
```

### Why Temporal?

1. **Reliability** - Automatically retries failed tasks
2. **Visibility** - Track order progress in real-time
3. **Scalability** - Handle thousands of concurrent orders
4. **Audit Trail** - Complete history of order processing
5. **Compensation** - Easy to handle refunds and cancellations

### Workflow Activities

| Activity | Purpose | Timeout |
|----------|---------|---------|
| `validateOrderActivity` | Verify items and inventory | 5 sec |
| `processPaymentActivity` | Charge payment method | 30 sec |
| `createKdsOrderActivity` | Send to kitchen | 2 sec |
| `updateOrderStatusActivity` | Update DB & notify | 3 sec |
| `notifyCustomerActivity` | Send notifications | 5 sec |
| `trackDeliveryActivity` | Manage delivery | 2 hours |
| `completeOrderActivity` | Finalize order | 5 sec |

---

## Integration Steps

### Step 1: Set Up Backend Environment

```bash
# Install Temporal CLI
temporal start-dev

# Verify Temporal is running
# UI: http://localhost:8233
# gRPC: localhost:7233

# Start Node.js backend
npm install
npm start

# Verify API health
curl http://localhost:4000/api/health
```

### Step 2: Configure Mobile App

#### 1. Update `pubspec.yaml`

```yaml
dependencies:
  # HTTP & API
  http: ^1.0.0
  dio: ^5.0.0
  
  # Storage
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.0.0
  
  # State Management
  provider: ^6.0.0
  
  # WebSocket
  web_socket_channel: ^3.0.0
  
  # Other
  intl: ^0.19.0
```

#### 2. Initialize Services in `main.dart`

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API client
  final apiClient = ApiClient();
  await apiClient.initialize();
  
  // Create services
  final authService = AuthService(apiClient: apiClient);
  final menuService = MenuService(apiClient: apiClient);
  final orderService = OrderService(apiClient: apiClient);
  final paymentService = PaymentService(apiClient: apiClient);
  final deliveryService = DeliveryAddressService(apiClient: apiClient);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: authService),
        ),
        ChangeNotifierProvider(
          create: (_) => MenuProvider(menuService: menuService),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(orderService: orderService),
        ),
        ChangeNotifierProvider(
          create: (_) => PaymentProvider(paymentService: paymentService),
        ),
        ChangeNotifierProvider(
          create: (_) => DeliveryProvider(deliveryService: deliveryService),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

### Step 3: Connect Screens to APIs

#### Example: Menu Screen

```dart
class MenuScreen extends StatefulWidget {
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    // Load menu data
    Future.microtask(() {
      context.read<MenuProvider>().loadMenuItems();
      context.read<MenuProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, _) {
        if (menuProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (menuProvider.error != null) {
          return ErrorWidget(message: menuProvider.error!);
        }

        return ListView(
          children: menuProvider.filteredMenuItems
              .map((item) => MenuItemTile(item: item))
              .toList(),
        );
      },
    );
  }
}
```

#### Example: Order Checkout & Temporal Trigger

```dart
Future<void> _submitOrder() async {
  final cart = context.read<CartProvider>();
  final orderProvider = context.read<OrderProvider>();
  final paymentProvider = context.read<PaymentProvider>();

  // Create order (triggers Temporal workflow on backend)
  final success = await orderProvider.createOrder(
    orderType: _selectedOrderType,
    items: cart.items.map((e) => OrderItem(
      itemId: e.id,
      quantity: e.qty,
      price: e.price,
    )).toList(),
    deliveryAddressId: _selectedAddressId,
    specialInstructions: _specialInstructions,
  );

  if (success && orderProvider.currentOrder != null) {
    // Initiate payment
    final paymentSuccess = await paymentProvider.initiatePayment(
      orderId: orderProvider.currentOrder!.id,
      amount: orderProvider.currentOrder!.total,
      paymentMethod: _selectedPaymentMethod,
    );

    if (paymentSuccess) {
      // Navigate to order tracking
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderTrackerScreen(
            orderId: orderProvider.currentOrder!.id,
          ),
        ),
      );
    }
  }
}
```

### Step 4: Real-Time Order Tracking

```dart
class OrderTrackerScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackerScreen({required this.orderId});

  @override
  State<OrderTrackerScreen> createState() => _OrderTrackerScreenState();
}

class _OrderTrackerScreenState extends State<OrderTrackerScreen> {
  late WebSocketService _wsService;

  @override
  void initState() {
    super.initState();
    _setupWebSocket();
  }

  Future<void> _setupWebSocket() async {
    _wsService = WebSocketService();
    final token = context.read<AuthProvider>().currentUser?.token;
    
    if (token != null) {
      await _wsService.connectToOrder(widget.orderId, token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        return ListenableBuilder(
          listenable: _wsService,
          builder: (context, _) {
            final status = _wsService.lastStatusUpdate;

            return Column(
              children: [
                // Display order timeline
                OrderTimeline(
                  status: orderProvider.currentOrderStatus?.status ?? 'PENDING',
                  estimatedTime: orderProvider.currentOrderStatus?.estimatedTimeRemaining ?? 0,
                ),
                
                // Display real-time updates
                if (status != null)
                  StatusCard(
                    message: status['message'],
                    timestamp: status['timestamp'],
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _wsService.disconnect();
    super.dispose();
  }
}
```

---

## Error Handling

### API Error Handling

```dart
try {
  await authProvider.login(email: email, password: password);
} on AuthException catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Login failed: ${e.message}')),
  );
}
```

### Network Retry Logic

The API client automatically:
- Retries failed requests (configurable)
- Refreshes expired tokens
- Handles connection timeouts
- Converts HTTP errors to custom exceptions

---

## Security Best Practices

1. **Token Storage**: Tokens stored in secure storage (encrypted)
2. **Token Refresh**: Automatic token refresh before expiration
3. **HTTPS Only**: Always use HTTPS in production
4. **Input Validation**: Validate all user inputs on client and server
5. **Payment Security**: Never store card details; use payment gateway APIs

---

## Testing

### Unit Tests

```dart
test('Login should return auth response', () async {
  final mockApiClient = MockApiClient();
  final authService = AuthService(apiClient: mockApiClient);
  
  final result = await authService.login(
    email: 'test@example.com',
    password: 'password123',
  );
  
  expect(result.customerId, isNotEmpty);
});
```

### Integration Tests

```dart
test('Complete order flow', () async {
  // 1. Login
  // 2. Load menu
  // 3. Create order
  // 4. Process payment
  // 5. Track order
  // 6. Complete order
});
```

---

## Temporal Monitoring

### View Workflows

```bash
# List all order workflows
temporal workflow list --query "WorkflowType='customerOrderWorkflow'"

# Get workflow details
temporal workflow describe -w <workflow-id>

# View execution history
temporal workflow show -w <workflow-id>
```

### UI Dashboard

- URL: `http://localhost:8233`
- View all workflows and their status
- Monitor activity execution
- Debug failures

---

## Performance Optimization

1. **Caching**: Menu items cached for 5 minutes
2. **Pagination**: Order history paginated (10 items per page)
3. **Image Optimization**: Lazy load images
4. **Connection Pooling**: Reuse HTTP connections
5. **WebSocket**: Single WebSocket per app session

---

## Deployment Checklist

- [ ] Set production API URL in `ApiClient`
- [ ] Enable HTTPS/SSL certificates
- [ ] Configure payment gateway (Stripe, Razorpay, etc.)
- [ ] Set up Firebase for push notifications
- [ ] Deploy Temporal to production
- [ ] Configure database backups
- [ ] Set up monitoring and logging
- [ ] Load testing (1000+ concurrent orders)
- [ ] Security audit
- [ ] Beta testing with real users

---

## Troubleshooting

### Issue: WebSocket connection failed
```
Solution: Ensure backend is running and WebSocket server is enabled
```

### Issue: Order not appearing in KDS
```
Solution: Check Temporal workflow execution; verify KDS service is running
```

### Issue: Payment processing timeout
```
Solution: Check payment gateway API; verify network connectivity
```

---

## Next Steps

1. Build remaining screens (Auth screens, Order tracking screens)
2. Set up Firebase Cloud Messaging for push notifications
3. Implement QR code scanning for dine-in orders
4. Add loyalty points system
5. Implement offline mode
6. Set up analytics tracking
7. Conduct load testing
8. Deploy to production

---

## Support & Documentation

- Backend API Docs: `http://localhost:4000/api/docs`
- Temporal Docs: https://docs.temporal.io
- Flutter Provider: https://pub.dev/packages/provider
- Socket.io: https://socket.io/docs

---

**Last Updated**: April 27, 2026
**Version**: 1.0.0
