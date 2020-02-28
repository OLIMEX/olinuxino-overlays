# Copyright (c) 2019 Olimex Ltd.
#
# GNU GENERAL PUBLIC LICENSE
#    Version 3, 29 June 2007
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

DTC ?= dtc

DTC_FLAGS += -Wno-unit_address_vs_reg \
	-Wno-unit_address_format \
	-Wno-avoid_unnecessary_addr_size \
	-Wno-alias_paths \
	-Wno-graph_child_address \
	-Wno-simple_bus_reg \
	-Wno-unique_unit_address \
	-Wno-pci_device_reg
DTC_INCLUDE += include

# Find all files
DTS	= $(sort  $(shell find $(SOURCEDIR) -name '*.dts'))
DTBO	= $(DTS:%.dts=%.dtbo)

dtc_cpp_flags  = -x assembler-with-cpp -nostdinc	\
                 $(addprefix -I,$(DTC_INCLUDE))		\
                 -undef -D__DTS__

%.dtbo: %.dts
	@echo "  DTC     " $@
	@$(DTC) -q -@ -I dts -O dtb -o $@ $<

# %.dtbo: %.dts
# 	@echo "  DTC     " $@
# 	@$(DTC) -q -@ -I dts -O dtb -o $@ $<
# 	@cpp $(dtc_cpp_flags) -o $(addsuffix .tmp,$<) $<
# 	@$(DTC) $(DTC_FLAGS) -b 0 -@ -i $(DTC_INCLUDE) -O dtb -o $@ $(addsuffix .tmp,$<)
# 	@rm -vf $(addsuffix .tmp,$<)

.PHONY: all
all: $(DTBO)

.PHONY: test
test:
	(cd test && ./bootstrap.sh)

.PHONY: clean
clean:
	@echo "  CLEAN"
	@find . -name "*.dtbo" -exec rm -f {} \;
