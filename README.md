### Introduction

At this time, action-jackson is an experiment, but I hope that won't be the case for long.

Rails before_filters don't take it far enough. What action-jackson allows you to do is define dependecies between your controller actions and before filters in the same way you do with rake tasks.

### Install

Stick this in your GemFile.

    gem 'action-jackson'

### Usage

#### Include the DSL

Might as well add it for all you controllers.

    class ApplicationController < ActionController::Base
      extend ActionJackson::DSL  
    end
    
Or you can do it on a per controller basis if you insist.

    class MyController < ApplicationController
      extend ActionJackson::DSL 
    end

#### Defineing Actions and Filters

Define your actions like this within your controller.

    action :index do
    end
    
Need a before filter? Wire it up like this.

    action :index => :load_user do
    end
    
    def load_user
      @user = User.find(params[:user_id])
    end
    
which is equivalent to...

    before_filter :load_user, :only => :index
    
    def index
    end
    
    def load_user
      @user = User.find(params[:user_id])
    end
    
But the fun doesn't stop there. We can define before filters for our before filters.

    action :index => :load_user do
    end
    
    filter :load_user => :some_other_filter do
    end
    
    def some_other_filter
    end
    
As you've probably guessed, `filter` acts just like `action` (as a matter of fact it's an alias, well at least for now...).

Lastly, you can also define multiple dependencies with an Array and they'll be executed in the order they appear.

    action :index => [:first_filter, :second_filter] do
    end
  
Keep in mind actions can depend on actions, filters can depend on filters, actions on filters, filters on actions, on and on and so forth. The dependency heirarchy can get very deep and complicated, but thanks to action-jackson your code doesn't have to.

### Gotchas

If you're using `return` in your actions you'll want to switch it out with `next` otherwise you'll receive an error.
    
    def index
      return unless param[:id]
      @item = Item.find(param[:id])
    end

becomes...

    action :index do
      next unless param[:id]
      @item = Item.find(param[:id])
    end


