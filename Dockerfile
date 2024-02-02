ARG IMAGE_NAME=dustynv/ros:humble-ros-base-l4t-r32.7.1

FROM ${IMAGE_NAME}

ARG ROS2_DIST=humble       # ROS2 distribution

ENV DEBIAN_FRONTEND noninteractive
ENV LOGNAME root

# Disable apt-get warnings
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 42D5A192B819C5DA || true && \
  apt-get update || true && apt-get install -y --no-install-recommends apt-utils dialog && \
  rm -rf /var/lib/apt/lists/*

# Install dependencies
RUN apt-get update && \
  apt-get install --yes lsb-release wget less udev sudo build-essential cmake python3 python3-dev python3-pip python3-wheel git jq libpq-dev zstd usbutils libboost-dev libboost-system-dev && \    
  rm -rf /var/lib/apt/lists/*

# Get the Neato XV 11 Driver
WORKDIR /root/ros2_ws/src
RUN git clone https://github.com/ricorx7/xv_11_driver_humble_jetson.git

# Check that all the dependencies are satisfied
WORKDIR /root/ros2_ws
RUN apt-get update -y || true && rosdep update && \
  rosdep install --from-paths src --ignore-src -r -y && \
  rm -rf /var/lib/apt/lists/*

# Build the dependencies and xv_11_driver
RUN /bin/bash -c "source /opt/ros/$ROS_DISTRO/install/setup.bash && \
  colcon build --parallel-workers $(nproc) --symlink-install \
  --event-handlers console_direct+ --base-paths src \
  --cmake-args ' -DCMAKE_BUILD_TYPE=Release' \
  ' -DCMAKE_LIBRARY_PATH=/usr/local/cuda/lib64/stubs' \
  ' -DCUDA_CUDART_LIBRARY=/usr/local/cuda/lib64/stubs' \
  ' -DCMAKE_CXX_FLAGS="-Wl,--allow-shlib-undefined"' \
  ' -Wno-pragma' \
  ' --no-warn-unused-cli' '-Wno-dev' "

# Set final working directory
WORKDIR /root/ros2_ws

# Setup environment variables 
COPY ros_entrypoint_jetson.sh /sbin/ros_entrypoint.sh
RUN sudo chmod 755 /sbin/ros_entrypoint.sh

# This symbolic link is needed to use the streaming features on Jetson inside a container
RUN ln -sf /usr/lib/aarch64-linux-gnu/tegra/libv4l2.so.0 /usr/lib/aarch64-linux-gnu/libv4l2.so

ENTRYPOINT ["/sbin/ros_entrypoint.sh"]
