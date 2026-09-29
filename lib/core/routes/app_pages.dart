import '../../features/ai/views/ai_suggestions_view.dart';
import '../../features/stories/views/stories_view.dart';
import '../../features/chat/views/chat_view.dart';
import '../../features/chef_finance/views/chef_finance_view.dart';
import 'package:get/get.dart';
import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/views/login_register_view.dart';
import '../../features/auth/views/role_view.dart';
import '../../features/auth/views/splash_view.dart';
import '../../features/chef/bindings/chef_binding.dart';
import '../../features/chef/views/chef_add_food_view.dart';
import '../../features/chef/views/chef_menu_view.dart';
import '../../features/customer/bindings/customer_binding.dart';
import '../../features/customer/views/discovery_view.dart';
import '../../features/customer/views/cart_view.dart';
import '../../features/customer/views/checkout_view.dart';
import '../../features/customer/views/customer_orders_view.dart';
import '../../features/chef/views/chef_orders_view.dart';
import '../../features/customer/views/order_review_view.dart';
import '../../features/chef/views/chef_reviews_view.dart';
import '../../features/customer/controllers/order_review_controller.dart';
import '../../features/chef/controllers/chef_reviews_controller.dart';
import '../../features/customer/views/chef_storefront_view.dart';
import '../../features/auth/views/settings_view.dart';
import '../../features/chef/views/chef_requests_view.dart';
import '../../features/customer/views/customer_custom_requests_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.roleSelect,
      page: () => const RoleView(),
      binding: RoleBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginRegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.chefMenu,
      page: () => const ChefMenuView(),
      binding: ChefBinding(),
    ),
    GetPage(
      name: AppRoutes.chefAddFood,
      page: () => const ChefAddFoodView(),
      binding: ChefBinding(),
    ),
    GetPage(
      name: AppRoutes.customerDiscovery,
      page: () => const DiscoveryView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: AppRoutes.customerCart,
      page: () => const CartView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: AppRoutes.customerCheckout,
      page: () => const CheckoutView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: AppRoutes.customerOrders,
      page: () => const CustomerOrdersView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: AppRoutes.chefOrders,
      page: () => const ChefOrdersView(),
      binding: ChefBinding(),
    ),
    GetPage(
      name: AppRoutes.customerReview,
      page: () => const OrderReviewView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => OrderReviewController());
      }),
    ),
    GetPage(
      name: AppRoutes.chefReviews,
      page: () => const ChefReviewsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ChefReviewsController());
      }),
    ),

    GetPage(
      name: AppRoutes.chefStorefront,
      page: () => const ChefStorefrontView(),
      binding: CustomerBinding(),
    ),
    GetPage(name: AppRoutes.stories, page: () => const StoriesView()),
    GetPage(name: AppRoutes.chat, page: () => ChatView()),
    GetPage(name: AppRoutes.chefFinance, page: () => ChefFinanceView()),
    GetPage(name: AppRoutes.aiSuggestions, page: () => const AiSuggestionsView()),
    GetPage(name: AppRoutes.settings, page: () => const SettingsView()),
    GetPage(name: AppRoutes.chefRequests, page: () => const ChefRequestsView()),
    GetPage(name: AppRoutes.customerCustomRequests, page: () => const CustomerCustomRequestsView()),
  ];
}
