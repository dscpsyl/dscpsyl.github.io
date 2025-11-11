---
layout: post
title: Port My Environment
---

I spin up and shut down servers constantly, whether it's for testing, for fun, or for necessity, I find myself with a dilemma. Either I can invest the time in migrating over my preferred environment to save time down the road, or I can take the efficiency loss and work with a minimal and inconvenient terminal. I want to choose neither. Thus, like all good programmers, I spent way too long automating the process of porting my setup.

1. 
{:toc}

## VBox

It is in these low-level projects that the power of virtualization really shines. From the start of my coding days, my goto solution has been [Oracle's VirtualBox](https://www.virtualbox.org/). It is free, open-source, cross-platform, and without any bloat. Critically, for me, it is compatible with my M-series MacBook. 

As I refuse to do anything in Powershell, this script will assume I have not lost my mind and am in a Unix environment. Because I like jellyfishes, I am using Ubuntu as my base OS for this project. However, the script will extend to the other major distributions, including MacOS. Using the ISO, I set up a basic installation of Ubuntu with a shared folder to my host machine. This is now my base image that I will copy for each iteration and test for my script.

### The Testing Workflow

With my CD/CI pipeline set up, I can now focus on the actual developonment of the script. My testing workflow is now as follows:

1. Make sure the current version of the script is in the shared folder.
2. Spin up a copy of the base image.
3. Test the script.
4. Rinse and repeat.

It cannot get any simpler. No more setting up fresh environments or worries of contamination from previous tests. Once I have my script in an acceptable state, I can adjust the base image to other distributions and test again.

## The Script

For the sake of universality, I have sacrilegiously chosen `bash` as the language. As such we must chant the spell at the beginning that will protect us from its curses:

```bash
#!/usr/bin/env bash

set -euo pipefail
```

### Prerequisite

Before touching the script, you need a list of the packages you want to install. It doesn't have to be exhaustive, but it should cover the essentials and get your environment to a comfortable state.

#### Let the Managers Manage

There are countless package managers nowadays with robust features. Why reinvent the wheel? If the package manager can handle you dependencies, then let it. If it doesn't need a standalone installation, don't make it harder than it needs to be. This script is designed to leverage package managers to do the heavy lifting, so install all the managers you'll need.

As my version of the script relies on these managers, if you choose to not install them, the script will simply exit.
{:.note title="Note"}

### Subroutines

Finally, with the planning phase out of the way, let's get into the meat of the script. We will set ourselves up for success by defining the most common subroutines we will need for each installation.

#### Installers

As we focus on Unix systems, we will look at the two routines we'll need: Linux and MacOS.

##### MacOS

As MacOS's most popular, and arguably only, package manager is Homebrew, we will define a subroutine to install packages through it.

```bash
__macInstall() {
	local app="$1";

	brew install "$app";
}
```

##### Linux

For Linux, we will prioritze `snap` as the primary package manager, with the distribution's native package manager as a backup. If it is a `classic snap` app, we will also have to specify it during the install command. Here, we choose the four horsemen of distributions to support: Debian-based (`apt`), RedHat-based (`dnf`), Arch-based (`pacman`), and Fedora-based (`yum`).

```bash
__linuxInstall() {
	local app="$1";
	local snap_classic=${2-""};

	if [[ $(command -v snap) ]]; then
		if [[ $(snap find "$app" 2>/dev/null | grep -c "^$app ") -gt 0 ]]; then
			sudo snap install $app $snap_classic;
			return 0;
		fi
	fi

	if [[ $(command -v apt) ]]; then # Debian/Ubuntu
        sudo apt-get update && sudo apt-get install -y $app;
        return 0;
    elif [[ $(command -v dnf) ]]; then # RedHat
        sudo dnf install -y $app;
        return 0;
    elif [[ $(command -v yum) ]]; then # Fedora
        sudo yum install -y $app;
        return 0;
    elif [[ $(command -v pacman) ]]; then # Arch
        sudo pacman install -y $app;
        return 0;
    else
        echo "ERROR::Unsupported Linux distribution. Please install $app manually." >&2;
        exit 2;
    fi
}
```

##### Extendable

To promote extensibility, you can easily add more subroutines for other operating systems or package managers as needed. When such new subroutines are added, you can simply add them as an option to the wrapper subroutine below that will call the appropriate installer based on the detected OS.

```bash
_install_() {
	local app="$1";
	local snap_classic=${2-""};

	case "$OSTYPE" in
		linux*)
			__linuxInstall "$app" "$snap_classic"
			;;
	    darwin*)
			__macInstall "$app"
			;;
	esac
}
```

#### TOML Helper

For one of my packages (Chezmoi), I will need to do work with TOML, and I will need to check for specific settings.

```bash
__tomlLineExists() {
	local line="$1";
	local section="$2";
	local file="$3";

	awk -v section="$section" -v line="$line" '
		$0 == section { in_section=1 }
        in_section && $0 == line { found=1; exit }
        END { exit !found }
	' "$file"
}
```

#### Transitions

I want this script to be pretty. As such, I've used [gum](https://github.com/charmbracelet/gum) to handle user interactions and display messages. This subroutine will help with transitions between different states in the script.

```bash
_transition_() {
	local text=$1;

	if [[ $prettyPrint == 1 ]]; then
		gum spin --spinner line --title "$text..." -- sleep 1;
	else
		echo "$text...";
		sleep 1;
	fi
}
```

#### Basic Printing

Of course, the pretty prints and UIs are not required. For those that cannot handle the extra weight, we will simply use `stdout` and these subroutines to print messages. Additionally, when the script is first starting up, it will not have the ability to pretty print, so these subroutines will be used there as well.

```bash
_print_() {
	local text=$1;

	if [[ $prettyPrint == 1 ]]; then
		echo "# $text" | gum format ;
	else
		echo "$text";
	fi
}

_print_header_() {
	local text=$1;

	if [[ $prettyPrint == 1 ]]; then
		gum style \
				--foreground 212 --border-foreground 91 --border double \
				--align center --width 50 --margin "1 2" --padding "2 4" \
				"$text";
	else
		echo "##########~$text~##########";
		echo "##################################################";
	fi
}

_end_() {
	if [[ $prettyPrint == 1 ]]; then
		clear -x;
	else
		echo "##################################################";
	fi
}
```

#### User Interaction

We will need the user to input and confirm certain actions as this is an interactive script.

```bash
_confirm_() {
	local prompt=$1;

	if [[ $prettyPrint == 1 ]]; then
		if gum confirm "$prompt"; then
			return 0;
		else
			return 1;
		fi
	else
		read -p "$prompt (y/n) " promptChoice;
		if [[ "${promptChoice,,}" == "y" || "${promptChoice,,}" == "yes" ]]; then
			return 0;
		else
			return 1;
		fi
	fi
}

_input_() {
	local placeholder=$1;
	if [[ $prettyPrint == 1 ]]; then
		echo $(gum input --placeholder="$placeholder")
	else
		read -p "$placeholder: " out;
		echo "$out";
	fi
}
```

#### Logging

As with all good scripts, we will want to log what is and has had happened in the script.

```bash
_log_() {
	local level=$1;
	local text=$2;

	if [[ $prettyPrint == 1 ]]; then
		gum log --prefix="[Port-My-Env]" --structured --time=RFC850 --level=$level "$text" --file="$HOME/port-my-env.log";
	else
		echo "[Port-My-Env] $(date +%Y/%m/%d-%H:%M:%S) ($level) $text" >> "$HOME/port-my-env.log";
	fi
}
```

### Setup

With all the subroutines defined, we can now do some quick housekeeping. Mainly, we need to check the OS compatibility and whether or not we will be using pretty printing.

#### OS Detection

First thing's first, we need to detect the OS. This will determine the packages, package managers, and other configurations needed. It will also exit the script immediately if the OS is unsupported. We will inform the user, log it, and finally start the script.

```bash
case "$OSTYPE" in
	linux*)
		osName="linux"
		if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then # If available, use LSB to identify distribution
    		export DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
		else # Otherwise, use release info file
    		export DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)
		fi
		;;
    darwin*)
		osName="mac"
		;;
    *)
		osName="__invalid__"
		;;
esac

if [[ "$osName" == "__invalid__" ]]; then
	_print_header_ ERROR::This script is only intended for UNIX devices.;
	exit 1;
fi

_print_ "We have detected that you are on a $osName device.";
_log_ "info" "Detected linux distro: $DISTRO";
_log_ "debug" "Starting script...";
```

#### Pretty Print

As this script uses `gum` for pretty printing and user interaction, we will need to check if it is installed. If not, we will offer to install it for the user. If the user declines, we will proceed without pretty printing. Otherwise, `gum` has specific installation instructions based on the OS, so we will follow those and set the pretty print flag accordingly.

```bash
prettyPrint=0;
export prettyPrint;

_print_header_ "Step 0";
if [[ ! $(command -v gum) ]]; then
	_print_ "This script has the ability to be interactive in a pretty way.";
	_print_ "It will use gum (https://github.com/charmbracelet/gum\) as the prettifier.";
	if _confirm_ "Would you like to install and use gum?"; then
		# For Linux gum install
		if [[ "$osName" == "linux" ]]; then
    		# Check for Ubuntu and install
    		if [[ "$DISTRO" != "Ubuntu" ]]; then
    			if [[ ! $(command -v gum) ]]; then
    				_print_ "You are on a linux distro that this script cannot automatically install gum for you.";
    				_print_ "Please see the Github page and install manually and then rerun the script.";
    				exit 0;
    			fi
    		else
    			sudo mkdir -p /etc/apt/keyrings;
				curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg;
				echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list;
				sudo apt update && sudo apt install gum;
				_log_ "info" "Autoinstalled gum via this script.";
    		fi
		fi

		# For Mac gum install
		if [[ "$osName" == "mac" ]]; then
			_print_ "Gum will be installed via Homebrew and will be deleted afterwards (if you so choose).";
			_print_ "If you have not installed Homebrew and do not want Homebrew, do not use pretty print on MacOS.";
			_input_ "Press [ENTER] to continue or CTRL+C to exit.";
			if [[ ! $(command -v brew) ]]; then
				NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)";
  				eval "$(/opt/homebrew/bin/brew shellenv)";
  			fi
  			HOMEBREW_NO_ENV_HINTS=1 brew install gum;
  			_log_ "info" "Autoinstalled gum via this script.";
		fi
		prettyPrint=1;
	else
		prettyPrint=0;
	fi
else
	if _confirm_ "Gum has been detected on your computer. Would you like to use it for pretty print?"; then
		prettyPrint=1;
	else
		prettyPrint=0;
	fi
fi

if [[ $prettyPrint == 1 ]]; then
	gum spin --spinner line --title "Gum is being used! You should see a spinner..." -- sleep 1;
	_log_ "info" "Using pretty printing."
else
	_print_ "No pretty printing today...";
	_log_ "info" "No pretty printing today."
	_end_;
	sleep 1;
fi
```

### Main

Now the moment you've been waiting for: let's get to the main script.

#### Git & SSH

Like with a goods things in life, it is never complete without Git and SSH. With that, these will be the first things to set up. Due to the sensitive nature of these two tools, we will not automate their setup, but rather simply remind the user to have them installed and configured.

```bash
_print_header_ "New System Environment Porting Script";
_print_ "Please make sure that you have SSH and Git installed and enough configured that you can clone your private Github repos (i.e., with usable keys).";
if ! _confirm_ "Are you ready to continue?"; then
	_print_ "Please rerun the script once yo've set both of them up!";
	_end_;
	exit 1;
fi
_log_ "info" "SSH and Git configuration confirmed";

GITHUB_USERNAME="dscpsyl"
GITHUB_DOTS_REPO="dotfiles"
_print_ "This script has your Github username as $GITHUB_USERNAME and your dotfiles repo as $GITHUB_DOTS_REPO.";
if ! _confirm_ "Are these values correct?"; then
	GITHUB_USERNAME=$(_input_ "Please type the correct Github Username...");
	GITHUB_DOTS_REPO=$(_input_ "Please type the correct Github Repo Name...");
fi
_log_ "info" "Using Github username $GITHUB_USERNAME and gitub dotfiles repo name $GITHUB_DOTS_REPO";
_end_;
```

#### Main Package Manager

Now, we want to setup the main installer for all of our packages. On linux, we will ask if the user wants to autoupdate packages, and then ask to install `snap`. Both of these are optional, as we will already have the distro's built-in manager, but recommended. On MacOS, we will ask to install `homebrew`. If this is declined, we will exit the script since MacOS has nothing else as popular.

```bash
_print_header_ "Package Manager"

if _confirm_ "You are on a linux system. Would you like to auto-update installs?"; then
	sudo dpkg-reconfigure --priority=low unattended-upgrades;
	_log_ "info" "DPKG auto update installed packages set";
	_print_ "DPKG setting set!";
else
	_log_ "warn" "DPKG auto update installed packages skipped";
	_print_ "No auto updating packages. Got it!";
fi

if [[ "$osName" == "linux" ]]; then
	if [[ ! $(command -v snap) ]]; then
		_print_ "Snap is not installed"

		if ! _confirm_ "Do you want to install Snap now?"; then
			_install_ snapd;
			sudo systemctl enable --now snapd.socket;
			sudo ln -s /var/lib/snapd/snap /snap;

			_print_ "Snap installed successfully!"
  			_log_ "info" "Snap installed";
  		else
  			_print_ "Skipping Snap installation";
  			_log_ "warn" "Snap installation skipped";
		fi

	else
		_print_ "Snap found!";
		_log_ "info" "Snap is already installed on this system";
	fi
fi

if [[ "$osName" == "mac" ]]; then
	if [[ ! $(command -v brew) ]]; then
		_print_ "Homebrew is not installed";
		
		if ! _confirm_ "Do you want to install Homebrew now?"; then
			_print_ "This script requires Homebrew on MacOS to function. Exiting...";
			_log_ "fatal" "Homebrew instillation request denied on MacOS";
			exit 1;
		fi

		if [[ $prettyPrint == 1 ]]; then
			gum spin --spinner=line --show-output -- NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)";
  		else
  			NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)";
  		fi
  		eval "$(/opt/homebrew/bin/brew shellenv)";

  		_print_ "Homebrew installed successfully!"
  		_log_ "info" "Homebrew installed"
	else
		_print_ "Homebrew found!";
		_log_ "info" "Homebrew is already installed on this system";
	fi
fi
_end_;
```

#### ZSH

I am a cult-bliever in `zsh` and `oh-my-zsh`. Thus, I have made these required in the script. To balance out this obsession, I have chosen to make making `zsh` the deault shell to be optional.

```bash
_print_header_ "ZSH Default Shell";
if [[ "$SHELL" != "/usr/bin/zsh" ]]; then
	if _confirm_ "Would you like to set ZSH as your default shell?"; then
		USER=$(whoami)
		chsh -s $(which zsh) $USER;
		_print_ "ZSH set as default shell! You will be dropped into zsh the next time you log in.";
		_log_ "info" "Default shell switched to ZSH.";
	else
		_print_ "We will ignore ZSH for now!";
		_log_ "warn" "ZSH default shell switch denied.";
	fi
else
	_print_ "ZSH already default!";
	_log_ "info" "ZSH is already the default shell.";
fi
_end_;

_print_header_ "Oh-My-ZSH";
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
	_print_ "Oh-My-ZSH is not installed and is required";
	if ! _confirm_ "Do you want to install Oh-My-ZSH now?"; then
		_print_ "This script requires Oh-My-ZSH to function. Exiting...";
		_log_ "fatal" "Oh-My-ZSH instillation request denied";
		exit 1;
	fi

	RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)";

	_print_ "Oh-My-ZSH installed successfully!"
  	_log_ "info" "Oh-My-ZSH installed";
else
	_print_ "Oh-My-ZSH found!";
	_log_ "info" "Oh-My-ZSH is already installed on this system";
fi
_end_;
```

#### NodeJS

As much as I like to hate on `javascript`, there is no denying that I partake in its wine from time to time. Thus, I will need `nodejs` installed. I have chosen `nvm` as my gateway drug and it will be the required manager for `nodejs`.

```bash
print_header_ "NVM and NodeJS";
if [[ ! -d "$HOME/.nvm" ]]; then
	_print_ "NVM and NodeJS are not installed and are required";
	if ! _confirm_ "Would you like to install NVM (Node Version Manager) and NodeJS?"; then
		_print_ "This script requires NVM and NodeJS to function. Exiting...";
		_log_ "fatal" "NVM and NodeJS instillation request denied";
		exit 1;
	fi

	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash;
	\. "$HOME/.nvm/nvm.sh";
	nvm install node;

	_print_ "NVM and NodeJS installed successfully!"
  	_log_ "info" "NVM and NodeJS installed";
else
	if [[ ! $(command -v node) ]]; then
		_print_ "NVM has been found on the system but not Node.";
		_log_ "info" "NVM is already installed on this system";
		if ! _confirm_ "Would you like to install NodeJS with NVM?"; then
			_print_ "This script requires NodeJS to function. Please manually install it. Exiting...";
			_log_ "fatal" "NodeJS instillation request denied";
			exit 1;
		fi
		nvm install node;
		_print_ "NodeJS installed successfully!"
  		_log_ "info" "NodeJS installed";
	else	
		_print_ "NVM and NodeJS found!";
		_log_ "info" "NVM and NodeJS are already installed on this system";
	fi
fi
_end_;
```

#### Rush

I think `rust` is fine. It has its quirks, but overall it'sa comfortable language to work with. With its popularity, many of the tools I use are written in `rust` and on `crates`. Thus, having `crates` is another necessity.

```bash
_print_header_ "Ruby";
if [[ ! $(command -v ruby) ]]; then
	_print_ "Ruby is not installed and is required";
	if ! _confirm_ "Do you want to install Ruby now?"; then
		_print_ "This script requires Ruby to function. Exiting...";
		_log_ "fatal" "Ruby instillation request denied";
		exit 1;
	fi

	_install_ ruby "--classic";

	_print_ "Ruby installed successfully!"
  	_log_ "info" "Ruby installed";
else
	_print_ "Ruby found!";
	_log_ "info" "Ruby is already installed on this system";
fi
_end_;
```

#### Python

Good old `python`. Love it. Nothing else to say here. Most of the time, it should already be installed, but just in case, we will check and install it if needed. While I like `pip` as much as the next guy, some tools are better off more standalone, so `pipx` it is.

```bash
_print_header_ "Python3";
if [[ ! $(command -v python3) ]]; then
	_print_ "Python3 is not installed and is required";
	if ! _confirm_ "Do you want to install Python3 now?"; then
		_print_ "This script requires Python3 to function. Exiting...";
		_log_ "fatal" "Python3 instillation request denied";
		exit 1;
	fi

	_install_ python3;

	_print_ "Python3 installed successfully!"
  	_log_ "info" "Python3 installed";
else
	_print_ "Python3 found!";
	_log_ "info" "Python3 is already installed on this system";
fi
_end_;

_print_header_ "pipx";
if [[ ! $(command -v pipx) ]]; then
	_print_ "pipx is not installed and is required";
	if ! _confirm_ "Do you want to install pipx now?"; then
		_print_ "This script requires pipx to function. Exiting...";
		_log_ "fatal" "pipx instillation request denied";
		exit 1;
	fi

	_install_ pipx;
	pipx ensurepath;

	_print_ "pipx installed successfully!"
  	_log_ "info" "pipx installed";
else
	_print_ "pipx found!";
	_log_ "info" "pipx is already installed on this system";
fi
_end_;
```

#### Make

This should be on the system already, like `python`. It's here more so as another just-in-case catch.

```bash
_print_header_ "make";
if [[ ! $(command -v make) ]]; then
	_print_ "make is not installed and is required";
	if ! _confirm_ "Do you want to install make now?"; then
		_print_ "This script requires make to function. Exiting...";
		_log_ "fatal" "make instillation request denied";
		exit 1;
	fi

	_install_ make;

	_print_ "make installed successfully!"
  	_log_ "info" "make installed";
else
	_print_ "make found!";
	_log_ "info" "make is already installed on this system";
fi
_end_;

_transition_ "Prerequisites Sastified! Continuing";
_end_;
```

You may have also noticed now that its starting to get pretty repetitive. I could wrap this structure up into another sobroutine for conciseness, but I was too lazy. You can make the change yourself, or just deal with it.

#### MacOS Defaults

Now that the essential package managers are installed, let's take a detour to MacOS land and apply my preferred defaults.

```bash
if [[ "$osName" == "mac" ]]; then
	_print_header_ "MacOS Defaults";
	if _confirm_ "Would you like to set the MacOS predefined defaults?"; then
		_print_ "Setting MacOS Dock Defaults...";
		defaults write com.apple.Dock autohide-delay -float 0;
		defaults write com.apple.dock expose-animation-duration -float 0.12;
		defaults write com.apple.Dock showhidden -bool YES;
		defaults write com.apple.dock expose-animation-duration -float 0;
		killall Dock;
		_log_ "info" "Set MacOS Dock Defaults";

		_print_ "Setting MacOS Finder Defaults...";
		defaults write com.apple.finder QLEnableTextSelection -bool TRUE;
		defaults write com.apple.finder AppleShowAllFiles -bool YES;
		defaults write com.apple.finder FXDefaultSearchScope -string "SCcf";
		killall Finder;
		_log_ "info" "Set MacOS Finder Defaults";

		_print_ "Setting MacOS ScreenCapture Defaults...";
		defaults write com.apple.screencapture location ~/Desktop;
		defaults write com.apple.screencapture type png && killall SystemUIServer;
		_log_ "info" "Set MacOS ScreenCapture Defaults";

		_print_ "Setting ~/Library/ noHidden Flag...";
		chflags nohidden ~/Library/;
		_log_ "info" "Set ~/Library/ noHidden Flag";

		_print_ "Setting MacOS to show all extensions...";
		defaults write -g AppleShowAllExtensions -bool true;
		_log_ "info" "Set MacOS to show all extensions";

		_print_ "Setting MacOS NSGlobalDomain Defaults...";
		defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true;
		defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true;
		defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true;
		defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool truefloat 0.05;
		_log_ "info" "Set MacOS NSGlobalDomain Defaults";

		_print_ "Setting MacOS Subpixel Anti-Aliasing (Font Smoothing)..."
		defaults write -g CGFontRenderingFontSmoothingDisabled -bool false;
		_log_ "info" "Set MacOS Subpixel Anti-Aliasing";

		_print_ "Setting MacOS Focus Follows Mouse in Terminal..."
		defaults write com.apple.Terminal FocusFollowsMouse -string YES;
		_log_ "info" "Set MacOS Focus Follows Mouse in Terminal";
	fi
	_end_;
fi
```

#### Tmux

I am a `tmux` man. It was my first multiplexer and my home. Are there better options? Maybe; I would argue not. Are there quirks and annoyances? Of course. But it is reliable and has never failed me, unlike other multiplexers. It is not a requirement here, but I will always press yes.

```bash
_print_header_ "Tmux"; # (https://github.com/tmux/tmux)
if [[ ! $(command -v tmux) ]]; then
	_print_ "Tmux is not installed";
	if _confirm_ "Do you want to install Tmux now?"; then
		
		_install_ tmux;

		_print_ "Tmux installed successfully!";
  		_log_ "info" "Tmux installed";
	else
		_print_ "Who needs panels anyways!";
		_log_ "warn" "Tmux installation denied";
	fi
else
	_print_ "Tmux found!";
	_log_ "info" "Tmux is already installed on this system";
fi
_end_;
```

#### RESH

I've always found the basic shell history lacking. As such, here is my preferred shell history plugin.

```bash
_print_header_ "RESH (Rich Enhanced Shell History)"; # (https://github.com/curusarn/resh)
if [[ ! -d "$HOME/.resh" ]]; then
	_print_ "RESH is not installed";
	if _confirm_ "Would you like to install RESH (Rich Enhanced Shell History) and set keybindings?"; then
		
		if [[ "$osName" == "mac" ]]; then
			if _confirm_ "This will also install coreutils on this Mac. Are you sure?"; then
				brew install coreutils;
				curl -fsSL https://raw.githubusercontent.com/curusarn/resh/master/scripts/rawinstall.sh | bash;
				_print_ "RESH installed successfully!";
  				_log_ "info" "RESH installed";
  			else
  				_print_ "No worries!";
				_log_ "warn" "RESH installation denied";
			fi
		else
			curl -fsSL https://raw.githubusercontent.com/curusarn/resh/master/scripts/rawinstall.sh | bash;
			_print_ "RESH installed successfully!";
  			_log_ "info" "RESH installed";
		fi
	else
		_print_ "No worries!";
		_log_ "warn" "RESH installation denied";
	fi
else
	_print_ "RESH found!";
	_log_ "info" "RESH is already installed on this system";
fi
_end_;
```

#### Chruby

I don't often work with `ruby`, but when I do, I am alwasy on the wrong version.

```bash
_print_header_ "Chruby"; # (https://github.com/postmodern/chruby)
if [[ ! -d "/usr/local/share/chruby" ]]; then
	_print_ "Chruby is not installed on this system and is used in ~/.zshrc.";
	if _confirm_ "Would you like to install Chruby (Ruby Version Manager)?"; then
		latestChruby=$(curl -s https://api.github.com/repos/postmodern/chruby/releases/latest);
		vChurby=$(echo "$latestChruby" | grep -oP '"tag_name": "\K[^"]+');
		urlChurby=$(echo "$latestChruby" | grep -oP '"tarball_url": "\K[^"]+');

		curl -L -o chruby-latest.tar.gz "$urlChurby" &>/dev/null;
		tar -xzf chruby-latest.tar.gz;
		repoChurby=$(tar -tzf chruby-latest.tar.gz | awk 'NR==1 {print $1}');
		cd "$repoChurby";
		sudo ./scripts/setup.sh;

		cd ..;
		rm -r "$repoChurby" chruby-latest.tar.gz;

		_print_ "Chruby installed successfully!";
  		_log_ "info" "Chruby installed";
	
	else
		_print_ "No worries!";
		_log_ "warn" "chruby installation denied";
	fi
else
	_print_ "chruby found!";
	_log_ "info" "chruby is already installed on this system";
fi
_end_;
```

#### Chezmoi

To tie all of these tools together, I have my dotfiles saved and managed with `chezmoi`. Of course, it doesn't need to be installed if I need a more simple and vanilla setup. But here we will install it, configure it, and apply the dotfiles to all these environment tools. Here, we will use the info of `git` and `ssh` from the beginning of the script. It all comes full circle.

```bash
if [[ $(command -v chezmoi) ]]; then
	_print_header_ "Dots and Files";
	_print_ "Chezmoi has been found on your system";
	if _confirm_ "Would you like to pull all your dotfiles from your dotfiles repo?"; then
		if [[ -z $(ls -A "$HOME/.local/share/chezmoi") ]]; then
			chezmoi init --apply git@github.com:$GITHUB_USERNAME/$GITHUB_DOTS_REPO.git;
			chezmoi apply;
			
			_print_ "Dotfiles applied!";
  			_log_ "info" "Dotfiles migrated to this machine";
		else
			_print_ "There seems to be an instance of Chezmoi here already. We will not init or apply anything for safety."
			_log_ "error" "Existing instance of Chezmoi present"
		fi
	else
		_print_ "No dotfiles will be here!";
		_log_ "warn" "Dotfile migration denied";
	fi
	_end_;
fi

if [[ -e "$HOME/.config/chezmoi/chezmoi.toml" ]]; then
	_print_header_ "Chezmoi Auto Update Dotfiles";
	if _confirm_ "Would you like to update your Chezmoi config file to auto commit and push newly applied changes?"; then		
		if [[ ! $(grep -q "^[git]$" "$HOME/.config/chezmoi/chezmoi.toml") ]]; then
			echo -e "\n[git]" >> "$HOME/.config/chezmoi/chezmoi.toml";
		fi

		if [[ ! $(__tomlLineExists "autoCommit = true" "[git]" "$HOME/.config/chezmoi/chezmoi.toml") ]]; then
			sed -i "/^[git]\$/a autoCommit = true" "$HOME/.config/chezmoi/chezmoi.toml";
		fi
	
		if [[ ! $(__tomlLineExists "autoPush = true" "[git]" "$HOME/.config/chezmoi/chezmoi.toml") ]]; then
			sed -i "/^[git]\$/a autoPush = true" "$HOME/.config/chezmoi/chezmoi.toml";
		fi

		_print_ "Chezmoi updated to autoupdate dotfile changes!";
		_log_ "info" "Chezmoi auto-update of dotfiles config applied";
	else
		_print_ "Make sure to manually apply changes in the future!";
		_log_ "warn" "Chezmoi auto-update of dotfiles denied";
	fi
	_end_;
fi
```

#### Homebrew

You didn't think I'd forgotten about `homebrew`, did you? Of course not. `homerew` stores its info in a `brewfile`, which is in my `dotfiles` repo. Thus, we will how apply this file to install all the pachages I need on MacOS.

```bash
if [[ "$osName" == "mac" ]]; then
	_print_header_ "Homebrew Programs";
	if _confirm_ "Would you like to install the MacOS predefined Homebrew applications from the Brewfile in your home directory?"; then
		brew bundle install;

		_print_ "Brewfile taps and casks installed!";
  		_log_ "info" "Brewfile items installed on this Mac";
	else
		_print_ "It's a clean slate!";
  		_log_ "info" "Brewfile not auto-installed on this Mac";
  	fi
  	_end_;
fi
```

### Cleanup

And that's it! This is my version of the script, but please feel free to copy and adapt it to your own needs. You can find the full version [here](https://gist.github.com/dscpsyl/91cdda5076efa3e20f3a5216426de4fb). Before we termiante, let's quickly cleanup `gum`, which we installed only for pretty printing.

```bash
if [[ $prettyPrint == 1 ]]; then
	_print_ "Uninstalling gum"
	prettyPrint=0;
	if [[ "$osName" == "mac" ]]; then
		brew uninstall gum;
	elif [[ "$DISTRO" == "Ubuntu" ]]; then
		sudo apt-get -y purge gum;
		sudo rm /etc/apt/sources.list.d/charm.list;
		sudo rm /etc/apt/keyrings/charm.gpg;
	fi
fi
```

Finally, we will display some helpful reminders to the user before closing.

```bash
echo -e "\n\u001b[33mRemember to press [PREFIX-I] in Tmux to install the plugins.\u001b[0m\n"
echo -e "\n\u001b[33mRemember to execute :PlugInstall in Vim to install the plugins.\u001b[0m\n"
echo -e "\n\u001b[33mRemember to generate any necessary GPG keys for Git and other applications.\u001b[0m\n"

echo -e "##################################################\n"
```

Congrats! How you will never need to manually install your environment again.

## Conclusion

The purpose of this post is two fold. First, I needed an excuse to share my micro-obsession for the past week. Second, I wanted to remind both myself and you reading that automation and virtualization is an underutilized power combo. If it doesn't need to be on bare metal, it's worth considering a virtural buffer. Especially with the rise fo cloud computing, having your applications be modular and movable is more critical than ever.
