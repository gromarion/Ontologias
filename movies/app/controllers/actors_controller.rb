class ActorsController < ApplicationController

  def index
    @results = sparql_client.query(actors_query, content_type: SPARQL::Client::RESULT_XML)
  end

  def show
    @actor = sparql_client.query(actor_query(params[:id])).first
  end

  def update_like
    @actor = sparql_client.query(actor_query(params[:id])).first
    sparql_client.query(insert_like_query(@actor, params[:liked][:all]))
    redirect_to URI.escape("http://localhost:3000/actor/#{params[:id]}")
  end

  def liked_actors
    @actors = sparql_client.query(liked_actors_query)
  end

  private

  def actors_query
    %(
      PREFIX dbo: <http://dbpedia.org/ontology/>

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
          ?actor dbo:birthDate ?birthDate .
          ?actor dbo:abstract ?abstract .
          ?actor dbp:yearsActive ?yearsActive .
          FILTER(LANG(?name) = "" || LANGMATCHES(LANG(?name), "en"))
        OPTIONAL {
          ?actor dbo:abstract ?abstract .
          ?actor dbp:yearsActive ?yearsActive .
          ?actor xsd:boolean ?liked
        }
      } GROUP BY ?actor
    )
  end

  def insert_like_query(actor, like)
    liked = actor.bound?(:liked) ? actor.liked.value : '0'
    %(
      DELETE DATA FROM <http://movies-ontologias.com> {
        <) + actor.actor + %(>  xsd:boolean ) + liked  + %(
      }
      INSERT DATA INTO <http://movies-ontologias.com> {
        <) + actor.actor + %(> xsd:boolean ) + like + %(
      }
    )
  end

  def liked_actors_query
    %(
      PREFIX dbo: <http://dbpedia.org/ontology/>

      SELECT *
        WHERE {
          ?actor a dbo:Actor .
          ?actor foaf:name ?name .
          ?actor foaf:depiction ?depiction .
          ?actor xsd:boolean ?liked.
          FILTER (?liked = "true"^^xsd:boolean)
      } GROUP BY ?actor
    )
  end

  def sparql_client
    @client ||= SPARQL::Client.new('http://localhost:8890/sparql', SPARQL::Client::ACCEPT_XML)
  end
end
