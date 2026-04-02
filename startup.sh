#!/bin/bash

# --- Clean up any existing VNC processes and lock files ---
vncserver -kill :1 >/dev/null 2>&1 || true
rm -f /tmp/.X1-lock >/dev/null 2>&1 || true
rm -f /tmp/.X11-unix/X1 >/dev/null 2>&1 || true

# --- Start DBUS session for XFCE ---
export DBUS_SESSION_BUS_ADDRESS=$(dbus-daemon --session --fork --print-address)

# --- Start the VNC server on display :1 with XFCE desktop ---
# Password is already configured in the container build
vncserver :1 -geometry 1980x1080 -depth 24 -rfbauth /home/ros-student/.vnc/passwd -xstartup /usr/bin/startxfce4

# --- Wait for VNC server to start properly ---
sleep 8

# --- Set DISPLAY variable ---
export DISPLAY=:1

# --- Start the noVNC web server (background process) ---
/opt/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 0.0.0.0:6080 &

# --- Keep the container running ---
exec tail -f /dev/null
