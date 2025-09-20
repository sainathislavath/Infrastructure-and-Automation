#!/bin/bash
set -e

apt-get update -y
apt-get install -y docker.io
systemctl start docker
systemctl enable docker

# Wait for Docker to be ready briefly
sleep 3

# Pull images (assumes public images)
docker pull ${user_image}
docker pull ${products_image}
docker pull ${orders_image}
docker pull ${cart_image}
docker pull ${frontend_image}

# Stop & remove old containers if any
for c in user products orders cart frontend; do
  if docker ps -a --format '{{.Names}}' | grep -q "^$${c}$"; then
    docker rm -f $${c} || true
  fi
done

# Start containers
docker run -d --restart unless-stopped --name user -p 3001:3001 ${user_image}
docker run -d --restart unless-stopped --name products -p 3002:3002 ${products_image}
docker run -d --restart unless-stopped --name orders -p 3003:3003 ${orders_image}
docker run -d --restart unless-stopped --name cart -p 3004:3004 ${cart_image}
docker run -d --restart unless-stopped --name frontend -p 80:80 ${frontend_image}

# show container status
docker ps -a
