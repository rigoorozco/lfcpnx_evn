RADIANT_PREFIX=/opt/lscc/radiant/2023.2/bin/lin64

PROJECT_NAME=lfcpnx_evn
EVAL_IP=True

%.rdf: sources.tcl
	@echo "Creating project: $(PROJECT_NAME)..."
	$(RADIANT_PREFIX)/radiantc scripts/create_project.tcl $(PROJECT_NAME) $(EVAL_IP)

%.bit: $(PROJECT_NAME)/$(PROJECT_NAME).rdf
	@echo "Launching runs for $(PROJECT_NAME)..."
	$(RADIANT_PREFIX)/radiantc scripts/build_project.tcl $<

project: $(PROJECT_NAME)/$(PROJECT_NAME).rdf

bitstream: $(PROJECT_NAME)/impl_1/$(PROJECT_NAME)_impl_1.bit

clean:
	rm -rf $(PROJECT_NAME)
	rm radiantc.log* radiantc.tcl*

.PHONY: project bitstream
