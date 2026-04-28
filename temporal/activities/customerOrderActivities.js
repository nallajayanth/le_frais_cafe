/**
 * Temporal Activities for Customer Order Processing
 * 
 * Activities are the individual tasks that the workflow orchestrates
 */

const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY || 'sk_test_xxx');

/**
 * Validate order items and inventory
 */
async function validateOrderActivity(input) {
  try {
    const { orderId, items, customerId } = input;

    // Check if customer exists
    const customer = await db.collection('customers').findOne({ _id: customerId });
    if (!customer) {
      return { isValid: false, message: 'Customer not found' };
    }

    // Validate each item exists and is in stock
    for (const item of items) {
      const menuItem = await db.collection('menu').findOne({ _id: item.itemId });
      if (!menuItem) {
        return { isValid: false, message: `Item ${item.itemId} not found` };
      }
      if (!menuItem.isAvailable) {
        return { isValid: false, message: `Item ${menuItem.name} is not available` };
      }
    }

    console.log(`[Activity] Order ${orderId} validated successfully`);
    return { isValid: true, message: 'Order validated' };
  } catch (error) {
    console.error(`[Activity] Validation error: ${error.message}`);
    throw error;
  }
}

/**
 * Process payment via payment gateway
 */
async function processPaymentActivity(input) {
  try {
    const { orderId, amount, paymentMethod, customerId } = input;

    // Get order from DB
    const order = await db.collection('orders').findOne({ _id: orderId });
    if (!order) {
      return { success: false, message: 'Order not found' };
    }

    // Get customer payment method
    const customer = await db.collection('customers').findOne({ _id: customerId });

    let paymentResult;

    // Process based on payment method
    if (paymentMethod === 'card' || paymentMethod === 'upi') {
      // Use Stripe for card/UPI payments
      paymentResult = await stripe.paymentIntents.create({
        amount: Math.round(amount * 100), // Convert to cents
        currency: 'inr',
        payment_method: customer.defaultPaymentMethodId,
        confirm: true,
        metadata: {
          orderId: orderId,
          customerId: customerId,
        },
      });

      if (paymentResult.status !== 'succeeded') {
        return { success: false, message: `Payment failed with status: ${paymentResult.status}` };
      }
    } else if (paymentMethod === 'cash') {
      // Cash payments are marked as pending
      paymentResult = {
        status: 'pending',
        id: `cash_${orderId}`,
      };
    }

    // Save payment record
    const payment = {
      _id: paymentResult.id,
      orderId: orderId,
      customerId: customerId,
      amount: amount,
      method: paymentMethod,
      status: paymentResult.status === 'pending' ? 'PENDING' : 'COMPLETED',
      createdAt: new Date(),
    };

    await db.collection('payments').insertOne(payment);

    console.log(`[Activity] Payment processed for order ${orderId}: ${payment.status}`);
    return { success: true, paymentId: payment._id, message: 'Payment processed' };
  } catch (error) {
    console.error(`[Activity] Payment processing error: ${error.message}`);
    throw error;
  }
}

/**
 * Create order in KDS (Kitchen Display System)
 */
async function createKdsOrderActivity(input) {
  try {
    const { orderId, items, tableNumber, specialInstructions } = input;

    // Create KDS order
    const kdsOrder = {
      _id: `kds_${orderId}`,
      orderId: orderId,
      items: items,
      tableNumber: tableNumber,
      specialInstructions: specialInstructions,
      status: 'PENDING',
      createdAt: new Date(),
      preparationStartedAt: null,
      completedAt: null,
    };

    await db.collection('kds_orders').insertOne(kdsOrder);

    // Emit socket event to KDS screens in real-time
    io.emit('new_order', {
      kdsOrderId: kdsOrder._id,
      orderId: orderId,
      items: items,
      tableNumber: tableNumber,
      specialInstructions: specialInstructions,
    });

    console.log(`[Activity] KDS order created: ${kdsOrder._id}`);
    return kdsOrder._id;
  } catch (error) {
    console.error(`[Activity] KDS order creation error: ${error.message}`);
    throw error;
  }
}

/**
 * Update order status in database
 */
