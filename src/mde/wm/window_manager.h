/**
 * Window Manager Header
 * Manages window layouts, focus, and tiling
 */

#ifndef MDE_WINDOW_MANAGER_H
#define MDE_WINDOW_MANAGER_H

#include <wayland-server-core.h>

typedef struct mde_window {
    struct wl_resource *surface;
    uint32_t id;
    int32_t x, y;
    uint32_t width, height;
    char *title;
    int focused;
} mde_window_t;

typedef struct mde_workspace {
    mde_window_t **windows;
    uint32_t window_count;
    uint32_t id;
} mde_workspace_t;

typedef struct mde_wm {
    mde_workspace_t **workspaces;
    uint32_t workspace_count;
    mde_window_t *focused_window;
} mde_wm_t;

mde_wm_t* mde_wm_create(void);
void mde_wm_destroy(mde_wm_t *wm);

void mde_wm_add_window(mde_wm_t *wm, mde_window_t *window);
void mde_wm_remove_window(mde_wm_t *wm, mde_window_t *window);
void mde_wm_focus_window(mde_wm_t *wm, mde_window_t *window);

void mde_wm_layout_tile(mde_wm_t *wm, mde_workspace_t *ws);
void mde_wm_layout_fullscreen(mde_wm_t *wm, mde_workspace_t *ws);

#endif // MDE_WINDOW_MANAGER_H
