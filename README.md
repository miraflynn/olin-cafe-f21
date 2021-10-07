# FPGA Labs
A collection of FPGA labs, most recently for Olin's ENGR3410: Computer Architecture course in Fall '21. 

# Hardware

## Supported Boards
Xilinx Boards:
  - [*] [Cmod A7](https://digilent.com/reference/programmable-logic/cmod-a7/start)

## Electronics Tools
*my preferred options are linked, but many of them are "buy it for life" quality (and price). Feel free to use any compatible tool.*

Required:

- Solderless Breadboard(s)
- [Solid core wire/jumper kit]()
- [Wire Strippers]()
- [Flush Cutters]()
- Multimeter
  - [Fluke 287](https://www.fluke.com/en-us/product/electrical-testing/digital-multimeters/fluke-287)
- Logic Analyzer
  - [Saleae Logic 8](https://www.saleae.com/). If you can afford it get the Pro 8. One of the nicest tools I've ever purchased, hardware and software are both just very well designed. Easy to write your own analysis software for it to, unlike pretty much every other tool on this list.

Recommended:
- Bench Power Supply
  - something with a programmable current limit, ideally 2 channels
  - [BK Precision 9132B](https://www.bkprecision.com/products/power-supplies/9132B-triple-output-programmable-dc-power-supply-2-0-60v-3a-1-0-5v-3a.html)
- Oscilloscope
  - any 2-4 channel with at least 100MHaz bandwidth is fine
  - [Rigol](https://www.rigolna.com/products/digital-oscilloscopes/1000z/) makes some decent budget options, their DS1102Z-E is a solid 2 channel scope, and the DS1104Z Plus has 4 channels and can be exanded to include a logic probe which would replace a stand alone logic analyzer.
  - [Digilent Analog Discovery Pro](https://digilent.com/reference/test-and-measurement/analog-discovery-pro-3x50/specifications) - it doesn't have a screen, but it is portable, has some great specifications, and has a built in logic analyzer. I haven't tested it yet but it could be a good "buy it for life" option.

# Software
This is only tested and maintained on Linux, if you are using Windows I recommend you use the [Windows Subsystem for Linux aka WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10). Most of this should work okay on macos, but I have no way of testing. 

Contact the [maintainer](mailto:avinash+fpga@nonholonomy.com) if you find any issues with with the install process.

Supported Linux Distros:
- [*] Ubuntu 20.04
- [*] Gentoo

Last, a note on philosophy - there are a lot of techniques to batch together the install of all of these tools (virtual machines, Docker/containers, build scripts, etc.), but a large part of being a good embedded engineer is know how to maintain and install a large set of tools with low to minimal documentation. If you are new to Linux command line/bash installation I recommend you work through the following tutorials before proceeding:
  - [Command Line for Beginners](https://ubuntu.com/tutorials/command-line-for-beginners#1-overview).
  - Get used to [Tab Completion](https://www.howtogeek.com/195207/use-tab-completion-to-type-commands-faster-on-any-operating-system/) - it saves you time and typos!
  - [Reverse Search](https://codeburst.io/use-reverse-i-search-to-quickly-navigate-through-your-history-917f4d7ffd37) - a very powerful tool for when you're rapidly iterating - let's you search your history and quickly re-run commands you've run before.
  - [A guide to bashrc](https://www.routerhosting.com/knowledge-base/what-is-linux-bashrc-and-how-to-use-it-full-guide/) - how you customize your command line (aka shell).
  - Last but not least, you can get information on most commands by typing `man command` or `command --help`.

*Strong Recommendation* - don't just copy and paste the instructions below - try to run each command one by one to get more familiarity and practice.

Installation checklist:
- [ ] have 30~60GB free on your computer
- [ ] build tools
- [ ] risc v toolchain
- [ ] icarus verilog
- [ ] verilator
- [ ] gtkwave
- [ ] Digilent Adept
- [ ] Xilinx Vivado
- [ ] Digilent Board Files
- [ ] a good graphical text editor (supported: [vscode](https://code.visualstudio.com/)) 
  - If you are using vscode, the mshr-h.veriloghdl extension is the best I've found. Edit the `verilog.linting.linter` to `verilator` (`ctrl+,` to open settings, then search for `verilog.linting...`, or just type `code --install-extension mshr-h.veriloghdl` from the command line). Once you have this enabled you'll get very handy warnings as you describe your hardware that will save you a ton of time.
- [ ] a good command line text editor (recommended: [nano](https://www.nano-editor.org/)). Not necessarily required for this class, but it's good to know how to edit a file from the command line so that you can do it when working over ssh (remote connection) or as root (gui programs and root don't mix well).
  
The install process is split between open source and propriety tools.

## Open Source Tools

- [icarus verilog](http://iverilog.icarus.com/) - a solid open source verilog simulator. It amazes me how much better it is than some of the professional tools out there.
- [verilator](https://www.veripool.org/verilator/) - another open verilog simulator. It's very very fast, but has some feature mismatches with icarus verilog. Plus tools have bugs, it's very helpful to have two simulators that you can test against each other.
- [gtkwave](http://gtkwave.sourceforge.net/) - a graphical tool that lets you examine waveforms from a simulator. Typically we use this to view "VCD" files.
  - Alternate: [drom.io](https://drom.io/vcd/) a browser based VCD viewer. ymmv, haven't tested it much.
- [gcc]() gnu compiler collection
- [llvm/clang]() 
- [risc v gnu toolchain](https://github.com/ucb-bar/esp-gnu-toolchain)
- [compiler explorer](https://godbolt.org/) - a fantastic in-browser tool that shows you the outputs of pretty much every modern compiler for given C/C++ code. Best way to learn what your CPU actually sees from the code you wrote.

## Proprietary Tools

If you are taking this as a class I will provide either a link where you can download all of these binaries together, or pass out USB sticks with the software you need. 

- [Xilinx Vivado](https://www.xilinx.com/products/design-tools/vivado.html) - Xilinx's latest IDE (Integrated Development Enviromment) with tools for design, simulation, and FPGA implementation. Also includes HLS (High Level Synthesis) support to auto-generate HDL modules based on high (C) level definitions.

- [Digilent Adept 2](https://digilent.com/reference/software/adept/start) - A set of software tools for programming (aka "flashing" FPGAs and other PLDs. You need the [runtime](https://digilent.com/reference/lib/exe/fetch.php?tok=f5f244&media=https%3A%2F%2Fmautic.digilentinc.com%2Fadept-runtime-download) and the [utilities](https://digilent.com/reference/lib/exe/fetch.php?tok=358c01&media=https%3A%2F%2Fmautic.digilentinc.com%2Fadept-utilities-download). If you want to get fancy the [sdk](https://digilent.com/reference/lib/exe/fetch.php?tok=2e05b9&media=https%3A%2F%2Fmautic.digilentinc.com%2Fadept-sdk-download) lets you write your own tools to interface with FPGA dev boards.

### Install: Ubuntu 20.04

```bash
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install build-essential nano python3 libusb-1.0-0
sudo apt-get install gtkwave verilator
sudo adduser $USER dialout

# install icarus verilog from source - thanks to Manu for the help!
sudo apt-get remove iverilog
sudo apt-get install gperf autoconf
cd /path/to/workspace
git clone https://github.com/steveicarus/iverilog.git
cd iverilog
git checkout --track -b v11-branch origin/v11-branch
sh autoconf.sh
./configure
make
sudo make install
```

Digilent:

Go to the [runtime](https://digilent.com/reference/lib/exe/fetch.php?tok=f5f244&media=https%3A%2F%2Fmautic.digilentinc.com%2Fadept-runtime-download) and [utilities](https://digilent.com/reference/lib/exe/fetch.php?tok=358c01&media=https%3A%2F%2Fmautic.digilentinc.com%2Fadept-utilities-download) sites and download the "Linux 64-bit.deb" options. Then, from where you downloaded it, run:
```bash
sudo dpkg -i digilent.adept.runtime_2.4.1-amd64.deb
sudo dpkg -i digilent.adept.utilities_2.4.1-amd64.deb
```

Then you can flash FPGAs without Xilinx tools using:
```
djtgcfg enum # Will show you the string to put for the -d arg
djtgcfg prog -d CmodA7 -i 0 -f main.bit
```

### Xilinx Install
(*Warning - this can take >2 hrs*) Instructions [here
Instructions [here](docs/install/xilinx/xilinx.md).


### Digilent Board Files install
```bash
cd $XILINX_INSTALL_PATH
git clone https://github.com/Digilent/vivado-boards
mkdir -p ${VIVADO_PATH}/data/boards/board_files/
cp -r vivado-boards/new/board_files/* ${VIVADO_PATH}/data/boards/board_files/
```

