SOLVE-Brain 1.0.3
===========

Brain-specific annotation of next-generation sequencing data. 

Release date 21 July 2014

Authors: Dalia Ghoneim, Alex Paciorkowski

The Paciorkowski Lab

*****
The MIT License (MIT)

Copyright (c) 2013 Paciorkowski Lab

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*****
To install on Linux systems:

1) Download the tar.gz of the latest release of SOLVE-Brain.

2) Move the tarball to your home directory.

3) Untar the tarball and access the unzipped directory:

$ tar xvfz SOLVE-Brain-x-x-x.tar.gz

$ cd SOLVE-Brain-x-x-x

4) Run the install script. You need to have sudo privileges to do this.

$ sudo sh install.sh

That's it.

NOTE: You may need to make sure CGI is enabled in your Apache installation. To do this go to /etc/httpd/httpd.conf and uncomment this line:

LoadModule cgi_module modules/mod_cgi.so

Then restart Apache: # /etc/rc.d/rc.httpd restart

And you should be all set. 

*****
To install on Mac OsX:

1) You may want to install the XAMPP stack (OsX version of Apache, MySQL, PHP, Perl) to give you an easy-to-run Apache environment. See http://www.apachefriends.org/en/xampp-macosx.html for details.

2) Start Apache. With Mac, look for the XAMPP Control application.

3) You will probably need to allow Apache to execute CGI scripts. Open /Applications/XAMPP/etc/httpd.conf in a text editor and make sure that:

  a) the following module is uncommented (i.e. if there is a preceding "#" remove it):
  LoadModule cgi_module modules/mod_cgi.so
*****
To install on Mac OsX:

1) You may want to install the XAMPP stack (OsX version of Apache, MySQL, PHP, Perl) to give you an easy-to-run Apache environment. See http://www.apachefriends.org/en/xampp-macosx.html for details.

2) Start Apache. With Mac, look for the XAMPP Control application.

3) You will probably need to allow Apache to execute CGI scripts. Open /Applications/XAMPP/etc/httpd.conf in a text editor and make sure that:

  a) the following module is uncommented (i.e. if there is a preceding "#" remove it):
  LoadModule cgi_module modules/mod_cgi.so

  b) the following parameters are present:
  <Directory "/Applications/XAMPP/xamppfiles/cgi-bin/">
     AllowOverride None
     Options Indexes FollowSymLinks ExecCGI Includes
     Order allow,deny
     Allow from all
  </Directory>

4) You will need to restart Apache if you made any changes to httpd.conf. To restart Apache, use the XAMPP Control application.

5) Download the tar.gz of the latest version of SOLVE-Brain.

6) Unzip the tarball using whatever Mac utiity you like.

7) Put the SOLVE-Brain folder in your home directory.

8) Run the install script from the command line. You will need sudo privileges to do this.

$ sudo sh install_solve.sh

That's it.

*****
Installation on Windows

We haven't made SOLVE-Brain Windows compatible yet. You can probably do this through installing Cygwin (http://ww.cygwin.com/), but we haven't tested in this environment yet.
