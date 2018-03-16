echo "Loading environment"
source .production_environment_secrets.sh

echo "Checking environment variables"
declare -a environment_variables=(
  "${DB_NAME}"
  "${DB_PASSWORD}"
  "${DB_USER_NAME}"
  "${DOCKER_IMAGE_REPOSITORY}"
  "${ENVIRONMENT}"
  "${MIX_ENV}"
  "${PORT}"
)
for env_var in "${environment_variables[@]}"; do
  if [[ -z "${env_var}" ]]; then
    echo "One or more of the environment variables required is missing - please set it and try again."
    exit 2
  fi
done

echo "Building docker image"
docker build \
  --build-arg DB_NAME=${DB_NAME} \
  --build-arg DB_PASSWORD=${DB_PASSWORD} \
  --build-arg DB_USER_NAME=${DB_USER_NAME} \
  --build-arg MIX_ENV=${MIX_ENV} \
  --build-arg PORT=${PORT} \
  --no-cache \
  -t "${DOCKER_IMAGE_REPOSITORY}:vx" . # need to think about versioning - maybe the git commit sha?

echo "Pushing new image to the repository"
gcloud docker -- push ${DOCKER_IMAGE_REPOSITORY}:vx

echo "Updating instance definition"
gcloud beta compute instances update-container chips-${ENVIRONMENT} \
  --container-image ${DOCKER_IMAGE_REPOSITORY}:vx
