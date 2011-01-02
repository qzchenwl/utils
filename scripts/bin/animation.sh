#!/bin/bash
# Gtk Theme
gconftool-2 --set /desktop/gnome/interface/gtk_theme --type string "Macbuntu"
gconftool-2 --set /apps/metacity/general/theme --type string "Macbuntu"
gconftool-2 --set /desktop/gnome/interface/icon_theme --type string "Macbuntu-Icons"
# Cursor
gconftool-2 --set /desktop/gnome/peripherals/mouse/cursor_theme --type string "Macbuntu-Cursors"
gconftool-2 --set /desktop/gnome/peripherals/mouse/cursor_size --type int 28
# Button layout
gconftool-2 --set /apps/metacity/general/button_layout --type string "close,minimize,maximize:menu"
# Panels
gconftool-2 --load panel/panel.entries
gconftool-2 --set /apps/panel/general/toplevel_id_list --type list --list-type string "[top_panel_screen0]"
gconftool-2 --set /apps/panel/toplevels/top_panel_screen0/background/type --type string "gtk"
# gconftool-2 --set /apps/panel/toplevels/top_panel_screen0/background/type --type string "image"
# gconftool-2 --set /apps/panel/toplevels/top_panel_screen0/background/image --type string "$HOME/.themes/Macbuntu/gtk-2.0/Panel/panel-bg-solid.png"
# Icons
gconftool-2 --set /desktop/gnome/interface/toolbar_style --type string "icons"
gconftool-2 --set /desktop/gnome/interface/buttons_have_icons --type boolean false
gconftool-2 --set /desktop/gnome/interface/menus_have_icons --type boolean true
# Nautilus
gconftool-2 --set /apps/nautilus/preferences/default_folder_viewer --type string "icon_view"
gconftool-2 --set /apps/nautilus/preferences/side_pane_view --type string "NautilusPlacesSidebar"
gconftool-2 --set /apps/nautilus/preferences/sort_directories_first --type boolean true
gconftool-2 --set /apps/nautilus/preferences/start_with_location_bar --type boolean true
gconftool-2 --set /apps/nautilus/preferences/always_use_location_entry --type boolean false
gconftool-2 --set /apps/nautilus/preferences/start_with_sidebar --type boolean true
gconftool-2 --set /apps/nautilus/preferences/start_with_status_bar --type boolean true
gconftool-2 --set /apps/nautilus/preferences/start_with_toolbar --type boolean true
# Compositing manager
gconftool-2 --set /apps/metacity/general/compositing_manager --type boolean true

