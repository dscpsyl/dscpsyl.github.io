There are tons of great [installation guides](https://ubuntu.com/tutorials) and steps to install [Ubuntu](https://ubuntu.com). So we will not be going over them here. We recommend installing the server version of Ubuntu to get rid of unnecessary applications. However, this post is to just introduce you to a command that will hopefully get rid of most unwanted programs already installed. You can always reinstall them later if needed.

We are not responsible for any losses incurred by using this command. Please read and understand what each application does before removing it. Use at your own risk.
{:.note title="DISCLAIMER:"}

With that being said, here is the command:

~~~bash
sudo apt-get remove account-plugin-facebook account-plugin-flickr account-plugin-jabber account-plugin-salut account-plugin-twitter account-plugin-windows-live account-plugin-yahoo aisleriot brltty duplicity empathy empathy-common example-content gnome-accessibility-themes gnome-contacts gnome-mahjongg gnome-mines gnome-orca gnome-screensaver gnome-sudoku gnome-video-effects gnomine landscape-common libreoffice-avmedia-backend-gstreamer libreoffice-base-core libreoffice-calc libreoffice-common libreoffice-core libreoffice-draw libreoffice-gnome libreoffice-gtk libreoffice-impress libreoffice-math libreoffice-ogltrans libreoffice-pdfimport libreoffice-style-galaxy libreoffice-style-human libreoffice-writer libsane libsane-common mcp-account-manager-uoa python3-uno rhythmbox rhythmbox-plugins rhythmbox-plugin-zeitgeist sane-utils shotwell shotwell-common telepathy-gabble telepathy-haze telepathy-idle telepathy-indicator telepathy-logger telepathy-mission-control-5 telepathy-salut totem totem-common totem-plugins printer-driver-brlaser printer-driver-foo2zjs printer-driver-foo2zjs-common printer-driver-m2300w printer-driver-ptouch printer-driver-splix
~~~

Of course recommend using auto-remove and purge after to further delete any related files that may have been left behind.

## Conclusion

This is a short side post that hopefully helps you jumpstart your server process. Google is your friend for any kind of trouble you run into. We will be diving more indebted to something actually useful and administrative in the next most. See you there!