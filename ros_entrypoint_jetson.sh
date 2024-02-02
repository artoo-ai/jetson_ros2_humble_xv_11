#!/bin/bash
set -e

# setup ros2 environment
source "/opt/ros/$ROS_DISTRO/install/setup.bash" --
source "/root/ros2_ws/install/local_setup.bash" --
source "/root/ros2_ws/install/setup.bash" --

ln -s /dev/ttyTHS1 /dev/ttyXV11

# Welcome information
echo "Neato xv_11 Driver ROS2 Docker Image"
echo "---------------------"
echo "ROS_DISTRO $ROS_DISTRO"
echo "ROS_ROOT   $ROS_ROOT"
echo 'DDS middleware: ' $RMW_IMPLEMENTATION 
echo "---"  
echo "---------------------"
echo "COLCON_PREFIX_PATH $COLCON_PREFIX_PATH"
echo "AMENT_PREFIX_PATH  $AMENT_PREFIX_PATH"
echo "CMAKE_PREFIX_PATH  $CMAKE_PREFIX_PATH"    
exec "$@"

ros2 run xv_11_driver xv_11_driver
