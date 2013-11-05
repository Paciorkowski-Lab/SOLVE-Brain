#!/bin/bash
#
# Alex Paciorkowski
# 3 Nov 2013
# installer script for SOLVE-Brain-1.0.1
# Usage:
# $ sudo sh install_solve.sh

echo "Installing SOLVE-Brain-1.0.1"
if [ -d "/var/www/htdocs/" ]; then # Most Linux distros
        mkdir /var/www/htdocs/images
else if [ -d "/var/www/html/" ]; then # Other Linux distros
        mkdir /var/www/html/images
else if [ -d "/Applications/XAMPP/htdocs/" ]; then # Mac OsX XAMPP stack
        mkdir /Applications/XAMPP/htdocs/images
fi
fi
fi
if [ -d "/var/www/cgi-bin" ]; then # Linux cgi-bin
        mv solve_brain.cgi /var/www/cgi-bin
else if [ -d "/Applications/XAMPP/cgi-bin" ]; then # Mac OsX XAMPP cgi-bin
        mv solve_brain.cgi /Applications/XAMPP/cgi-bin
fi
fi
if [ -d "var/www/html/images/" ]; then
        mv images/aibs.png /var/www/html/images
        mv images/lynx.png /var/www/html/images
        mv images/mgi.png /var/www/html/images
        mv images/PubMed.png /var/www/html/images
        mv images/SOLVE_brain_logo.jpg /var/www/html/images
        mv images/UCSC.png /var/www/html/images
else if [ -d "/var/www/htdocs/images" ]; then
        mv images/aibs.png /var/www/htdocs/images
        mv images/lynx.png /var/www/htdocs/images
        mv images/mgi.png /var/www/htdocs/images
        mv images/PubMed.png /var/www/htdocs/images
        mv images/SOLVE_brain_logo.jpg /var/www/htdocs/images
        mv images/UCSC.png /var/www/htdocs/images
else if [ -d "/Applications/XAMPP/htdocs/images" ]; then
        mv images/aibs.png /Applications/XAMPP/htdocs/images
        mv images/lynx.png /Applications/XAMPP/htdocs/images
        mv images/mgi.png /Applications/XAMPP/htdocs/images
        mv images/PubMed.png /Applications/XAMPP/htdocs/images
        mv images/SOLVE_brain_logo.jpg /Applications/XAMPP/htodcs/images
        mv images/UCSC.png /Applications/XAMPP/htdocs/images
fi
fi
fi
echo ""
echo "SOLVE-Brain-1.0.1 installed."
