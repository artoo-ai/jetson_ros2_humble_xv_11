# Intro
This will create a docker image that will run on a Jetson Nano running the ROS2 Humble.  


# Build the Docker Image
```bash
docker build -f Dockerfile . --no-cache
```

# Run the Docker Image
```bash
docker run -it --device /dev/ttyTHS1 --net=host --privileged <image>
```

