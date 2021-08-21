bringup: $(KDEVOPS_BRING_UP_DEPS)

destroy: $(KDEVOPS_DESTROY_DEPS)

bringup-help-menu:
	@echo "Bringup targets:"
	@echo "bringup            - Brings up target hosts"
	@echo "destroy            - Destroy all target hosts"
	@echo ""

HELP_TARGETS+=bringup-help-menu
