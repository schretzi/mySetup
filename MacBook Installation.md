---
creation date: 2024-02-28 06:31
tags:
  - IPL
aliases: 
account: Rewe
project: FD
---


!!! Change VPN thingies to puma instead of puma-agw !!!



## Links to resources
[ Mike's MacBook survival guide](https://confluence.rewe-group.at/pages/viewpage.action?pageId=103792734)

## Create User Certificate

[Link to long version](https://confluence.rewe-group.at/display/APA/Create+a+user+certificate)

### Short version of option 2 - without windows login
You need to be in the Office and Connect via Cabel to the network (or ask a Teammate or Zoltan for browser access) - if done on the Mac than only Safari will work!
[https://vaut0194.1tld.biz/certsrv/](https://vaut0194.1tld.biz/certsrv/)

- After that, In a popup, enter your AT0xxxxxx username and domain password
- Click on "**Download a CA certificate, certificate chain, or CRL"**
- Click on **Download CA Certificate Chain** (this step might be deprecated due to new macOS security settings, hop to the next step [3. Create certificate request](https://confluence.rewe-group.at/display/APA/Create+a+user+certificate#Createausercertificate-3.Createcertificaterequest))
- Once downloaded, double click on the file e.g. _certnew.cer_ in your Downloads folder to add it to your keychain.  
    **Make sure to select "login" ("Anmeldung" with German language settings) in the dropdown within the dialog** - otherwise some things will not work correctly.  
    Within your keychain you should see the following two certificates:

### Short version of option 3 - Create Certificate Request
* Open **Keychain Access** on the Mac
	![[Pasted image 20240228102453.png]]
* In the menu at the VERY top left of the screen click **Keychain Access** -> **Certificate Assistant** -> **Request a Certificate from a Certificate Authority**
	![[Pasted image 20240228102537.png]]
	-  User Email Address : WORK-EMAIL
	- Common Name: YOUR NAME
	- CA Email Address: empty
	- Save to disk
* Save this file locally as .certSigningRequest
	![[Pasted image 20240228102549.png]]
* Click continue

	If you can't connect to the network right now, send this to a Teammate:
- Open [https://vaut0194.1tld.biz/certsrv/](https://vaut0194.1tld.biz/certsrv/) (in Safari)
- - Click on **Request Certificate**
	![[Pasted image 20240228102606.png]]
- - Then click on **Submit a certificate request by using a base64...**
	![[Pasted image 20240228102627.png]]
- - Open the generated file e.g. CertificateSigningRequest.certSigningRequest with your favourite **text editor** (VS Code, Sublime Text ect.) 
    - **paste** the content to the input field in the browser
    - **Certificate Template: User Autoenroll REWE**
    - and click **Submit**
- Pick „User Autoenroll REWE“ from the dropdown list
	![[Pasted image 20240228102710.png]]
- Click **Download certificate** **chain** in DER format
	![[Pasted image 20240228102722.png]]
- save **certnew.p7b**, save personal User Certificate! 
- And ask your Teammate to send that cert to you and delete it immediatly!!
	
	double click on **certnew.p7b** and see if **Keychain Access** opens
	
## Network Options

- Ethernet
		Ethernet Cable is secured by some networking mechanism - don't use it or disable the LAN Port if you connect to a dock
- WIFI Intranet
		If connected to Intranet you need to use the proxy servers
			![[Pasted image 20240228103111.png]]
			- Benutzername or username is left empty
			- There might be a Pop-Up asking for username and password, here you enter your AT0xxxxxx number with the password
			and then you'll get asked twice for allowing access to the keychain where you enter your Mac user password.
- WIFI Smartgadget
	- Smartgadget is also hidden and you need a Password (Ask a Teammate)
	- No proxy needed
	- But you need to start a VPN Connection to connect to rewe systems
	
https://confluence.rewe-group.at/display/APA/Wi-Fi+INTRANET

If wanted you can use Locations to change network settings based on your location:
https://confluence.rewe-group.at/display/APA/HTTP+Proxy+configuration+with+OSX+Network+Locations


## VPN
Install Openvpn and vpn-slice (software included in Brewfiles)
https://confluence.rewe-group.at/pages/viewpage.action?pageId=105686585

## Umlaute
|   |
|---|
|`vim ~/.zshrc`|

and add line at the end: `export LC_CTYPE='UTF-8'`
##  Create User-directories


```
mkdir ~/bin
mkdir ~/tmp
mkdir ~/Workspace
```

## Brew

Install from brew.sh Homepage:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

This will also install the XCode Command Line Tools and will take a while

At the end we need to add it to the Shell:

```
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/schretzi/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

  
## Brewfile

all Brew installations should be in a Brewfile to have declarative, our multiple files for different reasons:

- ./brew/Brewfile.office
- ./brew/Brewfile.development
- ./brew/Brewfile.golang
- ./brew/Brewfile.java
- ./brew/Brewfile.python
- ./brew/Brewfile.private

```
brew bundle install --file=./brew/Brewfile.cloudnative
````

## Install without Brew

### Private:
- Dymo Label Printer
- GoodNotes
- HP Smart
- LabCom
- ivory mastodon client
  
- oauth2ms for mutt
- obsidian_calender.sh

### Rewe:
- Argus Display Link Manager for dockingstations: https://cdn.targus.com/web/us/downloads/DisplayLink%20Manager%20Graphics%20Connectivity%20for%20macOS.zip
- SentinelOne Security
- proxy.sh
- connect-rewe-vpn.sh

## SSH

```
ssh-keygen -t ed25519 -f ~/.ssh/x.yyyy-rewe -C x.yyyy@rewe-group.at
```

```
Host *
    UseKeychain yes
    AddKeysToAgent yes
    IdentityFile ~/.ssh/x.yyyy-rewe
```

## DNS

I need different DNS routing all the time, depending if connected to VPN, in home-network or for local development. I'm using unbound as service on Macos. Installation was done with brew
  
### Network interface
Let's use the loopback - but there mDNS from Apple is already listening, so we need a new ip. In the next step we create a startup script that adds 2 ips to the loopback range (127.0.0.2 and 127.0.0.3)
  

```
cd ~/tmp
cat <<EOF >> localhost_alias
ifconfig lo0 alias 127.0.0.2 up
ifconfig lo0 alias 127.0.0.3 up
EOF

cat <<EOF >> org.localhost.alias.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>org.localhost.alias</string>
    <key>RunAtLoad</key>
    <true/>
    <key>ProgramArguments</key>
    <array>
      <string>/usr/local/bin/localhost_alias</string>
      <string>2</string>
      <string>8</string>
    </array>
  </dict>
</plist>
EOF

  

sudo cp localhost_alias /usr/local/bin/localhost_alias
sudo chmod +x /usr/local/bin/localhost_alias
sudo cp org.localhost.alias.plist /Library/LaunchDaemons/org.localhost.alias.plist
sudo launchctl load /Library/LaunchDaemons/org.localhost.alias.plist

```

### Unbound configuration

TODO: Check unbound config, security, DNSSEc force, inbound IP Ranges, ....
https://sizeof.cat/post/unbound-on-macos/

#### Network

in /opt/homebrew/etc/unbound/unbound.conf we need to add the network ip where unbound shall listen on, which are the ip for the lima

```
server:
    interface: 127.0.0.2
```

  
#### Additional DNS entrys

I'm configuring all additional DNS entries or Forwards to other server in additional configuration files instead of adding this to the unbound.conf. For that we need to include the additional configuration files. So we add at the beginning of unbound.conf

```
include: "/opt/homebrew/etc/unbound/schretzi.conf"
include: "/opt/homebrew/etc/unbound/rewe.conf"
include: "/opt/homebrew/etc/unbound/k3d.conf"
```

#### schretzi.conf

I only forward my internal domain (in hope and trust on ICANN that this TLD will stay for private use) to the router of my home-network:

```
forward-zone:
name: "schretzi.internal"
forward-addr: 192.168.188.1
```

#### k3d.conf

```
server:
local-zone: "k3d.internal" transparent
local-data: "test.k3d.internal A 127.0.0.1"
```

  
  #### rewe.conf
  

### User Configuration

First we need a free id in system account range, 444 should be free. Check this in /etc/passwd, if 444 is used, take a free one.

```
sudo dscl . -create /Groups/_unbound
sudo dscl . -create /Groups/_unbound PrimaryGroupID 444
sudo dscl . -create /Users/_unbound
sudo dscl . -create /Users/_unbound RecordName _unbound unbound
sudo dscl . -create /Users/_unbound RealName "Unbound DNS server"
sudo dscl . -create /Users/_unbound UniqueID 444
sudo dscl . -create /Users/_unbound PrimaryGroupID 444
sudo dscl . -create /Users/_unbound UserShell /usr/bin/false
sudo dscl . -create /Users/_unbound Password '*'
sudo dscl . -create /Groups/_unbound GroupMembership _unbound
```

  ### Certificate work

#### Fetch the DNSSEC root certificate

sudo unbound-anchor -a /opt/homebrew/etc/unbound/root.key

#### Create our certificates

sudo unbound-control-setup -d /opt/homebrew/etc/unbound

### Create Startup script

```
cat <<EOF >>~/bin/net.unbound.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>net.unbound</string>
    <key>ProgramArguments</key>
    <array>
      <string>/opt/homebrew/sbin/unbound</string>
      <string>-d</string>
      <string>-c</string>
      <string>/opt/homebrew/etc/unbound/unbound.conf</string>
    </array>
    <key>KeepAlive</key>
    <true/>
    <key>RunAtLoad</key>
    <true/>
  </dict>
</plist>
EOF

sudo cp ~/bin/net.unbound.plist /Library/LaunchDaemons/net.unbound.plist
sudo launchctl load /Library/LaunchDaemons/net.unbound.plist
```

### Check and Start

First lets check for typos:

```
unbound-checkconf
```

  We should have no errors, so lets start it

```
sudo launchctl start unbound
```

## Gcloud Setup

```
gcloud components update
gcloud components install terraform-tools alpha beta
gcloud init

```

## Git Setup
```
git config --global user.name "<Your Name>"
git config --global user.email "x.yyyyy@rewe-group.at"
git config --global gpg.format ssh
git config --global user.signingkey 'ssh-ed25519 AAAAxxxxxxx x.yyyy@rewe-group.at'
git config --global commit.gpgsign true
git config --global tag.gpgsign true

# In case ssh/gpg signing does not work, create following file
~/.config/git/allowed_signers
# with content (you can add more keys here)
x.yyyy@rewe-group.at ssh-ed25519 AAAAxxxxxxx x.yyyyy@rewe-group.at
# add to global config
git config --global gpg.ssh.allowedSignersFile "$HOME/.config/git/allowed_signers"
```

## Aiven Client

- Create a Token in Aiven UI for your user
- avn user login EMAIL_ADDRESS --token


## Yubikey
https://github.com/drduh/YubiKey-Guide

This Guide is to long - especially if we are starting with new GPG certificates and/or new Yubikeys. We still run RSA 4096 here to be compatible with other systems.

We installed Gnu grep with brew, so we need to replace all grep with ggrep to work.
### Install Software via Brew
(https://docs.yubico.com/software/yubikey/tools/ykman/Install_ykman.html#macos)

### base commands

Check connection to yk 

```
export YKSERIAL=`ykman list --serials`
echo $YKSERIAL

ykman --device $YKSERIAL info

```


