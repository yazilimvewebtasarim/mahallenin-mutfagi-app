import os

base_dir = "/Users/ayyildiz/.gemini/antigravity-cli/brain/42327335-02e5-47f1-8068-b0cafa36e8c9/.system_generated/worktrees/subagent-Frontend-Developer-self-7c11405a/app"

def replace_in_file(path, old, new):
    full_path = os.path.join(base_dir, path)
    with open(full_path, 'r') as f:
        content = f.read()
    content = content.replace(old, new)
    with open(full_path, 'w') as f:
        f.write(content)

# Fix test imports
replace_in_file("test/features/customer/cart_controller_test.dart", "package:app/", "package:sandbox_app/")

# Fix discovery_controller.dart
replace_in_file("lib/features/customer/controllers/discovery_controller.dart",
                "(f.aciklama ?? '').toLowerCase()",
                "f.aciklama.toLowerCase()")

# Fix cart_view.dart
replace_in_file("lib/features/customer/views/cart_view.dart",
                "import '../../../core/routes/app_routes.dart';",
                "")
replace_in_file("lib/features/customer/views/cart_view.dart",
                "(item.food.resimUrl != null && item.food.resimUrl!.isNotEmpty)",
                "item.food.resimUrl.isNotEmpty")
replace_in_file("lib/features/customer/views/cart_view.dart",
                "item.food.resimUrl!",
                "item.food.resimUrl")
replace_in_file("lib/features/customer/views/cart_view.dart",
                "(_,__,___)",
                "(_, __, ___)")

# Fix discovery_view.dart
replace_in_file("lib/features/customer/views/discovery_view.dart",
                "(_,__,___)",
                "(_, __, ___)")
replace_in_file("lib/features/customer/views/discovery_view.dart",
                "(food.resimUrl != null && food.resimUrl!.isNotEmpty)",
                "food.resimUrl.isNotEmpty")
replace_in_file("lib/features/customer/views/discovery_view.dart",
                "food.resimUrl!",
                "food.resimUrl")
replace_in_file("lib/features/customer/views/discovery_view.dart",
                "if (food.aciklama != null)",
                "if (food.aciklama.isNotEmpty)")
replace_in_file("lib/features/customer/views/discovery_view.dart",
                "Text(food.aciklama!, maxLines: 2",
                "Text(food.aciklama, maxLines: 2")

print("Files fixed.")
