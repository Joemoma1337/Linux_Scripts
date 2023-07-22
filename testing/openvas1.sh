echo "Run the following commands:"
echo "sudo apt -y update && sudo apt -y upgrade"
echo "sudo useradd -r -M -U -G sudo -s /usr/sbin/nologin gvm"
echo 'sudo usermod -aG gvm $USER'
echo 'su $USER'