require 'mongo'
require 'sinatra'
require 'money'
require 'haml'
require 'redcarpet'

include Mongo

get '/' do
  @now = DateTime.now.strftime('%Y-%m-%d')
  @currencies = ExchangeRate.currencies << 'EUR'

  haml :index
end

post '/fx' do
  @date = Date.parse(params[:date]).strftime('%Y-%m-%d')
  @amount = params[:amount].to_f
  @from = params[:from]
  @to = params[:to]

  @converted = ExchangeRate.new(@date, @from, @to).convert(@amount)
  haml :converted
end

class ExchangeRate
  @@mongo_client = MongoClient.new('localhost', 27017)
  @@db = @@mongo_client.db('sinatracurrency')
  @@ratesCollection = @@db.collection('rates')

  def initialize(date, from_currency, to_currency)
    @date = date
    @from_currency = from_currency
    @to_currency = to_currency
  end

  def self.currencies
    @@ratesCollection.distinct('c').sort
  end

  def convert(amount)
    @@ratesCollection.find('d' => @date).to_a.each do |doc|
      Money.add_rate("EUR", doc['c'], doc['r'].to_f)
    end
    Money.add_rate("EUR", "EUR", 1.00)

    from = Money.new(amount, @from_currency)

    from_base_rate = Money.default_bank.get_rate("EUR", from.currency)
    to_base_rate = Money.default_bank.get_rate("EUR", @to_currency)
    rate = to_base_rate / from_base_rate

    Money.new(((Money::Currency.wrap(@to_currency).subunit_to_unit.to_f / from.currency.subunit_to_unit.to_f) * from.cents * rate), @to_currency).cents
  end
end

__END__

@@ layout
%html
  %head
    %title Sinatra Currency
    %link(rel='stylesheet' type='text/css' href='//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css')
    %link(rel='stylesheet' type='text/css' href='//alxlit.github.io/bootstrap-chosen/bootstrap.css')
    :css
      .jumbotron{
        background-color: #4099ff;
        color: #fff;
      }

  %body
    %script(src='https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js' type='text/javascript')
    %script(src='http://harvesthq.github.io/chosen/chosen.jquery.js' type='text/javascript')
    %script(src='http://parsleyjs.org/parsley.js' type='text/javascript')
    :javascript
      $(function() {
        $('.chosen-select').chosen();
        $('.chosen-select-deselect').chosen({ allow_single_deselect: true });
      });
      $(document).ready(function () {
        $('#fx').parsley({
          successClass: 'has-success',
          errorClass: 'has-error',
          errors: {
            classHandler: function(el) {
              return $(el).parent();
            },
            errorsWrapper: '<span class=\"help-block\"></span>',
            errorElem: '<span></span>'
          }
        });
      });

    %div.jumbotron
      %div.container
        %h1 Sinatra Currency
        %p
          See my other <a href="https://github.com/analytically" style="color: #555533;">work on GitHub</a>.

    %div.container
      %h1 FX-u-like
      = yield

@@ index
%form.form(action='/fx' method='post' id='fx')
  %div.form-group
    %label.control-label Date:
    %input.form-control(type='date' name='date' value=@now data-required='true')
  %div.form-group
    %label.control-label Amount to convert:
    %input.form-control(type='number' name='amount' data-required='true' data-type='number')
  %div.row
    %div.col-lg-6
      %div.form-group
        %label.control-label From:
        %select.chosen-select.form-control(data-placeholder='Select currency to convert from...' name='from' data-required='true')
          %option
          - @currencies.each do |c|
            %option(value=c)
              = c
    %div.col-lg-6
      %div.form-group
        %label.control-label To:
        %select.chosen-select.form-control(data-placeholder='Select currency to convert to...' name='to' data-required='true')
          %option
          - @currencies.each do |c|
            %option(value=c)
              = c
  %div.form-group
    %button.btn.btn-primary(type='submit') Go forth and Convert!
    or
    %a(href='http://www.yahoo.com') Cancel

@@ converted
%h3== Conversion successful: on #{@date}, #{@amount} #{@from} is <b>#{@converted} #{@to}</b>
%a(href='/') Again
