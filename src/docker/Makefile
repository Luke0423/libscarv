# Copyright (C) 2019 SCARV project <info@scarv.org>
#
# Use of this source code is restricted per the MIT license, a copy of which 
# can be found at https://opensource.org/licenses/MIT (or should be included 
# as LICENSE.txt within the associated archive or repository).

ifndef REPO_HOME
  $(error "execute 'source ./bin/conf.sh' to configure environment")
endif
ifndef REPO_VERSION
  $(error "execute 'source ./bin/conf.sh' to configure environment")
endif

# =============================================================================

${REPO_HOME}/build/${ARCH}/docker/Dockerfile       : ${REPO_HOME}/src/docker/Dockerfile
	@m4 --include="${REPO_HOME}/src/docker" --include="${REPO_HOME}/conf/${ARCH}" ${<} > ${@}
${REPO_HOME}/build/${ARCH}/docker/entrypoint.sh    : ${REPO_HOME}/src/docker/entrypoint.sh
	@cp ${<} ${@}
${REPO_HOME}/build/${ARCH}/docker/requirements.txt : ${REPO_HOME}/requirements.txt
	@cp ${<} ${@}

BUILD_FILES  = ${REPO_HOME}/build/${ARCH}/docker/Dockerfile
BUILD_FILES += ${REPO_HOME}/build/${ARCH}/docker/entrypoint.sh
BUILD_FILES += ${REPO_HOME}/build/${ARCH}/docker/requirements.txt

BUILD_PATHS  = ${REPO_HOME}/build/${ARCH}/docker

${BUILD_PATHS} :
	@mkdir --parents ${@}

${CLEAN_PATHS} :
	@rm --force --recursive ${@}

# =============================================================================

build : ${BUILD_PATHS} ${BUILD_FILES}
	@docker build --tag ${DOCKER_REPO}:${DOCKER_TAG} --build-arg DATE="$(shell date -u +'%d/%m/%Y-%H:%M:%SZ')" ${REPO_HOME}/build/${ARCH}/docker

clean : ${CLEAN_PATHS}
	@docker images | grep ${DOCKER_REPO} | grep ${DOCKER_TAG} | tr --squeeze-repeats ' ' | cut --delimiter=' ' --fields=3 | uniq | xargs --no-run-if-empty docker rmi --force && rm --force --recursive ${BUILD_PATHS}

push  :
	@docker push ${DOCKER_REPO}:${DOCKER_TAG}

pull  :
	@docker pull ${DOCKER_REPO}:${DOCKER_TAG}

# =============================================================================
