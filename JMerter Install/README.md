# Basic Steps to Install JMeter on Linux

[JMeter Install](https://linux.how2shout.com/2-ways-to-install-apache-jmeter-on-ubuntu-22-04-lts-linux/)

[X11-Forwarding](https://aws.amazon.com/blogs/compute/how-to-enable-x11-forwarding-from-red-hat-enterprise-linux-rhel-amazon-linux-suse-linux-ubuntu-server-to-support-gui-based-installations-from-amazon-ec2/)

```bash
  # Install JDK
  su -c "yum install java-1.8.0-openjdk-devel"

  or

  sudo apt install default-jdk
  
  # Install Maven
  sudo yum install maven -y

  # Download JMeter
  sudo wget https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.5.zip

  # Unzip
  sudo unzip apache-jmeter-5.5.zip

  # Rename folder
  sudo mv apache-jmeter-5.5 jmeter

  # Move to /opt directory
  sudo mv jmeter /opt

  # Add Jmeter do the system path
  sudo echo 'export PATH="$PATH:/opt/jmeter/bin"' >> ~/.bashrc

  # Start Jmeter
  jmeter

  # Throubleshooting
  # X11-forwarding 
  sudo yum install xorg-x11-xauth


  sudo chown -R ec2-user /opt/jmeter
  sudo chown -R root /opt/jm -R ec2-user /opt/jmeter

  # Reload printenv
  source ~/.bashrc
  or
  . ~/.bashrc

  # Removal of directories
  sudo rm -r /xyv/directory
```
# Creating Jmeter File
```bash
 # Make Dir ~/Desktop
  sudo mkdir ~/Desktop   # /usr/Desktop
```
```bash
  # Create This File
  sudo nano ~/Desktop/Jmeter.desktop
```  
  ***
  > ######  /usr/Desktop/Jmeter.desktop

    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=Apache-Jmeter
    Comment=Testing
    Exec=/opt/jmeter/bin/./jmeter.sh
    Icon=/opt/jmeter/docs/images/jmeter_square.png
    Terminal=false
    StartupNotify=false
  *** 
```bash
  # File Permission
  sudo chmod 4775 ~/Desktop/Jmeter.desktop

```