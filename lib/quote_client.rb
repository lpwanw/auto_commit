require "faraday"
require_relative "../lib/environment"

class QuoteClient
  URL = "https://quotes15.p.rapidapi.com/quotes/random/?language_code=en"
  API_HOST = "quotes15.p.rapidapi.com"
  
  def initialize
    call
  end

  def content_quote
    response_body["content"]
  end

  private

  attr_reader :response_body

  def call
    response = Faraday.get(URL) do |req|
      req.headers['X-RapidAPI-Key'] = ENV["API_KEY"]
      req.headers['X-RapidAPI-Host'] = API_HOST
    end

    @response_body = JSON.parse(response.body)
  end
 end

