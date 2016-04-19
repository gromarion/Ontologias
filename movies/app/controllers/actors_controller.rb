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
          ?actor foaf:depiction ?depiction .
          FILTER(LANG(?name) = "" || LANGMATCHES(LANG(?name), "en"))
        }
      } GROUP BY ?actor
    )
  end

  def actor_query(name)
    %(
      PREFIX dbo: <http://dbpedia.org/ontology/>
      PREFIX dbp: <http://dbpedia.org/property/>

      SELECT *
        WHERE {
          ?actor a dbo:Actor .
          ?actor foaf:name ") + name + %("@en.
          ?actor foaf:name ?name .
          ?actor foaf:depiction ?depiction .
          ?actor dbo:birthDate ?birthDate
        OPTIONAL {
          ?actor dbo:abstract ?abstract .
          ?actor dbp:yearsActive ?yearsActive .
          FILTER(LANG(?abstract) = "" || LANGMATCHES(LANG(?abstract), "en"))
        }
      } GROUP BY ?actor
    )
  end

  def sparql_client
    @client ||= SPARQL::Client.new(
      "http://localhost:8890/sparql",
      SPARQL::Client::ACCEPT_XML
    )
  end
end
