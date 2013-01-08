veewee vbox build quantal
rm -f quantal.box
vagrant package --base quantal --output quantal.box
vagrant box add quantal quantal.box
vagrant init quantal
vagrant up



