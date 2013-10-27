sinatra-currency
================

Ruby+Sinatra tech demo that imports the ECB currency rates and provides a web interface. Demonstrates the use of:

  - [Sinatra](http://www.sinatrarb.com/)
  - [HAML](http://haml.info/) - embedded Sinatra templates
  - [MongoDB](http://www.mongodb.org/) - overkill, but for demonstration purposes
  - [RubyMoney](https://github.com/RubyMoney/money)
  - [Twitter Bootstrap 3.0](http://getbootstrap.com/)
  - [bootstrap-chosen](https://github.com/alxlit/bootstrap-chosen)
  - [Parsley.js](http://parsleyjs.org/)

Follow [@analytically](http://twitter.com/analytically) for updates.

![See](see.gif)

## Requirements

  - Ruby
  - MongoDB

## Running

Make sure all dependencies are installed:

```sh
gem install nokogiri
gem install money
gem install haml
gem install redcarpet
```

First, dump the rates from [http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml](http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml) to MongoDB:

```sh
ruby dump_rates.rb
```

Then start the actual app:

```sh
ruby app.rb
```

Now point your browser to [http://localhost:4567](http://localhost:4567).

## Todo

  - Write tests!

# Screenshots

![Screenshot](screenshot.png)

