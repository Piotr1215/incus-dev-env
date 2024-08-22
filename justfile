set quiet 

default:
  just --list --unsorted

# Define the container name that needs the SSH keys
DEV_CONTAINER := "dev-container"

create_nvim_container:
  incus init images:ubuntu/22.04/cloud dev-container
  incus config set dev-container user.user-data - < ./nvim-config.yaml 
  incus config device add dev-container shared-disk disk source=/home/decoder/dev path=/mnt/dev
  incus config set dev-container raw.idmap 'both 1000 1000'
  incus start dev-container
  incus exec dev-container -- cloud-init status --wait
  incus exec dev-container -- ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N ""

copy_keys dev-container target-container:
  echo "Copying SSH keys from {{dev-container}} to {{target-container}}..."
  incus file pull {{dev-container}}/root/.ssh/id_rsa.pub /tmp/id_rsa.pub
  incus file push /tmp/id_rsa.pub {{target-container}}/root/.ssh/id_rsa.pub
  incus exec {{target-container}} -- sh -c "mkdir -p /root/.ssh && cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys && rm /root/.ssh/id_rsa.pub && chmod 600 /root/.ssh/authorized_keys && chmod 700 /root/.ssh"
  rm /tmp/id_rsa.pub

start_nvim:
  incus exec dev-container -- nvim

# Copy SSH keys to the dev-container
create_container container:
  incus init images:ubuntu/22.04/cloud {{container}}
  incus config set {{container}} cloud-init.user-data - < ssh-config.yaml
  incus config device add {{container}} shared-disk disk source=/home/decoder/dev path=/mnt/dev
  incus config set {{container}} raw.idmap 'both 1000 1000'
  incus start {{container}}
  incus exec {{container}} -- cloud-init status --wait

get_ip container:
  incus exec {{container}} -- hostname -I | awk '{print $1}'

get_ssh_logs container:
  incus exec {{container}} -- cat /var/log/cloud-init-output.log

