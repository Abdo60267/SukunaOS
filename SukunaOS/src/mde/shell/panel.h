/**
 * Panel and Shell Header
 * Top panel, taskbar, system tray
 */

#ifndef MDE_PANEL_H
#define MDE_PANEL_H

#include <wayland-server-core.h>

typedef struct mde_panel {
    struct wl_resource *surface;
    uint32_t width, height;
    int position; // 0 = top, 1 = bottom
} mde_panel_t;

typedef struct mde_taskbar_item {
    char *app_name;
    char *icon_path;
    uint32_t window_id;
} mde_taskbar_item_t;

typedef struct mde_shell {
    mde_panel_t *panel;
    mde_taskbar_item_t **taskbar_items;
    uint32_t taskbar_item_count;
} mde_shell_t;

mde_shell_t* mde_shell_create(void);
void mde_shell_destroy(mde_shell_t *shell);

void mde_shell_add_taskbar_item(mde_shell_t *shell, mde_taskbar_item_t *item);
void mde_shell_remove_taskbar_item(mde_shell_t *shell, uint32_t window_id);

void mde_panel_draw_taskbar(mde_panel_t *panel);
void mde_panel_draw_systray(mde_panel_t *panel);

#endif // MDE_PANEL_H
