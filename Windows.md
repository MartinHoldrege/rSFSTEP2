# Running rSFSTEP2 on Windows (Cygwin)

rSFSTEP2 is designed for Unix-based operating systems, so additional steps are required to run rSFSTEP2 on Windows. You can either run rSFSTEP2 under Cygwin, a Unix-compatible environment for Windows, or under Windows itself. Currently, this document only covers how to run rSFSTEP2 under Cygwin.

## Installing Cygwin and Cygwin Packages

Before running rSFSTEP2 on Cygwin, you should download Cygwin. Although Cygwin provides both 32-bit (x86) and 64-bit (x86-64) versions, the 64-bit version is highly recommended as rSFSTEP2 typically uses more memory than 32-bit applications can handle.

[Download Cygwin](https://cygwin.com/install.html)

After downloading Cygwin, you must install Cygwin, as well as certain Cygwin packages, so that rSFSTEP2 and required libraries can be built and run. Start by clicking the Cygwin installer, then click "Next" until prompted to select a download site. Select a download site nearby, then click "Next" until prompted to select packages. Click the dropdown to the right of "View" and select "Full."

While Cygwin comes preinstalled with some packages, other packages must be manually installed. For each of the following packages, type its name into the search bar, select the dropdown under the "New" column, and select the highest version number that is not a test version.

* gcc-core
* gcc-c++
* libbz2-devel
* libcurl-devel
* libiconv-devel
* libicu-devel
* libintl-devel
* liblzma-devel
* libpcre-devel
* libssl-devel
* libtirpc-devel
* make
* R
* zlib-devel

After selecting all packages, confirm your selections by clicking the dropdown to the right of "View" and select "Pending." If you are satisfied with your selections, click "Next" until the installer is finished. Anytime you want to install more packages, click the installer and go through the previously mentioned steps again.

## Installing rSFSTEP2

Open Cygwin and type the following commands to download rSFSTEP2 and rSOILWAT2:

```
git clone --recursive https://github.com/DrylandEcology/rSFSTEP2.git
git clone --recursive https://github.com/DrylandEcology/rSOILWAT2.git
```

Type the following commands to download required R packages. When prompted to select a mirror, select one that is nearby. Also, the `--no-staged-install` flag is necessary to prevent access permission issues, and this step will take some time as the packages are built.

```
R
install.packages("RSQLite", dependencies=T, INSTALL_opts="--no-staged-install")
install.packages("DBI", dependencies=T, INSTALL_opts="--no-staged-install")
install.packages("blob", dependencies=T, INSTALL_opts="--no-staged-install")
install.packages("doParallel", dependencies=T, INSTALL_opts="--no-staged-install")
q()
```

Install rSOILWAT2, ensuring you are in the directory containing the rSOILWAT2 folder:

```
R CMD INSTALL --no-staged-install rSOILWAT2
```

Now rSFSTEP2 is installed, and you can read the documentation on how to use rSFSTEP2 here:

[rSFSTEP2 Documentation](https://github.com/DrylandEcology/rSFSTEP2)
