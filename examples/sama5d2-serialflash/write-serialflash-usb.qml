import SAMBA 1.0
import SAMBA.Connection.Serial 1.0
import SAMBA.Device.SAMA5D2 1.0

AppletLoader {
	connection: SerialConnection {
		//port: "ttyACM0"
		//port: "COM85"
		baudRate: 57600
	}

	device: SAMA5D2 {
		/*
		config: SAMA5D2Config {
			spiInstance: 1
			spiIoset: 3
			spiChipSelect: 0
			spiFreq: 30
		}
		*/
	}

	onConnectionOpened: {
		// initialize serial flash applet
		if (!appletInitialize("serialflash"))
			return

		// erase first 4MB
		appletErase(0, 4 * 1024 * 1024)

		// write files
		appletWrite(0x00000, "at91bootstrap.bin")
		appletWrite(0x04000, "u-boot-env.bin")
		appletWrite(0x08000, "u-boot.bin")
		appletWrite(0x60000, "at91-sama5d2_xplained.dtb")
		appletWrite(0x6c000, "zImage")

		// Use GPBR_0 as boot configuration word
		BootCfg.writeBSCR(connection, BootCfg.BSC_CR_GPBR_VALID | BootCfg.BSC_CR_GPBR_0)

		// Enable external boot only on SPI0 IOSET1
		BootCfg.writeGPBR(connection, 0, BootCfg.BCW_EXT_MEM_BOOT_ENABLE |
						  BootCfg.BCW_CONSOLE1_IOSET1 |
						  BootCfg.BCW_JTAG_IOSET1 |
						  BootCfg.BCW_SDMMC1_DISABLE |
						  BootCfg.BCW_SDMMC0_DISABLE |
						  BootCfg.BCW_NFC_DISABLE |
						  BootCfg.BCW_SPI1_DISABLE |
						  BootCfg.BCW_SPI0_IOSET1 |
						  BootCfg.BCW_QSPI1_DISABLE |
						  BootCfg.BCW_QSPI0_DISABLE)
	}
}
