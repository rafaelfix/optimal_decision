# FINAL STAGE
FROM python:3.10-alpine

RUN mkdir -p /home/app
RUN addgroup -S app && adduser -S app -G app

ENV HOME=/home/app
ENV APP_HOME=/home/app/web
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN apk update && apk add libpq graphviz git ttf-freefont

# copy wheels and requirements
COPY --from=builder /usr/src/app/wheels /wheels
COPY --from=builder /usr/src/app/requirements.txt .

RUN pip install --no-cache /wheels/*

# clone your repo directly
RUN git clone https://github.com/rafaelfix/optimal_decision.git /tmp/optimal_decision && \
    cp -r /tmp/optimal_decision/backend/* $APP_HOME

RUN chown -R app:app $APP_HOME
USER app

RUN sed -i 's/\r$//g' $APP_HOME/entrypoint.sh
RUN chmod +x $APP_HOME/entrypoint.sh

ENTRYPOINT ["/home/app/web/entrypoint.sh"]
