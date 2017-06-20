# devcon-service
MrRafael.ca DevCon Service is a Microsoft DevCon service, for easy initialization on Windows boot. You can disable a problematic driver and start Windows normally

In the DevConList.txt, on the same path of exe, insert one driver per line, following by 0 (disable) or 1 (enable). 
Ex.: To disable and enable the Intel HD Graphics: 

	*DEV_0102*=0
	*DEV_0102*=1

To find the driver unique ID, type the following command on prompt:

	devcon find *> list.txt 

Choose a piece of the string that identifies the device, and verify it is unique: 

	c:\>devcon find *VEN_1113     
	PCI\VEN_1113&DEV_1211&SUBSYS_12111113&REV_10\3&13C0B0C5&0&48: Accton EN1207D Ser     
	ies PCI Fast Ethernet Adapter #2     
	1 matching device(s) found.