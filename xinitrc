
# Environment setup
export GDK_SCALE=1
export GDK_DPI_SCALE=0.95
export QT_SCREEN_SCALE_FACTOR=0.9
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_SCALE_FACTOR=1

xrandr --dpi 220
xrdb -merge ~/.Xresources

exec i3
