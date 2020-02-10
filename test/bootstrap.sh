#!/bin/bash

TEST=$(mktemp)
echo "Generating test script: $TEST"

# Create base worker function
cat > $TEST << '__EOF__'
#!/usr/bin/env bats

OVERLAY=$(mktemp)
OUTPUT=$(mktemp)

compile() {
	dtc -q -@ -I dts -O dtb "$1"
}

apply() {
	dtc -q -@ -I dts -O dtb -o $OVERLAY "$1"
	fdtoverlay -i "$2" -o $OUTPUT $OVERLAY
}

check_description() {
	dtc -q -@ -I dts -O dtb -o $OVERLAY "$1"
	fdtget $OVERLAY / description
}

check_compatible() {
	dtc -q -@ -I dts -O dtb -o $OVERLAY "$1"
	[[ "$(fdtget $OVERLAY / compatible)" == "allwinner,$2" ]]
}
__EOF__

for arch in sun7i-a20 sun50i-a64; do
	# Add tests to the suite
	for overlay in $(ls ../$arch/*.dts); do
		cat >> $TEST << __EOF__

@test "Compiling $(basename $overlay)" {
	compile $overlay
}

@test "Check compatible for $(basename $overlay)" {
	check_compatible $overlay $arch
}

@test "Check description for $(basename $overlay)" {
	check_description $overlay
}
__EOF__

		for target in $(ls targets/$arch/*.dtb); do
			cat >> $TEST << __EOF__

@test "Applying $(basename $overlay) to $(basename $target)" {
	apply $overlay $target
}
__EOF__
		done
	done

	# Add board specific tests
	for board in $(find ../$arch/* -type d -exec basename {} \;); do
		case $board in
		"A20-OLinuXino-Lime2")
			targets=$(ls targets/$arch/sun7i-a20-olinuxino-lime2*.dtb)
			;;

		"A20-SOM204")
			targets=$(ls targets/$arch/sun7i-a20-olimex-som204-evb*.dtb)
			;;

		*)
			continue
			;;
		esac

		for overlay in $(ls ../$arch/$board/*.dts); do

			for target in $targets; do
				cat >> $TEST << __EOF__

@test "Applying $(basename $overlay) to $(basename $target)" {
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
