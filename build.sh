VERSION_NUMBER=2.1
build()
{
	echo "Copying toolchain..."
	cp -r ../tc/* android-toolchain
	
	#Build pure zImage
	export CROSS_COMPILE=android-toolchain/bin/arm-eabi-
	export ARCH=arm
	make side_jf_defconfig
	make -j4
	
	PRODUCTIMAGE="arch/arm/boot/zImage"
	if [ ! -f "$PRODUCTIMAGE" ]; then
		echo "build failed" 
		exit 0;
	fi
	
	
	cp -r arch/arm/boot/zImage REPACKING/zImage
	
	cd REPACKING
	./repack.sh
	cd ..
	cp -r REPACKING/boot.img OUT/boot.img
	
	#Repacking
	cd OUT
	FILENAME=SideCore-SGS4-NOUGAT-${VERSION_NUMBER}-`date +"[%H-%M][%d-%m]"`.zip
	zip -r $FILENAME .;
	cd ..
	
}

deep_clean()
{
	rm -rf OUT/boot.img
	rm -rf OUT/*.zip
	rm -rf REPACKING/boot.img
	rm -rf REPACKING/zImage
	rm -rf REPACKING/ramdisk.gz
	
	
	rm -rf android-toolchain/*
	echo "Distro cleaning"
	make ARCH=arm mrproper;
	make clean;
	ccache -c 
	ccache -C
}

rerun()
{
	bash build.sh;
}
echo ""
echo ""
echo "SideCore kernel for jflte LineageOS ROMs"
echo "1) Clean Workspace"
echo "2) Build kernel"
echo "3) Exit"
echo ""
read -p "Please select an option " prompt
echo ""
if [ $prompt == "1" ]; then
	deep_clean; 
	rerun;
elif [ $prompt == "2" ]; then
	build;
	rerun;
elif [ $prompt == "3" ]; then
	exit;
fi


