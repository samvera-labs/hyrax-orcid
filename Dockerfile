ARG HYRAX_IMAGE_VERSION=latest
FROM ghcr.io/samvera/dassie:$HYRAX_IMAGE_VERSION as hyrax-orcid-dev

#ARG APP_PATH=.dassie
ARG BUNDLE_WITHOUT=

ENV HYRAX_ENGINE_PATH /app/samvera/hyrax-engine

#COPY --chown=1001:101 $APP_PATH /app/samvera/hyrax-webapp
COPY --chown=1001:101 ./Gemfile.dassie /app/samvera/hyrax-webapp/Gemfile
COPY --chown=1001:101 . /app/samvera/hyrax-engine

RUN cd /app/samvera/hyrax-engine && bundle install --jobs "$(nproc)"
RUN cd /app/samvera/hyrax-webapp && bundle install --jobs "$(nproc)"
#RUN cd /app/samvera/hyrax-webapp && RAILS_ENV=production SECRET_KEY_BASE='fakesecret1234' DB_ADAPTER=nulldb DATABASE_URL='postgresql://fake' bundle exec rake assets:precompile


FROM ghcr.io/samvera/dassie-worker:$HYRAX_IMAGE_VERSION as hyrax-orcid-dev-worker

#ARG APP_PATH=.dassie
ARG BUNDLE_WITHOUT=

ENV HYRAX_ENGINE_PATH /app/samvera/hyrax-engine

#COPY --chown=1001:101 $APP_PATH /app/samvera/hyrax-webapp
COPY --chown=1001:101 ./Gemfile.dassie /app/samvera/hyrax-webapp/Gemfile
COPY --chown=1001:101 . /app/samvera/hyrax-engine

RUN cd /app/samvera/hyrax-webapp && bundle install --jobs "$(nproc)"
RUN cd /app/samvera/hyrax-engine && bundle install --jobs "$(nproc)"

