FROM node:18.20.5-alpine3.20 AS builder

# Create app directory
WORKDIR /opt/app

RUN apk --virtual build-dependencies add \
    git libtool curl jq py3-configobj py3-pip py3-setuptools python3 python3-dev \
    g++ make libusb-dev eudev-dev linux-headers \
&& ln -sf python3 /usr/bin/python \
&& ln -s /lib/arm-linux-gnueabihf/libusb-1.0.so.0 libusb-1.0.dll

COPY package*.json ./
COPY yarn.lock ./

# Installing dependencies
RUN yarn cache clean \
&& yarn install --frozen-lockfile --unsafe-perm --ignore-scripts \
&& yarn add usb
# Copying files from current directory

COPY . .

# Create build and link
RUN yarn build

# Switch to the non-root user
USER node

FROM dionelago/tatum-kms:latest

# Copy the original file to /tmp (where it has permission)
RUN cp /opt/app/node_modules/@tatumio/tatum/dist/src/constants.js /tmp/constants.js

COPY patch-matic.cjs /tmp/patch-matic.cjs

# Apply the patch to the file inside /tmp
RUN node /tmp/patch-matic.cjs /tmp/constants.js

# Second stage: now we overwrite the original file
FROM dionelago/tatum-kms:latest

COPY --from=base /tmp/constants.js /opt/app/node_modules/@tatumio/tatum/dist/src/constants.js

ENTRYPOINT ["node", "/opt/app/dist/index.js"]

CMD ["daemon"]