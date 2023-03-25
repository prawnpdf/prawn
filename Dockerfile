FROM ruby:3.2.1

RUN apt-get update -qq \
&& apt-get install -y nodejs postgresql-client build-essential

WORKDIR /app

RUN gem install rspec
RUN gem install matrix -v 0.4
RUN gem install pdf-core -v 0.9.0
RUN gem install ttfunk -v 1.7
RUN gem install pdf-inspector -v 1.2.1
RUN gem install pdf-reader -v 1.4
RUN gem install prawn-dev -v 0.3.0
RUN gem install prawn-manual_builder -v 0.3.0

RUN gem install pry

ENTRYPOINT [""]
