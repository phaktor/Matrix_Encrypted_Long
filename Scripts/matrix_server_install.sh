sudo apt update && sudo apt upgrade

sudo apt-get install build-essential python3-dev libffi-dev \
  python-pip python-setuptools sqlite3 \
  libssl-dev python-virtualenv libjpeg-dev libxslt1-dev

mkdir -p ~/synapse
virtualenv -p python3 ~/synapse/env
source ~/synapse/env/bin/activate

pip install --upgrade pip virtualenv six packaging appdirs

pip install --upgrade setuptools
pip install --user jinja2
pip install matrix-synapse

source ~/synapse/env/bin/activate
pip install -U matrix-synapse
cd ~/synapse
python -m synapse.app.homeserver \
  --server-name matrix.example.com \
  --config-path homeserver.yaml \
  --generate-config \
  --report-stats=no
  
sudo apt-get install nginx

sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install certbot python-certbot-nginx

certbot -d matrix.vsploit.com --manual --preferred-challenges dns certonly

