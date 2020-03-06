.PHONY: all link zsh bash build prod_build profile run push pull

all: prod_build login push profile git_push

run:
	source ./alias && devrun

link:
	mkdir -p ${HOME}/.config/nvim/colors
	mkdir -p ${HOME}/.config/nvim/syntax
	ln -sfv $(dir $(abspath $(lastword $(MAKEFILE_LIST))))init.vim $(HOME)/.config/nvim/init.vim
	ln -sfv $(dir $(abspath $(lastword $(MAKEFILE_LIST))))starship.toml $(HOME)/.config/starship.toml
	ln -sfv $(dir $(abspath $(lastword $(MAKEFILE_LIST))))efm-lsp-conf.yaml $(HOME)/.config/nvim/efm-lsp-conf.yaml
	ln -sfv $(dir $(abspath $(lastword $(MAKEFILE_LIST))))coc-settings.json $(HOME)/.config/nvim/coc-settings.json
	ln -sfv $(dir $(abspath $(lastword $(MAKEFILE_LIST))))monokai.vim $(HOME)/.config/nvim/colors/monokai.vim
	ln -sfv $(dir $(abspath $(lastword $(MAKEFILE_LIST))))go.vim $(HOME)/.config/nvim/syntax/go.vim
	ln -sfv $(dir $(abspath $(lastword $(MAKEFILE_LIST))))efm-lsp-conf.yaml $(HOME)/.config/nvim/efm-lsp-conf.yaml
	ln -sfv $(dir $(abspath $(lastword $(MAKEFILE_LIST))))zshrc $(HOME)/.zshrc
	ln -sfv $(dir $(abspath $(lastword $(MAKEFILE_LIST))))editorconfig $(HOME)/.editorconfig
	ln -sfv $(dir $(abspath $(lastword $(MAKEFILE_LIST))))alias $(HOME)/.aliases
	ln -sfv $(dir $(abspath $(lastword $(MAKEFILE_LIST))))gitconfig $(HOME)/.gitconfig
	ln -sfv $(dir $(abspath $(lastword $(MAKEFILE_LIST))))gitattributes $(HOME)/.gitattributes
	ln -sfv $(dir $(abspath $(lastword $(MAKEFILE_LIST))))gitignore $(HOME)/.gitignore
	ln -sfv $(dir $(abspath $(lastword $(MAKEFILE_LIST))))tmux.conf $(HOME)/.tmux.conf
	ln -sfv $(dir $(abspath $(lastword $(MAKEFILE_LIST))))tmux-kube $(HOME)/.tmux-kube
	ln -sfv $(dir $(abspath $(lastword $(MAKEFILE_LIST))))tmux.new-session $(HOME)/.tmux.new-session

clean:
	#sed -e "/\[\ \-f\ \$HOME\/\.aliases\ \]\ \&\&\ source\ \$HOME\/\.aliases/d" ~/.bashrc
	sed -e "/\[\ \-f\ \$HOME\/\.aliases\ \]\ \&\&\ source\ \$HOME\/\.aliases/d" ~/.zshrc
	rm $(HOME)/.aliases

zsh: link
	[ -f $(HOME)/.zshrc ] && echo "[ -f $$HOME/.aliases ] && source $$HOME/.aliases" >> $(HOME)/.zshrc

bash: link
	[ -f $(HOME)/.bashrc ] && echo "[ -f $$HOME/.aliases ] && source $$HOME/.aliases" >> $(HOME)/.bashrc

build:
	docker build -t vankichi/dev:latest .

docker_build:
	docker build --squash -t ${IMAGE_NAME}:latest -f ${DOCKERFILE} .

docker_push:
	docker push ${IMAGE_NAME}:latest

prod_build:
	@make DOCKERFILE="./Dockerfile" IMAGE_NAME="vankichi/dev" docker_build

build_go:
	@make DOCKERFILE="./dockers/go.Dockerfile" IMAGE_NAME="vankichi/go" docker_build

build_rust:
	@make DOCKERFILE="./dockers/rust.Dockerfile" IMAGE_NAME="vankichi/rust" docker_build

build_nim:
	@make DOCKERFILE="./dockers/nim.Dockerfile" IMAGE_NAME="vankichi/nim" docker_build

build_dart:
	@make DOCKERFILE="./dockers/dart.Dockerfile" IMAGE_NAME="vankichi/dart" docker_build

build_docker:
	@make DOCKERFILE="./dockers/docker.Dockerfile" IMAGE_NAME="vankichi/docker" docker_build

build_base:
	@make DOCKERFILE="./dockers/base.Dockerfile" IMAGE_NAME="vankichi/dev-base" docker_build

build_env:
	@make DOCKERFILE="./dockers/env.Dockerfile" IMAGE_NAME="vankichi/env" docker_build

build_gcloud:
	@make DOCKERFILE="./dockers/gcloud.Dockerfile" IMAGE_NAME="vankichi/gcloud" docker_build

build_k8s:
	@make DOCKERFILE="./dockers/k8s.Dockerfile" IMAGE_NAME="vankichi/kube" docker_build

build_glibc:
	@make DOCKERFILE="./dockers/glibc.Dockerfile" IMAGE_NAME="vankichi/glibc" docker_build

prod_push:
	@make IMAGE_NAME="vankichi/dev" docker_push

push_go:
	@make IMAGE_NAME="vankichi/go" docker_push

push_rust:
	@make IMAGE_NAME="vankichi/rust" docker_push

push_nim:
	@make IMAGE_NAME="vankichi/nim" docker_push

push_dart:
	@make IMAGE_NAME="vankichi/dart" docker_push

push_docker:
	@make IMAGE_NAME="vankichi/docker" docker_push

push_base:
	@make IMAGE_NAME="vankichi/dev-base" docker_push

push_env:
	@make IMAGE_NAME="vankichi/env" docker_push

push_gcloud:
	@make IMAGE_NAME="vankichi/gcloud" docker_push

push_k8s:
	@make IMAGE_NAME="vankichi/kube" docker_push

push_glibc:
	@make IMAGE_NAME="vankichi/glibc" docker_push

build_all: \
	build_base \
	build_env \
	build_dart \
	build_docker \
	build_gcloud \
	build_glibc \
	build_go \
	build_k8s \
	build_nim \
	build_rust \
	prod_build
	echo "done"

push_all: \
	push_base \
	push_env \
	push_dart \
	push_docker \
	push_gcloud \
	push_glibc \
	push_go \
	push_k8s \
	push_nim \
	push_rust \
	prod_push
	echo "done"

profile:
	rm -f analyze.txt
	type dlayer >/dev/null 2>&1 && docker save vankichi/dev:latest | dlayer >> analyze.txt

login:
	docker login -u vankichi

push:
	docker push vankichi/dev:latest

pull:
	docker pull vankichi/dev:latest

git_push:
	git add -A
	git commit -m fix
	git push