async function updateOrderStatusActivity(input) {
  try {
    const { orderId, status, message, estimatedTime } = input;

    const updateData = {
      status: status,
      updatedAt: new Date(),
    };

    if (message) {
      updateData.lastStatusMessage = message;
    }

    if (estimatedTime) {
      updateData.estimatedTime = estimatedTime;
    }

    // Update in database
    await db.collection('orders').updateOne({ _id: orderId }, { $set: updateData });

    // Emit socket event for real-time updates to customer
    io.to(`order_${orderId}`).emit('order_status_updated', {
      orderId: orderId,
      status: status,
      message: message,
      updatedAt: updateData.updatedAt,
    });

    console.log(`[Activity] Order ${orderId} status updated to ${status}`);
  } catch (error) {
    console.error(`[Activity] Status update error: ${error.message}`);
    throw error;
  }
}

/**
 * Send notification to customer
 */
async function notifyCustomerActivity(input) {
  try {
    const { customerId, orderId, type, message } = input;

    // Get customer
    const customer = await db.collection('customers').findOne({ _id: customerId });
    if (!customer) {
      console.warn(`[Activity] Customer not found: ${customerId}`);
      return;
    }

    // Create notification record
    const notification = {
      customerId: customerId,
      orderId: orderId,
      type: type,
      message: message,
      read: false,
      createdAt: new Date(),
    };

    await db.collection('notifications').insertOne(notification);

    // Send push notification if customer has token
    if (customer.pushTokens && customer.pushTokens.length > 0) {
      const admin = require('firebase-admin');

      const payload = {
        notification: {
          title: 'Order Update',
          body: message,
        },
        data: {
          orderId: orderId,
          type: type,
        },
      };

      // Send to all customer's devices
      for (const token of customer.pushTokens) {
        try {
          await admin.messaging().sendToDevice(token, payload);
        } catch (e) {
          console.error(`Failed to send notification: ${e.message}`);
        }
      }
    }

    // Emit socket event for real-time notification
    io.to(`customer_${customerId}`).emit('notification', notification);

    console.log(`[Activity] Notification sent to customer ${customerId}: ${message}`);
  } catch (error) {
    console.error(`[Activity] Notification error: ${error.message}`);
    throw error;
  }
}

/**
 * Track delivery and update location
 */
async function trackDeliveryActivity(input) {
  try {
    const { orderId, deliveryAddress, customerId } = input;

    // Create delivery record
    const delivery = {
      orderId: orderId,
      customerId: customerId,
      deliveryAddress: deliveryAddress,
      status: 'ASSIGNED',
      assignedAt: new Date(),
      updates: [],
    };

    await db.collection('deliveries').insertOne(delivery);

    // In real scenario, integrate with delivery partner API (UberEats, Swiggy, etc.)
    // For now, we'll simulate with random updates
    // In production: const deliveryPartner = await assignDeliveryPartner(orderId, deliveryAddress);

    // Emit socket event
    io.to(`order_${orderId}`).emit('delivery_assigned', {
      orderId: orderId,
      status: 'ASSIGNED',
    });

    console.log(`[Activity] Delivery initiated for order ${orderId}`);
    return { success: true, message: 'Delivery assigned' };
  } catch (error) {
    console.error(`[Activity] Delivery tracking error: ${error.message}`);
    throw error;
  }
}

/**
 * Complete order
 */
async function completeOrderActivity(input) {
  try {
    const { orderId, completedAt } = input;

    // Update order
    await db.collection('orders').updateOne(
      { _id: orderId },
      {
        $set: {
          status: 'COMPLETED',
          completedAt: new Date(completedAt),
        },
      },
    );

    // Archive KDS order
    const kdsOrder = await db.collection('kds_orders').findOne({ orderId: orderId });
    if (kdsOrder) {
      await db.collection('kds_orders_archive').insertOne({
        ...kdsOrder,
        archivedAt: new Date(),
      });
      await db.collection('kds_orders').deleteOne({ _id: kdsOrder._id });
    }

    console.log(`[Activity] Order ${orderId} completed`);
  } catch (error) {
    console.error(`[Activity] Order completion error: ${error.message}`);
    throw error;
  }
}

module.exports = {
  validateOrderActivity,
  processPaymentActivity,
  createKdsOrderActivity,
  updateOrderStatusActivity,
  notifyCustomerActivity,
  trackDeliveryActivity,
  completeOrderActivity,
};
