# ASUS ZenBook A14 (Snapdragon X Plus)

This device runs a Snapdragon ARM chip (`x1p42100`) with limited Linux support. The fixes below are required after a fresh Ubuntu install.

## Internet (First Boot)

Connect a smartphone via USB tethering — Wi-Fi does not work out of the box.

## Wi-Fi

Follow the driver instructions at [linux-x1e80100-zenbook-a14](https://github.com/alexVinarskis/linux-x1e80100-zenbook-a14).

## Battery

```bash
sudo apt install ubuntu-x1e-settings qcom-firmware-extract -y
sudo qcom-firmware-extract
```

## Power & GPU (Resolved)

The default Ubuntu kernel (6.17 generic) has no GPU acceleration or CPU frequency scaling for X1P42100, resulting in ~10W idle power draw with software rendering. The fix is the X1E PPA kernel:

```bash
sudo add-apt-repository -y ppa:ubuntu-concept/x1e
sudo apt install -y linux-qcom-x1e
sudo reboot
```

This installs kernel `7.0.0-32-qcom-x1e` which includes:
- **Adreno X1-45 GPU** driver (`compatible = "qcom,adreno-43030c00"` in DTB)
- **CPU frequency scaling** via SCMI (`schedutil` governor, 1.9–2.9 GHz)
- Proper device tree for X1P42100

Results: idle power dropped from **~10W to ~4.6W** (on par with Windows).

### GPU Firmware

GPU firmware from Qualcomm's Windows Graphics Driver should be installed for full acceleration:

```bash
cd /tmp
git clone https://github.com/alejandroqh/qcom-firmware-updater.git
cd qcom-firmware-updater
sudo apt install 7zip msitools unzip curl -y
bash qcom-firmware-updater.sh --url "https://softwarecenter.qualcomm.com/api/download/software/tools/Windows_Graphics_Driver/Windows/ARM64/260228031.0.148.0/Windows_Graphics_Driver.Core.260228031.0.148.0.Windows-ARM64.zip"
```

### Additional Power Tweaks

```bash
# PCIe ASPM (add to GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub):
#   pcie_aspm.policy=powersupersave

# Disable unnecessary services:
sudo systemctl disable docker.service containerd.service docker.socket
sudo systemctl disable cups-browsed.service ModemManager.service
```

## Fn Keys

Build and install the [zenbook-a14-EC](https://github.com/serdeliuk/zenbook-a14-EC) kernel module. Must be rebuilt after each kernel upgrade:

```bash
cd /tmp
git clone https://github.com/serdeliuk/zenbook-a14-EC.git
cd zenbook-a14-EC
make
sudo cp hid-asus-ec.ko /lib/modules/$(uname -r)/kernel/drivers/hid/
sudo depmod -a
sudo modprobe hid-asus-ec
echo "hid-asus-ec" | sudo tee /etc/modules-load.d/hid-asus-ec.conf
```

## Audio

Requires upstream `alsa-ucm-conf` and `linux-firmware`. See [audio configuration](https://github.com/alexVinarskis/linux-x1e80100-zenbook-a14?tab=readme-ov-file#audio-configuration).

### Audioreach Topology

```bash
git clone https://github.com/linux-msm/audioreach-topology/
cd audioreach-topology
cmake . && cmake --build .
sudo cp qcom/x1e80100/ASUSTeK/zenbook-a14/X1E80100-ASUS-Zenbook-A14-tplg.bin \
  /lib/firmware/updates/qcom/x1e80100/X1E80100-ASUS-Zenbook-A14-tplg.bin
```

### ALSA UCM Config

```bash
curl -L -o alsa-ucm-conf.tar.gz https://github.com/alsa-project/alsa-ucm-conf/archive/refs/heads/master.tar.gz
sudo tar xvzf alsa-ucm-conf.tar.gz -C /usr/share/alsa --strip-components=1 --wildcards "*/ucm" "*/ucm2"
```
