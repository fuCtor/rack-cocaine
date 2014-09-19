require 'grape'

module Twitter
  class API < Grape::API
    version 'v1', using: :header, vendor: 'twitter'
    format :json

    get :hello do
      {:hello => "user" }
    end

    get :by do
      {:by => 1 }
    end

    # Use a different scope for this endpoint.
    get :bar do
      {:bar=> 1 }
    end

    get :env do
      env
    end

    post :foo do
      params
    end

    resource :statuses do
      get :count do
        {:count => 0 }
      end
    end

    route :any, '*path' do
      env
    end
  end
end