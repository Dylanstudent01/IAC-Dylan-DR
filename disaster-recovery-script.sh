#!/bin/bash
# Student: Dylan van Raaij, Studentnummer:s1178037
printf "#---------------------------------#"
printf "### Het Disaster-recovery-script! #"
printf "#---------------------------------#"
printf "\n"
printf "\n"

#---------------------------------------------------------#
# het genereren van een ssh key t.b.v. vagrant/virtualbox #
#---------------------------------------------------------#
echo "ssh-key genereren"
echo | ssh-keygen -t rsa

#---------------------------------------------------------------------------------------#
# In de gedeelte wordt de mappenstructuur opgebouwd en de recovery bestanden verplaatst #
#---------------------------------------------------------------------------------------#

echo "De mappenstrutuur wordt nu opgebouwd: /home/student/IAC/ /klanten & /productie/bestanden"
mkdir -p /home/student/IAC/productie/bestanden
mkdir -p /home/student/IAC/klanten
sudo chown -R student:student /home/student/IAC
echo "het uitpakken van de recovery bestanden naar /home/student/IAC/productie/bestanden"
#NOG AANPASSEN NAAR HET ECHTE ZIP BESTAND
unzip -d /home/student/IAC/productie/bestanden/ test_iac.zip

#------------------------------------------------------------------------------#
# in dit gedeelte wordt de 2e schijf t.b.v. de opslag van de VM's gerealiseerd #
#------------------------------------------------------------------------------#
echo "De extra toegevoegde schijf wordt geformateerd en gemount"
sudo parted /dev/sdb mklabel gpt
sudo parted -a opt /dev/sdb mkpart primary ext4 0% 100%
sudo mkfs.ext4 -L VMdata /dev/sdb1
sudo mkdir -p /mnt/data/VMdata
sudo mount -o defaults /dev/sdb1 /mnt/data/VMdata
sudo echo "/dev/sdb1 /mnt/data/VMdata ext4 defaults 0 2" >> /etc/fstab
sudo chown -R student:student /mnt/data/VMdata

#---------------------------------------------------------------------#
# In dit gedeelte worden ansible, vagrant en virtualbox geïnstalleerd #
#---------------------------------------------------------------------#
echo "Linux ubuntu packages worden bijgewerkt"
sudo apt update && sudo apt -y upgrade

echo "Virtualbox 6.1 wordt gedownload en geïnstalleerd"
sudo apt-get install virtualbox -y

echo "Ansible wordt gedownload en geïnstalleerd"
sudo apt-get install ansible -y

echo "vagrant wordt gedownload en geïnstalleerd"
sudo apt-get install vagrant -y

echo "toevoegen 0.0.0.0/0 aan /etc/vbox/networks.conf"
sudo mkdir /etc/vbox
sudo touch /etc/vbox/networks.conf
sudo echo "* 0.0.0.0/0" >> /etc/vbox/networks.conf

#---------------------------------------------------------------------#
# Met de volgende code wordt de default machinefolder van virtual box #
# aangepast naar /mnt/data/VMdata                                     #
#---------------------------------------------------------------------#
vboxmanage setproperty machinefolder /mnt/data/VMdata

printf "#---------------------------------------#"
printf "# De omgeving is nu klaar voor gebruik! #"
printf "#---------------------------------------#"

