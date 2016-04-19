#!bin/rails r
require 'rdf/ntriples'

RDF::Reader.open("http://ruby-rdf.github.com/rdf/etc/doap.nt") do |reader|
  reader.each_statement do |statement|
    puts statement.inspect
  end
end

#########################################
# QUERY PARA OBTENER ACTORES DE DBPEDIA #
#########################################
# PREFIX dbo: <http://dbpedia.org/ontology/>
# PREFIX dbp: <http://dbpedia.org/property/>

# CONSTRUCT
#   WHERE {
#     ?actor a dbo:Actor.
#     ?actor foaf:name ?name.
#     ?actor dbo:birthDate ?birth_date .
#     ?actor dbo:abstract ?abstract .
#     ?actor dbp:yearsActive ?yearsActive.
#     ?actor foaf:depiction ?depiction
#   }

repository = RDF::Repository.load('http://localhost:1111')
query = SPARQL.parse(%(
  PREFIX dbo: <http://dbpedia.org/ontology/>
  PREFIX dbp: <http://dbpedia.org/property/>

  CONSTRUCT
    WHERE {
      ?actor a dbo:Actor.
      ?actor dbo:birthDate ?birth_date .
      ?actor dbo:abstract ?abstract .
      ?actor dbp:yearsActive ?yearsActive.
      ?starring dbp:starring ?actor}))
query.execute(repository)

# DB.DBA.TTLP_MT (file_to_string_output ('/Users/gromarion/Documents/ITBA/Ontologias/Ontologias/movies.nt'), '', 'http://movies-ontologias.com');

# RDF::Repository.load('http://localhost:8890/sparql')
# RDF::FormatError: unknown RDF format: {:base_uri=>"http://localhost:8890/sparql", :content_type=>"text/html", :file_name=>"http://localhost:8890/sparql"}
# This may be resolved with a require of the 'linkeddata' gem.


sparql = SPARQL::Client.new("http://localhost:8890/sparql")
result = sparql.query(%(
  PREFIX dbo: <http://dbpedia.org/ontology/>
  PREFIX dbp: <http://dbpedia.org/property/>

  SELECT *
    WHERE {
      ?actor a dbo:Actor
      optional {
        ?actor foaf:name ?name .
        ?actor dbo:birthDate ?birth_date .
        ?actor dbo:abstract ?abstract .
        ?actor dbp:yearsActive ?yearsActive .
        ?starring dbp:starring ?actor
      }
    }), content_type: SPARQL::Client::RESULT_XML)
