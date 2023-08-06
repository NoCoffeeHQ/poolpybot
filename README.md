# PoolpyBot

## Local development

### Installation

Add the local domains to your system:
```bash
sudo /bin/sh -c 'echo "127.0.0.1 www.poolpybot.local" >> /etc/hosts'
sudo /bin/sh -c 'echo "::1 www.poolpybot.local" >> /etc/hosts'
sudo /bin/sh -c 'echo "127.0.0.1 app.poolpybot.local" >> /etc/hosts'
sudo /bin/sh -c 'echo "::1 www.poolpybot.local" >> /etc/hosts'
```

Install gems and JS packages:
```bash
bundle install
yarn install
```

Create the DB:
```bash
rails db:setup
```

### Run Ngrok for the ActionMailbox feature

This step is required to receive emails locally. 

```bash
ngrok http 5100
```

Get the URL and create Brevo weebhook.

```bash
rails brevo:create_local_webhook https://def1-2a01-cb19-8a61-e000-b598-f01-c3ec-2956.ngrok-free.app
```

### Run the server

```bash
./bin/dev
```

Open your browser and type the following address: http://app.poolpybot.local:5100

### Run tests

```bash
bundle exec rspec
```

### Generators

Generate new component for the UIKIt. Example:

```bash
bin/rails generate component UIKit::FormInput form attribute --sidecar
```

### Deployment

TODO