docker run -d \
  --name=kali-linux \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -p 3000:3000 \
  -p 3001:3001 \
  -v /dev/kali:/config \
  --shm-size="1gb" \
  --restart unless-stopped \
  lscr.io/linuxserver/kali-linux:latest
