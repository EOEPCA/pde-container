FROM nginx

COPY wrapper.sh /wrapper.sh
RUN chmod +x /wrapper.sh

ENTRYPOINT [ "/wrapper.sh" ]
CMD ["nginx", "-g", "daemon off;"]
