# Overlays for sun50i-a64

## Supported boards
* A64-OLinuXino

## Overlays

### Display panels

Detailed information about all display panels you can find [here][16a594ef].

Note: that ethernet phy pins are multiplexed with the LCD, so you cannot use both
simultaneously. The **PHYRST1** jumper should be closed if LCD is pressent.
The used compatible string are not present in the upstream kernel. A [patch][61882798]
should be applied to the kernel, or you can use other string.


Currently provided overlays and supported panels by them are:
* **lcd-olinuxino-5.dts** - Enable [LCD-OLinuXino-5CTS][adc0609e]
* **lcd-olinuxino-7.dts** - Enable [LCD-OLinuXino-7][afbb7741]
* **lcd-olinuxino-10.dts** - Enable [LCD-OLinuXino-10][5ab5a3cd]

  [afbb7741]: https://www.olimex.com/Products/OLinuXino/LCD/LCD-OLinuXino-7/open-source-hardware "LCD-OLinuXino-7"
  [5ab5a3cd]: https://www.olimex.com/Products/OLinuXino/LCD/LCD-OLinuXino-10/open-source-hardware "LCD-OLinuXino-10"


### Interface
#### I<sup>2</sup>C (TWI)
In some cases some I<sup>2</sup>C may be enabled. If overlay is provided
this will not cause issues.

Provided overlays are:
* **sun50i-a64-i2c0.dts**
* **sun50i-a64-i2c1.dts**

#### SPI

Provided overlays are:
* **sun50i-a64-spi0.dts**
* **sun50i-a64-spi1.dts**

### Devices

#### SPI Flash
On boards with SPIFlash (**A64-OlinuXino-1Gs16M**) you can enable it using
**spi0-spiflash.dts** overlay. This also will enable SPI0 bus.

Provided overlays are:
* **spi0-spiflash.dts**
* **spi1-spiflash.dts**

#### SPI Userspace (spidev)
To use a SPI bus from userspace, spidev kernel module should be loaded. Also
the device must be described in the dts. Note that, this operation will output
a bug in the system log:
```
buggy DT: spidev listed directly in DT
```

You should not pay attention to this.

Provided overlays are:
* **spi0-spidev.dts**
* **spi1-spidev.dts**


  [16a594ef]: https://github.com/OLIMEX/OLINUXINO/blob/master/DOCUMENTS/LCD-OLinuXino/OLinuXino-LCD-Selection-Guide.pdf "LCD-OLinuXino Selection Guide"

  [adc0609e]: https://www.olimex.com/Products/OLinuXino/LCD/LCD-OLinuXino-5CTS/ "LCD-OLinuXino-5CTS"

  [61882798]: https://gist.github.com/StefanMavrodiev/437c8ea8b046df0cbb17c4d1f157baf9 "panel-simple"
