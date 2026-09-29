class ApiConstants {
  static String get baseUrl {
    // Official Production URL via Render
    return 'https://mahallenin-mutfagi-backend.onrender.com/api/v1';
  }

  static const String chefFoods = '/chef/foods';
  static const String chefFoodsEndpoint = '/chef/foods';
  static const String customerChefsEndpoint = '/customer/chefs';
  static const String customerFoodsEndpoint = '/customer/foods';
  static const String customerRequestsEndpoint = '/customer/requests';
  static const String customerCartEndpoint = '/customer/cart';
  static const String ordersEndpoint = '/orders';
  static const String chefOrdersEndpoint = '/chef/orders';
  static const String reviewsEndpoint = '/reviews';
  static const String paymentEndpoint = '/payment';
  static const String chefSubscriptionStatus = '/chef/subscription/status';
  static const String chefSubscriptionNotify = '/chef/subscription/notify-payment';
  static const String chefSubscriptionInitCheckout = '/chef/subscription/initialize-checkout';
  static const String chefSubscriptionInitShopier = '/chef/subscription/initialize-shopier';
  static const String chefRequestsEndpoint = '/chef/requests';
  static const String chefFinanceEndpoint = '/chef/finance';
  static const String chefFinanceUpdateIban = '/chef/finance/update-iban';
  static const String chefFinanceWithdraw = '/chef/finance/withdraw';
  static const String customerShopierInit = '/payment/shopier/init';
  static const String platformStatsEndpoint = '/platform/stats';
  static const String authRefreshTokenEndpoint = '/auth/refresh-token';
}

