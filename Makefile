.PHONY: all
all: build

.PHONY: clean
clean:
	rm -rf .direnv
	nix-env --delete-generations old
	nix-store --gc

.PHONY: test
test:
	@echo "Need to add some tests at some point"

rekey-age:
	nix develop .#default -c agenix --rekey -i ~/.ssh/age/primary.pub

git-pull:
	nix develop .#default -c git pull origin

git-add:
	nix develop .#default -c git add .

fmt:
	nix fmt

switch:
	nix develop .#default -c nh os switch .

.PHONY: build
build: git-pull fmt git-add switch

.PHONY: update
update: git-pull git-add
	@nix flake update
