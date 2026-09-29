with open("lib/features/customer/controllers/checkout_controller.dart", "r") as f:
    content = f.read()

content = content.replace("await _paymentService.createCashPayment(order.id);", "await _paymentService.createCashPayment(order.id!);")
content = content.replace("final paymentUrl = await _paymentService.initCheckoutForm(order.id);", "await _paymentService.initCheckoutForm(order.id!);")

with open("lib/features/customer/controllers/checkout_controller.dart", "w") as f:
    f.write(content)
