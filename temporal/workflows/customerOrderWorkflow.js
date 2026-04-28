/**
 * Customer Order Processing Workflow
 * 
 * This Temporal workflow orchestrates the complete customer order lifecycle:
 * 1. Order Creation
 * 2. Payment Processing
 * 3. Kitchen Preparation
 * 4. Delivery (if applicable)
 * 5. Completion
 */

const { proxyActivities, defineSignal, setHandler, workflow } = require('@temporalio/workflow');

// Import activities
const {
  validateOrderActivity,
  processPaymentActivity,
  createKdsOrderActivity,
  updateOrderStatusActivity,
  notifyCustomerActivity,
  trackDeliveryActivity,
  completeOrderActivity,
} = require('./activities');

// Proxy activities
const activities = proxyActivities({
  validateOrderActivity,
  processPaymentActivity,
  createKdsOrderActivity,
  updateOrderStatusActivity,
  notifyCustomerActivity,
  trackDeliveryActivity,
  completeOrderActivity,
});

// Define signals for updates
const orderStatusSignal = defineSignal('orderStatus');
const paymentStatusSignal = defineSignal('paymentStatus');

/**
 * Main Customer Order Workflow
 */
async function customerOrderWorkflow(orderData) {
  let orderStatus = 'PENDING';
  let paymentStatus = 'PENDING';
  let kdsOrderId = null;

  // Set up signal handlers
  setHandler(orderStatusSignal, (newStatus) => {
    orderStatus = newStatus;
  });

  setHandler(paymentStatusSignal, (newStatus) => {
    paymentStatus = newStatus;
  });

  try {
    // Step 1: Validate Order
    console.log(`[Workflow] Validating order: ${orderData.orderId}`);
    const validationResult = await activities.validateOrderActivity({
      orderId: orderData.orderId,
      items: orderData.items,
      customerId: orderData.customerId,
    });

    if (!validationResult.isValid) {
      throw new Error(`Order validation failed: ${validationResult.message}`);
    }

    // Step 2: Update order status to PAYMENT_PENDING
    await activities.updateOrderStatusActivity({
      orderId: orderData.orderId,
      status: 'PAYMENT_PENDING',
      message: 'Processing payment...',
    });

    // Notify customer about payment
    await activities.notifyCustomerActivity({
      customerId: orderData.customerId,
      orderId: orderData.orderId,
      type: 'PAYMENT_INITIATED',
      message: 'Your payment is being processed',
    });

    // Step 3: Process Payment
    console.log(`[Workflow] Processing payment for order: ${orderData.orderId}`);
    const paymentResult = await activities.processPaymentActivity({
      orderId: orderData.orderId,
      amount: orderData.total,
      paymentMethod: orderData.paymentMethod,
      customerId: orderData.customerId,
    });

    if (!paymentResult.success) {
      throw new Error(`Payment failed: ${paymentResult.message}`);
    }

    // Update order status to PAYMENT_COMPLETED
    await activities.updateOrderStatusActivity({
      orderId: orderData.orderId,
      status: 'PAYMENT_COMPLETED',
      message: 'Payment successful',
    });

    // Notify customer about successful payment
    await activities.notifyCustomerActivity({
      customerId: orderData.customerId,
      orderId: orderData.orderId,
      type: 'PAYMENT_SUCCESS',
      message: 'Payment confirmed. Your order is being prepared.',
    });

    // Step 4: Create KDS (Kitchen Display System) Order
    console.log(`[Workflow] Creating KDS order: ${orderData.orderId}`);
    kdsOrderId = await activities.createKdsOrderActivity({
      orderId: orderData.orderId,
      items: orderData.items,
      tableNumber: orderData.tableNumber,
      specialInstructions: orderData.specialInstructions,
    });

    // Update order status to PREPARING
    await activities.updateOrderStatusActivity({
      orderId: orderData.orderId,
      status: 'PREPARING',
      message: 'Your order is being prepared',
      estimatedTime: orderData.estimatedTime,
    });

    // Notify customer that kitchen started
    await activities.notifyCustomerActivity({
      customerId: orderData.customerId,
      orderId: orderData.orderId,
      type: 'PREPARING',
      message: `Your order is being prepared. Est. time: ${orderData.estimatedTime} mins`,
    });

    // Step 5: Wait for preparation (simulated by timeout or activity result)
    // In real scenario, KDS would signal when food is ready
    await new Promise((resolve) => {
      const timeout = setTimeout(() => {
        resolve();
      }, orderData.estimatedTime * 60 * 1000); // Convert minutes to milliseconds
    });

    // Step 6: Update order status to READY
    await activities.updateOrderStatusActivity({
      orderId: orderData.orderId,
      status: 'READY',
      message: 'Your order is ready',
    });

    // Notify customer that order is ready
    await activities.notifyCustomerActivity({
      customerId: orderData.customerId,
      orderId: orderData.orderId,
      type: 'READY',
      message:
        orderData.orderType === 'delivery'
          ? 'Your order is ready and will be delivered soon'
          : orderData.orderType === 'pickup'
            ? 'Your order is ready for pickup'
            : 'Your order is ready. Enjoy your meal!',
    });

    // Step 7: Handle delivery if applicable
    if (orderData.orderType === 'delivery') {
      console.log(`[Workflow] Starting delivery for order: ${orderData.orderId}`);

      const deliveryResult = await activities.trackDeliveryActivity({
        orderId: orderData.orderId,
        deliveryAddress: orderData.deliveryAddress,
        customerId: orderData.customerId,
      });

      if (!deliveryResult.success) {
        throw new Error(`Delivery failed: ${deliveryResult.message}`);
      }

      // Update to DELIVERED
      await activities.updateOrderStatusActivity({
        orderId: orderData.orderId,
        status: 'DELIVERED',
        message: 'Your order has been delivered',
      });

      await activities.notifyCustomerActivity({
        customerId: orderData.customerId,
        orderId: orderData.orderId,
        type: 'DELIVERED',
        message: 'Your order has been delivered. Thank you!',
      });
    } else {
      // For dine-in, no additional action needed
      // For pickup, customer will pick up
    }

    // Step 8: Complete Order
    console.log(`[Workflow] Completing order: ${orderData.orderId}`);
    await activities.completeOrderActivity({
      orderId: orderData.orderId,
      completedAt: new Date().toISOString(),
    });

    // Update final status
    await activities.updateOrderStatusActivity({
      orderId: orderData.orderId,
      status: 'COMPLETED',
      message: 'Order completed',
    });

    // Final notification
    await activities.notifyCustomerActivity({
      customerId: orderData.customerId,
      orderId: orderData.orderId,
      type: 'COMPLETED',
      message: 'Thank you for your order! We hope you enjoyed it.',
    });

    return {
      success: true,
      orderId: orderData.orderId,
      message: 'Order processed successfully',
    };
  } catch (error) {
    console.error(`[Workflow] Error processing order: ${error.message}`);

    // Update order status to FAILED
    await activities.updateOrderStatusActivity({
      orderId: orderData.orderId,
      status: 'FAILED',
      message: `Order processing failed: ${error.message}`,
    });

    // Notify customer about failure
    await activities.notifyCustomerActivity({
      customerId: orderData.customerId,
      orderId: orderData.orderId,
      type: 'FAILED',
      message: `Your order could not be processed. Reason: ${error.message}`,
    });

    throw error;
  }
}

module.exports = { customerOrderWorkflow };
