#!/bin/bash

export DTC=${DTC:-dtc}
TEST=$(mktemp)
echo "DTC version: $(${DTC} -v)"
echo "Generating test script: $TEST"

# Create base worker function
cat > $TEST << '__EOF__'
#!/usr/bin/env bats

OVERLAY=$(mktemp)
OUTPUT=$(mktemp)

compile() {
	${DTC} -q -@ -I dts -O dtb "$1"
}

apply() {
	${DTC} -q -@ -I dts -O dtb -o $OVERLAY "$1"
	fdtoverlay -i "$2" -o $OUTPUT $OVERLAY
}

check_description() {
	${DTC} -q -@ -I dts -O dtb -o $OVERLAY "$1"
	fdtget $OVERLAY / description
}

check_compatible() {
	${DTC} -q -@ -I dts -O dtb -o $OVERLAY "$1"
	fdtget $OVERLAY / compatible | grep -w -q "$2"
}
__EOF__

for arch in sun5i-a13 sun7i-a20 sun50i-a64; do
	# Add tests to the suite
	for overlay in $(ls ../$arch/*.dts); do
		cat >> $TEST << __EOF__

@test "$arch: Compiling $(basename $overlay)" {
	compile $overlay
}

@test "$arch: Check compatible for $(basename $overlay)" {
	check_compatible $overlay "allwinner,$arch"
}

@test "$arch: Check description for $(basename $overlay)" {
	check_description $overlay
}
__EOF__

		for target in $(ls targets/$arch/*.dtb); do
			cat >> $TEST << __EOF__

@test "$arch: Applying $(basename $overlay) to $(basename $target)" {
	apply $overlay $target
}
__EOF__
		done
	done

	# Add board specific tests
	for board in $(find ../$arch/* -type d -exec basename {} \;); do
		case $board in
		"A20-OLinuXino-Lime")
			compatible="olimex,a20-olinuxino-lime"
			targets=$(ls targets/$arch/sun7i-a20-olinuxino-lime*.dtb)
			;;

		"A20-OLinuXino-Lime2")
			compatible="olimex,a20-olinuxino-lime2"
			targets=$(ls targets/$arch/sun7i-a20-olinuxino-lime2*.dtb)
			;;

		"A20-OLinuXino-Micro")
			compatible="olimex,a20-olinuxino-micro"
			targets=$(ls targets/$arch/sun7i-a20-olinuxino-micro*.dtb)
			;;

		"A20-SOM204")
			compatible="olimex,a20-olimex-som204-evb"
			targets=$(ls targets/$arch/sun7i-a20-olimex-som204-evb*.dtb)
			;;

		*)
			continue
			;;
		esac

		for overlay in $(ls ../$arch/$board/*.dts); do
			cat >> $TEST << __EOF__

@test "$arch: Compiling $(basename $overlay)" {
compile $overlay
}

@test "$arch: Check compatible for $(basename $overlay)" {
check_compatible $overlay $compatible
}

@test "$arch: Check description for $(basename $overlay)" {
check_description $overlay
}
__EOF__
			for target in $targets; do
				cat >> $TEST << __EOF__

@test "$arch: Applying $(basename $overlay) to $(basename $target)" {
	apply $overlay $target
}
__EOF__
			done
		done
	done
done

# Run actual tests
echo "Running tests"
bats $TEST
