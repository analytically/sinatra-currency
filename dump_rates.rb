# simple script that dumps the contents of eurofxref-hist-90d in MongoDB - invoked by cron job

require 'mongo'
require 'open-uri'
require 'nokogiri'

include Mongo
mongo_client = MongoClient.new('localhost', 27017)
db = mongo_client.db('sinatracurrency')
db.collection('rates').drop() # ugly but for quickness

ratesCollection = db.collection('rates')
ratesCollection.create_index([['c', Mongo::ASCENDING], ['r', Mongo::ASCENDING], ['d', Mongo::ASCENDING]])

doc = Nokogiri::XML(open('http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml')).remove_namespaces!

doc.xpath('//Cube/Cube').each do |cube|
  cube.xpath('./Cube').each do |subcube|
    # insert into MongoDB
    doc = {'c' => subcube.attr('currency'), 'r' => subcube.attr('rate'), 'd' => Date.parse(cube.attr('time')).strftime('%Y-%m-%d')}
    id = ratesCollection.insert(doc)
  end
end
