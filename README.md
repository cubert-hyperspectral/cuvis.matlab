![image](https://raw.githubusercontent.com/cubert-hyperspectral/cuvis.sdk/main/branding/logo/banner.png)

# cuvis.matlab

cuvis.matlab is the MATLAB wrapper for the Cuvis SDK written in C ([available here](https://github.com/cubert-hyperspectral/cuvis.sdk)).

- **Website:** https://www.cubert-hyperspectral.com/
- **Source code:** https://github.com/cubert-hyperspectral/
- **Support:** http://support.cubert-hyperspectral.com/

This wrapper enables operating Cubert GmbH Hyperspectral Cameras, as well as, 
analyzing data directly from the corporate data format(s) within MATLAB.
This wrapper provides an object-oriented full representation of the basic C SDK 
capabilities and MATLAB return variable formats.


For other supported program languages, please have a look at the 
source code page.

## Installation

### Prerequisites

First, you need to install the Cuvis C SDK from [here](https://cloud.cubert-gmbh.de/s/qpxkyWkycrmBK9m).

### Import

In your MATLAB skript, you need to include 2 lines:

1.) add the path to your cuvis_matlab location, e.g. `addpath('C:\Program Files\Cuvis\sdk\cuvis_matlab');`.

2.) initiate the cuvis_init.m funtionality with a settings directory, e.g. `cuvis_init('user/settings');`.

This will make the cuvis functionalities available, e.g.: `calib = cuvis_calibration(INIT_DIR);`, `proc = cuvis_proc_cont(calib);`, or `acq = cuvis_acq_cont(calib);`.


## How to ...

### Getting started

We provide an additional example repository [here](https://github.com/cubert-hyperspectral/cuvis.matlab.examples),
covering some basic applications.

Further, we provide a set of example measurements to explore [here](https://cloud.cubert-gmbh.de/s/SrkSRja5FKGS2Tw).
These measurements are also used by the examples mentioned above.

### Getting involved

cuvis.hub welcomes your enthusiasm and expertise!

With providing our SDK wrappers on GitHub, we aim for a community-driven open 
source application development by a diverse group of contributors.
Cubert GmbH aims for creating an open, inclusive, and positive community.
Feel free to branch/fork this repository for later merge requests, open 
issues or point us to your application specific projects.
Contact us, if you want your open source project to be included and shared 
on this hub; either if you search for direct support, collaborators or any 
other input or simply want your project being used by this community.
We ourselves try to expand the code base with further more specific 
applications using our wrappers to provide starting points for research 
projects, embedders or other users.

### Getting help

Directly code related issues can be posted here on the GitHub page, other, more 
general and application related issues should be directed to the 
aforementioned Cubert GmbH [support page](http://support.cubert-hyperspectral.com/).

