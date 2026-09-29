import os

base_dir = "/Users/ayyildiz/.gemini/antigravity-cli/brain/42327335-02e5-47f1-8068-b0cafa36e8c9/.system_generated/worktrees/subagent-Frontend-Developer-self-7c11405a/app"

def replace_in_file(path, old, new):
    full_path = os.path.join(base_dir, path)
    with open(full_path, 'r') as f:
        content = f.read()
    content = content.replace(old, new)
    with open(full_path, 'w') as f:
        f.write(content)

old_dialog = """  void _promptKitchenConflict(FoodModel food, {int quantity = 1, String? note}) {
    Get.defaultDialog("""
new_dialog = """  void _promptKitchenConflict(FoodModel food, {int quantity = 1, String? note}) {
    try {
      Get.defaultDialog("""

replace_in_file("lib/features/customer/controllers/cart_controller.dart", old_dialog, new_dialog)

old_end = """        Get.back();
      },
    );
  }"""
new_end = """        Get.back();
      },
    );
    } catch (_) {}
  }"""

replace_in_file("lib/features/customer/controllers/cart_controller.dart", old_end, new_end)
print("Patched cart_controller.dart")
