FROM python:3
COPY ./api.py /
COPY ./config.py /
COPY ./requirements.txt /requirements.txt
RUN groupadd -g 1000 icb && useradd -u 1000 -g 1000 icb
RUN mkdir /images
RUN mkdir /log
RUN chown -R icb:icb /images
RUN chown -R icb:icb /log
RUN pip install -r requirements.txt
VOLUME /images
CMD [ "python", "./api.py" ]

