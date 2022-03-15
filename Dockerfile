FROM phusion/passenger-ruby27:2.0.0 as base_image

RUN apt-get update && \
		apt-get install -y --no-install-recommends --allow-unauthenticated \
			build-essential \
      sendmail \
      libxml2-dev \
      libxslt-dev \
      zip \
      dumb-init \
      default-jre \
      ghostscript \
      imagemagick \
      libpq-dev \
      libreoffice \
      libsasl2-dev \
      netcat \
      postgresql-client \
      rsync \
      tzdata \
      unzip \
      wget \
      fonts-liberation \
      libgbm1 \
      xdg-utils

FROM base_image as image_dependencies

# Install Chrome and its dependencies
RUN apt-get install -fy \
		libatk-bridge2.0-0 libatspi2.0-0 libatk1.0-0 libgtk-3-0 libpango-1.0-0 libxcomposite1 libxdamage1 libxkbcommon0 && \
		cd /tmp && \
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
		apt-get --fix-broken install -y && \
		dpkg -i google-chrome-stable_current_amd64.deb

RUN mkdir -p /opt/fits && \
    curl -fsSL -o /opt/fits/fits-latest.zip https://projects.iq.harvard.edu/files/fits/files/fits-1.3.0.zip && \
    cd /opt/fits && unzip fits-latest.zip && \
    chmod +X /opt/fits/fits.sh
ENV PATH=/opt/fits:$PATH

RUN	apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

# Entry point from the docker-compose - last stage as Docker works backwards
FROM image_dependencies as development_image

WORKDIR /home/app

COPY --chown=app:app lib/hyrax/orcid/version.rb ./lib/hyrax/orcid/version.rb
COPY --chown=app:app hyrax_orcid.gemspec ./hyrax_orcid.gemspec
COPY --chown=app:app Gemfile ./Gemfile
COPY --chown=app:app Gemfile.lock ./Gemfile.lock
COPY --chown=app:app spec/internal_test_hyrax/Gemfile ./spec/internal_test_hyrax/Gemfile
COPY --chown=app:app spec/internal_test_hyrax/Gemfile.lock ./spec/internal_test_hyrax/Gemfile.lock

ENV CFLAGS=-Wno-error=format-overflow
RUN bundle config build.nokogiri --use-system-libraries && \
    bundle config set without "production" && \
    bundle config set with "aws development test postgres" && \
    setuser app bundle install --jobs=4 --retry=3 && \
    chmod 777 -R .bundle/*  # Otherwise `app` owns this file and the host cannot run bundler commands
