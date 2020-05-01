sudo systemctl restart nginx
sudo systemctl enable nginx

cd ~/synapse
source env/bin/activate
synctl start

register_new_matrix_user -c homeserver.yaml http://localhost:8008