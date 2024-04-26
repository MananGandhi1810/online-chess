FROM --platform=linux/amd64 node:lts-alpine3.19
WORKDIR /appuser
COPY package.json ./
COPY index.js ./
COPY .env ./.env
COPY ./prisma ./
RUN npm install
RUN npx prisma generate
EXPOSE 3000
EXPOSE 4000
CMD ["npm", "run", "start"]