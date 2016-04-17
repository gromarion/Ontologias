class ActorsController < ApplicationController

  def index
    results = sparql_client.query(actors_query, content_type: SPARQL::Client::RESULT_XML)
    @results = results.map { |result| result.each_binding  { |name, value| puts value.inspect } }
  end

  def show
    @actor = sparql_client.query(actor_query(params[:id])).first
  end

  private

  def actors_query
    %(
      PREFIX dbo: <http://dbpedia.org/ontology/>
      PREFIX dbp: <http://dbpedia.org/property/>

      SELECT *
        WHERE {
      ?actor a dbo:Actor
      optional {
        ?actor foaf:name ?name .
        ?actor foaf:depiction ?depiction
      }
    })
  end

  def actor_query(name)
    %(
      PREFIX dbo: <http://dbpedia.org/ontology/>
      PREFIX dbp: <http://dbpedia.org/property/>

      SELECT *
        WHERE {
          ?actor a dbo:Actor .
          ?actor foaf:name ") + name + %("@en
        optional {
          ?actor foaf:name ?name .
          ?actor foaf:depiction ?depiction .
          ?actor dbo:birthDate ?birthDate .
          ?actor dbo:abstract ?abstract .
          ?actor dbp:yearsActive ?yearsActive .
          ?starring dbp:starring ?actor .
          FILTER(LANG(?abastract) = "" || LANGMATCHES(LANG(?abstract), "en"))
        }
      }
    )
  end

  def sparql_client
    @client ||= SPARQL::Client.new(
      "http://localhost:8890/sparql",
      SPARQL::Client::ACCEPT_XML
    )
  end
end
