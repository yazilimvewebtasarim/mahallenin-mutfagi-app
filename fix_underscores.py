import os

base_dir = "/Users/ayyildiz/.gemini/antigravity-cli/brain/42327335-02e5-47f1-8068-b0cafa36e8c9/.system_generated/worktrees/subagent-Frontend-Developer-self-7c11405a/app"

def replace_in_file(path, old, new):
    full_path = os.path.join(base_dir, path)
    with open(full_path, 'r') as f:
        content = f.read()
    content = content.replace(old, new)
    with open(full_path, 'w') as f:
        f.write(content)

replace_in_file("lib/features/customer/views/cart_view.dart", "(_, __, ___)", "(context, error, stackTrace)")
replace_in_file("lib/features/customer/views/cart_view.dart", "(_, __)", "(context, index)")
replace_in_file("lib/features/customer/views/discovery_view.dart", "(_, __, ___)", "(context, error, stackTrace)")
replace_in_file("lib/features/customer/views/discovery_view.dart", "(_, __)", "(context, index)")

print("Fixed underscores.")
