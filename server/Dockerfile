FROM node:22-alpine

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm install

# Copia o restante do código para a imagem
COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev"]
