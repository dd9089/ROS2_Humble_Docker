# Base image
FROM osrf/ros:humble-desktop-full

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=humble
ENV DISPLAY=:1

# -----------------------------
# 1️⃣ Install system dependencies, desktop, VNC, and utilities
# -----------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        xfce4 xfce4-terminal \
        tigervnc-standalone-server tigervnc-common tigervnc-tools \
        wget python3-pip xfconf dbus-x11 vim git unzip firefox net-tools \
        python3-colcon-common-extensions \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# -----------------------------
# 2️⃣ Install ROS UR packages and Gazebo support
# -----------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ros-${ROS_DISTRO}-ur-robot-driver \
        ros-${ROS_DISTRO}-ur-msgs \
        ros-${ROS_DISTRO}-ros2-control \
        ros-${ROS_DISTRO}-ros2-controllers \
        ros-${ROS_DISTRO}-gazebo-ros-pkgs \
        ros-${ROS_DISTRO}-gazebo-ros2-control \
        ros-${ROS_DISTRO}-moveit \
        ros-${ROS_DISTRO}-moveit-ros-planning \
        ros-${ROS_DISTRO}-moveit-ros-planning-interface \
        ros-${ROS_DISTRO}-moveit-ros-visualization \
        ros-${ROS_DISTRO}-moveit-ros-perception \
        ros-${ROS_DISTRO}-ur-moveit-config \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# -----------------------------
# 3️⃣ Add non-root user
# -----------------------------
RUN useradd -m -s /bin/bash ros-student && \
    echo 'ros-student ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# -----------------------------
# 4️⃣ Install noVNC and websockify
# -----------------------------
RUN mkdir -p /opt/novnc && \
    wget -qO- https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0.tar.gz | tar xz -C /opt/novnc --strip-components=1 && \
    pip3 install websockify

# -----------------------------
# 5️⃣ Set up VNC password
# -----------------------------
RUN mkdir -p /home/ros-student/.vnc && \
    echo "robotics" | vncpasswd -f > /home/ros-student/.vnc/passwd && \
    chmod 600 /home/ros-student/.vnc/passwd && \
    chown -R ros-student:ros-student /home/ros-student/.vnc

# -----------------------------
# 6️⃣ Copy startup script (you provide this)
# -----------------------------
COPY ./startup.sh /home/ros-student/
RUN chmod +x /home/ros-student/startup.sh && \
    chown ros-student:ros-student /home/ros-student/startup.sh

# -----------------------------
# 7️⃣ Optional: download extra packages
# -----------------------------
RUN wget https://github.com/reedhedges/AriaCoda/archive/refs/heads/master.zip \
    && unzip master.zip -d /home/ros-student/ \
    && rm master.zip && \
    chown -R ros-student:ros-student /home/ros-student/AriaCoda-master

# -----------------------------
# 8️⃣ Switch to non-root user
# -----------------------------
USER ros-student
WORKDIR /home/ros-student

# -----------------------------
# 9️⃣ Configure ROS environment
# -----------------------------
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc

# -----------------------------
# 10️⃣ Expose VNC / noVNC ports
# -----------------------------
EXPOSE 5901 6080

# -----------------------------
# 11️⃣ Default command
# -----------------------------
CMD ["/home/ros-student/startup.sh"]
